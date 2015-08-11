classdef OpticalBeatDetection < BaseFigure
    %this figure is designed to load a csv file containing optical mapping
    %data and enable the user to detect beats
    properties
        DataAxes = 1;
        HeartRateAxes = 2;
        SelectedElectrode;
        PreviousElectrode;
        SelectedBeat;
        SelectedFile;
    end
    
    events
        ChannelSelected;
        BeatSelectionChange;
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
            set(oFigure.oGuiHandle.oLoadBeatsMenu, 'callback', @(src, event) oLoadBeatsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMapElectrodesMenu,'callback', @(src, event) oMapElectrodesMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oBeatPlotMenu,'callback', @(src, event) oBeatPlotMenu_Callback(oFigure, src, event));            
            set(oFigure.oGuiHandle.pmFileSelector, 'callback', @(src, event) pmFileSelectorMenu_Callback(oFigure, src, event));
            
            %set up axes
            oFigure.oGuiHandle.oPanel = panel(oFigure.oGuiHandle.uipanel);
            oFigure.oGuiHandle.oPanel.pack(1,1);
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
        
        function oFigure = oOpenMenu_Callback(oFigure,src,event)
            [sDataFileName,sDataPathName]=uigetfile('*.*','Select a CSV file that contains an optical transmembrane recording','multiselect','on');
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
                oFigure.oGuiHandle.oOptical(i) = GetOpticalRecordingFromCSVFile(oFigure.oGuiHandle.oOptical(i), sLongDataFileName, []);
            end
            oFigure.SelectedElectrode = 1;
            oFigure.SelectedFile = 1;
            oFigure.Replot(oFigure.SelectedElectrode);
        end
        
        function oFigure = oSmoothMenu_Callback(oFigure,src,event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %Smooth the signal being used for beat detection
                aInOptions = struct('Procedure','','Inputs',cell(1,1));
                aInOptions.Procedure = 'FilterData';
                aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
                oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).ProcessElectrodeData(1, aInOptions);
                if isfield(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(oFigure.SelectedElectrode).Processed,'Beats')
                    oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).RefreshBeatData();
                end
                oFigure.Replot(oFigure.SelectedElectrode);
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
                    oElectrodes(oFigure.SelectedElectrode).Processed.Data = oElectrodes.Potential.Data;
                    oElectrodes(oFigure.SelectedElectrode).Status = 'Processed';
                end
                aData = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).CalculateCurvature(oElectrodes(oFigure.SelectedElectrode).Processed.Data,20,5);
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
            oFigure.Replot(oFigure.SelectedElectrode);
        end
        
        function oMapElectrodesMenu_Callback(oFigure, src, event);
            %Open a electrode map plot
            oMapElectrodesFigure = MapElectrodes(oFigure);
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oMapElectrodesFigure,'ElectrodeSelected',@(src,event) oFigure.ElectrodeSelected(src, event));
            addlistener(oMapElectrodesFigure,'BeatChange',@(src,event) oFigure.BeatSlideValueListener(src, event));
        end
        
        function oBeatPlotMenu_Callback(oFigure,src,event)
            %             %Open a beat plot
            %             oBeatPlotFigure = BeatPlot(oFigure);
            %             addlistener(oBeatPlotFigure,'SignalEventRangeChange',@(src,event) oFigure.SignalEventRangeListener(src, event));
            %             addlistener(oBeatPlotFigure,'SignalEventDeleted',@(src,event) oFigure.SignalEventDeleted(src,event));
            %             addlistener(oBeatPlotFigure,'SignalEventSelected',@(src,event) oFigure.SignalEventSelected(src,event));
            %             addlistener(oBeatPlotFigure,'SignalEventMarkChange',@(src,event) oFigure.SignalEventMarkChange(src,event));
            %             addlistener(oBeatPlotFigure,'TimePointChange',@(src,event) oFigure.TimeSlideValueListener(src,event));
            %
            %             %Open a time point slider
            %             oTimeSliderControl = SlideControl(oFigure,'Select Time Point',{'TimeSelectionChange'});
            %             iBeatLength = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,2) - ...
            %                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes(oFigure.SelectedBeat,1);
            %             set(oTimeSliderControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
            %                 iBeatLength, 'Value', oFigure.SelectedTimePoint,'SliderStep',[1/iBeatLength  0.02]);
            %             set(oTimeSliderControl.oGuiHandle.oSliderTxtLeft,'string',1);
            %             set(oTimeSliderControl.oGuiHandle.oSliderTxtRight,'string',iBeatLength);
            %             set(oTimeSliderControl.oGuiHandle.oSliderEdit,'string',oFigure.SelectedTimePoint);
            %             addlistener(oTimeSliderControl,'SlideValueChanged',@(src,event) oFigure.TimeSlideValueListener(src, event));
        end
    end
    
    methods (Access = private)
        %% event listeners
        function ThresholdCurvature(oFigure, src, event)
            for i = 1:numel(oFigure.oGuiHandle.oOptical)
                oFigure.oGuiHandle.oOptical(i).GetArrayBeats(event.ArrayData);
            end
            oFigure.SelectedBeat = 1;
            oFigure.Replot(oFigure.SelectedElectrode);
        end
        
        function ElectrodeSelected(oFigure, src, event)
            oFigure.PreviousElectrode = oFigure.SelectedElectrode;
            oFigure.SelectedElectrode = event.Value;
            notify(oFigure,'ChannelSelected',DataPassingEvent([],oFigure.SelectedElectrode));
            oFigure.Replot(oFigure.SelectedElectrode);
        end
        
        function BeatSlideValueListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new beat using the
            %SlideControl
            oFigure.SelectedBeat = event.Value;
            notify(oFigure,'BeatSelectionChange',DataPassingEvent([1 size(oFigure.oGuiHandle.oOptical.Electrodes(1).Processed.BeatIndexes,1)], oFigure.SelectedBeat));
        end
    end
    
    methods (Access = public);
        %% Public functions
        function Replot(oFigure,iChannel)
            if ~isempty(oFigure.oGuiHandle.oOptical(oFigure.SelectedFile))
                %plot data
                oElectrode = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).Electrodes(iChannel);
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
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                        hold(oDataAxes,'on');
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries,oElectrode.Processed.Beats,'-g');
                        hold(oDataAxes,'off');
                        %plot the rate data
                        oRateAxes = oFigure.oGuiHandle.oPanel(oFigure.HeartRateAxes,1).select();
                        [aRateData dPeaks] = oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).CalculateSinusRate(1);
                        hline = plot(oRateAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries, aRateData,'k');
                        set(hline,'linewidth',1.5);
                    else
                        %just plot processed data
                        oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                    end
                else
                    %just plot potential data
                    oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                    plot(oDataAxes,oFigure.oGuiHandle.oOptical(oFigure.SelectedFile).TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                end
            end
        end
    end
end
