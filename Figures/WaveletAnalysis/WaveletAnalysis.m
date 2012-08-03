classdef WaveletAnalysis < SubFigure
    %WaveletAnalysis Summary
    %   This is the WaveletAnalysis class that wraps the
    %   WaveletAnalysisFig. It needs to be called from a parent figure 
    %   (e.g StartFigure) and the class wrapper
    %   for this parent passed as a input into the constructor. 
    
    %   This class assumes that the parent figure remains open while the
    %   WaveletAnalysisFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is done. 
    
    properties 
        NumberOfScales;
        Coefficients = [];
    end
    
    methods
        function oFigure = WaveletAnalysis(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'WaveletAnalysis',@WaveletAnalysis_OpeningFcn);

            %Initialise properties
            oFigure.NumberOfScales = 15;
            
            %Set the callback functions to the controls
            %set(oFigure.oGuiHandle.oSignalSlider, 'callback', @(src, event) oSignalSlider_Callback(oFigure, src, event));
            aSliderTexts = [oFigure.oGuiHandle.oSliderText1,oFigure.oGuiHandle.oSliderText2];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels, 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[0.01  0.1]},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCWTMenu, 'callback', @(src, event) oCWTMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Turn zoom on for this figure
            zoom(oFigure.oGuiHandle.(oFigure.sFigureTag), 'on');                       
            
            %Plot the original and processed data of the first signal
            oFigure.CreateSubPlot();
            oFigure.PlotOriginal(1);
            
            % --- Executes just before BaselineCorrection is made visible.
            function WaveletAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                set(handles.oAxesPanel,'title','Wavelet Decomposition');
                
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
        
        function nValue = GetSliderIntegerValue(oFigure,sSliderTag)
            nValue = GetSliderIntegerValue@BaseFigure(oFigure,sSliderTag);
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
           iChannel = oFigure.GetSliderIntegerValue('oSlider');
           oFigure.PlotOriginal(iChannel);
           oFigure.Coefficients = cwt9(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential,...
                1:oFigure.NumberOfScales,'gaus1');
            oFigure.PlotScalogram();
        end
        
               
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oCWTMenu_Callback(oFigure, src, event)
            %Calculate the CWT coefficients
%             iChannel = oFigure.GetSliderIntegerValue('oSlider');
            
        end
        
    end
    
    %% Private methods
    methods (Access = private)
        function CreateSubPlot(oFigure)
             %Create the space for the subplot that will contain all the
             %graphs
             
             %Clear the subplot panel first
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
             %Loop through list and delete
             for i = 1:size(aPlotObjects,1)
                 delete(aPlotObjects(i));
             end
             
             %Define space
             iMinRow = 1;
             iMinCol = 1; 
             iMaxRow = ((oFigure.NumberOfScales)/5)+4;
             iMaxCol = 1;
             %Divide up the space for the subplots
             xDiv = 1/(iMaxRow-iMinRow+1); 
             yDiv = 1/(iMaxCol-iMinCol+1);
             %Create the signal subplot
             aPosition = [0, 1-xDiv, yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oAxesPanel, 'Tag', 'SignalAxes');
             %Update the position vector and create the scalogram subplot
             iRow = 2;
             aPosition = [0, 1-(iRow*xDiv), yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oAxesPanel, 'Tag', 'ScalogramAxes');
             %Loop through the scales
             for i = 1:(((oFigure.NumberOfScales)/5)+2);
                 %Keep track of the row
                 iRow = iRow + 1;
                 %Create the position vector for the next plot
                 aPosition = [0, 1-(iRow*xDiv), yDiv, xDiv];%[left bottom width height]
                 %Create a subplot in the position specified
                 subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oAxesPanel, 'Tag', ...
                     sprintf('ScaleAxes%d',i));
             end
             
        end
         
        function PlotOriginal(oFigure, iChannel)
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, 'SignalAxes');
            set(oSignalPlot,'NextPlot','replacechildren');
            %Plot the signal data for the currently selected channels
            plot(oSignalPlot, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential,'k');
            axis(oSignalPlot, 'tight');
        end
        
        function PlotScalogram(oFigure)
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, 'ScalogramAxes');
            set(oAxes,'NextPlot','replacechildren');
            %Check to see if some CWT coefficients have been calculated
            if ~isempty(oFigure.Coefficients)
                %Set the current axes
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oAxes);
                %Plot the resulting scalogram
                imagesc(real(oFigure.Coefficients)); 
                colormap(oAxes,hot); 
                axis(oAxes,'tight'); 
                
                %Plot the scales
                for i = 1:((oFigure.NumberOfScales)/5);
                    oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, sprintf('ScaleAxes%d',i));
                    set(oAxes,'NextPlot','replacechildren');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, oFigure.Coefficients(i*5,:),'-r');
                    axis(oAxes,'tight');
                end
                
                rnear = 0;
                r0 = 0;
                for i = 1:1:7,
                    rnear = rnear + exp(-((i - 1)^2*0.061))*real(oFigure.Coefficients(i,:));
                    r0 = r0 + exp(-((i - 1)^2*0.061));
                end;
                rnear = rnear/r0;
                rfar = 0;
                for i = 1:1:7,
                    rfar = rfar + exp(-((i - 1)^2*0.061))*real(oFigure.Coefficients(end + 1 - i,:));
                end;
                rfar = rfar/r0;
                oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, sprintf('ScaleAxes%d',(((oFigure.NumberOfScales)/5)+1)));
                set(oAxes,'NextPlot','replacechildren');
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, real(rnear),'-r');
                axis(oAxes,'tight');
                oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, sprintf('ScaleAxes%d',(((oFigure.NumberOfScales)/5)+2)));
                set(oAxes,'NextPlot','replacechildren');
                plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, real(rfar));
                axis(oAxes,'tight');
            end
            
        end
    end
        
end
