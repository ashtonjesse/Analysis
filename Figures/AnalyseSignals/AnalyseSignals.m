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
        OldPlots = [];
        PlotLimits = [];
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
                 oFigure.PlotBeatOrElectrode();
             else
                 oFigure.PlotBeatOrElectrode(varargin);
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
         
         function PlotBeat(oFigure)
             %Create the space for the subplot that will contain all the
             %signals
             
             %Get the plot data
             oDataToPlot = oFigure.oParentFigure.oGuiHandle.oUnemap.GetDataForPlotting(oFigure.SelectedBeat, oFigure.SelectedChannels);
             %Get the plotting limits from this data
             oFigure.PlotLimits = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPlotLimits(oDataToPlot, oFigure.SelectedChannels);
             
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
             if ~isempty(oFigure.PlotLimits.Envelope)
                 iNumberOfPlots = 4;
             else
                 iNumberOfPlots = 3;
             end
             %Get details for old channels if there are any
             if ~isempty(oFigure.OldPlots)
                 aOldChannels = MultiLevelSubsRef(oFigure.oDAL.oHelper, oFigure.OldPlots, 'Channel');
                 iOldBeat = oFigure.OldPlots(1).Beat;
                 %find the old plots that will not be needed
                 [~ , ~, aPlotIndexes] = setxorwithduplicates(oFigure.SelectedChannels, aOldChannels);
                 if ~isempty(aPlotIndexes)
                    for j = 1:length(aPlotIndexes)
                        set(oFigure.OldPlots(aPlotIndexes(j)).Handle,'visible','off');
                        set(oFigure.OldPlots(aPlotIndexes(j)).Children,'visible','off');
                    end
                 end
             end
             
             for i = 1:size(oFigure.SelectedChannels,2);
                 iChannel = oFigure.SelectedChannels(i);
                 [iRow iCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iChannel);
                 %Normalise the row and columns to the minimum.
                 iRow = iRow - iMinRow;
                 iCol = iCol - iMinCol;
                 %Create the position vector for the next plot
                 aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
                 %check if this is the first time through
                 if isempty(oFigure.OldPlots)
                     %Create new axes
                     aIndices = oFigure.ArrangeSubPlots(1, iChannel, aPosition, [], oDataToPlot(i), i, iNumberOfPlots);
                 else
                     %Use those that have been created already and add more
                     %where necessary
                     aIndices = logical(aOldChannels==oFigure.SelectedChannels(i));
                     %check if this returned anything (there is overlap
                     %with the old selection).
                     if max(aIndices) > 0
                         %This channel already has associated plots
                         oPlotHandles = cell2mat({oFigure.OldPlots(aIndices).Handle});
                         aIndices = oFigure.ArrangeSubPlots(0, iChannel, aPosition, oPlotHandles, oDataToPlot(i), i, iNumberOfPlots);
                     else
                         %Arrange the plot
                         aIndices = oFigure.ArrangeSubPlots(1, iChannel, aPosition, [], oDataToPlot(i), i, iNumberOfPlots);
                     end
                 end
                 %Plot the electrode
                 oFigure.Plots(aIndices) = oFigure.PlotElectrode(oFigure.SelectedChannels(i),0,oFigure.Plots(aIndices));
             end
             
             if isempty(oFigure.OldPlots)
                 %Save the plots
                 oFigure.OldPlots = oFigure.Plots;
             else
                 if length(oFigure.OldPlots) < length(oFigure.Plots)
                     oFigure.OldPlots = oFigure.Plots;
                 end
             end
         end
         
         function aPlotNumbers = ArrangeSubPlots(oFigure, bCreateNewAxes, iChannelIndex, aPosition, aHandles, oDataToPlot, iIndex, iNumberOfPlots)
             %Initialise output
             aPlotNumbers = zeros(4,1);
             %Check if new axes have to be created
             aPlotNumbers(1,1) = (iIndex-1)*iNumberOfPlots+1;
             aPlotNumbers(2,1) = (iIndex-1)*iNumberOfPlots+2;
             if bCreateNewAxes
                 %create the data plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Signal%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Data, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+1);
                 %create the slope plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Slope%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Slope, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Slope, (iIndex-1)*iNumberOfPlots+2);
                 if ~isempty(oFigure.PlotLimits.Envelope)
                     %create the envelope plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Envelope%d',iChannelIndex), 0, oDataToPlot.Time, oDataToPlot.Envelope, ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Envelope, (iIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iIndex-1)*iNumberOfPlots+3;
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), 0, [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+4);
                     aPlotNumbers(4,1) = (iIndex-1)*iNumberOfPlots+4;
                 else
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), 0, [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iIndex-1)*iNumberOfPlots+3;
                     aPlotNumbers = aPlotNumbers(1:3,1);
                 end
             else
                 %use the handles specified in aHandles
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Signal%d',iChannelIndex), aHandles(1), oDataToPlot.Time, oDataToPlot.Data, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+1);
                 %create the slope plot
                 oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Slope%d',iChannelIndex), aHandles(2), oDataToPlot.Time, oDataToPlot.Slope, ...
                     oFigure.PlotLimits.Time, oFigure.PlotLimits.Slope, (iIndex-1)*iNumberOfPlots+2);
                 if ~isempty(oFigure.PlotLimits.Envelope)
                     %create the envelope plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('Envelope%d',iChannelIndex), aHandles(3), oDataToPlot.Time, oDataToPlot.Envelope, ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Envelope, (iIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iIndex-1)*iNumberOfPlots+3;
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), aHandles(4), [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+4);
                     aPlotNumbers(4,1) = (iIndex-1)*iNumberOfPlots+4;
                 else
                     %create the signalevent plot
                     oFigure.SetAxes(iChannelIndex, aPosition, sprintf('SignalEventPlot%d',iChannelIndex), aHandles(3), [], [], ...
                         oFigure.PlotLimits.Time, oFigure.PlotLimits.Data, (iIndex-1)*iNumberOfPlots+3);
                     aPlotNumbers(3,1) = (iIndex-1)*iNumberOfPlots+3;
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
                 oFigure.Plots(iPlotNumber).Children = flipud(get(oHandle,'children'));
                 set(oFigure.Plots(iPlotNumber).Handle,'visible','on');
                 aChildren = {oFigure.Plots(iPlotNumber).Children};
                 for m = 1:length(aChildren)
                     if ~isempty(aChildren{m})
                         set(aChildren{m},'visible','on');
                     end
                 end
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
             oFigure.Plots(iPlotNumber).Beat = oFigure.SelectedBeat; 
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
                 iChannelIndex = varargin{1}{1}(1);
                 aIndices = logical(cell2mat({oFigure.Plots(:).Channel})==iChannelIndex);
                 oFigure.PlotElectrode(iChannelIndex,0,oFigure.Plots(aIndices));
                 if max(ismember(oFigure.SelectedChannels,oFigure.PreviousChannel))
                     %replot the previous channel as well
                     aIndices = logical(cell2mat({oFigure.Plots(:).Channel})==oFigure.PreviousChannel);
                     oFigure.PlotElectrode(oFigure.PreviousChannel,0,oFigure.Plots(aIndices));
                 end
             end
             
         end
         
         function oOutPlots = PlotElectrode(oFigure,iChannelIndex,bClearAxes,oPlots)
             
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
             if oElectrode.Accepted
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
                     if oSignalEventPlot.Children(1) <= 0
                         %a line and a label per event plus a channel label
                         oSignalEventPlot.Children = zeros(length(oElectrode.SignalEvent)*2 + 1,1);
                     end
                     %Loop through events
                     for j = 1:length(oElectrode.SignalEvent)
                         %Mark the event times with a line
                         %Get the time index to use (closest to that
                         %recorded)
                         aTimeDiff = abs(oPlots(2).xData - oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                             oElectrode.SignalEvent(j).Index(iBeat)-1));
                         [C iEventIndex] = min(aTimeDiff);
                         sLineTag = strcat(sprintf('SignalEventLine%d',iChannelIndex),'_',sprintf('%d',j));
                         %Check if there has been a handle created for the
                         %line
                         if oSignalEventPlot.Children((j-1)*2+1) > 0
                             %already exists so just set properties
                             set(oSignalEventPlot.Children((j-1)*2+1),'XData',[oPlots(2).xData(iEventIndex) ...
                                 oPlots(2).xData(iEventIndex)], 'YData', [oFigure.PlotLimits.Data(2), oFigure.PlotLimits.Data(1)], ...
                                 'Tag',sLineTag,'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot.Handle, 'linewidth',2, 'visible', 'on');
                         else
                             %create a line
                             oSignalEventPlot.Children((j-1)*2+1) = line('XData', [oPlots(2).xData(iEventIndex) ...
                                 oPlots(2).xData(iEventIndex)], 'YData', [oFigure.PlotLimits.Data(2), oFigure.PlotLimits.Data(1)], ...
                                 'Tag', sLineTag,'color', oElectrode.SignalEvent(j).Label.Colour, 'parent',oSignalEventPlot.Handle, 'linewidth',2);
                         end
                         %Label the line with the event time
                         if isfield(oElectrode,'Pacing')
                             %This is a sequence of paced beats so express
                             %the time relative to the pacing index
                             sLabel = num2str((oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(iBeat,1) + ...
                                 oElectrode.SignalEvent(j).Index(iBeat)-1) - oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(oElectrode.Pacing.Index(iBeat)))*1000,'% 10.2f');
                         else
                             %Just express the time relative to the start
                             %of the recording
                             sLabel = num2str(oPlots(2).Time(iEventIndex),'% 10.4f');
                         end
                         %Check if there has been a handle created for the
                         %label
                         if oSignalEventPlot.Children((j-1)*2+2) > 0
                             %already exists so just set the properties
                             set(oSignalEventPlot.Children((j-1)*2+2), 'Position',[oFigure.PlotLimits.Time(2)-dWidth*0.4, oFigure.PlotLimits.Data(2) - dHeight*j*0.2], ...
                                 'string', sLabel, 'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points', 'parent',oSignalEventPlot.Handle, ...
                                 'visible', 'on');
                         else
                             %create new text label
                             oSignalEventPlot.Children((j-1)*2+2) = text('Position',[oFigure.PlotLimits.Time(2)-dWidth*0.4, oFigure.PlotLimits.Data(2) - dHeight*j*0.2], ...
                                 'string', sLabel, 'color',oElectrode.SignalEvent(j).Label.Colour,'FontWeight','bold','FontUnits','points', 'parent',oSignalEventPlot.Handle);
                         end
                         set(oSignalEventPlot.Children((j-1)*2+2),'FontSize',10);
                         if ~oFigure.Annotate
                             %hide the labels
                             set(oSignalEventPlot.Children((j-1)*2+2),'visible','off');
                         end
                     end
                 end
             else
                 %The signal is not accepted so plot it as red
                 %without gradient
                 if oPlots(1).Children(1) > 0
                     %replace the data for the line child
                     set(oPlots(1).Children(1), 'XData', oPlots(1).xData, 'YData', oPlots(1).yData,'color','r','parent',oPlots(1).Handle);
                 else
                     %The first child is the data line
                     oPlots(1).Children(1) = line(oPlots(1).xData,oPlots(1).yData,'color','r','parent',oPlots(1).Handle);
                 end
             end
             
             %Set some callbacks for this subplot
             set(oSignalEventPlot.Handle, 'buttondownfcn', @(src, event) oSignalEventPlot_Callback(oFigure, src, event));
                          
             if bClearAxes
                 %Set the axis on the subplot
                 if ~isempty(aEnvelopeLimits)
                     axis(oEnvelopePlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aEnvelopeLimits(1))*0.1)*aEnvelopeLimits(1), (1+sign(aEnvelopeLimits(2))*0.1)*aEnvelopeLimits(2)]);
                 end
                 axis(oSignalPlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSignalLimits(1))*0.1)*aSignalLimits(1), (1+sign(aSignalLimits(2))*0.1)*aSignalLimits(2)]);
                 axis(oSlopePlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSlopeLimits(1))*0.1)*aSlopeLimits(1), (1+sign(aSlopeLimits(2))*0.1)*aSlopeLimits(2)]);
                 axis(oSignalEventPlot,[aTimeLimits(1), aTimeLimits(2), (1-sign(aSignalLimits(1))*0.1)*aSignalLimits(1), (1+sign(aSignalLimits(2))*0.1)*aSignalLimits(2)]);
             end
             
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
             if oSignalEventPlot.Children(j*2+1) > 0
                 %already exists so just set the properties
                 set(oSignalEventPlot.Children(j*2+1),'Position', [oFigure.PlotLimits.Time(1), oFigure.PlotLimits.Data(2) - dHeight*0.1], ...
                     'string', char(oElectrode.Name), 'color',sFontColour,'FontWeight',sFontWeight,'FontUnits','points', ...
                     'parent',oSignalEventPlot.Handle, 'visible', 'on');
             else
                 %create new text label
                 oSignalEventPlot.Children(j*2+1) = text('Position', [oFigure.PlotLimits.Time(1), oFigure.PlotLimits.Data(2) - dHeight*0.1], ...
                     'string', char(oElectrode.Name), 'color',sFontColour,'FontWeight',sFontWeight,'FontUnits','points', ...
                     'parent',oSignalEventPlot.Handle);
             end
             set(oSignalEventPlot.Children(j*2+1),'FontSize',10);%0.2
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

