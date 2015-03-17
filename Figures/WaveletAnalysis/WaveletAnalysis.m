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
        FilteredSignals = [];
        aCurrentLimits = [];
    end
    
    events
        FigureDeleted;
        SlideSelectionChange;
    end
    
    methods
        function oFigure = WaveletAnalysis(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'WaveletAnalysis',@WaveletAnalysis_OpeningFcn);

            %Initialise properties
            oFigure.NumberOfScales = 10;
            
            %Set up beat slider
            oElectrodeSlider = SlideControl(oFigure,'Select Electrode',{'SlideSelectionChange'});
            iNumElectrodes = length(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes);
            set(oElectrodeSlider.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumElectrodes, 'Value', 1 ,'SliderStep',[1/iNumElectrodes  0.02]);
            set(oElectrodeSlider.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oElectrodeSlider.oGuiHandle.oSliderTxtRight,'string',iNumElectrodes);
            set(oElectrodeSlider.oGuiHandle.oSliderEdit,'string',1);
            addlistener(oElectrodeSlider,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Turn zoom on for this figure
            set(oFigure.oZoom,'enable','on');
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            %Plot the Potential and processed data of the first signal
            oFigure.CreateSubPlot();
            oFigure.PlotPotential(1);
            oFigure.FilteredSignals = oFigure.oParentFigure.oGuiHandle.oUnemap.ComputeDWTFilteredSignalsRemovingScales(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.Data, 0:oFigure.NumberOfScales);
            oFigure.PlotScalogram();
            % --- Executes just before Figure is made visible.
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
            notify(oFigure,'FigureDeleted');
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
        % --------------------------------------------------------------------
        function PostZoom_Callback(oFigure, src, event)
            %Synchronize the zoom of all the axes
            
            %Get the axes handles
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            %Get the current axes and selected limit
            oCurrentAxes = event.Axes;
            oLim = get(oCurrentAxes,'XLim');
            %Loop through the axes and set the new x limits
            for i = 1:length(aPlotObjects)
                    set(aPlotObjects(i),'XLim',oLim);
            end
            oFigure.aCurrentLimits = oLim;
         end
        
        % --------------------------------------------------------------------
        function SlideValueListener(oFigure, src, event)
           % Plot the data associated with this channel
           iChannel = event.Value;
           oFigure.PlotPotential(iChannel);
            
           oFigure.FilteredSignals = oFigure.oParentFigure.oGuiHandle.oUnemap.ComputeDWTFilteredSignalsRemovingScales(...
               oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data, 1:oFigure.NumberOfScales); 
           %            oFigure.Coefficients = cwt9(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Slope,...
           %                 1:oFigure.NumberOfScales,'gaus1');
           
            oFigure.PlotScalogram();
        end
        
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
    end
    
    %% Private methods
    methods (Access = private)
        %% Ui control callbacks    
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
        
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
             iMaxRow = oFigure.NumberOfScales + 1;
             iMaxCol = 1;
             %Divide up the space for the subplots
             xDiv = 1/(iMaxRow-iMinRow+1); 
             yDiv = 1/(iMaxCol-iMinCol+1);
             %Create the signal subplot
             aPosition = [0, 1-xDiv, yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oAxesPanel, 'Tag', 'SignalAxes');
             iRow = 1;
             %Loop through the scales
             for i = 1:oFigure.NumberOfScales;
                 %Keep track of the row
                 iRow = iRow + 1;
                 %Create the position vector for the next plot
                 aPosition = [0, 1-(iRow*xDiv), yDiv, xDiv];%[left bottom width height]
                 %Create a subplot in the position specified
                 subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oAxesPanel, 'Tag', ...
                     sprintf('ScaleAxes%d',i));
             end
        end
         
        function PlotPotential(oFigure, iChannel)
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, 'SignalAxes');
            set(oSignalPlot,'NextPlot','replacechildren');
            %Plot the signal data for the currently selected channels
            plot(oSignalPlot, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Potential.Data,'k');
            if ~isempty(oFigure.aCurrentLimits)
                set(oSignalPlot,'XLim',oFigure.aCurrentLimits);
            else
                axis(oSignalPlot,'tight');
            end

        end
        
        function PlotScalogram(oFigure)
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            %Plot the scales
            for i = 1:(oFigure.NumberOfScales);
                oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, sprintf('ScaleAxes%d',i));
                %Set the current axes
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oAxes);
                set(oAxes,'NextPlot','replacechildren');
                if ismember(i,[3 4])
                    [aPeaks,aPeakLocations] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPeaks(oFigure.FilteredSignals(:,i),3*std(oFigure.FilteredSignals(:,i)));
                    plot(oAxes,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aPeakLocations), oFigure.FilteredSignals(aPeakLocations,i),'+g');
                    hold(oAxes,'on');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                    hold(oAxes,'off');
                elseif i == 2
                    [aPeaks,aPeakLocations] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPeaks(oFigure.FilteredSignals(:,i),2.5*std(oFigure.FilteredSignals(:,i)));
                    plot(oAxes,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aPeakLocations), oFigure.FilteredSignals(aPeakLocations,i),'+g');
                    hold(oAxes,'on');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                    hold(oAxes,'off');
                else
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                end
                if ~isempty(oFigure.aCurrentLimits)
                    set(oAxes,'XLim',oFigure.aCurrentLimits);
                else
                    axis(oAxes,'tight');
                end
                
            end
            
        end
    end
        
end
