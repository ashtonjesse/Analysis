classdef BeatPlot < SubFigure
    %   BeatPlot.    
    
    properties
        CurrentEventLine;
        Dragging;
    end
    
    events
        SignalEventRangeChange;
    end
    
    methods
        function oFigure = BeatPlot(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BeatPlot',@OpeningFcn);
            %Add a listener so that the figure knows when a user has
            %made a beat selection
            addlistener(oFigure.oParentFigure,'SlideSelectionChange',@(src,event) oFigure.SelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'ChannelSelected',@(src,event) oFigure.SelectionListener(src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) oFigure.ParentFigureDeleted(src, event));
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Plot data
            oFigure.CreatePlots();
            oFigure.PlotBeat();
            % --- Executes just before BaselineCorrection is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)

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
                
        function oDataCursorOnTool_Callback(oFigure, src, event)
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
        end
        
        function oDataCursorOffTool_Callback(oFigure, src, event)
            %Turn brushing off 
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
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
                %Get the handle to these axes from the panel children
                oPanelChildren = get(oFigure.oGuiHandle.oPanel,'children');
                oAxes = oFigure.oDAL.oHelper.GetHandle(oPanelChildren, 'SignalEventPlot');
                %Get the handle to the line on these axes
                oAxesChildren = get(oAxes,'children');
                oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, oFigure.CurrentEventLine);
                %Get the current event for this channel
                iEvent = oFigure.GetEventNumberFromTag(oFigure.CurrentEventLine);
                %Get the xdata of this line and convert it into a timeseries
                %index
                dXdata = get(oLine, 'XData');
                %Update the signal event for this electrode and beat number
                oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.UpdateSignalEventMark(iChannelNumber, iEvent, oFigure.oParentFigure.SelectedBeat, dXdata(1));
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
             if ~isempty(oElectrode.Processed.CentralDifference)
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
             set(oSignalPlot,'XTick',[],'YTick',[], 'Tag', 'SignalPlot', 'NextPlot', 'replacechildren');
             
             %Get the handle to current envelope plot
             oEnvelopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'EnvelopePlot');
             set(oEnvelopePlot,'XTick',[],'YTick',[], 'Tag', 'EnvelopePlot', 'NextPlot', 'replacechildren');
             cla(oEnvelopePlot);
             
             %Get the handle to current slope plot
             oSlopePlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SlopePlot');
             set(oSlopePlot,'XTick',[],'YTick',[], 'Tag', 'SlopePlot', 'NextPlot', 'replacechildren');
             cla(oSlopePlot);
             
             %Get the handle to current signalevent plot
             oSignalEventPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SignalEventPlot');
             set(oSignalEventPlot,'XTick',[],'YTick',[], 'Tag', 'SignalEventPlot', 'NextPlot', 'replacechildren');
             cla(oSignalEventPlot);
             
             %Plot the data and slope
             if oElectrode.Accepted
                 %If the signal is accepted then plot it as black
                 plot(oSignalPlot,aTime,aData,'-k');
                 
                 if ~isempty(aEnvelope)
                     %Plot the envelope data
                     line(aTime,aEnvelope,'color','b','parent',oEnvelopePlot);
                     axis(oEnvelopePlot,[TimeMin, TimeMax, 1.1*aEnvelopeSubtracted(1), 1.1*aEnvelopeSubtracted(2)]);
                 end
                 
                 %Plot the slope data
                 line(aTime,aSlope,'color','r','parent',oSlopePlot);
                 %Loop through events
                 for j = 1:length(oElectrode.SignalEvent)
                     %Mark the event times with a line
                     oLine = line([aTime(oElectrode.SignalEvent(j).Index(iBeat)) ...
                         aTime(oElectrode.SignalEvent(j).Index(iBeat))], [SignalYMax, SignalYMin]);
                     sLineTag = strcat(sprintf('SignalEventLine%d',iChannelIndex),'_',sprintf('%d',j));
                     set(oLine,'Tag',sLineTag,'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot, ...
                         'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                     set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
                     %Label the line with the event time
                     oEventLabel = text(TimeMax-dWidth*0.4, SignalYMax - dHeight*j*0.2, ...
                         num2str(aTime(oElectrode.SignalEvent(j).Index(iBeat)),'% 10.4f'));
                     set(oEventLabel,'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points');
                     set(oEventLabel,'FontSize',10);
                     set(oEventLabel,'parent',oSignalEventPlot);
                 end
             else
                 %The signal is not accepted so plot it as red
                 %without gradient
                 plot(oSignalPlot,aTime,aData,'-r');
             end
             
             %Set the axis on the plot
             axis(oSignalPlot,[TimeMin, TimeMax, 1.1*SignalYMin, 1.1*SignalYMax]);
             axis(oEnvelopePlot,[TimeMin, TimeMax, 1.1*SlopeYMin, 1.1*SlopeYMax]);
             axis(oSlopePlot,[TimeMin, TimeMax, 1.1*SlopeYMin, 1.1*SlopeYMax]);
             axis(oSignalEventPlot,[TimeMin, TimeMax, 1.1*SignalYMin, 1.1*SignalYMax]);
             
             %Create a label that shows the channel name
             oLabel = text(TimeMin,SignalYMax - dHeight*0.1,char(oElectrode.Name));
             set(oLabel,'color','b','FontWeight','bold','FontUnits','points');
             set(oLabel,'FontSize',10);%0.2
             set(oLabel,'parent',oSignalEventPlot);
         end
     end
end
