function HRBaroFunction_GetPressureRange(aFiles,aPressureData,aRecordingIndex)
%this function plots a bunch of pressure plots and allows the user to
%select a range for each and save this to a variable called aRange
%initialise arrays

for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
        
    % get pressure time
    
    %     %get pressure data and filter
    if numel(oPressure.TimeSeries.Original) == numel(oPressure.Original.Data)
        aPressureTime = oPressure.TimeSeries.Original;
        aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    else
        aPressureTime = oPressure.TimeSeries.Original;
        aPressureProcessedData = oPressure.Processed.Data;
    end
    %     aPressureProcessedData = oPressure.Processed.Data;
    %     aPressureTime = oPressure.TimeSeries.Processed;
    %get pressure slope values
    aPressureSlope = fCalculateMovingSlope(aPressureProcessedData,50,3);
    aPressureCurvature = fCalculateMovingSlope(aPressureSlope,50,3);
    
    %get rate data
% %     if isempty(oPressure.oRecording(aRecordingIndex(j)).Electrodes) || ~isfield(oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed,'BeatRates')
% %         oPressure.oRecording(aRecordingIndex(j)).Beats.Indexes = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatIndexes;
% %         oPressure.oRecording(aRecordingIndex(j)).CalculateSinusRate();
%         aRates = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRates;
%         aTimes = oPressure.oRecording(aRecordingIndex(j)).TimeSeries(oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRateIndexes);
% %         %         aRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
% %         %         aTimes = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
%     else
         
%         aRates = [NaN,oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRates]';
%         aTimes = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRateTimes;
        aRates = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRates;
        aTimes = oPressure.oRecording(aRecordingIndex(j)).TimeSeries(oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRateIndexes);
        
%     end
    
    %get rate slope values
    [aRateCurvature xbar] = EstimateDerivative(aRates,aTimes,2,500,5);
    
    % plotting
    oFigure = figure();
    aSubplotPanel = panel(oFigure,'no-manage-font');
    aSubplotPanel.pack(2,1);
    oAxes = cell(1,2);
    oAxes{1} = aSubplotPanel(1,1).select();
    [RateAxes H1 H2] = plotyy(aTimes,aRates,xbar,aRateCurvature);
    oAxes{2} = aSubplotPanel(2,1).select();
    [PressureAxes H1 H2] = plotyy(aPressureTime,aPressureProcessedData,aPressureTime,aPressureCurvature);
    %     plot(oAxes{2},aPressureTime,aPressureProcessedData);
    
    
    %set appropriate range for curvature axes
    set(PressureAxes(2),'ylim',[-1*10^-6,1*10^-6]);
    %set appropriate x axis ranges
    set(PressureAxes(1),'xlim',get(RateAxes(1),'xlim'));
    set(PressureAxes(2),'xlim',get(RateAxes(1),'xlim'));
    %     set(oAxes{2},'xlim',get(RateAxes(1),'xlim'));
    %set up figure
    %make sure data cursor displays the index aswell
    dcm_obj = datacursormode(oFigure);
    set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    %create button
    oButton = uicontrol(oFigure,'style','pushbutton','string','Save Range','callback',@(src, event) ButtonCallback(src, event));
    set(oFigure,'toolbar','figure')
end

    function ButtonCallback(src, event)
        oFigure = get(src,'parent');
        hBrushLine = findall(oFigure,'tag','Brushing');
        % Get the Xdata and Ydata attitributes of this
        brushedData = get(hBrushLine, {'Xdata','Ydata'});
        % The data that has not been selected is labelled as NaN so get
        % rid of this
        % There are two axes on the plot so choose the second of these as
        % this corresponds to the pressure data
        brushedIdx = ~isnan(brushedData{2});
        brush(oFigure,'off');
        fprintf('%d,%d,%d\n',oFigure,find(brushedIdx,1,'first'),find(brushedIdx,1,'last'));
    end
end