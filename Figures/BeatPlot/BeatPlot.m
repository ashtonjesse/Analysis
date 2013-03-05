classdef BeatPlot < SubFigure
    %   BeatPlot.    
    
    properties
        CurrentEventLine;
        Dragging;
        SelectedEventID = [];
    end
    
    events
        SignalEventRangeChange;
        SignalEventDeleted;
    end
    
    methods
        function oFigure = BeatPlot(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BeatPlot',@OpeningFcn);
            %Add a listener so that the figure knows when a user has
            %made a beat selection
            addlistener(oFigure.oParentFigure,'SlideSelectionChange',@(src,event) oFigure.SelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'ChannelSelected',@(src,event) oFigure.SelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'EventMarkChange',@(src,event) oFigure.SelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'BeatIndexChange',@(src,event) oFigure.SelectionListener(src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) oFigure.ParentFigureDeleted(src, event));
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.oEventButtonGroup,  'SelectionChangeFcn', @(src,event) oFigure.EventSelectionChange_callback(src, event));
            set(oFigure.oGuiHandle.btnDeleteEvent,  'callback', @(src,event) oFigure.btnDeleteEvent_callback(src, event));
            set(oFigure.oGuiHandle.btnEventRange,  'callback', @(src,event) oFigure.btnEventRange_callback(src, event));
            
            %Set callbacks and other functions
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Plot data
            oFigure.CreatePlots();
            oFigure.PlotBeat();
            % --- Executes just before oFigure is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)
                set(handles.rbtnEvent1,'visible','off');
                set(handles.rbtnEvent2,'visible','off');
                set(handles.rbtnEvent3,'visible','off');
                set(handles.rbtnEvent4,'visible','off');
                set(handles.rbtnEvent5,'visible','off');
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
     end
    
     methods (Access = public)
         %% Menu Callbacks
        % -----------------------------------------------------------------
        function oUnused_Callback(oFigure, src, event)

        end
                
        %% Callbacks
        function SelectionListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new channel or new beat
            oFigure.PlotBeat();
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
     end
     
     methods (Access = private)
         function EventSelectionChange_callback(oFigure, src, event)
             %Update the selectedevent holder
             
             %Get the selected event
             oSelectedEvent = get(event.NewValue);
             %Save the string property
             oFigure.SelectedEventID = oSelectedEvent.String;
         end
         
         function btnEventRange_callback(oFigure, src, event)
             %Check the button state
             ButtonState = get(oFigure.oGuiHandle.btnEventRange,'Value');
             if ~isempty(oFigure.SelectedEventID)
                 if ButtonState == get(oFigure.oGuiHandle.btnEventRange,'Max')
                     % Toggle button has just been pressed
                     % Turn brushing on so that the user can select a range of data
                     brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
                     brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
                 elseif ButtonState == get(oFigure.oGuiHandle.btnEventRange,'Min')
                     % Toggle button has just been unpressed
                     
                     %Get the handle to these axes from the panel children
                     oPanelChildren = get(oFigure.oGuiHandle.oPanel,'children');
                     oAxes = oFigure.oDAL.oHelper.GetHandle(oPanelChildren, 'SignalPlot');
                     %Get the selected indexes
                     % Find any brushline objects associated with the ElectrodeAxes
                     hBrushLines = findall(oAxes,'tag','Brushing');
                     % Get the Xdata and Ydata attitributes of this
                     brushedData = get(hBrushLines, {'Xdata','Ydata'});
                     % The data that has not been selected is labelled as NaN so get
                     % rid of this
                     brushedIdx = ~isnan([brushedData{1,1}]);
                     [row, colIndices] = find(brushedIdx);
                     if ~isempty(colIndices)
                         aEventRange = [colIndices(1) colIndices(end)];
                         iBeat = oFigure.oParentFigure.SelectedBeat;
                         aBeatIndexes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.oParentFigure.SelectedChannel).Processed.BeatIndexes(iBeat,:);
                         iEventIndex = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.GetEventIndex(oFigure.oParentFigure.SelectedChannel,oFigure.SelectedEventID);
                         oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.UpdateEventRange(iEventIndex, iBeat, oFigure.oParentFigure.SelectedChannels, aEventRange + aBeatIndexes(1,1));
                     else
                         error('AnalyseSignals.bUpdateBeat_Callback:NoSelectedData', 'You need to select data');
                     end
                     % Turn brushing off
                     brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
                     %Refresh the plot
                     oFigure.PlotBeat();
                     %Notify listeners
                     notify(oFigure,'SignalEventRangeChange');
                 end
             end
         end
         
         function btnDeleteEvent_callback(oFigure,src, event)
             %Delete the selected event for the current beat for all
             %electrodes
             
             %Get the selected event
             oSelectedEvent = get(get(oFigure.oGuiHandle.oEventButtonGroup,'SelectedObject'));
             %Check that it is visible
             if strcmp(oSelectedEvent.Visible,'on')
                 %Get the string id of the event
                 sEventID = oSelectedEvent.String;
                 oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.DeleteEvent(sEventID, oFigure.oParentFigure.SelectedChannels);
                 oFigure.SelectedEventID = [];
             end
             %Refresh the plot
             oFigure.PlotBeat();
             notify(oFigure,'SignalEventDeleted');
         end
         
         function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
         end
         
         function StartDrag(oFigure, src, event)
            %The function that fires when a line on a subplot is dragged
            oFigure.Dragging = 1;
            oPlot = get(src,'Parent');
            oFigure.CurrentEventLine = get(src,'tag');
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', @(src,event) Drag(oFigure, src, DragEvent(oPlot)));
        end
        
        function StopDrag(oFigure, src, event)
            %The function that fires when the user lets go of a line on a
            %subplot
            if oFigure.Dragging
                %Make sure that the windowbuttonmotionfcn is no longer active
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', '');
                oFigure.Dragging = 0;
                %The tag of the current axes is the channel number
                iChannelNumber = oFigure.oParentFigure.SelectedChannel;
                iBeat = oFigure.oParentFigure.SelectedBeat;
                %Get the handle to these axes from the panel children
                oPanelChildren = get(oFigure.oGuiHandle.oPanel,'children');
                oAxes = oFigure.oDAL.oHelper.GetHandle(oPanelChildren, 'SignalEventPlot');
                %Get the handle to the line on these axes
                oAxesChildren = get(oAxes,'children');
                oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, oFigure.CurrentEventLine);
                %Get the current event for this channel
                iEvent = oFigure.oParentFigure.GetEventNumberFromTag(oFigure.CurrentEventLine);
                %Get the xdata of this line and convert it into a timeseries
                %index
                dXdata = get(oLine, 'XData');
                %Reset the range for this event to the beat indexes as the
                %user is manually changing the event time
                oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.UpdateEventRange(iEvent, iBeat, iChannelNumber, ...
                    oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelNumber).Processed.BeatIndexes(iBeat,:))
                %Update the signal event for this electrode and beat number
                oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.UpdateSignalEventMark(iChannelNumber, iEvent, iBeat, dXdata(1));
                oFigure.oParentFigure.Replot(iChannelNumber);
                %Refresh the plot
                oFigure.PlotBeat();
            end
        end
        
        function Drag(oFigure, src, event)
            %The function that fires while a line on a subplot is being
            %dragged
            oAxesChildren = get(event.ParentAxesHandle,'children');
            oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, oFigure.CurrentEventLine);
            oPoint = get(event.ParentAxesHandle, 'CurrentPoint');
            set(oLine, 'XData', oPoint(1)*[1 1]);
        end
         
         function CreatePlots(oFigure)
             %Create the plots that overlay oAxes
             
             %Clear the signal plot panel first
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.oPanel,'children');
             %Loop through list and delete
             for i = 1:size(aPlotObjects,1)
                 delete(aPlotObjects(i));
             end
             %Create the position vector for the next plot
             aPosition = [0, 0, 1, 1];%[left bottom width height]
             %Create a subplot in the position specified for Signal
             %data
             oSignalPlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel, 'Tag', 'SignalPlot');
             %Create axes for envelope data
             oEnvelopePlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel,'color','none', 'Tag', 'EnvelopePlot');
             %Create axes for slope data
             oSlopePlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel,'color','none','Tag', 'SlopePlot');
             %Create axes for event lines
             oSignalEventPlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel,'color','none', 'Tag', 'SignalEventPlot');
         end
         
         function PlotBeat(oFigure)
             %Plots the currently selected beat for the currently selected
             %channel
             
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Reset the visibility of the events
             set(oFigure.oGuiHandle.rbtnEvent1,'visible','off');
             set(oFigure.oGuiHandle.rbtnEvent2,'visible','off');
             set(oFigure.oGuiHandle.rbtnEvent3,'visible','off');
             set(oFigure.oGuiHandle.rbtnEvent4,'visible','off');
             set(oFigure.oGuiHandle.rbtnEvent5,'visible','off');

             %Get the current property values
             iBeat = oFigure.oParentFigure.SelectedBeat;
             %Find the max and min Y axis values for this selection
             oElectrode = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.oParentFigure.SelectedChannel);
             %Get the data associated with this channel in individual
             %arrays
             aData = oElectrode.Processed.Data(oElectrode.Processed.BeatIndexes(iBeat,1):...
                 oElectrode.Processed.BeatIndexes(iBeat,2),:);
             aSlope = oElectrode.Processed.Slope(oElectrode.Processed.BeatIndexes(iBeat,1):...
                 oElectrode.Processed.BeatIndexes(iBeat,2),:);
             aEnvelope = [];
             aEnvelopeLimits = [];
             if isfield(oElectrode.Processed,'CentralDifference')
                 aEnvelope = abs(oElectrode.Processed.CentralDifference(oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2),:));
                 aEnvelopeLimits = [min(aEnvelope), max(aEnvelope)];
             end
             aTime =  oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                 oElectrode.Processed.BeatIndexes(iBeat,1):...
                 oElectrode.Processed.BeatIndexes(iBeat,2));
             
             %Get the min/max values
             SignalYMax = max(max(aData));
             SignalYMin = min(min(aData));
             SlopeYMax = max(max(aSlope));
             SlopeYMin = min(min(aSlope));
             
             %Get these values so that we can place text in the
             %right place
             TimeMax = max(aTime);
             TimeMin = min(aTime);
             dWidth = TimeMax-TimeMin;
             dHeight = SignalYMax - SignalYMin;
            
             %Get the array of handles to the subplots that are children of
             %pnSignals panel
             aSubPlots = get(oFigure.oGuiHandle.oPanel,'children');
             oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SignalPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oSignalPlot, 'XTick',[],'YTick',[],'Tag', 'SignalPlot', 'NextPlot', 'replacechildren');
             cla(oSignalPlot);
             
             %Get the handle to current envelope plot
             oEnvelopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'EnvelopePlot');
             set(oEnvelopePlot,'XTick',[],'YTick',[],'Tag', 'EnvelopePlot', 'NextPlot', 'replacechildren');
             cla(oEnvelopePlot);
             
             %Get the handle to current slope plot
             oSlopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SlopePlot');
             set(oSlopePlot,'XTick',[],'YTick',[],'Tag', 'SlopePlot', 'NextPlot', 'replacechildren');
             cla(oSlopePlot);
             
             %Get the handle to current signalevent plot
             oSignalEventPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SignalEventPlot');
             set(oSignalEventPlot,'XTick',[],'YTick',[],'Tag', 'SignalEventPlot', 'NextPlot', 'replacechildren');
             cla(oSignalEventPlot);
             
             %Set the axis on the plot
             axis(oSignalPlot,[TimeMin, TimeMax, -1.1*abs(SignalYMin), 1.1*SignalYMax]);
             axis(oSlopePlot,[TimeMin, TimeMax, -1.1*abs(SlopeYMin), 1.1*SlopeYMax]);
             axis(oSignalEventPlot,[TimeMin, TimeMax, -1.1*abs(SignalYMin), 1.1*SignalYMax]);
             
             %Plot the data and slope
             if oElectrode.Accepted
                 %If the signal is accepted then plot it as black
                 plot(oSignalPlot,aTime,aData,'-k');
                 
                 if ~isempty(aEnvelope)
                     %Plot the envelope data
                     line(aTime,aEnvelope,'color','b','parent',oEnvelopePlot);
                     axis(oEnvelopePlot,[TimeMin, TimeMax, 1.1*aEnvelopeLimits(1), 1.1*aEnvelopeLimits(2)]);
                 end
                 
                 %Plot the slope data
                 line(aTime,aSlope,'color','r','parent',oSlopePlot);
                 %Loop through events
                 if isfield(oElectrode, 'SignalEvent')
                     for j = 1:length(oElectrode.SignalEvent)
                         %Mark the event times with a line
                         oLine = line([aTime(oElectrode.SignalEvent(j).Index(iBeat)) ...
                             aTime(oElectrode.SignalEvent(j).Index(iBeat))], [SignalYMax, SignalYMin]);
                         sLineTag = strcat(sprintf('SignalEventLine%d',oFigure.oParentFigure.SelectedChannel),'_',sprintf('%d',j));
                         set(oLine,'Tag',sLineTag,'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot, ...
                             'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                         set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
                         %Label the line with the event time
                         oEventLabel = text(TimeMax-dWidth*0.4, SignalYMax - dHeight*j*0.2, ...
                             num2str(aTime(oElectrode.SignalEvent(j).Index(iBeat)),'% 10.4f'));
                         set(oEventLabel,'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points');
                         set(oEventLabel,'FontSize',10);
                         set(oEventLabel,'parent',oSignalEventPlot);
                         set(oFigure.oGuiHandle.(sprintf('rbtnEvent%d',j)),'string',oElectrode.SignalEvent(j).ID);
                         set(oFigure.oGuiHandle.(sprintf('rbtnEvent%d',j)),'visible','on');
                     end
                     if isempty(oFigure.SelectedEventID) && ~isempty(oElectrode.SignalEvent)
                         set(oFigure.oGuiHandle.oEventButtonGroup,'SelectedObject',oFigure.oGuiHandle.rbtnEvent1);
                         oFigure.SelectedEventID = get(oFigure.oGuiHandle.rbtnEvent1,'string');
                     end
                 end
             else
                 %The signal is not accepted so plot it as red
                 %without gradient
                 plot(oSignalPlot,aTime,aData,'-r');
             end
             
            
             
             %Create a label that shows the channel name
             oLabel = text(TimeMin,SignalYMax - dHeight*0.1,char(oElectrode.Name));
             set(oLabel,'color','b','FontWeight','bold','FontUnits','points');
             set(oLabel,'FontSize',10);%0.2
             set(oLabel,'parent',oSignalEventPlot);
         end
     end
end
