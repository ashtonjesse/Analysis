classdef PressureAnalysis < SubFigure
% PressureAnalysis Summary of this class goes here

    properties
        DefaultPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\';
        Plots = [];
        CurrentZoomLimits = [];
        SelectedExperiments = [];
        Colours = ['k','r','b','g','c'];
        CurrentPlotNumber = 0;
        SelectedElectrode;
        FontSize = 8;
        RecordingType = 'Extracellular';
        SignalToUseForBeatDetection;
        SelectedBeat = [];
        SelectedRecordings = [];
        Peaks = [];
    end
    
    events
        FigureDeleted;
    end
    
    methods
        %% Constructor
        function oFigure = PressureAnalysis(oParent,sRecordingType)
            oFigure = oFigure@SubFigure(oParent,'PressureAnalysis',@OpeningFcn);
            
            %set properties
            oFigure.RecordingType = sRecordingType;
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oResampleMenu, 'callback', @(src, event) oResampleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateToUnemapMenu, 'callback', @(src, event) oTruncateToUnemapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateMenu, 'callback', @(src, event) oTruncateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenSingleMenu, 'callback', @(src, event) oOpenSingleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMultiMenu, 'callback', @(src, event) oOpenMultiMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportMenu, 'callback', @(src, event) oExportMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTimeAlignMenu, 'callback', @(src, event) oTimeAlignMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectBeatsMenu, 'callback', @(src, event) oDetectBeatsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothMenu, 'callback', @(src, event) oSmoothMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothPressureMenu, 'callback', @(src, event) oSmoothPressureMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateRefMenu, 'callback', @(src, event) oTruncateRefMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectBurstsMenu, 'callback', @(src, event) oDetectBurstsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdatePhrenicMenu, 'callback', @(src, event) oUpdatePhrenicMenu_Callback(oFigure, src, event));

            %get the children that belong to oExperimentPanel to set
            %properties
            oExpChildren = get(oFigure.oGuiHandle.oExperimentPanel,'children');
            for i = 1:length(oExpChildren)
                set(oExpChildren(i), 'callback', @(src, event) oExperimentSelection_Callback(oFigure, src, event));
            end
            %repeat for RecordingPanel
            oRecChildren = get(oFigure.oGuiHandle.oRecordingPanel,'children');
            for i = 1:length(oRecChildren)
                set(oRecChildren(i), 'callback', @(src, event) oRecordingSelection_Callback(oFigure, src, event));
            end
            
            set(oFigure.oGuiHandle.oChannelSelector, 'callback', @(src, event) oChannelSelector_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oHRSignalSelector, 'callback', @(src, event) oHRSignalSelector_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
           
            %set and save the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', @(src,event) ThisKeyPressFcn(oFigure, src, event));
            oldKeyPressFcnHook = get(oFigure.oGuiHandle.(oFigure.sFigureTag), 'KeyPressFcn');
            
            %Turn zoom on for this figure
            set(oFigure.oZoom,'enable','on');
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            %disable the listeners hold
            hManager = uigetmodemanager(oFigure.oGuiHandle.(oFigure.sFigureTag));
            set(hManager.WindowListenerHandles,'Enable','off');
             %reset the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', oldKeyPressFcnHook);
            
            %set up the checkboxes and plots
            switch (oFigure.RecordingType)
                case 'Extracellular'
                    sPlotNames = {'Pressure','Reference Signal', 'Unemap Reference Signal', 'Phrenic Integral', 'VRMS', 'Heart Rate', };
                case 'Optical'
                    sPlotNames = {'Pressure','Reference Signal', 'Optical Signal', 'Phrenic Signal', 'Heart Rate', 'Phrenic Integral', 'Phrenic Burst Rate', };
            end
            %set the default (first option in both cases)
            oFigure.SignalToUseForBeatDetection = 'Reference Signal';
            for i = 1:length(sPlotNames)
                oFigure.Plots(i).ID = 0;
                oFigure.Plots(i).Visible = 0;
                oFigure.Plots(i).Name = char(sPlotNames(i));
                oFigure.Plots(i).Checkbox = uicontrol(oFigure.oGuiHandle.oPlotPanel, 'style', 'checkbox', 'string', oFigure.Plots(i).Name, 'callback',  ...
                    @(src, event) oPlotSelector_Callback(oFigure, src, event), 'value', 0, 'visible', 'off','units','characters');
                set(oFigure.Plots(i).Checkbox, 'position', [3 13-(i-1)*1.875, 34, 1.75]);
            end

            
            if ~isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %Plot the data
                for i = 1:length(oFigure.Plots)
                    set(oFigure.Plots(i).Checkbox,'visible','on');
                end
                set(oFigure.Plots(1).Checkbox,'value', 1,'visible', 'on');
                oFigure.Plots(1).Visible = 1;
                oFigure.Replot();
                oXLim = get(oFigure.Plots(1).ID,'XLim');
                oYLim = get(oFigure.Plots(1).ID,'YLim');
                oFigure.CurrentZoomLimits = [oXLim ; oYLim];
                
                for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording)
                    set(oRecChildren(i), 'visible', 'on', 'string', strcat(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(i).Name,'_',oFigure.Colours(i)));
                end
            end
            
            % --- Executes just before BaselineCorrection is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %set the electrode options
                if isfield(oParent.oGuiHandle,'oUnemap')
                    aChannelNames = {oParent.oGuiHandle.oUnemap.Electrodes(:).Name};
                    set(handles.oChannelSelector,'string',aChannelNames);
                end
                %Set the options for signals that can be used to calculate
                %a heart rate plot from
                switch (sRecordingType)
                    case 'Extracellular'
                        set(handles.oHRSignalSelector,'string',{'Reference Signal', 'Unemap Reference Signal', 'VRMS'});
                    case 'Optical'
                        set(handles.oHRSignalSelector,'string',{'Reference Signal', 'Optical Signal', 'Phrenic'});
                end
                
                handles.output = hObject;
                %Update the gui handles
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            notify(oFigure,'FigureDeleted');
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        function oHRSignalSelector_Callback(oFigure, src, event)
            %get the selection and save it to the figure properties
            oFigure.SignalToUseForBeatDetection = cell2mat(oFigure.GetPopUpSelectionString('oHRSignalSelector'));
        end
        
        function oChannelSelector_Callback(oFigure, src, event)
            %Plot the selected electrode
            sString = oFigure.GetPopUpSelectionString('oChannelSelector');
            oFigure.SelectedElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName(sString);
            oPlot = oFigure.GetPlotByName('Electrode');
            if ~isempty(oPlot)
                cla(oPlot.ID);
                oFigure.PlotElectrode(oPlot.ID, oFigure.SelectedElectrode);
                set(oPlot.ID,'xminortick','off');
                xlabel(oPlot.ID,'');
                set(oPlot.ID,'xticklabel',[]);
                xlim(oPlot.ID,get(oFigure.Plots(1).ID,'xlim'));
            end
            
        end
        
        function oPlot = GetPlotByName(oFigure, sPlotName)
            %Get plot names
            aPlotNames = {oFigure.Plots(:).Name};
            aIndex = strcmpi(aPlotNames, sPlotName);
            oPlot = oFigure.Plots(aIndex);
        end
        
        function oExperimentSelection_Callback(oFigure, src, event)
            %Reset the selected experiments
            oFigure.SelectedExperiments = [];
            %get the children
            oCheckBoxes = get(oFigure.oGuiHandle.oExperimentPanel,'children');
            %Loop through the checkboxes and check their value
            for i = 1:length(oCheckBoxes)
                dValue = get(oCheckBoxes(i),'value');
                dVisible = get(oCheckBoxes(i),'visible');
                if dValue && strcmp(dVisible,'on')
                    oFigure.SelectedExperiments = [oFigure.SelectedExperiments , i];
                end
            end
        end
        
        function oRecordingSelection_Callback(oFigure, src, event)
            %Reset the selected experiments
            oFigure.SelectedRecordings = [];
            %get the children
            oCheckBoxes = get(oFigure.oGuiHandle.oRecordingPanel,'children');
            %Loop through the checkboxes and check their value
            for i = 1:length(oCheckBoxes)
                dValue = get(oCheckBoxes(i),'value');
                dVisible = get(oCheckBoxes(i),'visible');
                if dValue && strcmp(dVisible,'on')
                    oFigure.SelectedRecordings = [oFigure.SelectedRecordings , i];
                end
            end
            oFigure.Replot();
        end
        
        function oPlotSelector_Callback(oFigure, src, event)
            %Work out which check box fired this and recreate the plots
            
            %Get the value of the checkbox
            dIndex = find([oFigure.Plots(:).Checkbox] == src);
            if ~isempty(dIndex)
                %check if the selection corresponds to 'Electrode'
                if dIndex == find(strcmp({oFigure.Plots(:).Name},'Electrode'))
                    if get(src, 'value')
                        set(oFigure.oGuiHandle.oChannelSelector,'visible', 'on');
                    else
                        set(oFigure.oGuiHandle.oChannelSelector,'visible', 'off');
                    end
                end
                %update the visibility of this plot
                oFigure.Plots(dIndex).Visible = get(src, 'Value');
                oFigure.Replot();
                
            end
        end
        
        function ThisKeyPressFcn(oFigure, src, event)
            switch event.Key
                case 'delete'
                    oFigure.DeleteSelectedBeat();
            end
        end
        
        function DeleteSelectedBeat(oFigure)
            %Delete the currently selected beat
            if ~isempty(oFigure.SelectedBeat)
                switch (oFigure.SignalToUseForBeatDetection)
                    case {'Optical Signal','VRMS'}
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).DeleteBeat(oFigure.SelectedBeat);
                    case 'Phrenic'
                        oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.DeleteBeat(oFigure.SelectedBeat);
                end
                
            end
            oFigure.SelectedBeat = [];
            %replot
            oFigure.Replot();
        end
        
        % --------------------------------------------------------------------
        function PostZoom_Callback(oFigure, src, event)
            %Synchronize the zoom of all the axes
            
            %Get the current axes and selected limit
            oCurrentAxes = event.Axes;
            oXLim = get(oCurrentAxes,'XLim');
            oFigure.CurrentZoomLimits(1,:) = oXLim;
            %Apply to axes
            dIndex = find([oFigure.Plots(:).ID] == oCurrentAxes);
            %get copy of plots
            oPlots = oFigure.Plots;
            oPlots(dIndex) = [];
            for i = 1:length(oPlots)
                if oPlots(i).Visible
                    set(oPlots(i).ID,'XLim',oXLim);
                end
            end
        end
        
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end    
        
        % -----------------------------------------------------------------
        function oDetectBurstsMenu_Callback(oFigure, src, event)
            % Prepare the phrenic data for burst detection by reducing the
            % power of the ECG artifact using DWT, calculate integral and
            % then allow user to select threshold
            
            %Keep filter scale 1
            aBurstData = ComputeDWTFilteredSignalsKeepingScales(oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic, ...
                oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed.Data,1);
            %calc bin integral of this
            aBurstData = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.ComputeRectifiedBinIntegral(aBurstData, 500);
            %open threshold window
            %set variables for call to ThresholdFigure
            aTimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.TimeSeries;
            aOptions = {{'oInstructionText','string','Enter a threshold value to use'} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oEditText','string','Threshold value to use'} ; ...
                {'bCalcThreshold','visible','off'} ; ...
                {'oReturnButton','string','Done'}};
            oGetThresholdFigure = ThresholdData(oFigure, aTimeSeries, aBurstData, 'Values', aOptions);
            %Add a listener so that the figure knows when a user has
            %calculated the threshold
            addlistener(oGetThresholdFigure,'ThresholdCalculated',@(src,event) oFigure.ThresholdPhrenicBursts(src, event));
        end
        
        function oDetectBeatsMenu_Callback(oFigure, src, event)
            %Detect the beats through the selected signal
            %Set the defaults
            aTimeSeries = [];
            aData = [];
            aOptions = {};
            %Work out which signal to use for beat detection
            sThresholdType = 'Peaks';
            switch (oFigure.SignalToUseForBeatDetection)
                case 'Reference Signal'
                    %set variables for call to ThresholdFigure
                    aTimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.Status);
                    aData = oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Status);
                    aOptions = {{'oInstructionText','string','Enter a threshold value to use'} ; ...
                        {'oBottomText','visible','off'} ; ...
                        {'oBottomPopUp','visible','off'} ; ...
                        {'oEditText','string','Threshold value to use'} ; ...
                        {'bCalcThreshold','visible','off'} ; ...
                        {'oReturnButton','string','Done'}};
                case 'Unemap Reference Signal'
                    %set variables for call to ThresholdFigure
                    aTimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.TimeSeries;
                    aData = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes...
                        .(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes.Status).Data;
                    aOptions = {{'oInstructionText','string','Enter a threshold value to use'} ; ...
                        {'oBottomText','visible','off'} ; ...
                        {'oBottomPopUp','visible','off'} ; ...
                        {'oEditText','string','Threshold value to use'} ; ...
                        {'bCalcThreshold','visible','off'} ; ...
                        {'oReturnButton','string','Done'}};
                case 'VRMS'
                    %refresh the RMS curvature data
                    oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values = ...
                        oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateCurvature(...
                        oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed, ...
                        20,5);
                    %set variables for call to ThresholdFigure
                    aTimeSeries = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries;
                    aData = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values;
                    aOptions = {{'oInstructionText','string','Select a range of data during quiescence'} ; ...
                        {'oBottomText','string','How many standard deviations to apply?'} ; ...
                        {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                        {'oReturnButton','string','Done'} ; ...
                        {'oAxes','title','Curvature'}};
                case 'Optical Signal'
                    aTimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).TimeSeries;
                    oElectrodes = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes;
                    %Process the data if it isn't already
                    if strcmp(oElectrodes(1).Status,'Potential')
                        oElectrodes(1).Processed.Data = oElectrodes(1).Potential.Data;
                        oElectrodes(1).Status = 'Processed';
                    end
                    aData = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).CalculateCurvature(...
                        oElectrodes(1).Processed.Data,20,5);
                    aOptions = {{'oInstructionText','string','Select a range of data during quiescence'} ; ...
                        {'oBottomText','string','How many standard deviations to apply?'} ; ...
                        {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                        {'oReturnButton','string','Done'} ; ...
                        {'oAxes','title','Curvature'}};
                case 'Phrenic'
                     %set variables for call to ThresholdFigure
                    aTimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.TimeSeries;
                    aData = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.CalculateCurvature(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Status).Data,20,5);
                    aOptions = {{'oInstructionText','string','Select a range of data during quiescence'} ; ...
                        {'oBottomText','string','How many standard deviations to apply?'} ; ...
                        {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                        {'oReturnButton','string','Done'} ; ...
                        {'oAxes','title','Curvature'}};
                    sThresholdType = 'Values';
            end
            oGetThresholdFigure = ThresholdData(oFigure, aTimeSeries, aData, sThresholdType, aOptions);
            %Add a listener so that the figure knows when a user has
            %calculated the threshold
            addlistener(oGetThresholdFigure,'ThresholdCalculated',@(src,event) oFigure.ThresholdCurvature(src, event));
        end
        
        function oUpdatePhrenicMenu_Callback(oFigure, src, event)
            oPressure = oFigure.oParentFigure.oGuiHandle.oPressure;
            oPressure.oPhrenic = Phrenic(oPressure.oExperiment,oPressure.RefSignal.Original,oPressure.TimeSeries.Original);
            oPressure.oPhrenic.TimeSeries = oPressure.TimeSeries.Processed;
            oPressure.oPhrenic.Electrodes.Processed.Data = oPressure.RefSignal.Processed;
            oPressure.oPhrenic.Electrodes.Status = 'Processed';
        end
        
        function ThresholdCurvature(oFigure, src, event)
            %Callback for listener waiting for SelectData figure event to
            %fire when a user has selected a threshold for beat detection
            %Apply the threshold
            
            %regardless of the data that was used to calculate the peaks
            %(event.ArrayData) - the beats are loaded into the
            %oPressure.oRecording (there will always be one of these)
            switch (oFigure.SignalToUseForBeatDetection)
                case {'VRMS','Optical Signal'}
                    [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).GetSinusBeats(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.Status).Data, ...
                        event.ArrayData);
                    
                    oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.Processed.Beats = cell2mat(aOutData(1));
                    oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.Processed.BeatIndexes = cell2mat(aOutData(2));
                    
                    %get the plot id associated with Optical Reference
                    %                     bIndex = strcmp('Optical Signal', {oFigure.Plots(:).Name});
                    %                     if max(bIndex) > 0
                    %                         oFigure.Plots(bIndex).Name = 'Optical Signal With Beats';
                    %                     end
                case 'Phrenic'
                    [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.GetSinusBeats(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Status).Data, ...
                        event.ArrayData);
                    
                    oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed.Beats = cell2mat(aOutData(1));
                    oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed.BeatIndexes = cell2mat(aOutData(2));
                    
                    %get the plot id associated with Optical Reference
                    bIndex = strcmp('Phrenic Signal', {oFigure.Plots(:).Name});
                    if max(bIndex) > 0
                        oFigure.Plots(bIndex).Name = 'Phrenic Signal With Beats';
                    end
                case {'Unemap Reference Signal','Reference Signal'}
                    %just save the peaks to a variable as they will be used
                    %later to calculate a heart rate
                    oFigure.Peaks = event.ArrayData;
            end
            
            oFigure.Replot();
        end
        
        function ThresholdPhrenicBursts(oFigure, src, event)
            %Use this threshold to detect the bursts
            oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.CalculateBurstRate(event.ArrayData);
        end
        
        function oSmoothMenu_Callback(oFigure, src, event)
            %Smooth the signal being used for beat detection
            aInOptions = struct('Procedure','','Inputs',cell(1,1));
            aInOptions.Procedure = 'FilterData';
            aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
            
            if strcmp(oFigure.RecordingType,'Extracellular')
                switch (oFigure.SignalToUseForBeatDetection)
                    case 'Reference Signal'
                        oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Processed = FilterData(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording, ...
                            oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Status), ...
                            aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
                        %Status should now be processed
                        oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Status = 'Processed';
                    case 'Unemap Reference Signal'
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes.Processed.Data = ...
                            oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.FilterData(...
                            oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes.Status).Data, ...
                            aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
                        %Status should now be processed
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Electrodes.Status = 'Processed';
                    case 'VRMS'
                        %check if the RMS curvature data has been calculated yet
                        if ~isfield(oFigure.oParentFigure.oGuiHandle,'oUnemap') && ...
                                ~isfield(oFigure.oParentFigure.oGuiHandle.oUnemap.RMS,'Smoothed')
                            error('PressureAnalysis.oSmoothMenu_Callback:NoData', 'You need to have loaded a Unemap file with smoothed RMS data');
                        end
                        oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed = ...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.FilterData(...
                            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed, ...
                            aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
                        oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.PolyOrder = aInOptions.Inputs{2};
                        oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.WindowSize = aInOptions.Inputs{3};
                end
            elseif strcmp(oFigure.RecordingType,'Optical')
                switch (oFigure.SignalToUseForBeatDetection)
                    case 'Reference Signal'
                         oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Processed = FilterData(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording, ...
                            oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Status), ...
                            aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
                        %Status should now be processed
                        oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.Status = 'Processed';
                    case 'Optical Signal'
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).ProcessElectrodeData(1, aInOptions);
                        if isfield(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.Processed,'Beats')
                            oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).RefreshBeatData();
                        end
                    case 'Phrenic'
                        oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.ProcessElectrodeData(1, aInOptions);
                        if isfield(oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed,'Beats')
                            oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.RefreshBeatData();
                        end

                end
            end
            oFigure.Replot();
        end
                
        function oSmoothPressureMenu_Callback(oFigure, src, event)
            %             %Apply a smoothing to the pressure data
            oPressure = oFigure.oParentFigure.oGuiHandle.oPressure;
            %             oPressure.Processed.Data = oPressure.FilterData(oPressure.(oPressure.Status).Data, 'DWTFilterRemoveScales', 12);
            oPressure.Processed.Data = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment.Optical.SamplingRate, 0.2);
            oFigure.Replot();
        end
        
        function oExportMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if (~ischar(sFilename) && ~ischar(sPathName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sPathName,sFilename);
            aPosition = get(oFigure.oGuiHandle.oPanel,'position');
            dMontageWidth = (8.27 - 2)/aPosition(3); %in inches, with borders
            dMontageHeight = 4.845/aPosition(4);
            dPixelsToChopSouth = ceil(dMontageHeight*300 - 1500);
            dPixelsToChopEast = ceil(dMontageWidth*300 - 1800);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperunits','inches');
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperposition',[0 0 dMontageWidth dMontageHeight]);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'papersize',[dMontageWidth dMontageHeight]);
            %put on a title
            aPathFolders = regexp(sPathName,'\\','split');
            sFigureTitle = char(aPathFolders{end-1});
            oChildren = get(oFigure.Plots(1).ID, 'children');
            oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'FigureTitle');
            if oHandle > 0 
                set(oHandle, 'position', [0 -0.18]); %-0.25
            else
                oFigureTitle = text('string', sFigureTitle, 'parent', oFigure.Plots(1).ID, 'tag', 'FigureTitle');
                set(oFigureTitle, 'units', 'normalized');
                set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
                set(oFigureTitle, 'position', [0 -0.18]); %-0.25
            end
            oFigure.PrintFigureToFile(sLongDataFileName);
            %             Trim the white space
            sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.bmp', sLongDataFileName)}, ...
                {' -gravity South -chop 0x'},{sprintf('%d', dPixelsToChopSouth)},{' -gravity East -chop '},{sprintf('%d', dPixelsToChopEast)},{'x0'},{sprintf(' %s.bmp', sLongDataFileName)});
            sStatus = dos(char(sChopString{1}));
        end
        
        function oOpenMultiMenu_Callback(oFigure, src, event)
            %Open a multiple pressure files
            
            %  Call built-in file dialog to select filename
            sDataPathName=uigetdir(oFigure.DefaultPath,'Select a folder containing Pressure data.');
            %Make sure the dialogs return char objects
            if ~ischar(sDataPathName)
                return
            end
            
            %Get all the labview derived files txt in the directory
            aFileFull = fGetFileNamesOnly(sDataPathName,'lb*.txt');
            
            if ~isempty(aFileFull)
                %If there are txt files in this directory then load
                %them
                if isfield(oFigure.oParentFigure.oGuiHandle,'oPressure')
                    %Append a new pressure entity to that already
                    %existing
                    oFigure.oParentFigure.oGuiHandle.oPressure = [oFigure.oParentFigure.oGuiHandle.oPressure ; Pressure()];
                    for i = 1:length(aFileFull)
                        oFigure.oParentFigure.oGuiHandle.oPressure(end) =  GetPressureFromTXTFile(oFigure.oParentFigure.oGuiHandle.oPressure(end),char(aFileFull(i)));
                    end
                else
                    %Create a new pressure entity
                    oFigure.oParentFigure.oGuiHandle.oPressure = Pressure();
                    for i = 1:length(aFileFull)
                        oFigure.oParentFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(oFigure.oParentFigure.oGuiHandle.oPressure,char(aFileFull(i)));
                    end
                end
                
            else
                %There are no txt in this directory files
                return
            end
            
            %Plot the data
            for i = 1:length(oFigure.Plots)
                set(oFigure.Plots(i).Checkbox,'visible','on');
            end
            set(oFigure.Plots(1).Checkbox,'value', 1);
            oFigure.Plots(1).Visible = 1;
            oFigure.Replot();
        end
        
        function oTruncateRefMenu_Callback(oFigure, src, event)
            oSelectDataFigure = SelectData(oFigure,'SelectData',oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.Status).Data,...
                {{'oInstructionText','string','Select a range of data to truncate.'} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oReturnButton','string','Done'} ; ...
                {'oAxes','title','Reference Signal'}});
            %Add a listener so that the figure knows when a user has
            %selected the data to truncate
            addlistener(oSelectDataFigure,'DataSelected',@(src,event) oFigure.TruncateRefData(src, event));
        end
                
        function oFigure = oOpenSingleMenu_Callback(oFigure, src, event)
            %Open a single pressure file
            
            if isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %  Call built-in file dialog to select filename
                [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing Pressure data',oFigure.DefaultPath);
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                    return
                end
                %Check the extension
                sLongDataFileName=strcat(sDataPathName,sDataFileName);
                %                 sLongDataFileName = 'D:\Users\jash042\Documents\PhD\Analysis\Database\20130221\pbaropacetest004_pressure.mat';
                [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
                switch (ext)
                    case '.txt'
                        oFigure.oParentFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(Pressure,sLongDataFileName);
                    case '.mat'
                        oFigure.oParentFigure.oGuiHandle.oPressure = GetPressureFromMATFile(Pressure,sLongDataFileName,oFigure.RecordingType);
                end
                oFigure.oParentFigure.oGuiHandle.oPressure.RecordingType = oFigure.RecordingType;
                if strcmp(oFigure.oParentFigure.oGuiHandle.oPressure.RecordingType, 'Extracellular') && isempty(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording)
                    [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing Unemap signal data',oFigure.DefaultPath);
                    %Make sure the dialogs return char objects
                    if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                        return
                    end
                    %Check the extension
                    sLongDataFileName=strcat(sDataPathName,sDataFileName);
                    
                    %Get the unemap reference data
                    oFigure.oParentFigure.oGuiHandle.oPressure.oRecording = GetSpecificElectrodeFromTXTFile(Unemap, 289, sLongDataFileName, oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment);
                elseif strcmp(oFigure.oParentFigure.oGuiHandle.oPressure.RecordingType, 'Optical') && isempty(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording)
                    [sDataFileName,sDataPathName]=uigetfile('*.*','Select a CSV file that contains an optical transmembrane recording',oFigure.DefaultPath,'MultiSelect','on');
                    %check if multiple files were selected
                    if iscell(sDataFileName)
                        %Make sure the dialogs return char objects
                        if (isempty(sDataFileName) && ~ischar(sDataPathName))
                            return
                        end
                        %get the recordings checkboxes
                        oChildren = get(oFigure.oGuiHandle.oRecordingPanel,'children');
                        %get the optical data
                        for i = 1:length(sDataFileName)
                            sLongDataFileName=strcat(sDataPathName,char(sDataFileName{i}));
                            oFigure.oParentFigure.oGuiHandle.oPressure.oRecording = [oFigure.oParentFigure.oGuiHandle.oPressure.oRecording, ...
                                GetOpticalRecordingFromCSVFile(Optical, sLongDataFileName, oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment,6)];%10
                            sResult = regexp(char(sDataFileName{i}),'_');
                            sFileName = char(sDataFileName{i});
                            oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(i).Name = sFileName(1:sResult(1)-1);
                            set(oChildren(i), 'visible', 'on', 'string', strcat(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(i).Name,'_',oFigure.Colours(i)));
                        end
                    else
                        %Make sure the dialogs return char objects
                        if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                            return
                        end
                        oChildren = get(oFigure.oGuiHandle.oRecordingPanel,'children');
                        %get the optical data
                        sLongDataFileName=strcat(sDataPathName,char(sDataFileName));
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording = ...
                            GetOpticalRecordingFromCSVFile(Optical, sLongDataFileName, oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment,6);%10
                        sResult = regexp(char(sDataFileName),'_');
                        sFileName = char(sDataFileName);
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Name = sFileName(1:sResult(1)-1);
                        set(oChildren(1), 'visible', 'on', 'string', strcat(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording.Name,'_',oFigure.Colours(1)));
                    end
                elseif strcmp(oFigure.oParentFigure.oGuiHandle.oPressure.RecordingType, 'Optical')
                    %just put checkboxes for each oRecording
                    %get the recordings checkboxes
                    oChildren = get(oFigure.oGuiHandle.oRecordingPanel,'children');
                    for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording)
                        set(oChildren(i), 'visible', 'on', 'string', strcat(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(i).Name,'_',oFigure.Colours(i)));
                    end
                end
                
                %Plot the data
                for i = 1:length(oFigure.Plots)
                    set(oFigure.Plots(i).Checkbox,'visible','on');
                end
                set(oFigure.Plots(1).Checkbox,'value', 1);
                oFigure.Plots(1).Visible = 1;
                oFigure.Replot();
            end
        end
                
        function oFigure = oSaveMenu_Callback(oFigure, src, event)
            % Save the current entities
           
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the .mat file',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.oParentFigure.oGuiHandle.oPressure.Save(sLongDataFileName);
            
        end
        
        function oFigure = Unused_Callback(oFigure, src, event)
            %Default callback for menu items
        end
        
        function oResampleMenu_Callback(oFigure, src, event)
            %Resample the data to match the sampling frequency of Unemap
            %data
            switch (oFigure.RecordingType)
                case 'Extracellular'
                    oFigure.oParentFigure.oGuiHandle.oPressure.ResampleOriginalData(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment.Unemap.ADConversion.SamplingRate)
                case 'Optical'
                    oFigure.oParentFigure.oGuiHandle.oPressure.ResampleOriginalData(...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment.Optical.SamplingRate)
            end
            %Plot data
            oFigure.Replot();
        end
        
        function oTimeAlignMenu_Callback(oFigure, src, event)
            %Bring up a dialog box that allows user to enter points to time
            %align
            oEditControl = EditControl(oFigure,'Enter the times of the points to align.',2);
            addlistener(oEditControl,'ValuesEntered',@(src,event) oFigure.TimeAlign(src, event));
        end
        
        function oTruncateToUnemapMenu_Callback(oFigure, src, event)
            %Truncate the data to fit unemap reference signal then provide
            %opportunity to truncate further
            
            %Get Unemap reference signal time series limits
            dMinTime = min(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording.TimeSeries);
            dMaxTime = max(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording.TimeSeries);
            %Get the values below and above these limits
            bLowIndexes = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.Status) < dMinTime;
            bHighIndexes = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.Status) > dMaxTime;
            %Combine these and negate to determine indexes to keep
            bIndexesToKeep = ~(bLowIndexes | bHighIndexes);
            %truncate the data and time series
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TruncateData(bIndexesToKeep);
            %replot
            oFigure.Replot();
        end
        
        function oTruncateMenu_Callback(oFigure, src, event)
            oSelectDataFigure = SelectData(oFigure,'SelectData',oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.Status),...
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).Status).Data,...
                {{'oInstructionText','string','Select a range of data to truncate.'} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oReturnButton','string','Done'} ; ...
                {'oAxes','title','Pressure Data'}});
            %Add a listener so that the figure knows when a user has
            %selected the data to truncate
            addlistener(oSelectDataFigure,'DataSelected',@(src,event) oFigure.TruncateData(src, event));
        end
        
        function TruncateData(oFigure, src, event)
            %Get the boolean time indexes of the data that has been selected
            bIndexes = event.Indexes;
            %Negate this so that we can select the potential data we want
            %to keep.
            bIndexes = ~bIndexes;
            %Truncate data that is not selected
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TruncateData(bIndexes);
            oFigure.Replot();
        end
        
        function TruncateRefData(oFigure,src,event)
            %Get the boolean time indexes of the data that has been selected
            bIndexes = event.Indexes;
            %Negate this so that we can select the potential data we want
            %to keep.
            bIndexes = ~bIndexes;
            %Truncate data that is not selected
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.Status).Data = ...
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).Electrodes.Status).Data(bIndexes);
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).TimeSeries = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oRecording(oFigure.SelectedRecordings(1)).TimeSeries(bIndexes);
            oFigure.Replot();
        end
        
        function CreateSubPlot(oFigure)
            %Initialise the subplots
            
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            %Divide up the space for the subplots
            yDiv = 1/(length(oFigure.Plots(logical([oFigure.Plots(:).Visible])))+0.4);%0.4
            j = 0;%counter of visible plots
            %Loop through all the plots
            for i = 1:length(oFigure.Plots)
                if oFigure.Plots(i).Visible
                    j = j + 1;
                    aPosition = [0.1, (j-1)*yDiv + 0.08, 0.8, yDiv-0.02];%[left bottom width height]0.02
                    %check if the plot still exists
                    if oFigure.Plots(i).ID > 0 && ~isempty(find(get(oFigure.oGuiHandle.oPanel,'children') == oFigure.Plots(i).ID))
                        %plot already been created so just adjust its
                        %position and make it visible
                        set(oFigure.Plots(i).ID, 'position', aPosition, 'visible', 'on');
                        cla(oFigure.Plots(i).ID);
                    else
                        %create a new subplot
                        oFigure.Plots(i).ID = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel, 'Tag', sprintf('Plot%d',i));
                    end
                else
                    if oFigure.Plots(i).ID > 0
                        %plot has already been created but should not be
                        %visible
                        set(oFigure.Plots(i).ID, 'visible', 'off');
                        cla(oFigure.Plots(i).ID);
                    end
                end
            end
        end
        
        function Replot(oFigure)
            %Plot the appropriate data
            
            %Set up the plots 
            oFigure.CreateSubPlot();
            oPlots = oFigure.Plots(logical([oFigure.Plots(:).Visible]));
            
            %loop through the plots currently visible
            for i = 1:length(oPlots)
                set(oPlots(i).ID,'fontsize',oFigure.FontSize);
                switch (oPlots(i).Name)
                    case 'Pressure'
                        oFigure.PlotPressure(oPlots(i).ID);
                    case 'Reference Signal'
                        oFigure.PlotRefSignal(oPlots(i).ID);
                    case 'Unemap Reference Signal'
                        oFigure.PlotRecordingRefSignal(oPlots(i).ID);
                    case 'Electrode'
                        oFigure.PlotElectrode(oPlots(i).ID,oFigure.SelectedElectrode, ...
                            transpose(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries));
                    case 'Heart Rate'
                        switch (oFigure.SignalToUseForBeatDetection)
                            case 'Phrenic'
                                oFigure.PlotHeartRate(oPlots(i).ID, oFigure.oParentFigur.oGuiHandle.oPressure.oPhrenic);
                            case 'Optical Signal'
                                hold(oPlots(i).ID,'on');
                                oFigure.CurrentZoomLimits(2,:) = [999, 0];
                                for j = 1:length(oFigure.SelectedRecordings)
                                    oFigure.PlotHeartRate(oPlots(i).ID, oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(j)));
                                end
                                hold(oPlots(i).ID,'off');
                        end
                    case 'Phrenic Integral'
                        oFigure.PlotIntegral(oPlots(i).ID);
                    case 'Phrenic Signal'
                        oFigure.PlotPhrenic(oPlots(i).ID);
                    case 'Optical Signal'
                        hold(oPlots(i).ID,'on');
                        for j = 1:length(oFigure.SelectedRecordings)
                            %each optical electrode belongs to a separate
                            %recording so there is only ever one electrode
                            %per recording
                            oElectrodes = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(j)).Electrodes;
                            if j == 1
                                ymax = max(oElectrodes.(oElectrodes(1).Status).Data);
                                ymin = min(oElectrodes.(oElectrodes(1).Status).Data);
                            else
                                ymax = max(ymax, max(oElectrodes.(oElectrodes(1).Status).Data));
                                ymin = min(ymin, min(oElectrodes.(oElectrodes(1).Status).Data));
                            end
                            oFigure.PlotElectrode(oPlots(i).ID,oElectrodes(1), ...
                                transpose(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(j)).TimeSeries),oFigure.Colours(oFigure.SelectedRecordings(j)), ymin, ymax);
                        end
                        hold(oPlots(i).ID,'off');
                    case 'Phrenic Signal With Beats'
                        oFigure.PlotElectrode(oPlots(i).ID,oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes(1),...
                            transpose(oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.TimeSeries));
                    case 'VRMS'
                        oFigure.PlotVRMS(oPlots(i).ID);
                    case 'Phrenic Burst Rate'
                        oFigure.CurrentZoomLimits(2,:) = [999, 0];
                        oFigure.PlotPhrenicBurstRate(oPlots(i).ID);
                end
                if i == 1
                    xLimits = get(oFigure.Plots(1).ID,'xlim');
                    set(oPlots(1).ID,'xminortick','on');
                    xlabel(oPlots(1).ID,'Time (s)');
                else
                    set(oPlots(i).ID,'xminortick','off');
                    xlabel(oPlots(i).ID,'');
                    set(oPlots(i).ID,'xticklabel',[]);
                    xlim(oPlots(i).ID,xLimits);
                end
            end
        end
        
        function PlotPhrenic(oFigure, oAxesHandle)
            %Plot the ref signal trace(s).
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.TimeSeries,...
                    oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Status).Data, oFigure.Colours(i));
                ymax = max(ymax, max(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Status).Data));
                ymin = min(ymin, min(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Status).Data));
            end
            hold(oAxesHandle, 'off');
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            oLabel = ylabel(oAxesHandle,'Phrenic (V)');
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
        end
        
        function PlotIntegral(oFigure, oAxesHandle)
            % Calculate a bin integral for the phrenic signal
            % if already calculated then plot what is there
            
            for j = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                if ~isfield(oFigure.oParentFigure.oGuiHandle.oPressure(j).oPhrenic.Electrodes.Processed,'Integral')
                    oFigure.oParentFigure.oGuiHandle.oPressure(j).oPhrenic.ComputeIntegral(50);
                end
            end
            
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.Status),oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Processed.Integral,oFigure.Colours(i));
                ymax = max(ymax,max(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Processed.Integral));
                ymin = min(ymin,min(oFigure.oParentFigure.oGuiHandle.oPressure(i).oPhrenic.Electrodes.Processed.Integral));
            end
            set(oAxesHandle,'xticklabel',[]);
            oLabel = ylabel(oAxesHandle,['Phrenic', 10, 'Integral (Vs)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
            hold(oAxesHandle, 'off');
        end
        
        function PlotPressure(oFigure,oAxesHandle)
            %Reset the visibility of the events
            oChildren = get(oFigure.oGuiHandle.oExperimentPanel,'children');
            for i = 1:length(oChildren)
                set(oChildren(i), 'visible', 'off');
            end
            
            %Plot the pressure trace(s).
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.Status),...
                    oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data, oFigure.Colours(i));
                ymax = max(ymax,max(oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data));
                ymin = min(ymin,min(oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data));
                set(oChildren(i),'string',sprintf('%d_%s',oFigure.oParentFigure.oGuiHandle.oPressure(i).oExperiment.Date, oFigure.Colours(i)));
                set(oChildren(i),'visible','on');
            end
            hold(oAxesHandle, 'off');
            oLabel = ylabel(oAxesHandle,['Pressure', 10, '(mmHg)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
            ylim(oAxesHandle,[ymin-abs(ymin/25) ymax+ymax/25]);
        end
        
        function PlotRefSignal(oFigure,oAxesHandle)
            %Plot the ref signal trace(s).
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.Status),...
                    oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Status), oFigure.Colours(i));
                ymax = max(ymax, max(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Status)));
                ymin = min(ymin, min(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Status)));
            end
            hold(oAxesHandle, 'off');
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            oLabel = ylabel(oAxesHandle,[oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Name, 10, '(V)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
        end
        
        function PlotRecordingRefSignal(oFigure,oAxesHandle)
            %Plot the recording data
            %loop through the selected recordings
            ymax = 0;
            ymin = 999;
            if ~isempty(oFigure.SelectedRecordings)
                hold(oAxesHandle,'on');
                for i = 1:length(oFigure.SelectedRecordings)
                    plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).TimeSeries, ...
                        oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.Status).Data,oFigure.Colours(oFigure.SelectedRecordings(i)));
                    ymax = max(ymax, max(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.Status).Data));
                    ymin = min(ymin, min(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(i)).Electrodes.Status).Data));
                end
                hold(oAxesHandle,'off');
                ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
                oLabel = ylabel(oAxesHandle, ['Recorded Reference', 10, 'Signal']);
                set(oLabel, 'FontUnits', 'points');
                set(oLabel,'FontSize',oFigure.FontSize);
            end
            
        end
        
        function PlotElectrode(oFigure, oAxesHandle, oElectrode, aTime, sColour, ymin, ymax)
            %Plot the selected electrode
            aData = oElectrode.(oElectrode.Status).Data;
            %check for beats
            if strcmp(oElectrode.Status,'Processed')
                if isfield(oElectrode.Processed,'Beats')
                    aBeatData = oElectrode.Processed.Beats;
                    aBeatIndexes = oElectrode.Processed.BeatIndexes;
                end
            end
            %Plot all the data
            if oElectrode.Accepted
                %If the signal is accepted then plot it as black
                plot(oAxesHandle,aTime,aData,sColour);
                ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
                if strcmp(oElectrode.Status,'Processed')
                    %only processed data has beats
                    if isfield(oElectrode.Processed,'Beats')
                        plot(oAxesHandle,aTime,aBeatData,'-g');
                        if ~isempty(oFigure.SelectedBeat)
                            %Get the currently selected beat
                            aSelectedBeat = aBeatData(aBeatIndexes(oFigure.SelectedBeat,1):aBeatIndexes(oFigure.SelectedBeat,2));
                            aSelectedTime = aTime(aBeatIndexes(oFigure.SelectedBeat,1):aBeatIndexes(oFigure.SelectedBeat,2));
                            plot(oAxesHandle,aSelectedTime,aSelectedBeat,'-b');
                        end
                    end
                end
            else
                %The signal is not accepted so plot it as red
                %without beats
                plot(oAxesHandle,aTime,aData,'-r');
                ylim(oAxesHandle,[ymin - 0.2, ymax + 0.2]);
            end
            
            switch (oFigure.SignalToUseForBeatDetection)
                case {'Reference Signal', 'Unemap Reference Signal', 'VRMS'}
                    oLabel = ylabel(oAxesHandle, ['Electrogram', 10, '(V)']);
                case 'Optical Signal'
                    oLabel = ylabel(oAxesHandle, 'Optical Signal');
                    if isfield(oElectrode.Processed,'Beats')
                        set(oAxesHandle, 'buttondownfcn', @(src, event)  oSelectedOpticalBeat_Callback(oFigure, src, event));
                    end
                case 'Phrenic'
                    oLabel = ylabel(oAxesHandle, 'Phrenic (V)');
                    if isfield(oElectrode.Processed,'Beats')
                        set(oAxesHandle, 'buttondownfcn', @(src, event)  oSelectedPhrenicBeat_Callback(oFigure, src, event));
                    end
            end
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
        end
        
        function PlotVRMS(oFigure, oAxesHandle)
            %plot the RMS data associated with this recording
            % Plot VRMS.Smoothed
            cla(oAxesHandle);
            aProcessedData = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed;
            aTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries;
            plot(oAxesHandle, aTime, aProcessedData,'k');
            aBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes;
            YMax = max(aProcessedData);
            YMin = min(aProcessedData);
            ylim(oAxesHandle,[YMin - 0.2, YMax + 0.2]);
            hold(oAxesHandle,'on');
            %loop through the beats
            for i = 1:size(aBeatIndexes,1)
                plot(oAxesHandle,aTime(aBeatIndexes(i,1):aBeatIndexes(i,2)),aProcessedData(aBeatIndexes(i,1):aBeatIndexes(i,2)),'-g');
            end
            hold(oAxesHandle,'off');
            oLabel = ylabel(oAxesHandle, 'VRMS');
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
        end
        
        function oSelectedOpticalBeat_Callback(oFigure, src, event)
            oPoint = get(src,'currentpoint');
            xDim = oPoint(1,1);
            iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).GetClosestBeat(1,xDim);
            %Update the selected beat
            if abs(oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).TimeSeries(...
                    oFigure.oParentFigure.oGuiHandle.oPressure.oRecording(oFigure.SelectedRecordings(1)).Electrodes.Processed.BeatIndexes(iBeatIndexes{1,1},1)) - xDim) > 5
                oFigure.SelectedBeat = [];
            else
                oFigure.SelectedBeat = iBeatIndexes{1,1};
            end
            oFigure.Replot();
        end
        
        function oSelectedPhrenicBeat_Callback(oFigure, src, event)
            oPoint = get(src,'currentpoint');
            xDim = oPoint(1,1);
            iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.GetClosestBeat(1,xDim);
            %Update the selected beat
            if abs(oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.TimeSeries(...
                    oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed.BeatIndexes(iBeatIndexes{1,1},1)) - xDim) > 5
                oFigure.SelectedBeat = [];
            else
                oFigure.SelectedBeat = iBeatIndexes{1,1};
            end
            oFigure.Replot();
        end
        
        function PlotHeartRate(oFigure, oAxesHandle, oRecording)
            %get electrode index
            if strcmp(oFigure.RecordingType, 'Extracellular')
                    switch (oFigure.SignalToUseForBeatDetection)
                        case {'Unemap Reference Signal','Reference Signal'}
                            [aRateData aRates dPeaks] = oRecording.GetHeartRateData(oFigure.Peaks(2,:));
                            plot(oAxesHandle,oRecording.TimeSeries, aRateData,'k');
                        case 'VRMS'
                            [aRateData aRates dPeaks] = oRecording.CalculateSinusRateFromRMS();
                            plot(oAxesHandle,oRecording.TimeSeries, aRateData,'k');
                    end
            elseif strcmp(oFigure.RecordingType,'Optical')
                [aRateData dPeaks] = oRecording.CalculateSinusRate(1);
                plot(oAxesHandle,oRecording.TimeSeries, aRateData,'k');
            end
            YMin = min(oFigure.CurrentZoomLimits(2,1),min(aRateData));
            YMax = max(oFigure.CurrentZoomLimits(2,2),max(aRateData));
            oFigure.CurrentZoomLimits(2,:) = [YMin, YMax];
            ylim(oAxesHandle,[YMin - 10, YMax + 10]);
            oLabel = ylabel(oAxesHandle,['Sinus', 10, 'Rate (bpm)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
            if strcmp(oFigure.RecordingType, 'Extracellular')
                for k = 4:4:length(dPeaks)
                    oBeatLabel = text(oRecording.TimeSeries(dPeaks(1,k)),aRateData(dPeaks(1,k-1))+5, num2str(k));%-50
                    set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','points');
                    set(oBeatLabel,'FontSize',4);
                    set(oBeatLabel,'parent',oAxesHandle);
                end
            elseif strcmp(oFigure.RecordingType,'Optical')
                for k = 4:4:length(dPeaks)
                    if ((oRecording.TimeSeries(dPeaks(1,k)-50) > oFigure.CurrentZoomLimits(1,1)) && ...
                            (oRecording.TimeSeries(dPeaks(1,k)-50) < oFigure.CurrentZoomLimits(1,2)))
                        oBeatLabel = text(oRecording.TimeSeries(dPeaks(1,k)-50),aRateData(dPeaks(1,k-1))+2, num2str(k));%+300,+5
                        set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','points');
                        set(oBeatLabel,'FontSize',4);
                        set(oBeatLabel,'parent',oAxesHandle);
                    end
                    
                end
            end
        end
        
        function PlotPhrenicBurstRate(oFigure, oAxesHandle)
            aRateData = oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.Electrodes.Processed.BeatRateData;
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.oPhrenic.TimeSeries, aRateData,'k');
            YMin = min(oFigure.CurrentZoomLimits(2,1),min(aRateData));
            YMax = max(oFigure.CurrentZoomLimits(2,2),max(aRateData));
            oFigure.CurrentZoomLimits(2,:) = [YMin, YMax];
            ylim(oAxesHandle,[YMin - 10, YMax + 10]);
            oLabel = ylabel(oAxesHandle,['Phrenic Burst', 10, 'Rate (bpm)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',oFigure.FontSize);
        end
        
        function TimeAlign(oFigure, src, event)
            %Get the times of the points to align
            dFirstTime = event.Values(1);
            dSecondTime = event.Values(2);
            %Shift the time array by the difference
            dDiff = dSecondTime - dFirstTime;
            if strcmp(oFigure.RecordingType, 'Extracellular') || dDiff > 0
                %shift the pressure data
                %shift the time series first
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.Processed = ...
                    oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.Status) + dDiff;
                %update timeseries status
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Status = 'Processed';
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.Status = 'Processed';
                %if there is no processed data then copy the original data
                %over
                if isempty(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Processed)
                    oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Processed.Data = ...
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Original.Data;
                    oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Processed = ...
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Original;
                    oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Status = 'Processed';
                end
            else
                %shift the selected recording data
                if ~isempty((oFigure.SelectedRecordings))
                    oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).oRecording(oFigure.SelectedRecordings(1)).TimeSeries = ...
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).oRecording(oFigure.SelectedRecordings(1)).TimeSeries - dDiff;

                    %if there is no processed data then copy the original
                    %data over
                    if isempty(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Processed)
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Processed.Data = ...
                            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Original.Data;
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Processed = ...
                            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Original;
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Status = 'Processed';
                        oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Status = 'Processed';
                    end
                end
            end
            
            oFigure.Replot();
        end
    end
    
end
