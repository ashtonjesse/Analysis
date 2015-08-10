classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
        CurrentZoomLimits = [];
        SelectedChannels;
        SelectedChannel = 2;
        PreviousChannel = 1;
        SelectedBeat = 1;
        SelectedTimePoint = 25;
        SubPlotXdim;
        SubPlotYdim;
        NumberofChannels;
        Dragging;
        Annotate;
        CurrentEventLine;
        sECGAxesContent = 'ECG';
        Plots = [];
        PlotLimits = [];
        SelectedEventID;
        EventFilePath=[];
    end
        
    events
        ChannelSelected;
        FigureDeleted;
        EventMarkChange;
        BeatIndexChange; %beat range
        TimeSelectionChange;
        BeatSelectionChange;
        SignalEventSelectionChange;
        NewSignalEventCreated;
        NewBeatInserted;
        SignalEventLoaded;
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor

            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            
            %Set up beat slider
            oBeatSliderControl = SlideControl(oFigure,'Select Beat', {'BeatSelectionChange','NewBeatInserted'});
            iNumBeats = size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
            set(oBeatSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumBeats, 'Value', 1 ,'SliderStep',[1/iNumBeats  0.02]);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtRight,'string',iNumBeats);
            set(oBeatSliderControl.oGuiHandle.oSliderEdit,'string',1);
            addlistener(oBeatSliderControl,'SlideValueChanged',@(src,event) oFigure.BeatSlideValueListener(src, event));
            
            %Get constants
            oFigure.SubPlotXdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.xDim;
            oFigure.SubPlotYdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.yDim;
            oFigure.NumberofChannels = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels;
            
            %Set callbacks
            set(oFigure.oGuiHandle.bRejectChannel, 'callback', @(src, event)  bAcceptChannel_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oUnusedMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oUnusedMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oUnusedMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oUnusedMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oWindowMenu, 'callback', @(src, event) oUnusedMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMapMenu, 'callback', @(src, event) oMapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oBeatWindowMenu, 'callback', @(src, event) oBeatWindowMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oNewEventMenu, 'callback', @(src, event) oNewEventMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGetSlopeMenu, 'callback', @(src, event) oGetSlopeMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAnnotationMenu, 'callback', @(src, event) oAnnotationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAdjustBeatMenu, 'callback', @(src, event) oAdjustBeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEnvelopeMenu, 'callback', @(src, event) oEnvelopeMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRejectAllMenu, 'callback', @(src, event) oRejectAllChannels_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAcceptAllMenu, 'callback', @(src, event) oAcceptAllChannels_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCentralDifferenceMenu, 'callback', @(src, event) oCentralDifferenceMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bUpdateBeat, 'callback', @(src, event)  bUpdateBeat_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'oncallback', @(src, event) oZoomOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'offcallback', @(src, event) oZoomOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPlotPressureMenu, 'callback', @(src, event) oPlotPressureMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oNormaliseBeatMenu, 'callback', @(src, event) oNormaliseBeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPrintFigureMenu, 'callback', @(src, event) oPrintFigureMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPlotSinusRateMenu, 'callback', @(src, event) oPlotSinusRateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDeleteBeatMenu, 'callback', @(src, event) oDeleteBeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oInsertBeatMenu, 'callback', @(src, event) oInsertBeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveEventMenu, 'callback', @(src, event) oSaveEventMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oLoadEventMenu, 'callback', @(src, event) oLoadEventMenu_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.bInsertBeat, 'callback', @(src, event) bInsertBeat_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bPreviousGroup, 'callback', @(src, event) bPreviousGroup_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %set the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', @(src,event) ThisKeyPressFcn(oFigure, src, event));
            %save the old keypressfcn
            oldKeyPressFcnHook = get(oFigure.oGuiHandle.(oFigure.sFigureTag), 'KeyPressFcn');
            %set zoom callback
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            %disable the listeners hold
            hManager = uigetmodemanager(oFigure.oGuiHandle.(oFigure.sFigureTag));
            set(hManager.WindowListenerHandles,'Enable','off');
            %reset the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', oldKeyPressFcnHook);
           
            %Set default selection
            oFigure.SelectedChannels = 1:length(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes);
            if isfield(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1),'SignalEvent')
                oFigure.SelectedEventID = 1;
            end
            
            %Set annotation on
            oFigure.Annotate = 1;
            %Draw and fill plots
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

                %Set the keypress function for the figure
                
                
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
        
     end
    
     methods (Access = public)
         %% Ui control callbacks
         function ThisKeyPressFcn(oFigure, src, event)
             %Handles key press events
             switch event.Key
                 case 'r'
                     bAcceptChannel_Callback(oFigure, oFigure.oGuiHandle.bRejectChannel, []);
             end
         end
         
         function oFigure = Close_fcn(oFigure, src, event)
             deleteme(oFigure);
         end
         
         function oZoomOnTool_Callback(oFigure, src, event)
             set(oFigure.oZoom,'enable','on');
         end
         
         function oZoomOffTool_Callback(oFigure, src, event)
             set(oFigure.oZoom,'enable','off');
         end
         
         function PostZoom_Callback(oFigure, src, event)
             %Synchronize the zoom of electrode and ECG axes
             
             %Get the current axes and selected limit
             oFigure.GetZoomLimits(event.Axes);
             oFigure.ApplyZoomLimits('XLim');
             oFigure.ApplyZoomLimits('YLim');
         end
         
         function ApplyZoomLimits(oFigure,sAxis)
             %Apply to axes
             switch (sAxis)
                 case 'XLim'
                     set(oFigure.oGuiHandle.oElectrodeAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
                     set(oFigure.oGuiHandle.oECGAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
                 case 'YLim'
                     set(oFigure.oGuiHandle.oECGAxes,'YLim',oFigure.CurrentZoomLimits(2,:));
             end
         end
         
         function GetZoomLimits(oFigure, oAxes)
             %Get the zoom limits for the specified axes
             oXLim = get(oAxes,'XLim');
             oYLim = get(oAxes,'YLim');
             oFigure.CurrentZoomLimits = [oXLim ; oYLim];
         end
         
         function StartDrag(oFigure, src, event)
             %The function that fires when a line on a subplot is dragged
             oFigure.Dragging = 1;
             oPlot = get(src,'Parent');
             oFigure.CurrentEventLine = get(src,'tag');
             oFigure.SelectedChannel = oFigure.oDAL.oHelper.GetDoubleFromString(get(oPlot,'tag'));
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
                 iChannelNumber = oFigure.SelectedChannel;
                 iBeat = oFigure.SelectedBeat;
                 notify(oFigure,'ChannelSelected',DataPassingEvent([],iChannelNumber));
                 %Get the handle to these axes from the panel children
                 oPanelChildren = get(oFigure.oGuiHandle.pnSignals,'children');
                 oAxes = findobj(oPanelChildren, 'tag', sprintf('SignalEventPlot%d',iChannelNumber));
                 %Get the handle to the line on these axes
                 oAxesChildren = get(oAxes,'children');
                 oLine = findobj(oAxesChildren, 'tag', oFigure.CurrentEventLine);
                 %Get the current event for this channel
                 iEvent = oFigure.GetEventNumberFromTag(oFigure.CurrentEventLine);
                 %Get the xdata of this line and convert it into a timeseries
                 %index
                 dXdata = get(oLine, 'XData');
                 %Reset the range for this event to the beat indexes as the
                 %user is manually changing the event time
                 oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateEventRange(iEvent, iBeat, iChannelNumber, ...
                     [0 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,2) - ...
                     oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,1)]);
                 %Update the signal event for this electrode and beat number
                 oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateSignalEventMark(iChannelNumber, iEvent, oFigure.SelectedBeat, dXdata(1));
                 aPassData = {iChannelNumber, iEvent, oFigure.SelectedBeat, dXdata(1)};
                 notify(oFigure,'EventMarkChange',DataPassingEvent(aPassData,[]));
                 %Refresh the plot
                 oFigure.Replot(iChannelNumber);
             end
         end
         
         function Drag(oFigure, src, event)
             %The function that fires while a line on a subplot is being
             %dragged
             oAxesChildren = get(event.ParentAxesHandle,'children');
             oLine = findobj(oAxesChildren, 'tag', oFigure.CurrentEventLine);
             oPoint = get(event.ParentAxesHandle, 'CurrentPoint');
             set(oLine, 'XData', oPoint(1)*[1 1]);
         end
         
         function oSignalEventPlot_Callback(oFigure, src, event)
             oFigure.PreviousChannel = oFigure.SelectedChannel;
             oFigure.SelectedChannel = oFigure.oDAL.oHelper.GetDoubleFromString(get(src,'tag'));
             notify(oFigure,'ChannelSelected',DataPassingEvent([],oFigure.SelectedChannel));
             oFigure.Replot(oFigure.SelectedChannel);
         end
         
         function oElectrodePlot_Callback(oFigure, src, event)
             oPoint = get(src,'currentpoint');
             xDim = oPoint(1,1);
             iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(oFigure.SelectedChannel,xDim);
             %Notify listeners so that the selected beat can be propagated
             %and update the Slide Control
             oFigure.SelectedBeat = iBeatIndexes{1,1};
             notify(oFigure,'BeatSelectionChange',DataPassingEvent([1 size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1)],iBeatIndexes{1,1}));
             oFigure.Replot();
         end
         
         function bAcceptChannel_Callback(oFigure,src,event)
             ButtonState = get(oFigure.oGuiHandle.bRejectChannel,'Value');
             if ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Max')
                 % Toggle button is pressed
                 oFigure.oParentFigure.oGuiHandle.oUnemap.RejectChannel(oFigure.SelectedChannel);
                 notify(oFigure,'ChannelSelected');
             elseif ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Min')
                 % Toggle button is not pressed
                 oFigure.oParentFigure.oGuiHandle.oUnemap.AcceptChannel(oFigure.SelectedChannel);
                 notify(oFigure,'ChannelSelected');
             end
             oFigure.Replot(oFigure.SelectedChannel);
         end
         
         function oRejectAllChannels_Callback(oFigure,src,event)
             %Reject all selected channels
             for i = 1:length(oFigure.SelectedChannels)
                 oFigure.oParentFigure.oGuiHandle.oUnemap.RejectChannel(oFigure.SelectedChannels(i));
             end
             oFigure.Replot();
         end
         
         function oAcceptAllChannels_Callback(oFigure,src,event)
             %Reject all selected channels
             for i = 1:length(oFigure.SelectedChannels)
                 oFigure.oParentFigure.oGuiHandle.oUnemap.AcceptChannel(oFigure.SelectedChannels(i));
             end
             oFigure.Replot();
         end
         
         function bInsertBeat_Callback(oFigure, src, event)
             %Insert a new beat 
             
             % Find any brushline objects associated with the ElectrodeAxes
             hBrushLines = findall(oFigure.oGuiHandle.oElectrodeAxes,'tag','Brushing');
             % Get the Xdata and Ydata attitributes of this
             brushedData = get(hBrushLines, {'Xdata','Ydata'});
             % The data that has not been selected is labelled as NaN so get
             % rid of this
             if ~isempty(brushedData)
                 brushedIdx = ~isnan([brushedData{1,1}]);
                 [row, colIndices] = find(brushedIdx);
                 if ~isempty(colIndices)
                     aBeatIndexes = [colIndices(1) colIndices(end)];
                     dStartTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aBeatIndexes(1));
                     oFigure.oParentFigure.oGuiHandle.oUnemap.InsertNewBeat(oFigure.SelectedBeat,aBeatIndexes);
                 else
                     %Reset the gui
                     brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
                     set(oFigure.oGuiHandle.bInsertBeat, 'visible', 'off');
                     oFigure.Replot();
                     error('AnalyseSignals.bInsertBeat_Callback:NoSelectedData', 'You need to select data');
                 end
             else
                 %Reset the gui
                 brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
                 set(oFigure.oGuiHandle.bInsertBeat, 'visible', 'off');
                 oFigure.Replot();
                 error('AnalyseSignals.bInsertBeat_Callback:NoSelectedData', 'You need to select data');
             end
             %Reset the gui
             brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
             set(oFigure.oGuiHandle.bInsertBeat, 'visible', 'off');
             oFigure.Replot();
             notify(oFigure,'NewBeatInserted', DataPassingEvent([1, size( ...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1)], oFigure.SelectedBeat));
         end
         
         function bPreviousGroup_Callback(oFigure, src, event)
             %-------Not implemented right now as no way of easily
             %selecting channels based on location
             
             %Select the previous group of channels - where group is
             %defined by the x and y dimensions specified in the experiment
             %metadata

             %Find the min channel currently selected
             iCornerChannel = min(oFigure.SelectedChannels);
             if iCornerChannel < (oFigure.SubPlotXdim*oFigure.SubPlotYdim)
                 %Stay at the start
                 oFigure.SelectedChannels = 1:oFigure.SubPlotXdim*oFigure.SubPlotYdim;
             else
                 %Move to the previous group
                 oFigure.SelectedChannels = (iCornerChannel - oFigure.SubPlotXdim*oFigure.SubPlotYdim):(iCornerChannel - 1);
             end
             %replot
             oFigure.Replot();
         end
         
          function bUpdateBeat_Callback(oFigure, src, event)
             %Update the currently selected beat
             
             % Find any brushline objects associated with the ElectrodeAxes
             hBrushLines = findall(oFigure.oGuiHandle.oElectrodeAxes,'tag','Brushing');
             % Get the Xdata and Ydata attitributes of this
             brushedData = get(hBrushLines, {'Xdata','Ydata'});
             % The data that has not been selected is labelled as NaN so get
             % rid of this
             if ~isempty(brushedData)
                 brushedIdx = ~isnan([brushedData{1,1}]);
                 [row, colIndices] = find(brushedIdx);
                 if ~isempty(colIndices)
                     aBeatIndexes = [colIndices(1) colIndices(end)];
                     dStartTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aBeatIndexes(1));
                     %                      aNewBeat = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(oFigure.SelectedChannel,dStartTime);
                     %                      oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateBeatIndexes(aNewBeat{1,1},aBeatIndexes);
                     oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateBeatIndexes(oFigure.SelectedBeat,aBeatIndexes);
                 else
                     %Reset the gui
                     brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
                     set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
                     oFigure.Replot();
                     notify(oFigure,'BeatIndexChange');
                     error('AnalyseSignals.bUpdateBeat_Callback:NoSelectedData', 'You need to select data');
                 end
             else
                 %Reset the gui
                 brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
                 set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
                 oFigure.Replot();
                 notify(oFigure,'BeatIndexChange');
                 error('AnalyseSignals.bUpdateBeat_Callback:NoSelectedData', 'You need to select data');
             end
             %Reset the gui
             brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
             set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
             oFigure.Replot();
             notify(oFigure,'BeatIndexChange');
          end
         
         %% Event listeners
         function ChannelSelectionChange(oFigure,src,event)
             %An event listener callback
             %Is called when the user selects a new set of channels and hits
             %the update selection menu option in MapElectrodes.fig
             %Draw plots
             oFigure.SelectedChannels = event.ArrayData;
             %Fill plots
             oFigure.Replot();
             
         end
         
         function ElectrodeSelected(oFigure, src, event)
             oFigure.PreviousChannel = oFigure.SelectedChannel;
             oFigure.SelectedChannel = event.Value;
             notify(oFigure,'ChannelSelected',DataPassingEvent([],oFigure.SelectedChannel));
             oFigure.Replot(oFigure.SelectedChannel);
         end
         
         function SignalEventRangeListener(oFigure,src, event)
             oFigure.Replot();
         end
         
         function SignalEventDeleted(oFigure,src,event)
             oFigure.Replot();
         end
         
         function SignalEventSelected(oFigure, src, event)
             %Pass on notification
             oFigure.SelectedEventID = event.Value;
             oFigure.Replot();
             notify(oFigure,'SignalEventSelectionChange',DataPassingEvent([],event.Value));
         end
         
         function SignalEventMarkChange(oFigure, src, event)
             %Replot just the specified channel
             oFigure.Replot(event.Value);
         end
         
         function BeatSlideValueListener(oFigure,src,event)
             %An event listener callback
             %Is called when the user selects a new beat using the
             %SlideControl
             oFigure.SelectedBeat = event.Value;
             notify(oFigure,'BeatSelectionChange',DataPassingEvent([1 size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1)],oFigure.SelectedBeat));
             oFigure.Replot();
             
         end
         
         function TimeSlideValueListener(oFigure, src, event)
             %An event listener callback
             %Is called when the user selects a new time point using the
             %SlideControl
             %Save the value and pass on the event notification
             oFigure.SelectedTimePoint = event.Value;
             iBeatLength = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,2) - ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,1);
             notify(oFigure,'TimeSelectionChange', DataPassingEvent([1 iBeatLength],oFigure.SelectedTimePoint));
         end
         
         %% Event Callbacks --------------------------------------
         function SubtractEnvelope(oFigure,src,event)
             %Carries out an envelope subtraction neighbourhood action
             
             %Get the rows and cols
             iRows = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_1');
             iCols = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_2');
             %Set up inputs
             aInOptions = struct();
             aInOptions.Procedure = 'SignalEnvelopeSubtraction';
             aInOptions.KernelBounds = [iRows iCols];
             oFigure.oParentFigure.oGuiHandle.oUnemap.ApplyNeighbourhoodAverage(aInOptions);
         end
         
         function NewEventCreated(oFigure,src,event)
             %Get the values from the mixedcontrol
             switch (char(event.Values{5}))
                 case 'CurrentElectrode'
                     aElectrodes = oFigure.SelectedChannel;
                 case 'SelectedElectrodes'
                     aElectrodes = oFigure.SelectedChannels;
                 case 'AllElectrodes'
                     aElectrodes = 1:length(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes);
             end
             switch (char(event.Values{4}))
                 case 'AllBeats'
                     for i = 1:length(aElectrodes);
                         iChannel = aElectrodes(i);
                         oFigure.oParentFigure.oGuiHandle.oUnemap.CreateNewEvent(iChannel, char(event.Values{1}), char(event.Values{2}), char(event.Values{3}));
                     end
                 case 'SingleBeat'
                     iBeat = oFigure.SelectedBeat;
                     for i = 1:length(aElectrodes);
                         iChannel = aElectrodes(i);
                         oFigure.oParentFigure.oGuiHandle.oUnemap.CreateNewEvent(iChannel, char(event.Values{1}), char(event.Values{2}), char(event.Values{3}), iBeat);
                     end
             end
             oFigure.Replot();
             notify(oFigure,'NewSignalEventCreated');
         end
         
           %% Menu Callbacks
         function oUnusedMenu_Callback(oFigure, src, event)
             
         end
         
         function oMapMenu_Callback(oFigure, src, event)
            %Open a electrode map plot
            oMapElectrodesFigure = MapElectrodes(oFigure,oFigure.SubPlotXdim,oFigure.SubPlotYdim);
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oMapElectrodesFigure,'ChannelGroupSelection',@(src,event) oFigure.ChannelSelectionChange(src, event));
            addlistener(oMapElectrodesFigure,'ElectrodeSelected',@(src,event) oFigure.ElectrodeSelected(src, event));
            addlistener(oMapElectrodesFigure,'SaveButtonPressed',@(src,event) oFigure.oSaveEventMenu_Callback(src, event));
            addlistener(oMapElectrodesFigure,'BeatChange',@(src,event) oFigure.BeatSlideValueListener(src, event));
         end
         
         function oBeatWindowMenu_Callback(oFigure, src, event)
            %Open a beat plot
            oBeatPlotFigure = BeatPlot(oFigure);
            addlistener(oBeatPlotFigure,'SignalEventRangeChange',@(src,event) oFigure.SignalEventRangeListener(src, event));
            addlistener(oBeatPlotFigure,'SignalEventDeleted',@(src,event) oFigure.SignalEventDeleted(src,event));
            addlistener(oBeatPlotFigure,'SignalEventSelected',@(src,event) oFigure.SignalEventSelected(src,event));
            addlistener(oBeatPlotFigure,'SignalEventMarkChange',@(src,event) oFigure.SignalEventMarkChange(src,event));
            addlistener(oBeatPlotFigure,'TimePointChange',@(src,event) oFigure.TimeSlideValueListener(src,event));
            
            %Open a time point slider
            oTimeSliderControl = SlideControl(oFigure,'Select Time Point',{'TimeSelectionChange'});
            iBeatLength = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,2) - ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,1);
            set(oTimeSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iBeatLength, 'Value', oFigure.SelectedTimePoint,'SliderStep',[1/iBeatLength  0.02]);
            set(oTimeSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oTimeSliderControl.oGuiHandle.oSliderTxtRight,'string',iBeatLength);
            set(oTimeSliderControl.oGuiHandle.oSliderEdit,'string',oFigure.SelectedTimePoint);
            addlistener(oTimeSliderControl,'SlideValueChanged',@(src,event) oFigure.TimeSlideValueListener(src, event));
         end
         
         function oNewEventMenu_Callback(oFigure, src, event)
             aControlData = cell(4,1);
             aControlData{1} = {'r','g','b','k','c','m','y'};
             aControlData{2} = {'Activation','Repolarisation'};
             aControlData{3} = {'SteepestPositiveSlope','SteepestNegativeSlope','CentralDifference','MaxSignalMagnitude'};
             aControlData{4} = {'SelectedBeat','AllBeats'};
             aControlData{5} = {'CurrentElectrode','SelectedElectrodes','AllElectrodes'};
             oMixedControl = MixedControl(oFigure,'Enter the label colour, event type, marking technique, beat selection and electrode selection for the new event.',aControlData);
             addlistener(oMixedControl,'ValuesEntered',@(src,event) oFigure.NewEventCreated(src, event));

         end
         
         function oMaxSpatialMenu_Callback(oFigure, src, event)
             oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('CentralDifference',oFigure.SelectedBeat);
             oFigure.Replot();
         end
         
         function oReMenu_Callback(oFigure, src, event)
             oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('MaxSignalMagnitude',oFigure.SelectedBeat);
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
         
         function oCentralDifferenceMenu_Callback(oFigure, src, event)
             %Set up inputs
             aInOptions = struct();
             aInOptions.Procedure = 'CentralDifference';
             aInOptions.KernelBounds = [3 3];
             oFigure.oParentFigure.oGuiHandle.oUnemap.ApplyNeighbourhoodAverage(aInOptions);
         end
         
         function oPlotPressureMenu_Callback(oFigure, src, event)
             %Plot pressure on the ECG axes
             oFigure.sECGAxesContent = 'Pressure';
             oFigure.PlotPressure();
             oFigure.GetZoomLimits(oFigure.oGuiHandle.oElectrodeAxes);
             oFigure.ApplyZoomLimits('XLim');
         end
         
         function oPlotSinusRateMenu_Callback(oFigure, src, event)
             %Plot pressure on the ECG axes
             oFigure.sECGAxesContent = 'SinusRate';
             oFigure.PlotSinusRate();
             oFigure.GetZoomLimits(oFigure.oGuiHandle.oElectrodeAxes);
             oFigure.ApplyZoomLimits('XLim');
         end
         
         function oDeleteBeatMenu_Callback(oFigure, src, event)
             %Delete the currently selected beat
             oFigure.oParentFigure.oGuiHandle.oUnemap.DeleteBeat(oFigure.SelectedBeat);
             oFigure.oParentFigure.oGuiHandle.oECG.DeleteBeat(oFigure.SelectedBeat);
             oFigure.SelectedBeat = 1;
             oFigure.Replot();
             notify(oFigure,'BeatIndexChange');
         end
         
         function oNormaliseBeatMenu_Callback(oFigure, src, event)
             %Carry out normalisation of the potential values of the selected beat
             oFigure.oParentFigure.oGuiHandle.oUnemap.NormaliseBeat(oFigure.SelectedBeat);
             oFigure.Replot();
         end
         
         function oPrintFigureMenu_Callback(oFigure, src, event)
             %Get the save file path
             %Call built-in file dialog to select filename
             [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
             %Make sure the dialogs return char objects
             if (~ischar(sFilename) && ~ischar(sPathName))
                 return
             end
             sLongDataFileName=strcat(sPathName,sFilename,'.bmp');
             oFigure.PrintFigureToFile(sLongDataFileName);
         end
         
         function oInsertBeatMenu_Callback(oFigure, src, event)
             brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
             brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
             set(oFigure.oGuiHandle.bInsertBeat, 'visible', 'on');
         end
         
         function oSaveEventMenu_Callback(oFigure, src, event)
             if isempty(event) && ~isempty(oFigure.SelectedEventID)
                 %the event has been called from the menu so open a file
                 %save dialog
                 %choose location to save to
                 [sDataFileName,sDataPathName]=uiputfile('*.txt','Select a location for the event text file');
                 %Make sure the dialogs return char objects
                 if (~ischar(sDataFileName))
                     return
                 end
                 
                 %Get the full file name
                 oFigure.EventFilePath = strcat(sDataPathName,sDataFileName);
                 %save the event
                 oFigure.SaveEvent(oFigure.EventFilePath);
             elseif ~isempty(event) && ~isempty(oFigure.SelectedEventID)
                 %save the value passed in the event
                 oFigure.EventFilePath = char(event.Value);
                 %save the event
                 oFigure.SaveEvent(oFigure.EventFilePath);
             end
         end
         
         function oLoadEventMenu_Callback(oFigure, src, event)
             %load data from text file and save to appropriate locations in
             %oUnemap structure
             %Call built-in file dialog to select filename
             [sDataFileName,sDataPathName]=uigetfile('*.txt','Select a file containing signal event indexes and ranges');
             %Make sure the dialogs return char objects
             if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                 return
             end
             
             %Get the full file name
             sLongDataFileName=strcat(sDataPathName,sDataFileName);
             %Read the data in to the appropriate location in oUnemap
             oFigure.oParentFigure.oGuiHandle.oUnemap.oDAL.GetSignalEventInformationFromTextFile(...
                 oFigure.oParentFigure.oGuiHandle.oUnemap,oFigure.SelectedEventID,sLongDataFileName);
             %refresh analysesignals and mapelectrodes figures
             oFigure.PlotBeat();
             notify(oFigure,'SignalEventLoaded',DataPassingEvent([],oFigure.SelectedEventID));
             fprintf('Loaded event file at %s\n', sLongDataFileName);
         end
         
         %% Misc
         function iEventNumber = GetEventNumberFromTag(oFigure, sTag)
             %Find the event number specified by the input handle tag
             [~,~,~,~,~,~,splitstring] = regexpi(sTag,'_');
             iEventNumber = str2double(char(splitstring(1,2)));
         end
         
         function iChannel = GetChannelFromTag(oFigure, sTag)
             %Find the channel specified by the input handle tag
             [~,~,~,~,~,~,splitstring] = regexpi(sTag,'_');
             iChannel = str2double(char(splitstring(1,1)));
         end
         
         function Replot(oFigure,varargin)
             %Make sure the current figure is AnalyseSignals
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %              oWaitbar = waitbar(0,'Please wait...');
             if isempty(varargin)
                 oFigure.PlotBeatOrElectrode();
             else
                 oFigure.PlotBeatOrElectrode(varargin);
             end
             
             oFigure.PlotWholeRecord();
             switch (oFigure.sECGAxesContent)
                 case 'ECG'
                     oFigure.PlotECG();
                 case 'Pressure'
                     oFigure.PlotPressure();
             end
             oFigure.GetZoomLimits(oFigure.oGuiHandle.oElectrodeAxes);
             oFigure.ApplyZoomLimits('XLim');
             oFigure.CheckRejectToggleButton();
             %              close(oWaitbar);
         end
         
         function SaveEvent(oFigure, sFilePath)
             %get the beat indexes and activation times to save
             aSignalEvents = oFigure.oDAL.oHelper.MultiLevelSubsRef(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes,'SignalEvent','Index',oFigure.SelectedEventID);
             oDataToWrite = horzcat(aSignalEvents,oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).SignalEvent(oFigure.SelectedEventID).Range);
            
             %build header cell array
             aRowHeader = cell2mat({oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(:).Name});
             aRowHeader = reshape(aRowHeader,5,size(aSignalEvents,2));
             aRowHeader = cellstr(aRowHeader');
             aRowHeader{size(aSignalEvents,2)+1} = 'LowerRange';
             aRowHeader{size(aSignalEvents,2)+2} = 'UpperRange';
             %save data to txt file
             FID = oFigure.oDAL.oHelper.ExportDataToTextFile(sFilePath,aRowHeader,oDataToWrite,'%6.0u,');
             fprintf('Event file saved successfully to %s\n', sFilePath);
         end
     end
     
     methods (Access = private)
         function CheckRejectToggleButton(oFigure)
             if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannel).Accepted
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',0);
             else
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',1);
             end
         end
         
         function PlotBeat(oFigure)
             %Create the space for the subplot that will contain all the
             %signals
             
             %Get the plot data
             oDataToPlot = oFigure.oParentFigure.oGuiHandle.oUnemap.GetDataForPlotting(oFigure.SelectedBeat, oFigure.SelectedChannels);
             %Get the plotting limits from this data
             oFigure.PlotLimits = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPlotLimits(oDataToPlot, oFigure.SelectedChannels);
             
             %Find the bounds of the selected area
             %Get the list of locations
             aLocations = MultiLevelSubsRef(oFigure.oDAL.oHelper,oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannels),'Location');
             [C, iMinChannel] = min(sum(aLocations,1));
             [C, iMaxChannel] = max(sum(aLocations,1));
             %Convert into row and col indices
             aMinLocation = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannels(iMinChannel)).Location;
             aMaxLocation = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannels(iMaxChannel)).Location;
             %Divide up the space for the subplots
             xDiv = 1/(aMaxLocation(1)-aMinLocation(1)+1);
             yDiv = 1/(aMaxLocation(2)-aMinLocation(2)+1);
             
             %Set number of plots per channel
             if ~isempty(oFigure.PlotLimits.Envelope)
                 iNumberOfPlots = 4;
             else
                 iNumberOfPlots = 3;
             end
             %initialise aChannelsWithPlots
             aChannelsWithPlots = [];
             if ~isempty(oFigure.Plots)
                 aChannelsWithPlots = cell2mat({oFigure.Plots(:).Channel});
             end
             %get time series
             aTimeSeries = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries;
             for i = 1:size(oFigure.SelectedChannels,2);
                 iChannel = oFigure.SelectedChannels(i);
                 iRow = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Location(1);
                 iCol = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Location(2);
                 %Normalise the row and columns to the minimum.
                 iRow = iRow - aMinLocation(1);
                 iCol = iCol - aMinLocation(2);
                 %Create the position vector for the next plot
                 aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
                 %check if this is the first time through
                 if isempty(aChannelsWithPlots)
                     %Create new axes
                     aIndices = oFigure.ArrangeSubPlots(1, iChannel, aPosition, [], oDataToPlot(i), iNumberOfPlots);
                     
                 else
                     %Use those that have been created already and add more
                     %where necessary
                     aIndices = logical(aChannelsWithPlots==oFigure.SelectedChannels(i));
                     %check if this returned anything (there is overlap
                     %with the old selection).
                     if max(aIndices) > 0
                         %This channel already has associated plots
                         oPlotHandles = cell2mat({oFigure.Plots(aIndices).Handle});
                         aIndices = oFigure.ArrangeSubPlots(0, iChannel, aPosition, oPlotHandles, oDataToPlot(i), iNumberOfPlots);
                     else
                         %Arrange a new plot
                         aIndices = oFigure.ArrangeSubPlots(1, iChannel, aPosition, [] , oDataToPlot(i), iNumberOfPlots);
                     end
                 end
                 %Plot the electrode
                 oFigure.Plots(aIndices) = oFigure.PlotElectrode(oFigure.SelectedChannels(i),oFigure.Plots(aIndices),aTimeSeries);
             end
             
             %find the plots that will not be needed
             aPlotIndexes = ~ismember(aChannelsWithPlots,oFigure.SelectedChannels);
             if max(aPlotIndexes) > 0
                 oPlotsToHide = oFigure.Plots(aPlotIndexes);
                 set(cell2mat({oPlotsToHide(:).Handle}),'visible','off');
                 for j = 1:length(oPlotsToHide)
                     set(oPlotsToHide(j).Children,'visible','off');
                 end
             end
         end
         
         function aPlotNumbers = ArrangeSubPlots(oFigure, bCreateNewAxes, iChannelIndex, aPosition, aHandles, oDataToPlot, iNumberOfPlots)
             %Initialise output
             aPlotNumbers = zeros(4,1);
             %Check if new axes have to be created
             aPlotNumbers(1,1) = (iChannelIndex-1)*iNumberOfPlots+1;
             aPlotNumbers(2,1) = (iChannelIndex-1)*iNumberOfPlots+2;
             if bCreateNewAxes
                 %create the data plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Signal%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Data, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+1);
                 %create the slope plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Slope%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Slope, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Slope, (iChannelIndex-1)*iNumberOfPlots+2);
                 if ~isempty(oFigure.PlotLimits.Envelope)
                     %create the envelope plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Envelope%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Envelope, ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Envelope, (iChannelIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iChannelIndex-1)*iNumberOfPlots+3;
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), 0, [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+4);
                     aPlotNumbers(4,1) = (iChannelIndex-1)*iNumberOfPlots+4;
                 else
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), 0, [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iChannelIndex-1)*iNumberOfPlots+3;
                     aPlotNumbers = aPlotNumbers(1:3,1);
                 end
             else
                 %use the handles specified in aHandles
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Signal%d',iChannelIndex), aHandles(1), oDataToPlot.Time, oDataToPlot.Data, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+1);
                 %create the slope plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Slope%d',iChannelIndex), aHandles(2), oDataToPlot.Time, oDataToPlot.Slope, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Slope, (iChannelIndex-1)*iNumberOfPlots+2);
                 if ~isempty(oFigure.PlotLimits.Envelope)
                     %create the envelope plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Envelope%d',iChannelIndex), aHandles(3), oDataToPlot.Time, oDataToPlot.Envelope, ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Envelope, (iChannelIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iChannelIndex-1)*iNumberOfPlots+3;
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), aHandles(4), [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+4);
                     aPlotNumbers(4,1) = (iChannelIndex-1)*iNumberOfPlots+4;
                 else
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), aHandles(3), [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iChannelIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iChannelIndex-1)*iNumberOfPlots+3;
                     aPlotNumbers = aPlotNumbers(1:3,1);
                 end
             end
             
         end
         
         function SetAxes(oFigure, iChannelIndex, aPosition, sTag, oHandle, xData, yData, xLim, yLim, iPlotNumber)
             %Create axes  in the position specified for Signal
             %data
             if oHandle > 0
                 %Use old ones
                 set(oHandle,'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none', ...
                     'Tag', sTag, 'xlim', xLim, 'ylim', yLim);
                 oFigure.Plots(iPlotNumber).Handle = oHandle;
                 set(oHandle,'visible','on');
             else
                 oPlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[], 'color','none', ...
                     'Tag', sTag, 'xlim', xLim, 'ylim', yLim);
                 oFigure.Plots(iPlotNumber).Handle = oPlot;
                 oFigure.Plots(iPlotNumber).Children = zeros(1,1);
             end
             
             %Save the plot data
             oFigure.Plots(iPlotNumber).xData =  xData;
             oFigure.Plots(iPlotNumber).yData =  yData;
             oFigure.Plots(iPlotNumber).Channel =  iChannelIndex;
         end
         
         function PlotBeatOrElectrode(oFigure,varargin)
             %Plot the beats for the selected channels in the subplot
             
             %Check if an electrode number was supplied
             if isempty(varargin)
                 %Arrange the plots
                 oFigure.PlotBeat();
             elseif nargin == 2
                 %Replot the specified electrode and the previously
                 %selected electrode
                 aTimeSeries = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries;
                 if max(ismember(oFigure.SelectedChannels,oFigure.SelectedChannel))
                     %if the selected channel is part of the selected
                     %channels array then replot it
                     iChannelIndex = varargin{1}{1}(1);
                     aIndices = logical(cell2mat({oFigure.Plots(:).Channel})==iChannelIndex);
                     oFigure.PlotElectrode(iChannelIndex,oFigure.Plots(aIndices),aTimeSeries);
                 end
                 if max(ismember(oFigure.SelectedChannels,oFigure.PreviousChannel))
                     %replot the previous channel as well
                     aIndices = logical(cell2mat({oFigure.Plots(:).Channel})==oFigure.PreviousChannel);
                     oFigure.PlotElectrode(oFigure.PreviousChannel,oFigure.Plots(aIndices),aTimeSeries);
                 end
             end
             
         end
         
         function oOutPlots = PlotElectrode(oFigure,iChannelIndex,oPlots,aTimeSeries)
             
             %Get these values so that we can place text in the
             %right place
             dWidth = oFigure.PlotLimits.Time(2) - oFigure.PlotLimits.Time(1);
             dHeight = oFigure.PlotLimits.Data(2) - oFigure.PlotLimits.Data(1);
             iBeat = oFigure.SelectedBeat;
             %Get the handle to current signal plot and rename it (the name
             %is not propagated)
             set(oPlots(1).Handle,'Tag',sprintf('Signal%d',iChannelIndex),'nextplot','replace');
             %Repeat for the slope plot
             set(oPlots(2).Handle,'Tag', sprintf('Slope%d',iChannelIndex),'nextplot','replace');
             
             %Get electrode
             oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelIndex);
             
             %Recall the other plots depending on if an envelopeplot has
             %been created/set
             if ~isempty(oFigure.PlotLimits.Envelope)
                 set(oPlots(3).Handle, 'Tag',sprintf('Envelope%d',iChannelIndex),'nextplot','replace');
                 set(oPlots(4).Handle,'Tag', sprintf('SignalEventPlot%d',iChannelIndex),'nextplot','replace');
                 oSignalEventPlot = oPlots(4);
             else
                 set(oPlots(3).Handle,'Tag', sprintf('SignalEventPlot%d',iChannelIndex),'nextplot','replace');
                 oSignalEventPlot = oPlots(3);
             end
             %Initialise signalevent index
             j = 0;
             %Plot the data and slope
             %If the signal is accepted then plot it as black
             if oPlots(1).Children(1) > 0
                 %replace the data for the line child
                 set(oPlots(1).Children(1), 'XData', oPlots(1).xData, 'YData', oPlots(1).yData,'color','k','parent',oPlots(1).Handle, 'visible', 'on');
             else
                 %The first child is the data line
                 oPlots(1).Children(1) = line(oPlots(1).xData,oPlots(1).yData,'color','k','parent',oPlots(1).Handle);
             end
             
             %Plot the slope data
             if oPlots(2).Children > 0
                 %replace the data for the line child
                 set(oPlots(2).Children(1), 'XData', oPlots(2).xData, 'YData', oPlots(2).yData,'color','r','parent',oPlots(2).Handle, 'visible', 'on');
             else
                 %The first child is the slope line
                 oPlots(2).Children(1) = line(oPlots(2).xData,oPlots(2).yData,'color','r','parent',oPlots(2).Handle);
             end
             
             if ~isempty(oFigure.PlotLimits.Envelope)
                 %Plot the envelope data
                 if oPlots(3).Children > 0
                     %replace the data for the line child
                     set(oPlots(3).Children(1), 'XData', oPlots(3).xData, 'YData', oPlots(3).yData,'color','b','parent',oPlots(3).Handle, 'visible', 'on');
                 else
                     oPlots(3).Children(1) = line(oPlots(3).xData,oPlots(3).yData,'color','b','parent',oPlots(3).Handle);
                 end
             end
             
             %Plot the signal events if there are any
             if isfield(oElectrode,'SignalEvent')
                 %Initialise children array if needed
                 if length(oSignalEventPlot.Children) == 1
                     if oSignalEventPlot.Children(1) > 0
                         %If a child has already been loaded then save this
                         %handle and put it back into the children array
                         oHandle = oSignalEventPlot.Children(1);
                     else
                         oHandle = 0;
                     end
                     %a line and a label per event plus a channel label
                     oSignalEventPlot.Children = zeros(length(oElectrode.SignalEvent)*2 + 1,1);
                     oSignalEventPlot.Children(1) = oHandle;
                 elseif (length(oSignalEventPlot.Children)) < (length(oElectrode.SignalEvent)*2 + 1)
                     %Another event has been created so add a line and a label per event 
                     oSignalEventPlot.Children = [oSignalEventPlot.Children ; 0 ; 0];
                 elseif (length(oSignalEventPlot.Children)) > (length(oElectrode.SignalEvent)*2 + 1)
                     %Events have been deleted so loop through and hide
                     %children not required
                     for m = (length(oElectrode.SignalEvent)*2 + 1):length(oSignalEventPlot.Children)
                         set(oSignalEventPlot.Children(m),'visible','off');
                     end
                 end
                 %Loop through events
                 for j = 1:length(oElectrode.SignalEvent)
                     %Mark the event times with a line
                     %Get the time index to use (closest to that
                     %recorded)
                     aTimeDiff = abs(oPlots(2).xData - aTimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                         oElectrode.SignalEvent(j).Index(iBeat)-1));
                     [C iEventIndex] = min(aTimeDiff);
                     %sLineTag = strcat(sprintf('SignalEventLine%d',iChannelIndex),'_',sprintf('%d',j));
                     %Check if there has been a handle created for the
                     %line
                     if oSignalEventPlot.Children((j-1)*2+2) > 0
                         %already exists so just set properties
                         set(oSignalEventPlot.Children((j-1)*2+2),'XData',[oPlots(2).xData(iEventIndex) ...
                             oPlots(2).xData(iEventIndex)], 'YData', [oFigure.PlotLimits.Data(2), oFigure.PlotLimits.Data(1)], ...
                             'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot.Handle, 'linewidth',2, 'visible', 'on');
                     else
                         %create a line
                         oSignalEventPlot.Children((j-1)*2+2) = line('XData', [oPlots(2).xData(iEventIndex) ...
                             oPlots(2).xData(iEventIndex)], 'YData', [oFigure.PlotLimits.Data(2), oFigure.PlotLimits.Data(1)], ...
                             'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot.Handle, 'linewidth',2);
                     end
                     %Label the line with the event time
                     if isfield(oElectrode,'Pacing')
                         %This is a sequence of paced beats so express
                         %the time relative to the pacing index
                         sLabel = num2str((aTimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                             oElectrode.SignalEvent(j).Index(iBeat)-1) - aTimeSeries(oElectrode.Pacing.Index(iBeat)))*1000,'% 10.2f');
                     else
                         %Just express the time relative to the start
                         %of the recording
                         sLabel = num2str(aTimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                             oElectrode.SignalEvent(j).Index(iBeat)-1),'% 10.4f');
                     end
                     %Check if there has been a handle created for the
                     %label
                     if oSignalEventPlot.Children((j-1)*2+3) > 0
                         %already exists so just set the properties
                         set(oSignalEventPlot.Children((j-1)*2+3), 'Position',[oFigure.PlotLimits.Time(2)-dWidth*0.4, oFigure.PlotLimits.Data(2) - dHeight*j*0.2], ...
                             'string', sLabel, 'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points', 'parent',oSignalEventPlot.Handle, ...
                             'visible', 'on');
                     else
                         %create new text label
                         oSignalEventPlot.Children((j-1)*2+3) = text('Position',[oFigure.PlotLimits.Time(2)-dWidth*0.4, oFigure.PlotLimits.Data(2) - dHeight*j*0.2], ...
                             'string', sLabel, 'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points', 'parent',oSignalEventPlot.Handle);
                     end
                     set(oSignalEventPlot.Children((j-1)*2+3),'FontSize',10);
                     if ~oFigure.Annotate
                         %hide the labels
                         set(oSignalEventPlot.Children((j-1)*2+3),'visible','off');
                     end
                 end
             end
             
             if ~oElectrode.Accepted
                 %The signal is not accepted so plot it as red
                 %without gradient, envelope or signal events
                 set(oPlots(1).Children(1), 'color','r');
                 set(oPlots(2).Children(1), 'visible','off');
                 if ~isempty(oFigure.PlotLimits.Envelope)
                     set(oPlots(3).Children(1), 'visible','off');
                 end
                 set(oSignalEventPlot.Children,'visible','off');
             end
             
             %Set some callbacks for this subplot
             set(oSignalEventPlot.Handle, 'buttondownfcn', @(src, event) oSignalEventPlot_Callback(oFigure, src, event));
             
             %Check if this is the selected channel
             if iChannelIndex == oFigure.SelectedChannel
                 sFontWeight = 'bold';
                 sFontColour = 'b';
             else
                 sFontWeight = 'normal';
                 sFontColour = 'k';
             end
             %Check if there has been a handle created for the
             %label
             if oSignalEventPlot.Children(1) > 0
                 %already exists so just set the properties
                 set(oSignalEventPlot.Children(1),'Position', [oFigure.PlotLimits.Time(1), oFigure.PlotLimits.Data(2) - dHeight*0.1], ...
                     'string', char(oElectrode.Name), 'color',sFontColour,'FontWeight',sFontWeight,'FontUnits','points', ...
                     'parent',oSignalEventPlot.Handle, 'visible', 'on');
             else
                 %create new text label
                 oSignalEventPlot.Children(1) = text('Position', [oFigure.PlotLimits.Time(1), oFigure.PlotLimits.Data(2) - dHeight*0.1], ...
                     'string', char(oElectrode.Name), 'color',sFontColour,'FontWeight',sFontWeight,'FontUnits','points', ...
                     'parent',oSignalEventPlot.Handle);
             end
             set(oSignalEventPlot.Children(1),'FontSize',10);%0.2
             if ~oFigure.Annotate
                 set(oSignalEventPlot.Children(j*2+1),'visible','off');
             end
             
             %store signal event data
             if ~isempty(oFigure.PlotLimits.Envelope)
                 oPlots(4) = oSignalEventPlot;
             else
                 oPlots(3) = oSignalEventPlot;
             end
             %output plot struct
             oOutPlots = oPlots;
         end
                  
         function PlotWholeRecord(oFigure)
             %Plot all the beats for the selected channel in the axes at
             %the bottom
             
             %Get the current property values
             iBeat = oFigure.SelectedBeat;
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
                 for j = 1:4:size(aBeatIndexes,1);
                     oBeatLabel = text(aTime(aBeatIndexes(j,1)),YMax, num2str(j));
                     set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','normalized');
                     set(oBeatLabel,'FontSize',0.10);
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
         
         function PlotPressure(oFigure)
             % Plot Pressure Data
             
             %Clear axes and set to be visible
             cla(oFigure.oGuiHandle.oECGAxes);
             %Find axis limits
             TimeMin = min(oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
             TimeMax = max(oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
             YMin = min(oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data);
             YMax = max(oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data);
             %Plot the Pressure data
             plot(oFigure.oGuiHandle.oECGAxes, ...
                 oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status), ...
                 oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data,'k');
             axis(oFigure.oGuiHandle.oECGAxes,[TimeMin, TimeMax, YMin - 10, YMax + 10]);
             oXLabel = get(oFigure.oGuiHandle.oECGAxes,'XLabel');
%              set(oXLabel,'string','Time (s)','Position',get(oXLabel,'Position') + [0 10 0]);
         end
         
         function PlotSinusRate(oFigure)
             %Clear axes and set to be visible
             cla(oFigure.oGuiHandle.oECGAxes);
             aRateData = oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateSinusRate(oFigure.SelectedChannel);
             plot(oFigure.oGuiHandle.oECGAxes, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, aRateData,'k');
             TimeMin = min(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries);
             TimeMax = max(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries);
             YMin = min(aRateData);
             YMax = max(aRateData);
             axis(oFigure.oGuiHandle.oECGAxes,[TimeMin, TimeMax, YMin - 10, YMax + 10]);
             oXLabel = get(oFigure.oGuiHandle.oECGAxes,'XLabel');
             set(oXLabel,'string','Time (s)','Position',get(oXLabel,'Position') + [0 10 0]);
         end
     end
end

