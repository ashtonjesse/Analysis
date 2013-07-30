classdef Preprocessing < SubFigure
    %Preprocessing Summary
    %   This is the Preprocessing class that wraps the
    %   PreprocessingFig. It needs to be called from a parent figure 
    %   (e.g StartFigure) and the class wrapper
    %   for this parent passed as a input into the constructor. 
    
    %   This class assumes that the parent figure remains open while the
    %   PreprocessingFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is done. 
    
    properties 
        CurrentZoomLimits = [];
    end
    
    methods
        function oFigure = Preprocessing(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'Preprocessing',@Preprocessing_OpeningFcn);
                        
            aSliderTexts = [oFigure.oGuiHandle.oSliderText1,oFigure.oGuiHandle.oSliderText2];
            dSliderStep = [1/(oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels-1), ...
                (1/(oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels-1))*10];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels, 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',dSliderStep},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oApplyChannelMenu, 'callback', @(src, event) oApplyChannelMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oApplyAllMenu, 'callback', @(src, event) oApplyAllMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateMenu, 'callback', @(src, event) oTruncateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Set callback functions for controls
            set(oFigure.oGuiHandle.oCheckBoxReject, 'callback', @(src, event) oCheckBoxReject_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', @(src,event) ThisKeyPressFcn(oFigure, src, event));
            
            %Turn zoom on for this figure
%             set(oFigure.oZoom,'enable','on'); 
%             set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            
            %Plot the original and processed data of the first signal
            oFigure.PlotOriginal(1);
            oFigure.PlotProcessed(1);
            
            
            % --- Executes just before the figure is made visible.
            function Preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                set(handles.oCheckBoxBaseline, 'string', 'Fit Polynomial')
                set(handles.oCheckBoxWavelet, 'string', 'Keep Wavelet Scales');
                set(handles.oCheckBoxFilter, 'string', 'Filter');
                set(handles.oCheckBoxDeprocess, 'string', 'Delete Processed Data');
                set(handles.oCheckBoxBeats, 'string', 'Plot beats');
                set(handles.oCheckBoxBeats, 'TooltipString', 'Plot beats');
                set(handles.oCheckBoxOriginal, 'string', 'Plot Original');
                set(handles.oCheckBoxReject, 'string', 'Accepted');
                set(handles.oCheckBoxReject, 'TooltipString', 'Uncheck to reject channel');
                
                %Set the output attribute
                handles.output = hObject;
                %Update the gui handles 
                guidata(hObject, handles);
            end
        end
    end
    
    
    methods (Access = protected)
         %% Protected methods inherited from superclass
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            nValue = GetPopUpSelectionDouble@BaseFigure(oFigure,sPopUpMenuTag);
        end
        
        function nValue = GetSliderIntegerValue(oFigure, sSliderTag)
            nValue = GetSliderIntegerValue@BaseFigure(oFigure, sSliderTag);
        end
        
        function nValue = GetEditInputDouble(oFigure, sEditTag)
            nValue = GetEditInputDouble@BaseFigure(oFigure, sEditTag);
            if nValue <= 0
                error('Preprocessing.GetEditInputDouble.VerifyInput:Incorrect', 'You have entered a number incorrectly.')
            end
        end
    end
    
    methods (Access = public)
        %% Ui control callbacks
        function ThisKeyPressFcn(oFigure, src, event)
            %Handles key press events
            switch event.Key
                case 'a'
                    set(oFigure.oGuiHandle.oCheckBoxReject,'Value',1);
                    oCheckBoxReject_Callback(oFigure, oFigure.oGuiHandle.oCheckBoxReject, []);
                case 'r'
                    set(oFigure.oGuiHandle.oCheckBoxReject,'Value',0);
                    oCheckBoxReject_Callback(oFigure, oFigure.oGuiHandle.oCheckBoxReject, []);
                case 'rightarrow'
                    iChannel = str2num(get(oFigure.oGuiHandle.oSliderEdit,'string'));
                    if iChannel + 1 <= oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels
                        set(oFigure.oGuiHandle.oSliderEdit,'string',num2str(iChannel + 1));
                        set(oFigure.oGuiHandle.oSlider,'value',iChannel + 1);
                        oSlider_Callback(oFigure, oFigure.oGuiHandle.oSlider, [])
                    end
                case 'leftarrow'
                    iChannel = str2num(get(oFigure.oGuiHandle.oSliderEdit,'string'));
                    if iChannel - 1 >= 1
                        set(oFigure.oGuiHandle.oSliderEdit,'string',num2str(iChannel - 1));
                        set(oFigure.oGuiHandle.oSlider,'value',iChannel - 1);
                        oSlider_Callback(oFigure, oFigure.oGuiHandle.oSlider, [])
                    end
            end
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
        
        % --------------------------------------------------------------------
        function oSlider_Callback(oFigure, src, event)
           % Plot the data associated with this channel
           iChannel = oFigure.GetSliderIntegerValue('oSlider');
           oFigure.CurrentZoomLimits = [];
           oFigure.PlotOriginal(iChannel);
           oFigure.PlotProcessed(iChannel);
        end
        % --------------------------------------------------------------------
        function PostZoom_Callback(oFigure, src, event)
            %Synchronize the zoom of all the axes
            
            %Get the current axes and selected limit
            oCurrentAxes = event.Axes;
            oXLim = get(oCurrentAxes,'XLim');
            oYLim = get(oCurrentAxes,'YLim');
            oFigure.CurrentZoomLimits = [oXLim ; oYLim];
            %Apply to axes
            set(oFigure.oGuiHandle.oTopAxes,'XLim',oXLim);
            set(oFigure.oGuiHandle.oMiddleAxes,'XLim',oXLim);
            set(oFigure.oGuiHandle.oTopAxes,'YLim',oYLim);
            set(oFigure.oGuiHandle.oMiddleAxes,'YLim',oYLim);
        end
        % --------------------------------------------------------------------
        function pmPolynomialOrder_Callback(oFigure, src, event)
            
        end
        % --------------------------------------------------------------------
        function pmSplineOrder_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function pmFilterOrder_Callback(oFigure, src, event)

        end
        % --------------------------------------------------------------------
        function pmWindowSize_Callback(oFigure, src, event)

        end
        % --------------------------------------------------------------------
        function oCheckBoxReject_Callback(oFigure, src, event)
            %Get the button state
            ButtonState = get(oFigure.oGuiHandle.oCheckBoxReject,'Value');
            %Get the channel index
            iChannel = oFigure.GetSliderIntegerValue('oSlider');
            if ButtonState == get(oFigure.oGuiHandle.oCheckBoxReject,'Max')
                % Toggle button is pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.AcceptChannel(iChannel);
            elseif ButtonState == get(oFigure.oGuiHandle.oCheckBoxReject,'Min')
                % Toggle button is not pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.RejectChannel(iChannel);
            end
            %Replot
            oFigure.PlotOriginal(iChannel);
            oFigure.PlotProcessed(iChannel);
        end
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oTruncateMenu_Callback(oFigure, src, event)
            %Open the SelectData figure to select the data to truncate
            if strcmp(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Status,'Potential')
                sInstructions = 'Select a range of data to truncate.';
            else
                sInstructions = 'Select a range of data to truncate. This truncation will only be applied to the potential data (not any processed data)';
            end
            %Get the currently selected electrode
            iChannel = oFigure.GetSliderIntegerValue('oSlider');
            oSelectDataFigure = SelectData(oFigure,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential.Data,...
                {{'oInstructionText','string',sInstructions} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oButton','string','Done'} ; ...
                {'oAxes','title',sprintf('Channel %s Potential Data',iChannel)}});
            %Add a listener so that the figure knows when a user has
            %selected the data to truncate            
            addlistener(oSelectDataFigure,'DataSelected',@(src,event) oFigure.TruncateData(src, event));
        end
        

        
        % --------------------------------------------------------------------
        function oApplyChannelMenu_Callback(oFigure, src, event)
            %Apply processing steps to the currently selected channel
            
            %Get the channel index
            iChannel = oFigure.GetSliderIntegerValue('oSlider');
            
            %Work out from the checkbox selections which processing steps
            %are to be carried out and get the Input options
            aInOptions = oFigure.GetInputsForProcessing();
            
            %Process the data
            oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessElectrodeData(iChannel, aInOptions);

            %Replot the results
            oFigure.PlotProcessed(iChannel);
            if get(oFigure.oGuiHandle.oCheckBoxBaseline,'Value');
                oFigure.PlotPolynomial(iChannel);
            end
        end
        
        % --------------------------------------------------------------------
        function oApplyAllMenu_Callback(oFigure, src, event)
            %   Apply the selected processing steps to all the channels in
            %   oUnemap.Electrodes
            
            %Work out from the checkbox selections which processing steps
            %are to be carried out and get the Input options
            aInOptions = oFigure.GetInputsForProcessing();
            
            %Process the data
            oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessArrayData(aInOptions);
            
            %Replot the results
            iChannel = oFigure.GetSliderIntegerValue('oSlider');
            oFigure.PlotProcessed(iChannel);
            if get(oFigure.oGuiHandle.oCheckBoxBaseline,'Value');
                oFigure.PlotPolynomial(iChannel);
            end
        end
    end
    
    %% Private methods
    methods (Access = private)
        function CheckChannelStatus(oFigure,iChannel)
            %Get selected channel and set checkbox value
            set(oFigure.oGuiHandle.oCheckBoxReject,'value',oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Accepted);
        end
        
        function PlotOriginal(oFigure, iChannel)
            oAxes = oFigure.oGuiHandle.oTopAxes;
            cla(oAxes);
            sTitle = sprintf('Original Signal for Channel %s',oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Name);
            if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Accepted
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential.Data,'k');
            else
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential.Data,'r');
            end
            axis(oAxes, 'auto');
            title(oAxes, sTitle);
            if ~isempty(oFigure.CurrentZoomLimits)
                    %Apply the current zoom limits if there are some
                    set(oAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
                    set(oAxes,'YLim',oFigure.CurrentZoomLimits(2,:));
            end
            oFigure.CheckChannelStatus(iChannel);
        end
        
        function TruncateData(oFigure, src, event)
            %Get the boolean time indexes of the data that has been selected
            bIndexes = event.Indexes;
            %Negate this so that we can select the potential data we want
            %to keep.
            bIndexes = ~bIndexes;
            %Truncate data that is not selected
            oFigure.oParentFigure.oGuiHandle.oUnemap.TruncateArrayData(bIndexes);
            oFigure.oParentFigure.oGuiHandle.oECG.TruncateData(bIndexes);
        end
      
        function PlotProcessed(oFigure, iChannel)
            oAxes = oFigure.oGuiHandle.oMiddleAxes;
            cla(oAxes);
            %If there has been some processing done then plot the data
            if strcmp(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Status,'Processed')
                set(oAxes,'Visible','on');
                if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Accepted
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                        oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data,'k');
                    hold(oAxes, 'on');
                    if get(oFigure.oGuiHandle.oCheckBoxOriginal,'Value')
                        plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential.Data,'-b');
                        hold(oAxes, 'off');
                    end
                    if get(oFigure.oGuiHandle.oCheckBoxBeats,'Value')
                        hold(oAxes, 'on');
                        plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Beats,'-g');
                        hold(oAxes, 'off');
                    end
                else
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                        oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data,'-r');
                end
                axis(oAxes, 'auto');
                if ~isempty(oFigure.CurrentZoomLimits)
                    %Apply the current zoom limits if there are some
                    set(oAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
                    set(oAxes,'YLim',oFigure.CurrentZoomLimits(2,:));
                end
                sTitle = sprintf('Processed Signal for Channel %s', oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Name);
                title(oAxes,sTitle);
            else
                %Else hide the axes
                set(oAxes,'Visible','off');
            end
            
        end
        
        function PlotPolynomial(oFigure, iChannel)
            oAxes = oFigure.oGuiHandle.oMiddleAxes;
            if strcmp(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Status,'Processed')
                hold(oAxes, 'on');
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BaselinePoly,'-r');
                hold(oAxes,'off');
            end
        end
        
        function aInOptions = GetInputsForProcessing(oFigure)
            %Call this function to check the checkbox inputs to determine
            %what processing steps are to be carried out.
            
            %Get the values of the checkboxes to see which processing steps
            %have been selected
            bDeProcess = get(oFigure.oGuiHandle.oCheckBoxDeprocess,'Value');
            %Initialise Options array and counter
            aInOptions = [];
            i = 1;
            if bDeProcess
                aInOptions(i).Procedure = 'ClearData';
            else
                bBaseline = get(oFigure.oGuiHandle.oCheckBoxBaseline,'Value');
                bWavelet = get(oFigure.oGuiHandle.oCheckBoxWavelet,'Value');
                bFilter = get(oFigure.oGuiHandle.oCheckBoxFilter,'Value');
                
                if bBaseline
                    iPolynomialOrder = oFigure.GetEditInputDouble('edtPolynomialOrder');
                    aInOptions(i).Procedure = 'RemoveMedianAndFitPolynomial';
                    aInOptions(i).Inputs = iPolynomialOrder;
                    i = i + 1;
                end
                
                if bWavelet
                    iScalesToKeep = oFigure.GetEditInputDouble('edtWaveletScales');
                    aInOptions(i).Procedure = 'KeepWaveletScales';
                    aInOptions(i).Inputs = iScalesToKeep;
                    i = i + 1;
                end
                
                if bFilter
                    iOrder = oFigure.GetEditInputDouble('edtFilterOrder');
                    iWindowSize = oFigure.GetEditInputDouble('edtWindowSize');
                    aInOptions(i).Procedure = 'FilterData';
                    aInOptions(i).Inputs = {'SovitzkyGolay',iOrder,iWindowSize};
                end
                
            end
        end
    end
 
end

