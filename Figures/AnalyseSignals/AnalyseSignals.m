classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
        oSlideControl;
        SelectedChannel = 1;
        SubPlotXdim;
        SubPlotYdim;
        NumberofChannels;
        LineColours=['r','b','g'];
        oMapElectrodesFigure;
        oEditControl;
        Dragging;
        Annotate;
    end
        
    events
        BeatSelected;
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            oFigure.oSlideControl = SlideControl(oFigure,'Select Beat');
            %Set up slider
            iNumBeats = size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Activation(1).Indexes,1);
            set(oFigure.oSlideControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumBeats, 'Value', 1,'SliderStep',[1/iNumBeats  0.02]);
            set(oFigure.oSlideControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oFigure.oSlideControl.oGuiHandle.oSliderTxtRight,'string',iNumBeats);
            set(oFigure.oSlideControl.oGuiHandle.oSliderEdit,'string',1);
            
            %Get constants
            oFigure.SubPlotXdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.xDim;
            oFigure.SubPlotYdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.yDim;
            oFigure.NumberofChannels = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels;
            
            %Set callbacks
            set(oFigure.oGuiHandle.bRejectChannel, 'callback', @(src, event)  bAcceptChannel_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oToolMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oActivationMenu, 'callback', @(src, event) oActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGetSlopeMenu, 'callback', @(src, event) oGetSlopeMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAnnotationMenu, 'callback', @(src, event) oAnnotationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAdjustBeatMenu, 'callback', @(src, event) oAdjustBeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEnvelopeMenu, 'callback', @(src, event) oEnvelopeMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bUpdateBeat, 'callback', @(src, event)  bUpdateBeat_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'oncallback', @(src, event) oZoomOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'offcallback', @(src, event) oZoomOffTool_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.oMapElectrodesFigure = MapElectrodes(oFigure,oFigure.SubPlotXdim,oFigure.SubPlotYdim);
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oFigure.oMapElectrodesFigure,'ChannelSelection',@(src,event) oFigure.ChannelSelectionChange(src, event));
            addlistener(oFigure.oSlideControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            
            %Draw plots
            oFigure.CreateSubPlot();
            %Set annotation on
            oFigure.Annotate = 1;
            %Fill plots
            oFigure.Replot();
            oFigure.PlotECG();

            % --- Executes just before Figure is made visible.
            function AnalyseSignals_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)
                
                %Set ui control creation attributes 

                
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
    
     methods (Access = public)
         %% Ui control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deletefigure(oFigure.oMapElectrodesFigure);
            deletefigure(oFigure.oSlideControl);
            deleteme(oFigure);
        end
        
        function oZoomOnTool_Callback(oFigure, src, event)
            set(oFigure.oZoom,'enable','on'); 
        end
        
        function oZoomOffTool_Callback(oFigure, src, event)
            set(oFigure.oZoom,'enable','off'); 
        end
        
        function StartDrag(oFigure, src, event)
            %The function that fires when a line on a subplot is dragged
            oFigure.Dragging = 1;
            oSlopePlot = get(src,'Parent');
            oFigure.SelectedChannel = oFigure.oDAL.oHelper.GetDoubleFromString(get(oSlopePlot,'tag'));
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', @(src,event) Drag(oFigure, src, DragEvent(oSlopePlot)));
        end
        
        function StopDrag(oFigure, src, event)
            %The function that fires when the user lets go of a line on a
            %subplot
            if oFigure.Dragging
                %Make sure that the windowbuttonmotionfcn is no longer active
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', '');
                oFigure.Dragging = 0;
                %The tag of the current axes is the channel number
                iChannelNumber = oFigure.SelectedChannel;
                %Get the handle to these axes from the panel children
                oPanelChildren = get(oFigure.oGuiHandle.pnSignals,'children');
                oAxes = oFigure.oDAL.oHelper.GetHandle(oPanelChildren, sprintf('Slope%d',iChannelNumber));
                %Get the handle to the line on these axes
                oAxesChildren = get(oAxes,'children');
                oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, sprintf('ActLine%d',iChannelNumber));
                %Get the xdata of this line and convert it into a timeseries
                %index
                dXdata = get(oLine, 'XData');
                %Update the activation for this electrode and beat number
                oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateActivationMark(iChannelNumber, oFigure.oSlideControl.GetSliderIntegerValue('oSlider'), dXdata(1));
                %Refresh the plot
                oFigure.Replot();
            end
        end
        
        function Drag(oFigure, src, event)
            %The function that fires while a line on a subplot is being
            %dragged
            oPoint = get(event.ParentAxesHandle, 'CurrentPoint');
            oAxesTag = oFigure.oDAL.oHelper.GetDoubleFromString(get(event.ParentAxesHandle,'tag'));
            oAxesChildren = get(event.ParentAxesHandle,'children');
            oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, sprintf('ActLine%d',oAxesTag));
            set(oLine, 'XData', oPoint(1)*[1 1]);
        end
        
        function oSlopePlot_Callback(oFigure, src, event)
            oFigure.SelectedChannel = oFigure.oDAL.oHelper.GetDoubleFromString(get(src,'tag'));
            oFigure.Replot();
        end
        
        function oElectrodePlot_Callback(oFigure, src, event)
            oPoint = get(src,'currentpoint');
            xDim = oPoint(1,1);
            iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(oFigure.SelectedChannel,xDim);
            %Notify listeners so that the selected beat can be propagated
            %and update the Slide Control
            set(oFigure.oSlideControl.oGuiHandle.oSlider,'Value',iBeatIndexes{1,1});
            set(oFigure.oSlideControl.oGuiHandle.oSliderEdit,'String',iBeatIndexes{1,1});
            notify(oFigure,'BeatSelected');
            oFigure.Replot();
        end
        
        function bAcceptChannel_Callback(oFigure,src,event)
            ButtonState = get(oFigure.oGuiHandle.bRejectChannel,'Value');
            if ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Max')
                % Toggle button is pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.RejectChannel(oFigure.SelectedChannel);
            elseif ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Min')
                % Toggle button is not pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.AcceptChannel(oFigure.SelectedChannel);
            end
            oFigure.Replot();
        end
       
        function ChannelSelectionChange(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new set of channels and hits
            %the update selection menu option in MapElectrodes.fig
            %Draw plots
            oFigure.CreateSubPlot();
            %Fill plots
            oFigure.Replot();
        end
        
        function SlideValueListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new beat using the
            %SlideControl
            oFigure.Replot();
        end
        
        function SubtractEnvelope(oFigure,src,event)
            %Carries out an envelope subtraction neighbourhood action
            
            %Get the rows and cols
            iRows = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_1');
            iCols = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_2');
            %Set up inputs
            aInOptions = struct();
            aInOptions.Procedure = 'EnvelopeSubtraction';
            aInOptions.KernelBounds = [iRows iCols];
            oFigure.oParentFigure.oGuiHandle.oUnemap.ApplyNeighbourhoodAverage(aInOptions);
        end
        
        function bUpdateBeat_Callback(oFigure, src, event)
            %Update the currently selected beat 
            
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            brushedIdx = ~isnan([brushedData{3,1}]);
            [row, colIndices] = find(brushedIdx);
            if ~isempty(colIndices)
                aBeatIndexes = [colIndices(1) colIndices(end)];
                dStartTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aBeatIndexes(1));
                aNewBeat = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(oFigure.SelectedChannel,dStartTime);
                oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateBeatIndexes(aNewBeat{1,1},aBeatIndexes);
            else
                error('AnalyseSignals.bUpdateBeat_Callback:NoSelectedData', 'You need to select data');
            end
            
            %Reset the gui
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
            set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
            oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('SteepestSlope',oFigure.oSlideControl.GetSliderIntegerValue('oSlider'));
            oFigure.Replot();
        end
        
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oToolMenu_Callback(oFigure, src, event)
            
        end
        
        % --------------------------------------------------------------------
        function oActivationMenu_Callback(oFigure, src, event)
            oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('SteepestSlope',oFigure.oSlideControl.GetSliderIntegerValue('oSlider'));
            oFigure.Replot();
        end
        
        function oGetSlopeMenu_Callback(oFigure, src, event)
           oFigure.oParentFigure.oGuiHandle.oUnemap.GetSlope();
           oFigure.Replot();
        end
        
        function oAdjustBeatMenu_Callback(oFigure, src, event)
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
            set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'on');
        end
        
        function oAnnotationMenu_Callback(oFigure, src, event)
            %Change the annotation flag 
            if oFigure.Annotate
                oFigure.Annotate = 0;
            else
                oFigure.Annotate = 1;
            end
            %Replot
            oFigure.Replot();
        end
        
        function oEnvelopeMenu_Callback(oFigure, src, event)
            %Open an edit control
            oFigure.oEditControl = EditControl(oFigure,'Enter the number of rows and columns to have in the kernel.',2);
            addlistener(oFigure.oEditControl,'ValuesEntered',@(src,event) oFigure.SubtractEnvelope(src, event));
        end
     end
     
     methods (Access = private)
         function Replot(oFigure)
             %Make sure the current figure is AnalyseSignals
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             oFigure.PlotBeat();
             oFigure.PlotElectrode();
             oFigure.CheckRejectToggleButton();
         end
         
         function CheckRejectToggleButton(oFigure)
             if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannel).Accepted
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',0);
             else
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',1);
             end
         end
         
         function CreateSubPlot(oFigure)
             %Create the space for the subplot that will contain all the
             %signals
             
             %Clear the signal plot panel first
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.pnSignals,'children');
             %Loop through list and delete
             for i = 1:size(aPlotObjects,1)
                 delete(aPlotObjects(i));
             end
             %Find the bounds of the selected area
             iMinChannel = min(oFigure.oMapElectrodesFigure.SelectedChannels);
             iMaxChannel = max(oFigure.oMapElectrodesFigure.SelectedChannels);
             %Convert into row and col indices
             [iMinRow iMinCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMinChannel);
             [iMaxRow iMaxCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMaxChannel);
             %Divide up the space for the subplots
             xDiv = 1/(iMaxRow-iMinRow+1); 
             yDiv = 1/(iMaxCol-iMinCol+1);
                         
             %Loop through the selected channels
             for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
                 [iRow iCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(oFigure.oMapElectrodesFigure.SelectedChannels(i));
                 %Normalise the row and columns to the minimum.
                 iRow = iRow - iMinRow;
                 iCol = iCol - iMinCol;
                 %Create the position vector for the next plot
                 aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
                 %Create a subplot in the position specified for Signal
                 %data
                 oSignalPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals, 'Tag', ...
                     sprintf('Signal%d',oFigure.oMapElectrodesFigure.SelectedChannels(i)));
                 %Create axes for slope data
                 oSlopePlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'color','none',...
                     'Tag', sprintf('Slope%d',oFigure.oMapElectrodesFigure.SelectedChannels(i)));
             end
         end
         
         function PlotBeat(oFigure)
             %Plot the beats for the selected channels in the subplot 
             
             %Get the array of handles to the subplots that are children of
             %pnSignals panel
             aSubPlots = get(oFigure.oGuiHandle.pnSignals,'children');
             %Get the current property values
             iBeat = oFigure.oSlideControl.GetSliderIntegerValue('oSlider');
             %Find the max and min Y axis values for this selection
             %Initialise data arrays
             oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1);
             aData = zeros(oElectrode.Processed.BeatIndexes(iBeat,2) - oElectrode.Processed.BeatIndexes(iBeat,1) + 1, ...
                 length(oFigure.oMapElectrodesFigure.SelectedChannels));
             aSlope = zeros(oElectrode.Processed.BeatIndexes(iBeat,2) - oElectrode.Processed.BeatIndexes(iBeat,1) + 1, ...
                 length(oFigure.oMapElectrodesFigure.SelectedChannels));
             %Looping through channels is probably not the best way to do
             %this but I can't be bothered coding a better solution
             for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
                 iChannelIndex = oFigure.oMapElectrodesFigure.SelectedChannels(i);
                 %The channel data to plot on the iIndex subplot
                 oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelIndex);
                 if oElectrode.Accepted
                     aData(:,i) = oElectrode.Processed.Data(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                     aSlope(:,i) = oElectrode.Processed.Slope(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                 end
             end
             %Get the min/max of data and slope
             SignalYMax = max(max(aData));
             SignalYMin = min(min(aData));
             SlopeYMax = max(max(aSlope));
             SlopeYMin = min(min(aSlope));
             
             for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
                 iChannelIndex = oFigure.oMapElectrodesFigure.SelectedChannels(i);
                 %The channel data to plot on the iIndex subplot
                 oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelIndex);
                 %Get the data
                 aData = oElectrode.Processed.Data(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                 aSlope = oElectrode.Processed.Slope(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                 aTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                 %Get these values so that we can place text in the
                 %right place
                 TimeMax = max(aTime);
                 TimeMin = min(aTime);
                 %Get the handle to current signal plot
                 oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, sprintf('Signal%d',iChannelIndex));
                 set(oSignalPlot,'XTick',[],'YTick',[], 'Tag', ...
                     sprintf('Signal%d',iChannelIndex),'NextPlot','replacechildren');
                 %Get the handle to current slope plot 
                 oSlopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, sprintf('Slope%d',iChannelIndex));
                 set(oSlopePlot,'XTick',[],'YTick',[], 'Tag', ...
                     sprintf('Slope%d',iChannelIndex),'NextPlot','replacechildren');
                 cla(oSlopePlot);
                 %Plot the data and slope
                 if oElectrode.Accepted
                     %If the signal is accepted then plot it as black
                     plot(oSignalPlot,aTime,aData,'-k');
                     %Plot the slope data
                     line(aTime,aSlope,'color','r','parent',oSlopePlot);
                     hold(oSlopePlot,'on');
                     if ~isempty(oElectrode.Activation)
                         %Mark the activation times with a line
                         %Label the line with the activation time
                         oLine = line([aTime(oElectrode.Activation(1).Indexes(iBeat)) ...
                             aTime(oElectrode.Activation(1).Indexes(iBeat))], ...
                             [aSlope(oElectrode.Activation(1).Indexes(iBeat)) - 1 ...
                             aSlope(oElectrode.Activation(1).Indexes(iBeat)) + 1]);
                         set(oLine,'Tag',sprintf('ActLine%d',iChannelIndex),'color','r','parent',oSlopePlot, ...
                             'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                         set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
                         if oFigure.Annotate
                             oActivationLabel = text(TimeMin, SlopeYMax, ...
                                 num2str(aTime(oElectrode.Activation(1).Indexes(iBeat)),'% 10.4f'));
                             set(oActivationLabel,'color','r','FontWeight','bold','FontUnits','points');
                             set(oActivationLabel,'FontSize',10);
                             set(oActivationLabel,'parent',oSlopePlot);
                         end
                     end
                     hold(oSlopePlot,'off');
                 else
                     %The signal is not accepted so plot it as red
                     %without gradient
                     plot(oSignalPlot,aTime,aData,'-r');
                 end
    
                 %Set some callbacks for this subplot
                 set(oSlopePlot, 'buttondownfcn', @(src, event)  oSlopePlot_Callback(oFigure, src, event));
                 %Set the axis on the subplot
                 axis(oSignalPlot,[TimeMin, TimeMax, SignalYMin - 0.5, SignalYMax + 1]);
                 axis(oSlopePlot,[TimeMin, TimeMax, SlopeYMin - 0.5, SlopeYMax + 1]);
                 %Annotate?
                 if oFigure.Annotate
                     %Create a label that shows the channel name
                     oLabel = text(TimeMin,SlopeYMax+0.2,char(oElectrode.Name));
                     if iChannelIndex == oFigure.SelectedChannel;
                         set(oLabel,'color','b','FontWeight','bold','FontUnits','points');
                         set(oLabel,'FontSize',12);%0.2
                     else
                         set(oLabel,'FontUnits','points');
                         set(oLabel,'FontSize',10);%0.15
                     end
                     set(oLabel,'parent',oSlopePlot);
                 end
             end
             
         end
         
         function PlotElectrode(oFigure)
             %Plot all the beats for the selected channel in the axes at
             %the bottom
             
             %Get the current property values
             iBeat = oFigure.oSlideControl.GetSliderIntegerValue('oSlider');
             iChannel = oFigure.SelectedChannel;
             oAxes = oFigure.oGuiHandle.oElectrodeAxes;
             aProcessedData = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data;
             aBeatData = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Beats;
             aBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes;
             aTime = transpose(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries);
             
             %Get these values so that we can place text in the
             %right place and give the axes dimensions
             YMax = max(aProcessedData);
             YMin = min(aProcessedData);
             TimeMax = max(aTime);
             TimeMin = min(aTime);
             %Get the currently selected beat
             aSelectedBeat = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data(...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1):...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,2));
             aSelectedTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1):...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,2));
             %Plot all the data        
             cla(oAxes);
             if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannel).Accepted
                 %If the signal is accepted then plot it as black
                 plot(oAxes,aTime,aProcessedData,'k');
                 axis(oAxes,[TimeMin, TimeMax, YMin - 0.2, YMax + 0.2]);
                 hold(oAxes,'on');
                 plot(oAxes,aTime,aBeatData,'-g');
                 plot(oAxes,aSelectedTime,aSelectedBeat,'-b');
                 %Loop through beats and label
                 for j = 1:size(aBeatIndexes,1);
                     oBeatLabel = text(aTime(aBeatIndexes(j,1)),YMax, num2str(j));
                     set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','normalized');
                     set(oBeatLabel,'FontSize',0.12);
                     set(oBeatLabel,'parent',oAxes);
                 end
                 hold(oAxes,'off');
                 %Set callback
                 set(oAxes, 'buttondownfcn', @(src, event)  oElectrodePlot_Callback(oFigure, src, event));
             else
                 %The signal is not accepted so plot it as red
                 %without beats
                 plot(oAxes,aTime,aProcessedData,'-r');
                 axis(oAxes,[TimeMin, TimeMax, YMin - 0.2, YMax + 0.2]);
             end
             set(oAxes, 'XTickLabel','');
         end
         
         function PlotECG(oFigure)
             % Plot ECG Data
            
            %Clear axes and set to be visible
            cla(oFigure.oGuiHandle.oECGAxes);
            %Find axis limits
            TimeMin = min(oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries);
            TimeMax = max(oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries);
            YMin = min(oFigure.oParentFigure.oGuiHandle.oECG.Original);
            YMax = max(oFigure.oParentFigure.oGuiHandle.oECG.Original);
            %Plot the ECG channel data
            plot(oFigure.oGuiHandle.oECGAxes, ...
                oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oECG.Original,'k');
            hold(oFigure.oGuiHandle.oECGAxes, 'on');
            plot(oFigure.oGuiHandle.oECGAxes, ...
                oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries, ...
                transpose(oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats),'-g');
            axis(oFigure.oGuiHandle.oECGAxes,[TimeMin, TimeMax, YMin - 10, YMax + 10]);
            hold(oFigure.oGuiHandle.oECGAxes, 'off');
            oXLabel = get(oFigure.oGuiHandle.oECGAxes,'XLabel');
            set(oXLabel,'string','Time (s)','Position',get(oXLabel,'Position') + [0 10 0]);
         end
             
     end
end

