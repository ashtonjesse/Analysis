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
        PlotHandles;
    end
        
    events
        SlideSelectionChange; %selected beat
        ChannelSelected;
        FigureDeleted;
        EventMarkChange;
        BeatIndexChange; %beat range
        TimeSelectionChange;
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor

            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            
            %Set up beat slider
            oBeatSliderControl = SlideControl(oFigure,'Select Beat');
            iNumBeats = size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
            set(oBeatSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumBeats, 'Value', oFigure.SelectedTimePoint,'SliderStep',[1/iNumBeats  0.02]);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtRight,'string',iNumBeats);
            set(oBeatSliderControl.oGuiHandle.oSliderEdit,'string',oFigure.SelectedTimePoint);
            addlistener(oBeatSliderControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            
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
            
            set(oFigure.oGuiHandle.bNextGroup, 'callback', @(src, event) bNextGroup_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bPreviousGroup, 'callback', @(src, event) bPreviousGroup_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bUpdateBeat, 'visible', 'off');
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', @(src,event) KeyPress_fcn(oFigure, src, event));
            
            %Open a electrode map plot
            oMapElectrodesFigure = MapElectrodes(oFigure,oFigure.SubPlotXdim,oFigure.SubPlotYdim);
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oMapElectrodesFigure,'ChannelSelection',@(src,event) oFigure.ChannelSelectionChange(src, event));
            %Set default selection
            oFigure.SelectedChannels = 1:(oFigure.SubPlotXdim*oFigure.SubPlotYdim);
            
            %Open a beat plot
            oBeatPlotFigure = BeatPlot(oFigure);
            addlistener(oBeatPlotFigure,'SignalEventRangeChange',@(src,event) oFigure.SignalEventRangeListener(src, event));
            addlistener(oBeatPlotFigure,'SignalEventDeleted',@(src,event) oFigure.EventDeleted(src,event));
            
            %Open a time point slider
            oTimeSliderControl = SlideControl(oFigure,'Select Time Point');
            iBeatLength = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(1,2) - ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(1,1);
            set(oTimeSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iBeatLength, 'Value', 1,'SliderStep',[1/iBeatLength  0.02]);
            set(oTimeSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oTimeSliderControl.oGuiHandle.oSliderTxtRight,'string',iBeatLength);
            set(oTimeSliderControl.oGuiHandle.oSliderEdit,'string',1);
            addlistener(oTimeSliderControl,'SlideValueChanged',@(src,event) oFigure.TimeSlideValueListener(src, event));
            
            
            %set zoom callback
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
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
         function KeyPress_fcn(oFigure, src, event)
             %Handles key press events
             switch event.Key
                 case 'n'
                     bNextGroup_Callback(oFigure, oFigure.oGuiHandle.bNextGroup, []);
                 case 'p'
                     bPreviousGroup_Callback(oFigure, oFigure.oGuiHandle.bPreviousGroup, []);
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
             oCurrentAxes = event.Axes;
             oXLim = get(oCurrentAxes,'XLim');
             oYLim = get(oCurrentAxes,'YLim');
             oFigure.CurrentZoomLimits = [oXLim ; oYLim];
             oFigure.ApplyZoomLimits();
         end
         
         function ApplyZoomLimits(oFigure)
             %Apply to axes
             set(oFigure.oGuiHandle.oElectrodeAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
             set(oFigure.oGuiHandle.oECGAxes,'XLim',oFigure.CurrentZoomLimits(1,:));
             set(oFigure.oGuiHandle.oElectrodeAxes,'YLim',oFigure.CurrentZoomLimits(2,:));
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
                     oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelNumber).Processed.BeatIndexes(iBeat,:))
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
             notify(oFigure,'SlideSelectionChange',DataPassingEvent([],iBeatIndexes{1,1}));
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
         
         function bNextGroup_Callback(oFigure, src, event)
             %Select the next group of channels - where group is
             %defined by the x and y dimensions specified in the experiment
             %metadata
             
             %Find the max channel currently selected
             iCornerChannel = max(oFigure.SelectedChannels);
             if iCornerChannel > (oFigure.NumberofChannels - oFigure.SubPlotXdim*oFigure.SubPlotYdim)
                 %Go back to the start
                 oFigure.SelectedChannels = 1:oFigure.SubPlotXdim*oFigure.SubPlotYdim;
             else
                 %Move to the next group
                 oFigure.SelectedChannels = (iCornerChannel + 1):(iCornerChannel + oFigure.SubPlotXdim*oFigure.SubPlotYdim);
             end
             %replot
             oFigure.Replot();
         end
         
         function bPreviousGroup_Callback(oFigure, src, event)
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
         
         function SignalEventRangeListener(oFigure,src, event)
             oFigure.Replot();
         end
         
         function EventDeleted(oFigure,src,event)
             oFigure.Replot();
         end
         
         function SlideValueListener(oFigure,src,event)
             %An event listener callback
             %Is called when the user selects a new beat using the
             %SlideControl
             oFigure.SelectedBeat = event.Value;
             notify(oFigure,'SlideSelectionChange');
             oFigure.Replot();
             
         end
         
         function TimeSlideValueListener(oFigure, src, event)
             %An event listener callback
             %Is called when the user selects a new time point using the
             %SlideControl
             oFigure.SelectedTimePoint = event.Value;
             notify(oFigure,'TimeSelectionChange');
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
             switch (char(event.Values{4}))
                 case 'AllBeats'
                     for i = 1:size(oFigure.SelectedChannels,2);
                         iChannel = oFigure.SelectedChannels(i);
                         oFigure.oParentFigure.oGuiHandle.oUnemap.CreateNewEvent(iChannel, char(event.Values{1}), char(event.Values{2}), char(event.Values{3}), char(event.Values{5}));
                     end
                 case 'SingleBeat'
                     iBeat = oFigure.SelectedBeat;
                     for i = 1:size(oFigure.SelectedChannels,2);
                         iChannel = oFigure.SelectedChannels(i);
                         oFigure.oParentFigure.oGuiHandle.oUnemap.CreateNewEvent(iChannel, char(event.Values{1}), char(event.Values{2}), char(event.Values{3}), char(event.Values{5}), iBeat);
                     end
             end
             oFigure.Replot();
         end
         %% ------------------------------------------------------------------
         
         function bUpdateBeat_Callback(oFigure, src, event)
             %Update the currently selected beat
             
             % Find any brushline objects associated with the ElectrodeAxes
             hBrushLines = findall(oFigure.oGuiHandle.oElectrodeAxes,'tag','Brushing');
             % Get the Xdata and Ydata attitributes of this
             brushedData = get(hBrushLines, {'Xdata','Ydata'});
             % The data that has not been selected is labelled as NaN so get
             % rid of this
             brushedIdx = ~isnan([brushedData{1,1}]);
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
             oFigure.Replot();
             notify(oFigure,'BeatIndexChange');
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
         function oNewEventMenu_Callback(oFigure, src, event)
             aControlData = cell(4,1);
             aControlData{1} = {'r','g','b','k','c','m','y'};
             aControlData{2} = {'Activation','Repolarisation'};
             aControlData{3} = {'SteepestPositiveSlope','SteepestNegativeSlope','CentralDifference','MaxSignalMagnitude'};
             aControlData{4} = {'SingleBeat','AllBeats'};
             oMixedControl = MixedControl(oFigure,'Enter the label colour, event type, marking technique, beat selection and string ID details for the new event.',aControlData);
             addlistener(oMixedControl,'ValuesEntered',@(src,event) oFigure.NewEventCreated(src, event));
         end
         
         % --------------------------------------------------------------------
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
         end
         
         function oNormaliseBeatMenu_Callback(oFigure, src, event)
             %Carry out normalisation of the potential values of the selected beat
             oFigure.oParentFigure.oGuiHandle.oUnemap.NormaliseBeat(oFigure.SelectedBeat);
             oFigure.Replot();
         end
         
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
             tic;
             if isempty(varargin)
                 oFigure.PlotBeat();
             else
                 oFigure.PlotBeat(varargin);
             end
             toc;
             oFigure.PlotWholeRecord();
             switch (oFigure.sECGAxesContent)
                 case 'ECG'
                     oFigure.PlotECG();
                 case 'Pressure'
                     oFigure.PlotPressure();
             end
             oFigure.CheckRejectToggleButton();
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
         
         function CreateSubPlot(oFigure,aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits)
             %Create the space for the subplot that will contain all the
             %signals

             %Find the bounds of the selected area
             iMinChannel = min(oFigure.SelectedChannels);
             iMaxChannel = max(oFigure.SelectedChannels);
             %Convert into row and col indices
             [iMinRow iMinCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMinChannel);
             [iMaxRow iMaxCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMaxChannel);
             %Divide up the space for the subplots
             xDiv = 1/(iMaxRow-iMinRow+1);
             yDiv = 1/(iMaxCol-iMinCol+1);
             
             %Set number of plots per channel
             if ~isempty(aEnvelopeLimits)
                 iNumberOfPlots = 4;
             else
                 iNumberOfPlots = 3;
             end
             
             %Initialise the plot handles array
             oFigure.PlotHandles = cell(length(oFigure.SelectedChannels)*iNumberOfPlots,2);
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.pnSignals,'children');
             %if it's the first time through then make all new subplots
             if isempty(aPlotObjects)
                 for i = 1:size(oFigure.SelectedChannels,2);
                     %Create new axes
                     oFigure.SetAxes(1, i, iMinRow, iMinCol, xDiv, yDiv, aPlotObjects, iNumberOfPlots, ...
                         aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits);
                 end
             else
                 %Check number of plots
                 if length(aPlotObjects) > length(oFigure.SelectedChannels)*iNumberOfPlots
                     %Loop through list and delete what is not needed
                     for i = length(aPlotObjects):-1:(length(oFigure.SelectedChannels)*iNumberOfPlots + 1)
                         delete(aPlotObjects(i));
                     end
                     %Reduce the size of the plots and plothandles arrays
                     oFigure.Plots = oFigure.Plots(1:length(oFigure.SelectedChannels));
                     %Loop through the plots and reset location
                     for i = 1:length(oFigure.SelectedChannels)
                         %Set old axes
                         oFigure.SetAxes(0, i, iMinRow, iMinCol, xDiv, yDiv, aPlotObjects, iNumberOfPlots, ...
                             aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits);
                     end
                 else
                     %Initialise plot count
                     iPlotCount = 0;
                     %Use the old and make new plots as needed
                     for i = 1:length(oFigure.SelectedChannels)
                         if iPlotCount >= length(aPlotObjects)
                             %Create new axes
                             oFigure.SetAxes(1, i, iMinRow, iMinCol, xDiv, yDiv, aPlotObjects, iNumberOfPlots, ...
                                 aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits);
                         else
                             %Set old axes
                             oFigure.SetAxes(0, i, iMinRow, iMinCol, xDiv, yDiv, aPlotObjects, iNumberOfPlots, ...
                                 aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits);
                         end
                         %Increment the plot count
                         iPlotCount = iPlotCount + iNumberOfPlots;
                     end
                 end
             end
         end
         
         function SetAxes(oFigure, bCreateNewAxes, iChannelIndex, iMinRow, iMinCol, xDiv, yDiv, aPlotObjects, iNumberOfPlots, ...
                 aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits)
             i = iChannelIndex;
             [iRow iCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(oFigure.SelectedChannels(i));
             %Normalise the row and columns to the minimum.
             iRow = iRow - iMinRow;
             iCol = iCol - iMinCol;
             %Create the position vector for the next plot
             aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
             %Create axes  in the position specified for Signal
             %data
             
             if bCreateNewAxes
                 oSignalPlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[], 'color','none', ...
                     'Tag', sprintf('Signal%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aDataLimits(1))*0.1)*aDataLimits(1), (1+sign(aDataLimits(2))*0.1)*aDataLimits(2)]);
                 %Create axes for slope data
                 oSlopePlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                     'Tag', sprintf('Slope%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aSlopeLimits(1))*0.1)*aSlopeLimits(1), (1+sign(aSlopeLimits(2))*0.1)*aSlopeLimits(2)]);
                 if ~isempty(aEnvelopeLimits)
                     %Create axes for envelope data
                     oEnvelopePlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                         'Tag', sprintf('Envelope%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aEnvelopeLimits(1))*0.1)*aEnvelopeLimits(1), (1+sign(aEnvelopeLimits(2))*0.1)*aEnvelopeLimits(2)]);
                 end
                 %Create axes for event lines
                 oSignalEventPlot = axes('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                     'Tag', sprintf('SignalEventPlot%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aDataLimits(1))*0.1)*aDataLimits(1), (1+sign(aDataLimits(2))*0.1)*aDataLimits(2)]);
             else
                 
                 %Use old ones
                 set(aPlotObjects((i-1)*iNumberOfPlots+1),'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none','Tag', ...
                     sprintf('Signal%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aDataLimits(1))*0.1)*aDataLimits(1), (1+sign(aDataLimits(2))*0.1)*aDataLimits(2)]);
                 oSignalPlot = aPlotObjects((i-1)*iNumberOfPlots+1);
                 aChildren = get(aPlotObjects((i-1)*iNumberOfPlots+1),'children');
                 delete(aChildren);
                 %set axes for slope data
                 set(aPlotObjects((i-1)*iNumberOfPlots+2),'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                     'Tag', sprintf('Slope%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aSlopeLimits(1))*0.1)*aSlopeLimits(1), (1+sign(aSlopeLimits(2))*0.1)*aSlopeLimits(2)]);
                 oSlopePlot = aPlotObjects((i-1)*iNumberOfPlots+2);
                 aChildren = get(aPlotObjects((i-1)*iNumberOfPlots+2),'children');
                 delete(aChildren);
                 %set  axes for envelope data
                 if ~isempty(aEnvelopeLimits)
                     set(aPlotObjects((i-1)*iNumberOfPlots+3),'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                         'Tag', sprintf('Envelope%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aEnvelopeLimits(1))*0.1)*aEnvelopeLimits(1), (1+sign(aEnvelopeLimits(2))*0.1)*aEnvelopeLimits(2)]);
                     oEnvelopePlot = aPlotObjects((i-1)*iNumberOfPlots+3);
                     aChildren = get(aPlotObjects((i-1)*iNumberOfPlots+3),'children');
                     delete(aChildren);
                     %set axes for event lines
                     set(aPlotObjects((i-1)*iNumberOfPlots+4),'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                         'Tag', sprintf('SignalEventPlot%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aDataLimits(1))*0.1)*aDataLimits(1), (1+sign(aDataLimits(2))*0.1)*aDataLimits(2)]);
                     oSignalEventPlot = aPlotObjects((i-1)*iNumberOfPlots+4);
                     aChildren = get(aPlotObjects((i-1)*iNumberOfPlots+4),'children');
                     delete(aChildren);
                 else
                     %set axes for event lines
                     set(aPlotObjects((i-1)*iNumberOfPlots+3),'Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals,'XTick',[],'YTick',[],'color','none',...
                         'Tag', sprintf('SignalEventPlot%d',oFigure.SelectedChannels(i)), 'xlim', aTimeLimits, 'ylim', [(1-sign(aDataLimits(1))*0.1)*aDataLimits(1), (1+sign(aDataLimits(2))*0.1)*aDataLimits(2)]);
                     oSignalEventPlot = aPlotObjects((i-1)*iNumberOfPlots+3);
                     aChildren = get(aPlotObjects((i-1)*iNumberOfPlots+3),'children');
                     delete(aChildren);
                 end
             end
             
             %Save the plot handles
             oFigure.PlotHandles{(i-1)*iNumberOfPlots+1,1} = oSignalPlot;
             oFigure.PlotHandles{(i-1)*iNumberOfPlots+2,1} = oSlopePlot;
             if ~isempty(aEnvelopeLimits)
                 oFigure.PlotHandles{(i-1)*iNumberOfPlots+3,1} = oEnvelopePlot;
                 oFigure.PlotHandles{(i-1)*iNumberOfPlots+4,1} = oSignalEventPlot;
                 oFigure.PlotHandles((i-1)*4+1:(i-1)*4+4,2) = {oFigure.SelectedChannels(i)};
             else
                 oFigure.PlotHandles{(i-1)*iNumberOfPlots+3,1} = oSignalEventPlot;
                 oFigure.PlotHandles((i-1)*iNumberOfPlots+1:(i-1)*iNumberOfPlots+3,2) = {oFigure.SelectedChannels(i)};
             end
         end
         
         function PlotBeat(oFigure,varargin)
             %Plot the beats for the selected channels in the subplot
             
             aSelectedElectrodes = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannels);
             %Get the current property values
             iBeat = oFigure.SelectedBeat;
             %Check if this is the first time PlotBeat is being called
             %after creating a new set of subplots
             if isempty(oFigure.Plots)
                 %Get the data for these electrodes
                 oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1); %just needed to define the beat range
                 aData = MultiLevelSubsRef(oFigure.oDAL.oHelper,aSelectedElectrodes,'Processed','Data');
                 aSlope = MultiLevelSubsRef(oFigure.oDAL.oHelper,aSelectedElectrodes,'Processed','Slope');
                 aEnvelope = MultiLevelSubsRef(oFigure.oDAL.oHelper,aSelectedElectrodes,'Processed','CentralDifference');
                 %Select the data for this beat
                 aTime =  oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                     oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2));
                 aData = aData(oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2),:);
                 aSlope = aSlope(oElectrode.Processed.BeatIndexes(iBeat,1):...
                     oElectrode.Processed.BeatIndexes(iBeat,2),:);
                 %Record the total length of this data - used to check if
                 %we need to reduce this through interpolation for plotting
                 %purposes
                 iDataLength = size(aData,1)*size(aData,2) + size(aSlope,1)*size(aSlope,2);
                 if ~isempty(aEnvelope)
                     % If there was aEnvelope data stored
                     aEnvelope = abs(aEnvelope(oElectrode.Processed.BeatIndexes(iBeat,1):...
                         oElectrode.Processed.BeatIndexes(iBeat,2),:));
                     iDataLength = iDataLength + size(aEnvelope,1)*size(aEnvelope,2) ;
                 end
                 %Initialise the Plots array
                 for i = 1:length(aSelectedElectrodes)
                     %Set up the plots struct
                     oFigure.Plots(i).ChannelIndex = oFigure.SelectedChannels(i);
                 end
                 %Reduce the size of the data arrays depending on the
                 %number of plots to make
                 if iDataLength > 10000
                     iLeftover = iDataLength - 10000;
                     dLengthToShortenTo = max(20,size(aTime,2) - floor(iLeftover / length(oFigure.SelectedChannels)));
                     %Calc the interpolated time array
                     aTimeToPlot = linspace(min(aTime),max(aTime),dLengthToShortenTo).';
                     %Initialise arrays to hold interpolated data
                     aDataToPlot = zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                     aSlopeToPlot = zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                     aEnvelopeToPlot =  zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                     %Shorten data for all selected electroes
                     for i = 1:size(aSelectedElectrodes,2);
                         aDataToPlot(:,i) = interp1(aTime,aData(:,i),aTimeToPlot);
                         aSlopeToPlot(:,i) = interp1(aTime,aSlope(:,i),aTimeToPlot);
                         if ~isempty(aEnvelope)
                             aEnvelopeToPlot(:,i) = interp1(aTime,aEnvelope(:,i),aTimeToPlot);
                         end
                     end
                     if isempty(aEnvelope)
                         %Reset envelope to be empty if there is no
                         %envelope data because above it was replaced with
                         %an array of zeros.
                         aEnvelopeToPlot = [];
                     end
                 else
                     %No need for interpolation
                     aTimeToPlot = aTime;
                     aDataToPlot = aData;
                     aSlopeToPlot = aSlope;
                     aEnvelopeToPlot = aEnvelope;
                 end
                 %assign to plots struct
                 [oFigure.Plots(:).Time] = deal(aTimeToPlot);
                 aCellArray = mat2cell(aDataToPlot,size(aDataToPlot,1),ones(1,size(aDataToPlot,2)));
                 [oFigure.Plots(:).Data] = aCellArray{:};
                 aCellArray = mat2cell(aSlopeToPlot,size(aSlopeToPlot,1),ones(1,size(aSlopeToPlot,2)));
                 [oFigure.Plots(:).Slope] = aCellArray{:};
                 if ~isempty(aEnvelope)
                     aCellArray = mat2cell(aEnvelopeToPlot,size(aEnvelopeToPlot,1),ones(1,size(aEnvelopeToPlot,2)));
                     [oFigure.Plots(:).Envelope] = aCellArray{:};
                 else
                     [oFigure.Plots(:).Envelope] = deal([]);
                 end
             else
                 %Get the data from the plots struct
                 aTimeToPlot = oFigure.Plots(1).Time;
                 aDataToPlot = cell2mat({oFigure.Plots(:).Data});
                 aSlopeToPlot = cell2mat({oFigure.Plots(:).Slope});
                 if ~isempty(oFigure.Plots(1).Envelope)
                     aEnvelopeToPlot = cell2mat({oFigure.Plots(:).Envelope});
                 else
                     aEnvelopeToPlot = [];
                 end
             end
             %Find the accepted channels within this subset
             [rowIndexes, colIndexes, vector] = find(cell2mat({aSelectedElectrodes(:).Accepted}));
             %Select the accepted channels if there are any
             if ~isempty(colIndexes)
                 aAcceptedElectrodes = colIndexes;
             else
                 aAcceptedElectrodes = 1:length(oFigure.SelectedChannels);
             end
             %Recalculate the limits
             aTimeLimits = [min(aTimeToPlot),max(aTimeToPlot)];
             aDataLimits = [min(min(aDataToPlot(:,aAcceptedElectrodes))), max(max(aDataToPlot(:,aAcceptedElectrodes)))];
             aSlopeLimits = [min(min(aSlopeToPlot(:,aAcceptedElectrodes))), max(max(aSlopeToPlot(:,aAcceptedElectrodes)))];
             if ~isempty(aEnvelopeToPlot)
                 aEnvelopeLimits = [min(min(aEnvelopeToPlot(:,aAcceptedElectrodes))), max(max(aEnvelopeToPlot(:,aAcceptedElectrodes)))];
             else
                 aEnvelopeLimits = [];
             end
             
             %Check if an electrode number was supplied
             if isempty(varargin)
                 %Arrange the plots
                 oFigure.CreateSubPlot(aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits);
                 %plot all electrodes for this beat 
                 for i = 1:size(oFigure.SelectedChannels,2);
                     iChannelIndex = oFigure.SelectedChannels(i);
                     %Plot the electrode
                     oFigure.PlotElectrode(iChannelIndex,iBeat,aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits,0);
                 end
             elseif nargin == 2
                 %Replot the specified electrode and the previously
                 %selected electrode
                 iChannelIndex = varargin{1}{1}(1);
                 oFigure.PlotElectrode(iChannelIndex,iBeat,aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits,1);
                 if max(ismember(oFigure.SelectedChannels,oFigure.PreviousChannel))
                     %replot the previous channel as well
                     oFigure.PlotElectrode(oFigure.PreviousChannel,iBeat,aTimeLimits,aDataLimits,aSlopeLimits,aEnvelopeLimits,1);
                 end
             end
                 
         end
         
         function PlotElectrode(oFigure,iChannelIndex,iBeat,aTimeLimits,aSignalLimits,aSlopeLimits,aEnvelopeLimits,bClearAxes)
             
             %Get these values so that we can place text in the
             %right place
             dWidth = aTimeLimits(2) - aTimeLimits(1);
             dHeight = aSignalLimits(2) - aSignalLimits(1);
             
             %Get the handles to the plots for this channel
             aHandles = cell2mat(oFigure.PlotHandles(:,2));
             aSubPlots = cell2mat(oFigure.PlotHandles(aHandles==iChannelIndex,1));
             %Get the handle to current signal plot and rename it (the name
             %is not propagated)
             oSignalPlot = aSubPlots(1);
             set(oSignalPlot,'Tag',sprintf('Signal%d',iChannelIndex),'nextplot','replace');
             %Repeat for the slope plot
             oSlopePlot = aSubPlots(2);
             set(oSlopePlot,'Tag', sprintf('Slope%d',iChannelIndex),'nextplot','replace');
             if bClearAxes
                 cla(oSignalPlot);
                 cla(oSlopePlot);
             end
             
             %Get electrode
             oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelIndex);
             %Get the corresponding plot
             [iRow, iCol] = ind2sub(size(oFigure.SelectedChannels),find(oFigure.SelectedChannels==iChannelIndex));
             oPlot = oFigure.Plots(iCol);
             %Recall the other plots depending on if an envelopeplot has
             %been created/set
             if ~isempty(aEnvelopeLimits)
                 oEnvelopePlot = aSubPlots(3);
                 set(oEnvelopePlot, 'Tag',sprintf('Envelope%d',iChannelIndex),'nextplot','replace');
                 oSignalEventPlot = aSubPlots(4);
                 set(oSignalEventPlot,'Tag', sprintf('SignalEventPlot%d',iChannelIndex),'nextplot','replace');
                 if bClearAxes
                     cla(oEnvelopePlot);
                     cla(oSignalEventPlot);
                 end
             else
                 oSignalEventPlot = aSubPlots(3);
                 set(oSignalEventPlot,'Tag', sprintf('SignalEventPlot%d',iChannelIndex),'nextplot','replace');
                 if bClearAxes
                     cla(oSignalEventPlot);
                 end
             end
             
             %Plot the data and slope
             if oElectrode.Accepted
                 %If the signal is accepted then plot it as black
                 line(oPlot.Time,oPlot.Data,'color','k','parent',oSignalPlot);
                 %Plot the slope data
                 line(oPlot.Time,oPlot.Slope,'color','r','parent',oSlopePlot);
                 if ~isempty(aEnvelopeLimits)
                     %Plot the envelope data
                     line(oPlot.Time,oPlot.Envelope,'color','b','parent',oEnvelopePlot);
                 end
                 if isfield(oElectrode,'SignalEvent')
                     %Loop through events
                     for j = 1:length(oElectrode.SignalEvent)
                         %Mark the event times with a line
                         %Get the time index to use (closest to that
                         %recorded)
                         aTimeDiff = abs(oPlot.Time - oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                             oElectrode.SignalEvent(j).Index(iBeat)-1));
                         [C iEventIndex] = min(aTimeDiff);
                         oLine = line([oPlot.Time(iEventIndex) ...
                             oPlot.Time(iEventIndex)], [aSignalLimits(2), aSignalLimits(1)]);
                         sLineTag = strcat(sprintf('SignalEventLine%d',iChannelIndex),'_',sprintf('%d',j));
                         set(oLine,'Tag',sLineTag,'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot, ...
                             'linewidth',2);
                         %Label the line with the event time
                         if oFigure.Annotate
                             if isfield(oElectrode,'Pacing')
                                 %This is a sequence of paced beats so express
                                 %the time relative to the pacing index
                                 sLabel = num2str((oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                                     oElectrode.SignalEvent(j).Index(iBeat)-1) - oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Pacing.Index(iBeat)))*1000,'% 10.2f');
                             else
                                 %Just express the time relative to the start
                                 %of the recording
                                 sLabel = num2str(oPlot.Time(iEventIndex),'% 10.4f');
                             end
                             oEventLabel = text(aTimeLimits(2)-dWidth*0.4, aSignalLimits(2) - dHeight*j*0.2, sLabel);
                             set(oEventLabel,'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points');
                             set(oEventLabel,'FontSize',10);
                             set(oEventLabel,'parent',oSignalEventPlot);
                         end
                     end
                 end
             else
                 %The signal is not accepted so plot it as red
                 %without gradient
                 line(oPlot.Time,oPlot.Data,'color','r','parent',oSignalPlot);
             end
             
             %Set some callbacks for this subplot
             set(oSignalEventPlot, 'buttondownfcn', @(src, event) oSignalEventPlot_Callback(oFigure, src, event));
             
             if bClearAxes
                 %Set the axis on the subplot
                 if ~isempty(aEnvelopeLimits)
                     axis(oEnvelopePlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aEnvelopeLimits(1))*0.1)*aEnvelopeLimits(1), (1+sign(aEnvelopeLimits(2))*0.1)*aEnvelopeLimits(2)]);
                 end
                 axis(oSignalPlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSignalLimits(1))*0.1)*aSignalLimits(1), (1+sign(aSignalLimits(2))*0.1)*aSignalLimits(2)]);
                 axis(oSlopePlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSlopeLimits(1))*0.1)*aSlopeLimits(1), (1+sign(aSlopeLimits(2))*0.1)*aSlopeLimits(2)]);
                 axis(oSignalEventPlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSignalLimits(1))*0.1)*aSignalLimits(1), (1+sign(aSignalLimits(2))*0.1)*aSignalLimits(2)]);
             end
             
             if oFigure.Annotate
                 %Create a label that shows the channel name
                 oLabel = text(aTimeLimits(1), aSignalLimits(2) - dHeight*0.1,char(oElectrode.Name));
                 if iChannelIndex == oFigure.SelectedChannel;
                     set(oLabel,'color','b','FontWeight','bold','FontUnits','points');
                     set(oLabel,'FontSize',10);%0.2
                 else
                     set(oLabel,'color','k','FontWeight','normal','FontUnits','points');
                     set(oLabel,'FontSize',10);%0.15
                 end
                 set(oLabel,'parent',oSignalEventPlot);
             end
             
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
             set(oXLabel,'string','Time (s)','Position',get(oXLabel,'Position') + [0 10 0]);
         end
     end
end

