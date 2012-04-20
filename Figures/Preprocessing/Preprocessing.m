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

    end
    
    methods
        function oFigure = Preprocessing(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'Preprocessing',@Preprocessing_OpeningFcn);
            
            %Set the callback functions to the controls
            %set(oFigure.oGuiHandle.oSignalSlider, 'callback', @(src, event) oSignalSlider_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.pmPolynomialOrder , 'callback', @(src, event)  pmPolynomialOrder_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.pmSplineOrder, 'callback', @(src, event)  pmSplineOrder_Callback(oFigure, src, event));
            
            aSliderTexts = [oFigure.oGuiHandle.oSliderText1,oFigure.oGuiHandle.oSliderText2];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels, 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event)},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFilterMenu, 'callback', @(src, event) oFilterMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oBaselineMenu, 'callback', @(src, event) oBaselineMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSplineMenu, 'callback', @(src, event) oSplineMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oApplyMenu, 'callback', @(src, event) oApplyMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Turn zoom on for this figure
            zoom(oFigure.oGuiHandle.(oFigure.sFigureTag), 'on');                       
            
            %Plot the original and processed data of the first signal
            oFigure.PlotOriginal(1);
            oFigure.PlotProcessed(1);
                       
            % --- Executes just before BaselineCorrection is made visible.
            function Preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                set(handles.pmPolynomialOrder, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                set(handles.pmSplineOrder, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                set(handles.oCheckBoxBaseline, 'string', 'Baseline Correction');
                set(handles.oCheckBoxSpline, 'string', 'Spline');
                set(handles.oCheckBoxFilter, 'string', 'Filter');
                set(handles.oCheckBoxBeats, 'string', 'Plot beats');
                set(handles.oCheckBoxBaseline, 'TooltipString', 'Baseline Correction');
                set(handles.oCheckBoxSpline, 'TooltipString', 'Spline');
                set(handles.oCheckBoxFilter, 'TooltipString', 'Filter');
                set(handles.oCheckBoxBeats, 'TooltipString', 'Plot beats');
                
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
        
    end
    
    methods
        %% Ui control callbacks    
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
        
        % --------------------------------------------------------------------
        function oSlider_Callback(oFigure, src, event)
           % Plot the data associated with this channel
            oFigure.PlotOriginal(get(oFigure.oGuiHandle.oSlider,'Value'));
            oFigure.PlotProcessed(get(oFigure.oGuiHandle.oSlider,'Value'));
        end
        % --------------------------------------------------------------------
        function pmPolynomialOrder_Callback(oFigure, src, event)
            
        end
        % --------------------------------------------------------------------
        function pmSplineOrder_Callback(oFigure, src, event)

        end
               
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oFilterMenu_Callback(oFigure, src, event)
            %Build 50Hz notch filter
            %Get nyquist frequency
            wo = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.ADConversion.SamplingRate/2;
            [z p k] = butter(3, [49 51]./wo, 'stop'); % 10th order filter
            [sos,g] = zp2sos(z,p,k); % Convert to 2nd order sections form
            oFilter = dfilt.df2sos(sos,g); % Create filter object
            fvtool(oFilter);
            iChannel = round(get(oFigure.oGuiHandle.oSlider,'Value'));
            %Check if this filter should be applied to processed or
            %original data
            if isnan(oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(1,iChannel))
                aFilteredData = filter(oFilter,oFigure.oParentFigure.oGuiHandle.oUnemap.Original(:,iChannel));
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(:,iChannel) = aFilteredData;
            else
                aFilteredData = filter(oFilter,oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(:,iChannel));
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(:,iChannel) = aFilteredData;
            end
            oFigure.PlotProcessed(iChannel);
            
        end
        
        % --------------------------------------------------------------------
        function oBaselineMenu_Callback(oFigure, src, event)
            %Takes the polynomial order specified in the popup and applies
            %this polynomial fit to the data 
            
            %Get the polynomial order from the selection made in the popup
            iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
            %Get the currently selected channel
            iChannel = round(get(oFigure.oGuiHandle.oSlider,'Value'));
            %Remove baseline from either the original data or if there is
            %processed data already for this channel then apply to that.
            if isnan(oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(1,iChannel))
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                    'RemoveMedianAndFitPolynomial', iPolynomialOrder,iChannel);
            else
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data, ...
                    'RemoveMedianAndFitPolynomial', iPolynomialOrder,iChannel);
            end
            
            oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.PolyOrder = iPolynomialOrder;
            
            %Plot the data with the baseline removed.
            oFigure.PlotProcessed(iChannel);
        end
        
        % --------------------------------------------------------------------
        function oSplineMenu_Callback(oFigure, src, event)
            
            %Get the spline approximation order from the selection made in the popup
            iSplineOrder = oFigure.GetPopUpSelectionDouble('pmSplineOrder');
            %Get the currently selected channel
            iChannel = round(get(oFigure.oGuiHandle.oSlider,'Value'));           
            
            %Smooth with a spline the data from either the original  or if there is
            %processed data already for this channel then apply to that.
            if isnan(oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(1,iChannel))
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                    'SplineSmoothData', iSplineOrder,iChannel);
            else
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data, ...
                    'SplineSmoothData', iSplineOrder,iChannel);
            end
            
            oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.SplineOrder = iSplineOrder;
            
            %Plot the Spline approximation
             oFigure.PlotProcessed(iChannel);
            
        end
        
        % --------------------------------------------------------------------
        function oApplyMenu_Callback(oFigure, src, event)
            %   Apply the selected processing steps to all the channels in oUnemap.Original and save.
            bBaseline = get(oFigure.oGuiHandle.oCheckBoxBaseline,'Value');
            bSpline = get(oFigure.oGuiHandle.oCheckBoxSpline,'Value');
            if bBaseline
                %   Get the polynomial order from the selection made in the listbox
                %   control
                iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
                
                %  Remove baseline (not specifying a channel number so this call
                %  will do all the channels
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                    'RemoveMedianAndFitPolynomial', iPolynomialOrder);
            end
            
            if bBaseline && bSpline
                ApplySpline(oFigure,'Processed')
            elseif ~bBaseline && bSpline
                ApplySpline(oFigure,'Original')
            end
            
            function ApplySpline(oFigure,sDataType)
                %Get the spline approximation order from the selection made in the popup
                iSplineOrder = oFigure.GetPopUpSelectionDouble('pmSplineOrder');
                
                %Smooth the data with a spline approximation
                switch sDataType
                    case 'Processed'
                        oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data, ...
                            'SplineSmoothData',iSplineOrder);
                    case 'Original'
                        oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data = ...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                            'SplineSmoothData',iSplineOrder);
                    otherwise
                end
            end
        end
        
    end
    
    %% Private methods
    methods (Access = private)
        function PlotOriginal(oFigure, iChannel)
            if ~isinteger(iChannel)
                %Round down to nearest integer if a double is supplied
                iChannel = round(iChannel(1));
            end
            sTitle = sprintf('Original Signal for Channel %d',iChannel);
            oAxes = oFigure.oGuiHandle.oTopAxes;
            plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Original(:,iChannel),'k');
            axis(oAxes, 'auto');
            title(oAxes, sTitle);
        end
        
        function PlotProcessed(oFigure, iChannel)
            oAxes = oFigure.oGuiHandle.oMiddleAxes;
            if ~isinteger(iChannel)
                %Round down to nearest integer if a double is supplied
                iChannel = round(iChannel(1));
            end
            %If there has been some processing done then plot the data
            if ~isnan(oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(1,iChannel))
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(:,iChannel),'k');
                if get(oFigure.oGuiHandle.oCheckBoxBeats,'Value')
                    hold(oAxes, 'on');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                        oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Beats(:,iChannel),'-g');
                    hold(oAxes, 'off');
                end
                axis(oAxes, 'auto');
                sTitle = sprintf('Processed Signal for Channel %d', iChannel);
                title(oAxes,sTitle);
            else
                %Else clear the axes and hide them
                cla(oAxes);
                set(oAxes,'Visible','off');
            end
            
        end
    end
        
end
