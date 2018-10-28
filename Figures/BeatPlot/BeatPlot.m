classdef BeatPlot < SubFigure
    %   BeatPlot.    
    
    properties
        CurrentPlotLine;
        Dragging;
        SelectedEventID;
        ElectrodesForAction = [];
        BeatsForAction = [];
        oRootFigure;
        BasePotentialFile;
    end
    
    events
        SignalEventRangeChange;
        SignalEventDeleted;
        SignalEventSelected;
        SignalEventMarkChange;
        TimePointChange;
    end
    
    methods
        function oFigure = BeatPlot(oParent,oRootFigure,sBasePotentialFile)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BeatPlot',@OpeningFcn);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'position',[22.3333   14.0000  184.6667   49.7500]);
            oFigure.oRootFigure = oRootFigure;
            oFigure.BasePotentialFile = sBasePotentialFile;
            %Add a listener so that the figure knows when a user has
            %made a beat selection
            addlistener(oFigure.oParentFigure,'BeatSelectionChange',@(src,event) oFigure.BeatSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'NewSignalEventCreated',@(src,event) oFigure.BeatSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'ChannelSelected',@(src,event) oFigure.BeatSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'EventMarkChange',@(src,event) oFigure.BeatSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'BeatIndexChange',@(src,event) oFigure.BeatSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'SignalEventLoaded',@(src,event) oFigure.BeatSelectionListener(src, event));
            
            %Add a listener so the figure knows when a user has made a time
            %point selection
            addlistener(oFigure.oParentFigure,'TimeSelectionChange',@(src,event) oFigure.TimeSelectionListener(src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) ParentFigureDeleted(oFigure,src, event));
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.oEventButtonGroup,  'SelectionChangeFcn', @(src,event) oFigure.EventSelectionChange_callback(src, event));
            set(oFigure.oGuiHandle.oElectrodeButtonGroup,  'SelectionChangeFcn', @(src,event) oFigure.oElectrodeButtonGroup_SelectionChangeFcn(src, event));
            set(oFigure.oGuiHandle.oBeatButtonGroup,  'SelectionChangeFcn', @(src,event) oFigure.BeatActionSelectionChange_SelectionChangeFcn(src, event));
            set(oFigure.oGuiHandle.btnDeleteEvent,  'callback', @(src,event) oFigure.btnDeleteEvent_callback(src, event));
            set(oFigure.oGuiHandle.btnEventRange,  'callback', @(src,event) oFigure.btnEventRange_callback(src, event));
            set(oFigure.oGuiHandle.btnRefreshSignalEvent,  'callback', @(src,event) oFigure.btnRefreshSignalEvent_callback(src, event));
            set(oFigure.oGuiHandle.oFileMenu,  'callback', @(src,event) oFigure.oUnused_Callback(src, event));
            set(oFigure.oGuiHandle.oPrintMenu,  'callback', @(src,event) oFigure.oPrintMenu_Callback(src, event));
            
            %Set callbacks and other functions
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Plot data
            oFigure.CreatePlots();
            oFigure.PlotBeat();
            
            oFigure.ElectrodesForAction = oFigure.oParentFigure.SelectedChannel;
            oFigure.BeatsForAction = oFigure.oParentFigure.SelectedBeat;
            oFigure.SelectedEventID = oFigure.oParentFigure.SelectedEventID;
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
    
    methods 
        %% Property set methods
        function set.SelectedEventID(oFigure,Value)
            oFigure.SelectedEventID = Value;
            notify(oFigure,'SignalEventSelected',DataPassingEvent([],oFigure.SelectedEventID));
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
        
        function oPrintMenu_Callback(oFigure, src, event)
            [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if (~ischar(sFilename) && ~ischar(sPathName))
                return
            end
            
            sLongDataFileName=strcat(sPathName,sFilename,'.bmp');
            oFigure.PrintFigureToFile(sLongDataFileName);
        end
        
        %% Callbacks
        function BeatSelectionListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new channel or new beat
            oFigure.UpdateActionSelections();
            oFigure.PlotBeat();
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        function TimeSelectionListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new time point
            oFigure.PlotBeat();
        end
        
     end
     
     methods (Access = private)
         function EventSelectionChange_callback(oFigure, src, event)
             %Update the selectedevent holder
             
             %Get the selected event
             oSelectedEvent = get(event.NewValue);
             %Convert the string into an integer index and set property
             oFigure.SelectedEventID = oSelectedEvent.String;
         end
         
          function oElectrodeButtonGroup_SelectionChangeFcn(oFigure, src, event)
             %Update the ElectrodeAction holder
             
             %Get the selected checkbox
             oSelectedObject = get(event.NewValue);
             
             switch (oSelectedObject.Tag)
                 case 'rbThisElectrode'
                     oFigure.ElectrodesForAction = oFigure.oParentFigure.SelectedChannel;
                 case 'rbSelectedElectrodes'
                     oFigure.ElectrodesForAction = oFigure.oParentFigure.SelectedChannels;
                 case 'rbAllElectrodes'
                     oFigure.ElectrodesForAction = 1:length(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes);
             end
          end
         
          function BeatActionSelectionChange_SelectionChangeFcn(oFigure, src, event)
             %Update the BeatAction holder
             
             %Get the selected checkbox
             oSelectedObject = get(event.NewValue);
             switch (oSelectedObject.Tag)
                 case 'rbThisBeat'
                     oFigure.BeatsForAction = oFigure.oParentFigure.SelectedBeat;
                 case 'rbAllBeats'
                     oFigure.BeatsForAction = 1:size(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes,1);
             end
          end
         
          function UpdateActionSelections(oFigure)
              %Update the ElectrodesForAction and BeatsForAction properties
              %so that they reflect current selections
              %get the selected objects first
              oSelectedObject = get(oFigure.oGuiHandle.oElectrodeButtonGroup,'SelectedObject');
              switch (get(oSelectedObject,'Tag'))
                  case 'rbThisElectrode'
                      oFigure.ElectrodesForAction = oFigure.oParentFigure.SelectedChannel;
                  case 'rbSelectedElectrodes'
                      oFigure.ElectrodesForAction = oFigure.oParentFigure.SelectedChannels;
                  case 'rbAllElectrodes'
                      oFigure.ElectrodesForAction = 1:length(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes);
              end
              
              oSelectedObject = get(oFigure.oGuiHandle.oBeatButtonGroup,'SelectedObject');
              switch (get(oSelectedObject,'Tag'))
                 case 'rbThisBeat'
                     oFigure.BeatsForAction = oFigure.oParentFigure.SelectedBeat;
                 case 'rbAllBeats'
                     oFigure.BeatsForAction = 1:size(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes,1);
             end
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
                     if ~isempty(brushedData)
                         brushedIdx = ~isnan([brushedData{1,1}]);
                         [row, colIndices] = find(brushedIdx);
                         if ~isempty(colIndices)
                             aEventRange = [colIndices(1) colIndices(end)];
                             %Update the event range
                             oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).UpdateEventRange(oFigure.SelectedEventID, oFigure.BeatsForAction, oFigure.ElectrodesForAction, aEventRange,oFigure.oParentFigure.SelectedChannel);
                         end
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
                 oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).DeleteEvent(sEventID);
                 oFigure.SelectedEventID = [];
             end
             %Refresh the plot
             oFigure.PlotBeat();
             notify(oFigure,'SignalEventDeleted');
         end
         
         function btnRefreshSignalEvent_callback(oFigure, src, event)
             %Update the event mark as it is no longer accurate.
             
             %get a local copy of the unemap struct
             oBasePotential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile);
             %Get the current event for this channel
             sEventID = oFigure.SelectedEventID;
             oBasePotential.MarkEvent(sEventID,oFigure.BeatsForAction,oFigure.ElectrodesForAction);
             %Notify listeners
             notify(oFigure,'SignalEventMarkChange');
             %Refresh the plot
             oFigure.PlotBeat();
         end
         
         function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
         end
         
         function StartDrag(oFigure, src, event)
            %The function that fires when a line on a subplot is dragged
            oFigure.Dragging = 1;
            oPlot = get(src,'Parent');
            oFigure.CurrentPlotLine = get(src,'tag');
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
                oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, oFigure.CurrentPlotLine);
                %Get the xdata of this line and convert it into a timeseries
                %index
                dXdata = get(oLine, 'XData');
                sTag = get(oLine,'Tag');
                %Check if this is a time line or a line associated with an
                %event
                switch (sTag(1))
                    case 'T'
                        %TimeLine
                        %Get the index associated with this time point
                        iTimeIndex = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetIndexFromTime(iChannelNumber, iBeat, dXdata(1));
                        notify(oFigure, 'TimePointChange',DataPassingEvent([],iTimeIndex));
                    case 'S'
                        %SignalEventLine
                        %Get the current event for this channel
                        sEventID = oFigure.oParentFigure.GetEventIDFromTag(oFigure.CurrentPlotLine);
                        %check if we need to reset the range for this event
                        iRangeStart = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannelNumber).(sEventID).RangeStart(iBeat);
                        iRangeEnd = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannelNumber).(sEventID).RangeEnd(iBeat);
                        iTimeIndex = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetIndexFromTime(iChannelNumber, iBeat, dXdata(1));
                        dLocation = iTimeIndex + oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1) - 1;
                        if dLocation < iRangeStart || dLocation > iRangeEnd
                            %Reset the range for this event to the beat indexes as the
                            %user is manually changing the event time
                            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).UpdateEventRange(sEventID, iBeat, iChannelNumber, ...
                                [1 oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,2) - ...
                                oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1)],[]);
                        end
                        %Update the signal event for this electrode and beat number
                        oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).UpdateSignalEventMark(iChannelNumber, sEventID, iBeat, dXdata(1));
                        notify(oFigure, 'SignalEventMarkChange',DataPassingEvent([],iChannelNumber));
                end
                %Refresh the plot
                oFigure.PlotBeat();
            end
        end
        
        function Drag(oFigure, src, event)
            %The function that fires while a line on a subplot is being
            %dragged
            oAxesChildren = get(event.ParentAxesHandle,'children');
            oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, oFigure.CurrentPlotLine);
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
             aPosition = [0.1, 0.1, 0.85, 0.9];%[left bottom width height]
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
             
             %Make sure the current figure 
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
             oElectrode = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(oFigure.oParentFigure.SelectedChannel);
             oBasePotential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile);
             %Get the data associated with this channel in individual
             %arrays
             aData = oElectrode.Processed.Data(oBasePotential.Beats.Indexes(iBeat,1):...
                 oBasePotential.Beats.Indexes(iBeat,2),:);
             aSlope = oElectrode.Processed.Slope(oBasePotential.Beats.Indexes(iBeat,1):...
                 oBasePotential.Beats.Indexes(iBeat,2),:);
             aCurvature = oElectrode.Processed.Curvature(oBasePotential.Beats.Indexes(iBeat,1):...
                 oBasePotential.Beats.Indexes(iBeat,2),:);
             aEnvelope = [];
             aEnvelopeLimits = [];
             if isfield(oElectrode.Processed,'CentralDifference')
                 aEnvelope = abs(oElectrode.Processed.CentralDifference(oBasePotential.Beats.Indexes(iBeat,1):...
                     oBasePotential.Beats.Indexes(iBeat,2),:));
                 aEnvelopeLimits = [min(aEnvelope), max(aEnvelope)];
             end
             %get regional average
             aRegion = GetElectrodesWithinRadius(oBasePotential,oElectrode.Coords',0.5, [oBasePotential.Electrodes(:).Coords]');
             aAllData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Data');
             aAverageData = aAllData(oBasePotential.Beats.Indexes(iBeat,1):...
                 oBasePotential.Beats.Indexes(iBeat,2),aRegion);
             aAverageData = mean(aAverageData,2);
             
             aTime =  oBasePotential.TimeSeries(...
                 oBasePotential.Beats.Indexes(iBeat,1):...
                 oBasePotential.Beats.Indexes(iBeat,2));
             
             %Get the min/max values
             SignalYMax = max(max(aData));
             SignalYMin = min(min(aData));
             SlopeYMax = max(max(aSlope));
             SlopeYMin = min(min(aSlope));
             CurvatureYMax = max(max(aCurvature)); 
             CurvatureYMin = min(min(aCurvature));
             %              %Get these values so that we can place text in the
             %              %right place
             %              TimeMax = min(aTime)+((max(aTime)-min(aTime))/2);
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
             set(oSignalPlot, 'Tag', 'SignalPlot', 'NextPlot', 'replacechildren');
%              set(oSignalPlot,'xticklabel',0:5:30);
             set(get(oSignalPlot,'xlabel'),'string','Time (s)');
             set(oSignalPlot,'fontsize',8);
             cla(oSignalPlot);
             
             %Get the handle to current envelope plot
             oEnvelopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'EnvelopePlot');
             set(oEnvelopePlot,'XTick',[],'YColor','c','Tag', 'EnvelopePlot', 'NextPlot', 'replacechildren');
             cla(oEnvelopePlot);
             
             %Get the handle to current slope plot
             oSlopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SlopePlot');
             set(oSlopePlot,'XTick',[],'YColor','r','Tag', 'SlopePlot', 'NextPlot', 'replacechildren');
             cla(oSlopePlot);
             
             %Get the handle to current signalevent plot
             oSignalEventPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SignalEventPlot');
             set(oSignalEventPlot,'XTick',[],'YTick',[],'Tag', 'SignalEventPlot', 'NextPlot', 'replacechildren');
             cla(oSignalEventPlot);
             
             %Set the axis on the plot
             axis(oSignalPlot,[TimeMin, TimeMax, (1-sign(SignalYMin)*0.1)*SignalYMin, (1+sign(SignalYMax)*0.1)*SignalYMax]);
             axis(oSlopePlot,[TimeMin, TimeMax, (1-sign(SlopeYMin)*0.1)*SlopeYMin, (1+sign(SlopeYMax)*0.1)*SlopeYMax]);
             axis(oSignalEventPlot,[TimeMin, TimeMax, (1-sign(SignalYMin)*0.1)*SignalYMin, (1+sign(SignalYMax)*0.1)*SignalYMax]);
             axis(oEnvelopePlot,[TimeMin, TimeMax, (1-sign(CurvatureYMin)*0.1)*CurvatureYMin, (1+sign(CurvatureYMax)*0.1)*CurvatureYMax]);
             
             %Plot the data and slope
             if oElectrode.Accepted
                 %If the signal is accepted then plot it as black
                 plot(oSignalPlot,aTime,aData,'-k');
                 %plot a line that shows the currently selected timepoint
                 oLine = line([aTime(oFigure.oParentFigure.SelectedTimePoint) ...
                     aTime(oFigure.oParentFigure.SelectedTimePoint)], [SignalYMax, SignalYMin]);
                 sLineTag = sprintf('TimeLine%d',oFigure.oParentFigure.SelectedChannel);
                 set(oLine,'Tag',sLineTag,'color', 'k', 'parent',oSignalEventPlot, ...
                     'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                 if ~isempty(aEnvelope)
                     %Plot the envelope data
                     line(aTime,aEnvelope,'color','b','parent',oEnvelopePlot);
                     axis(oEnvelopePlot,[TimeMin, TimeMax, (1-sign(aEnvelopeLimits(1))*0.1)*aEnvelopeLimits(1), (1+sign(aEnvelopeLimits(2))*0.1)*aEnvelopeLimits(2)]);
                 end
                 hold(oSignalPlot,'on');
                 %plot baseline estimate
                 plot(oSignalPlot,aTime(1:10),mean(aData(1:10))*ones(1,10),'k--','linewidth',2);
                 hold(oSignalPlot,'off');
                 %Plot the slope data
                 plot(aTime,aSlope,'color','r','parent',oSlopePlot);
                 plot(aTime,aCurvature,'color','c','parent',oEnvelopePlot );
                 %Loop through events
                 if isfield(oElectrode,'SignalEvents')
                     for j = 1:length(oElectrode.SignalEvents)
                         %Mark the event times with a line
                         oLine = line([aTime(oElectrode.(oElectrode.SignalEvents{j}).Index(iBeat)) ...
                             aTime(oElectrode.(oElectrode.SignalEvents{j}).Index(iBeat))], [SignalYMax, SignalYMin]);
                         sLineTag = strcat(sprintf('SignalEventLine%d',oFigure.oParentFigure.SelectedChannel),'_',oElectrode.SignalEvents{j});
                         set(oLine,'Tag',sLineTag,'color', oElectrode.(oElectrode.SignalEvents{j}).Label.Colour, 'parent',oSignalEventPlot, ...
                             'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                         set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
                         %and label the event range with little lines
                         oLine = line([oBasePotential.TimeSeries(oElectrode.(oElectrode.SignalEvents{j}).RangeStart(iBeat)) ...
                             oBasePotential.TimeSeries(oElectrode.(oElectrode.SignalEvents{j}).RangeStart(iBeat))], [...
                             oElectrode.Processed.Data(oElectrode.(oElectrode.SignalEvents{j}).RangeStart(iBeat))+(dHeight*0.01), ...
                             oElectrode.Processed.Data(oElectrode.(oElectrode.SignalEvents{j}).RangeStart(iBeat))-(dHeight*0.01)]);
                         set(oLine,'color', oElectrode.(oElectrode.SignalEvents{j}).Label.Colour, 'parent',oSignalEventPlot, ...
                             'linewidth',3);
                         oLine = line([oBasePotential.TimeSeries(oElectrode.(oElectrode.SignalEvents{j}).RangeEnd(iBeat)) ...
                             oBasePotential.TimeSeries(oElectrode.(oElectrode.SignalEvents{j}).RangeEnd(iBeat))], [...
                             oElectrode.Processed.Data(oElectrode.(oElectrode.SignalEvents{j}).RangeEnd(iBeat))+(dHeight*0.01), ...
                             oElectrode.Processed.Data(oElectrode.(oElectrode.SignalEvents{j}).RangeEnd(iBeat))-(dHeight*0.01)]);
                         set(oLine,'color', oElectrode.(oElectrode.SignalEvents{j}).Label.Colour, 'parent',oSignalEventPlot, ...
                             'linewidth',3);
                         %Label the line with the event time
                         if isfield(oElectrode,'Pacing')
                             %This is a sequence of paced beats so express
                             %the time relative to the pacing index
                             sLabel = num2str((aTime(oElectrode.(oElectrode.SignalEvents{j}).Index(iBeat)) - ...
                                 oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(oElectrode.Pacing.Index(iBeat)))*1000,'% 10.2f');
                         else
                             %Just express the time relative to the start
                             %of the recording
                             sLabel = num2str(aTime(oElectrode.(oElectrode.SignalEvents{j}).Index(iBeat)),'% 10.4f');
                         end
                         oEventLabel = text(TimeMax-dWidth*0.4, SignalYMax - dHeight*j*0.2, sLabel);
                         set(oEventLabel,'color',oElectrode.(oElectrode.SignalEvents{j}).Label.Colour,'FontWeight','bold','FontUnits','points');
                         set(oEventLabel,'FontSize',10);
                         set(oEventLabel,'parent',oSignalEventPlot);
                         set(oFigure.oGuiHandle.(sprintf('rbtnEvent%d',j)),'string',oElectrode.SignalEvents{j});
                         set(oFigure.oGuiHandle.(sprintf('rbtnEvent%d',j)),'visible','on');
                         set(oSlopePlot,'yaxislocation','right');
                         set(oEnvelopePlot,'yaxislocation','right');
                     end
                     if isempty(oFigure.SelectedEventID) && ~isempty(oElectrode.SignalEvents)
                         set(oFigure.oGuiHandle.oEventButtonGroup,'SelectedObject',oFigure.oGuiHandle.rbtnEvent1);
                         oFigure.SelectedEventID = get(oFigure.oGuiHandle.rbtnEvent1,'string');
                     end
                 end
             else
                 %The signal is not accepted so plot it as red
                 %without gradient
                 plot(oSignalPlot,aTime,aData,'-r');
             end
%              set(oSignalPlot,'xlim',[TimeMin TimeMax-0.12]);
%              set(oSlopePlot,'xlim',[TimeMin TimeMax-0.12]);
            
             
             %Create a label that shows the channel name
             oLabel = text(TimeMin,SignalYMax - dHeight*0.1,char(oElectrode.Name));
             set(oLabel,'color','b','FontWeight','bold','FontUnits','points');
             set(oLabel,'FontSize',10);%0.2
             set(oLabel,'parent',oSignalEventPlot);
         end
     end
end
