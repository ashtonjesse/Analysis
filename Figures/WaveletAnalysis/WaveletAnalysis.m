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
        oRootFigure;
        BasePotentialFile;
    end
    
    events
        FigureDeleted;
        SlideSelectionChange;
    end
    
    methods
        function oFigure = WaveletAnalysis(oParent,oRootFigure,sBasePotentialFile)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'WaveletAnalysis',@WaveletAnalysis_OpeningFcn);
            oFigure.oRootFigure = oRootFigure;
            oFigure.BasePotentialFile = sBasePotentialFile;
            %Initialise properties
            oFigure.NumberOfScales = 10;
            
            %Set up beat slider
            %             oElectrodeSlider = SlideControl(oFigure,'Select Electrode',{'SlideSelectionChange'},[ 23.6667    1.0625  110.6667   10.2500]);
            %             iNumElectrodes = length(oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes);
            %             set(oElectrodeSlider.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
            %                 iNumElectrodes, 'Value', 1 ,'SliderStep',[1/iNumElectrodes  0.02]);
            %             set(oElectrodeSlider.oGuiHandle.oSliderTxtLeft,'string',1);
            %             set(oElectrodeSlider.oGuiHandle.oSliderTxtRight,'string',iNumElectrodes);
            %             set(oElectrodeSlider.oGuiHandle.oSliderEdit,'string',1);
            %             addlistener(oElectrodeSlider,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            addlistener(oFigure.oParentFigure,'ChannelSelected',@(src,event) oFigure.SlideValueListener(src, event));
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) ParentFigureDeleted(oFigure,src, event));

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
            oFigure.PlotPotential(oFigure.oParentFigure.SelectedChannel);
            %ComputeDWTFilteredSignalsRemovingScales
            oFigure.FilteredSignals = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).ComputeDWTFilteredSignalsKeepingScales(...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(oFigure.oParentFigure.SelectedChannel).Potential.Data, 1:oFigure.NumberOfScales);
            oFigure.PlotScalogram(oFigure.oParentFigure.SelectedChannel);
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
        %% Property set methods
        function set.FilteredSignals(oFigure,Value)
            oFigure.FilteredSignals = Value;
            oFigure.oParentFigure.FilteredSignals = Value;
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
            %            iChannel = event.Value;
            iChannel = oFigure.oParentFigure.SelectedChannel;
           oFigure.PlotPotential(iChannel);
            
           oFigure.FilteredSignals = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).ComputeDWTFilteredSignalsKeepingScales(...
               oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Potential.Data, 1:oFigure.NumberOfScales); 
           %            oFigure.Coefficients = cwt9(oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Processed.Slope,...
           %                 1:oFigure.NumberOfScales,'gaus1');
           
            oFigure.PlotScalogram(iChannel);
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
        function ParentFigureDeleted(oFigure,src, event)
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
            iBeat = oFigure.oParentFigure.SelectedBeat;
            set(oSignalPlot,'NextPlot','replacechildren');
            %Plot the signal data for the currently selected channels
            plot(oSignalPlot, oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Potential.Data,'k');
            %plot the selected beat
            aSelectedBeat = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Processed.Data(...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1):...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,2));
            aSelectedTime = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1):...
                oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,2));
            hold(oSignalPlot,'on');
            plot(oSignalPlot,aSelectedTime,aSelectedBeat,'g-','linewidth',1.5);
            if ~isempty(oFigure.aCurrentLimits)
                set(oSignalPlot,'XLim',oFigure.aCurrentLimits);
            else
                axis(oSignalPlot,'tight');
            end

        end
        
        function PlotScalogram(oFigure,iChannel)
            %Get the array of handles to the plot objects
            aPlotObjects = get(oFigure.oGuiHandle.oAxesPanel,'children');
            %Plot the scales
            for i = 1:(oFigure.NumberOfScales);
                oAxes = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, sprintf('ScaleAxes%d',i));
                %Set the current axes
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oAxes);
                set(oAxes,'NextPlot','replacechildren');
                if ismember(i,[3 4])
                    %                     [aPeaks,aPeakLocations] = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).GetPeaks(oFigure.FilteredSignals(:,i),3*std(oFigure.FilteredSignals(:,i)));
                    %                     plot(oAxes,oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(aPeakLocations), oFigure.FilteredSignals(aPeakLocations,i),'+g');
                    %                     hold(oAxes,'on');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                    %                     hold(oAxes,'off');
                elseif i == 2
                    %                     [aPeaks,aPeakLocations] = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).GetPeaks(oFigure.FilteredSignals(:,i),2.5*std(oFigure.FilteredSignals(:,i)));
                    %                     plot(oAxes,oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(aPeakLocations), oFigure.FilteredSignals(aPeakLocations,i),'+g');
                    %                     hold(oAxes,'on');
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                    %                     hold(oAxes,'off');
                else
                    plot(oAxes, oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries, oFigure.FilteredSignals(:,i),'-r');
                end
                if ~isempty(oFigure.aCurrentLimits)
                    set(oAxes,'XLim',oFigure.aCurrentLimits);
                else
                    axis(oAxes,'tight');
                end
                %plot lines to indicate which beat is selected
                iBeat = oFigure.oParentFigure.SelectedBeat;
                aSelectedTime = oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(...
                    oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1):...
                    oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,2));
                hold(oAxes,'on');
                aYLim = get(oAxes,'ylim');
                plot(oAxes,[aSelectedTime(1) aSelectedTime(1)],[aYLim(1) aYLim(2)],'g-','linewidth',1.5);
                plot(oAxes,[aSelectedTime(end) aSelectedTime(end)],[aYLim(1) aYLim(2)],'g-','linewidth',1.5);
                hold(oAxes,'off');
                
                
            end
            oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aPlotObjects, 'SignalAxes');
            hold(oSignalPlot,'on');
            aBaseline = DWTFilterRemoveScales(oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Potential.Data, oFigure.NumberOfScales);
            plot(oSignalPlot,  oFigure.oParentFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries, aBaseline,'-r');
        end
    end
        
end
