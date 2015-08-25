classdef OpticalBeatDetection < BaseFigure
    %this figure is designed to load a csv file containing optical mapping
    %data and enable the user to detect beats
    properties
        DataAxes = 1;
        HeartRateAxes = 2;
        SelectedChannel;
        SelectedChannels;
        PreviousChannel;
        SelectedBeat;
        SelectedFile;
        SelectedEventID;
        SelectedTimePoint = 25;
    end
    
    events
        ChannelSelected;
        FigureDeleted;
        EventMarkChange;
        BeatIndexChange; %beat range
        TimeSelectionChange;
        BeatSelectionChange;
        EventRangeChange;
        SignalEventSelectionChange;
        NewSignalEventCreated;
        NewBeatInserted;
        SignalEventLoaded;
    end
    
    methods
        function oFigure = OpticalBeatDetection()
            oFigure = oFigure@BaseFigure('OpticalBeatDetection',@OpeningFcn);
            %Set the callback functions to the menu items
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oDummy_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolsMenu, 'callback', @(src, event) oDummy_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oWindowMenu, 'callback', @(src, event) oDummy_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothMenu, 'callback', @(src, event) oSmoothMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectBeatsMenu, 'callback', @(src, event) oDetectBeatsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oNewEventMenu, 'callback', @(src, event) oNewEventMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMapElectrodesMenu,'callback', @(src, event) oMapElectrodesMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oBeatPlotMenu,'callback', @(src, event) oBeatPlotMenu_Callback(oFigure, src, event));            
            set(oFigure.oGuiHandle.pmFileSelector, 'callback', @(src, event) pmFileSelectorMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bRejectChannel, 'callback', @(src, event)  bAcceptChannel_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGetSlopeMenu, 'callback', @(src, event) oGetSlopeMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRejectAllMenu, 'callback', @(src, event) oRejectAllMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAcceptAllMenu, 'callback', @(src, event) oAcceptAllMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDeleteMenu, 'callback', @(src, event) oDeleteMenu_Callback(oFigure, src, event));
            
            %set up axes
            oFigure.oGuiHandle.oPanel = panel(oFigure.oGuiHandle.uipanel);
            oFigure.oGuiHandle.oPanel.pack(1,1);
            
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set the output attribute
                set(handles.pmFileSelector, 'string', {''});
                handles.output = hObject;
                %Update the gui handles
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = protected)
        function deleteme(oFigure)
            notify(oFigure,'FigureDeleted');
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end   
        
        function oFigure = oDummy_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oSaveMenu_Callback(oFigure, src, event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                % Save the current entities
                set(oFigure.oGuiHandle.txtFeedback,'string','Saving...');
                               
                %Call built-in file dialog to select filename
                [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the .mat file');
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName))
                    return
                end
                
                %Get the full file name
                sLongDataFileName=strcat(sDataPathName,sDataFileName);
                
                %Save
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Save(sLongDataFileName);
                set(oFigure.oGuiHandle.txtFeedback,'string','File Saved');
            end
        end
        
        function oDeleteMenu_Callback(oFigure, src, event)
             %Delete the currently selected beat
             oFigure.oGuiHandle.oOptical.DeleteBeat(oFigure.SelectedBeat);
             oFigure.SelectedBeat = 1;
             oFigure.Replot(oFigure.SelectedChannel);
             notify(oFigure,'BeatIndexChange');
         end
        
        function oFigure = oOpenMenu_Callback(oFigure,src,event)
            [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file that contains an optical transmembrane recording','multiselect','on');
            %Make sure the dialogs return char objects
            if ~iscell(sDataFileName)
                sDataFileName = {sDataFileName};
            end
            if (~ischar(sDataFileName{1}) && ~ischar(sDataPathName))
                return
            end
            %put these file names into the popupmenu
            set(oFigure.oGuiHandle.pmFileSelector,'string',sDataFileName);
            %get the optical data
            oFigure.oGuiHandle.oOptical(numel(sDataFileName),1) = Optical;
            for i = 1:numel(sDataFileName)
                sLongDataFileName=strcat(sDataPathName,char(sDataFileName{i}));
                [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
                switch (ext)
                    case '.csv'
                        oFigure.oGuiHandle.oOptical(i) = GetOpticalRecordingFromCSVFile(oFigure.oGuiHandle.oOptical(i), sLongDataFileName, []);
                    case '.mat'
                        oFigure.oGuiHandle.oOptical(i) = GetOpticalFromMATFile(oFigure.oGuiHandle.oOptical(i), sLongDataFileName);
                end
            end
            oFigure.SelectedChannel = 1;
            oFigure.SelectedFile = 1;
            if isfield(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(1),'SignalEvent')
                oFigure.SelectedEventID = 1;
            end
            if ~isempty(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats)
                oFigure.SelectedBeat = 1;
                oFigure.OpenBeatSlider();
            end
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function oFigure = oSmoothMenu_Callback(oFigure,src,event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %Smooth the signal being used for beat detection
                aInOptions = struct('Procedure','','Inputs',cell(1,1));
                aInOptions.Procedure = 'FilterData';
                aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).ProcessElectrodeData(1, aInOptions);
                if isfield(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(oFigure.SelectedChannel).Processed,'Beats')
                    oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).RefreshBeatData();
                end
                oFigure.Replot(oFigure.SelectedChannel);
            end
        end
        
        function oFigure = oDetectBeatsMenu_Callback(oFigure,src,event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %Detect the beats through the selected signal
                
                sThresholdType = 'Peaks';
                aTimeSeries = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries;
                oElectrodes = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes;
                %Process the data if it isn't already
                if strcmp(oElectrodes(1).Status,'Potential')
                    oElectrodes(oFigure.SelectedChannel).Processed.Data = oElectrodes.Potential.Data;
                    oElectrodes(oFigure.SelectedChannel).Status = 'Processed';
                end
                aData = abs(oElectrodes(oFigure.SelectedChannel).Processed.Curvature);                   
                aOptions = {{'oInstructionText','string','Select a range of data during quiescence'} ; ...
                    {'oBottomText','string','How many standard deviations to apply?'} ; ...
                    {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                    {'oReturnButton','string','Done'} ; ...
                    {'oAxes','title','Curvature'}};
                oGetThresholdFigure = ThresholdData(oFigure, aTimeSeries, aData, sThresholdType, aOptions);
                %Add a listener so that the figure knows when a user has
                %calculated the threshold
                addlistener(oGetThresholdFigure,'ThresholdCalculated',@(src,event) oFigure.ThresholdCurvature(src, event));
            end
        end
          
        function pmFileSelectorMenu_Callback(oFigure, src, event)
            oFigure.SelectedFile = get(oFigure.oGuiHandle.pmFileSelector,'value');
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function oMapElectrodesMenu_Callback(oFigure, src, event);
            %Open a electrode map plot
            oMapElectrodesFigure = MapElectrodes(oFigure,oFigure,'oOptical');
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oMapElectrodesFigure,'ElectrodeSelected',@(src,event) oFigure.ElectrodeSelected(src, event));
            addlistener(oMapElectrodesFigure,'BeatChange',@(src,event) oFigure.BeatSlideValueListener(src, event));
            addlistener(oMapElectrodesFigure,'ChannelGroupSelection',@(src,event) oFigure.ChannelSelectionChange(src, event));
        end
        
        function oBeatPlotMenu_Callback(oFigure,src,event)
            %Open a beat plot
            oBeatPlotFigure = BeatPlot(oFigure,oFigure,'oOptical');
            addlistener(oBeatPlotFigure,'SignalEventRangeChange',@(src,event) oFigure.SignalEventRangeListener(src, event));
            addlistener(oBeatPlotFigure,'SignalEventDeleted',@(src,event) oFigure.SignalEventDeleted(src,event));
            addlistener(oBeatPlotFigure,'SignalEventSelected',@(src,event) oFigure.SignalEventSelected(src,event));
            addlistener(oBeatPlotFigure,'SignalEventMarkChange',@(src,event) oFigure.SignalEventMarkChange(src,event));
            addlistener(oBeatPlotFigure,'TimePointChange',@(src,event) oFigure.TimeSlideValueListener(src,event));
            
            %Open a time point slider
            oTimeSliderControl = SlideControl(oFigure,'Select Time Point',{'TimeSelectionChange'});
            iBeatLength = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes(oFigure.SelectedBeat,2) - ...
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes(oFigure.SelectedBeat,1);
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
             aControlData{3} = {'SteepestPositiveSlope','SteepestNegativeSlope','MaxSignalMagnitude','HalfSignalMagnitude'};
             aControlData{4} = {'AllBeats','SelectedBeat'};
             aControlData{5} = {'AllElectrodes'};
             oMixedControl = MixedControl(oFigure,'Enter the label colour, event type, marking technique, beat selection and electrode selection for the new event.',aControlData);
             addlistener(oMixedControl,'ValuesEntered',@(src,event) oFigure.NewEventCreated(src, event));
        end
         
        function oGetSlopeMenu_Callback(oFigure, src, event)
            oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).GetSlope();
            oFigure.Replot(oFigure.SelectedChannel); 
        end
         
        function bAcceptChannel_Callback(oFigure,src,event)
            ButtonState = get(oFigure.oGuiHandle.bRejectChannel,'Value');
            if ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Max')
                % Toggle button is pressed
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).RejectChannel(oFigure.SelectedChannel);
                notify(oFigure,'ChannelSelected');
            elseif ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Min')
                % Toggle button is not pressed
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).AcceptChannel(oFigure.SelectedChannel);
                notify(oFigure,'ChannelSelected');
            end
            oFigure.Replot(oFigure.SelectedChannel);
        end
    end
    
    methods (Access = private)
        %% event listeners
        function ThresholdCurvature(oFigure, src, event)
            for i = 1:numel(oFigure.oGuiHandle.oOptical)
                oFigure.oGuiHandle.oOptical(i).GetArrayBeats(event.ArrayData);
            end
            oFigure.SelectedBeat = 1;
            oFigure.OpenBeatSlider();
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function ElectrodeSelected(oFigure, src, event)
            oFigure.PreviousChannel = oFigure.SelectedChannel;
            oFigure.SelectedChannel = event.Value;
            notify(oFigure,'ChannelSelected',DataPassingEvent([],oFigure.SelectedChannel));
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function BeatSlideValueListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new beat using the
            %SlideControl
            oFigure.SelectedBeat = event.Value;
            notify(oFigure,'BeatSelectionChange',DataPassingEvent([1 size(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes,1)], oFigure.SelectedBeat));
            oFigure.Replot(oFigure.SelectedChannel);
        end
         
         function TimeSlideValueListener(oFigure, src, event)
             %An event listener callback
             %Is called when the user selects a new time point using the
             %SlideControl
             %Save the value and pass on the event notification
             oFigure.SelectedTimePoint = event.Value;
             iBeatLength = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes(oFigure.SelectedBeat,2) - ...
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes(oFigure.SelectedBeat,1);
             notify(oFigure,'TimeSelectionChange', DataPassingEvent([1 iBeatLength],oFigure.SelectedTimePoint));
         end
        
        function SignalEventRangeListener(oFigure,src, event)
            oFigure.Replot(oFigure.SelectedChannel);
            notify(oFigure,'EventRangeChange');
        end
        
        function SignalEventDeleted(oFigure,src,event)
            oFigure.SelectedEventID = [];
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function SignalEventSelected(oFigure, src, event)
            %Pass on notification
            oFigure.SelectedEventID = event.Value;
            oFigure.Replot(oFigure.SelectedChannel);
            notify(oFigure,'SignalEventSelectionChange',DataPassingEvent([],event.Value));
        end
        
        function SignalEventMarkChange(oFigure, src, event)
            %Replot just the specified channel
            notify(oFigure,'EventMarkChange');
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
         function NewEventCreated(oFigure,src,event)
             %Get the values from the mixedcontrol
             switch (char(event.Values{5}))
                 case 'CurrentElectrode'
                     aElectrodes = oFigure.SelectedChannel;
                 case 'SelectedElectrodes'
                     aElectrodes = oFigure.SelectedChannels;
                 case 'AllElectrodes'
                     aElectrodes = 1:length(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes);
             end
             switch (char(event.Values{4}))
                 case 'AllBeats'
                     aBeats = 1:1:size(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes,1);
                 case 'SelectedBeat'
                     aBeats = oFigure.SelectedBeat;
             end
             oFigure.oGuiHandle.oOptical.CreateNewEvent(aElectrodes, aBeats, char(event.Values{1}), char(event.Values{2}), char(event.Values{3}));
             if isempty(oFigure.SelectedEventID)
                 oFigure.SelectedEventID = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(1).SignalEvents{1};
             end
             oFigure.Replot(oFigure.SelectedChannel);
             notify(oFigure,'NewSignalEventCreated');
         end
         
         function CheckRejectToggleButton(oFigure)
             if oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(oFigure.SelectedChannel).Accepted
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',0);
             else
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',1);
             end
         end
         
          function ChannelSelectionChange(oFigure,src,event)
             %An event listener callback
             %Is called when the user selects a new set of channels and hits
             %the update selection menu option in MapElectrodes.fig
             %Draw plots
             oFigure.SelectedChannels = event.ArrayData;
             %Fill plots
             oFigure.Replot(oFigure.SelectedChannel);
          end
  
    end
    
    methods (Access = public);
        %% Public functions
        function Replot(oFigure,iChannel)
            if ~isempty(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile))
                %plot data
                oElectrode = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(iChannel);
                oOptical = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile);
                if strcmp(oElectrode.Status,'Processed')
                    if isfield(oElectrode.Processed,'Beats')
                        %then need to set up axes for plotting both HR and
                        %data
                        oFigure.oGuiHandle.oPanel = panel(oFigure.oGuiHandle.uipanel);
                        oFigure.oGuiHandle.oPanel.pack(2,1);
                        oFigure.oGuiHandle.oPanel.margin = [10 5 5 5];
                        oFigure.oGuiHandle.oPanel(oFigure.DataAxes).margin = [5 5 0 0];
                        oFigure.oGuiHandle.oPanel(oFigure.HeartRateAxes).margin = [5 5 0 0];
                        %plot the processed data
                        oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                        if oElectrode.Accepted
                            plot(oDataAxes,oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                            hold(oDataAxes,'on');
                            plot(oDataAxes,oOptical.TimeSeries,oElectrode.Processed.Beats,'-g');
                            plot(oDataAxes,oOptical.TimeSeries(...
                                oOptical.Beats.Indexes(oFigure.SelectedBeat,1):...
                                oOptical.Beats.Indexes(oFigure.SelectedBeat,2)),...
                                oElectrode.Processed.Data(...
                                oOptical.Beats.Indexes(oFigure.SelectedBeat,1):...
                                oOptical.Beats.Indexes(oFigure.SelectedBeat,2)),'-b');
                            hold(oDataAxes,'off');
                        else
                            plot(oDataAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries,oElectrode.(oElectrode.Status).Data,'r');
                        end
                        
                        %plot the rate data
                        oRateAxes = oFigure.oGuiHandle.oPanel(oFigure.HeartRateAxes,1).select();
                        aRateData = oOptical.GetBeatRateData(iChannel);
                        hline = plot(oRateAxes,oOptical.TimeSeries, aRateData,'k');
                        set(hline,'linewidth',1.5);
                        if oFigure.SelectedBeat > 1
                            hold(oRateAxes,'on');
                            hline = plot(oRateAxes,oOptical.TimeSeries(...
                                oElectrode.Processed.BeatRateIndexes(oFigure.SelectedBeat-1):...
                                oElectrode.Processed.BeatRateIndexes(oFigure.SelectedBeat)), ...
                                aRateData(oElectrode.Processed.BeatRateIndexes(oFigure.SelectedBeat-1):...
                                oElectrode.Processed.BeatRateIndexes(oFigure.SelectedBeat)),'r');
                            hold(oRateAxes,'off');
                            set(hline,'linewidth',1.5);
                        end
                        set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
                        for i = 2:4:numel(oElectrode.Processed.BeatRates)
                            oBeatLabel = text(oOptical.TimeSeries(oElectrode.Processed.BeatRateIndexes(i)),...
                                oElectrode.Processed.BeatRates(i), sprintf('%d',i),'parent',oRateAxes);
                            set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','normalized','horizontalalignment','center');
                            set(oBeatLabel,'FontSize',0.05);
                        end
                    else
                        %just plot processed data
                        oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                        if oElectrode.Accepted
                            plot(oDataAxes,oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                        else
                            plot(oDataAxes,oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'r');
                        end
                    end
                else
                    %just plot potential data
                    oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                    if oElectrode.Accepted
                        plot(oDataAxes,oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                    else
                        plot(oDataAxes,oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'r');
                    end
                end
            end
            oFigure.CheckRejectToggleButton();
        end
        
        function OpenBeatSlider(oFigure)
            %Set up beat slider
            oBeatSliderControl = SlideControl(oFigure,'Select Beat', {'BeatSelectionChange','NewBeatInserted'});
            iNumBeats = size(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Beats.Indexes,1);
            set(oBeatSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumBeats, 'Value', 1 ,'SliderStep',[1/iNumBeats  0.02]);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oBeatSliderControl.oGuiHandle.oSliderTxtRight,'string',iNumBeats);
            set(oBeatSliderControl.oGuiHandle.oSliderEdit,'string',1);
            addlistener(oBeatSliderControl,'SlideValueChanged',@(src,event) oFigure.BeatSlideValueListener(src, event));
        end
        
        function sEventID = GetEventIDFromTag(oFigure, sTag)
             %Find the event number specified by the input handle tag
             [~,~,~,~,~,~,splitstring] = regexpi(sTag,'_');
             sEventID = char(splitstring(1,2));
        end
         
        function iChannel = GetChannelFromTag(oFigure, sTag)
            %Find the channel specified by the input handle tag
            [~,~,~,~,~,~,splitstring] = regexpi(sTag,'_');
            iChannel = str2double(char(splitstring(1,1)));
        end
        
        function oRejectAllMenu_Callback(oFigure,src,event)
            %Reject all selected channels
            for i = 1:length(oFigure.SelectedChannels)
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).RejectChannel(oFigure.SelectedChannels(i));
            end
            oFigure.Replot(oFigure.SelectedChannel);
        end
        
        function oAcceptAllMenu_Callback(oFigure,src,event)
            %Reject all selected channels
            for i = 1:length(oFigure.SelectedChannels)
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).AcceptChannel(oFigure.SelectedChannels(i));
            end
            oFigure.Replot(oFigure.SelectedChannel);
        end
    end
end
