close all;
% clear all;
% % open all the files 
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat' ...
%     };
% aPressureData = cell(1,numel(aFiles));
% for i = 1:numel(aFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aFiles{i}));
% end

% %plot all the HR traces
oFigure = figure();
aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(3,1);
oAxes = cell(1,3);
oAxes{1} = aSubplotPanel(1,1).select();
oAxes{2} = aSubplotPanel(2,1).select();
oAxes{3} = aSubplotPanel(3,1).select();
oColors = distinguishable_colors(numel(aFiles));
%initialise arrays
aHRStartPoint = zeros(numel(aFiles),1);
aHRSlope = zeros(numel(aFiles),2);
aPressureStartPoint = zeros(numel(aFiles),1);
aPressureSlope = zeros(numel(aFiles),2);
for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
    
    aPhrenicRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
    aPhrenicTime = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
    aSeriesPoints = find(aPhrenicTime >= aTimes(1) & aPhrenicTime <= aTimes(end));
    aPhrenicTime = aPhrenicTime(aSeriesPoints);
    aPhrenicRates = aPhrenicRates(aSeriesPoints);
    %normalise rates
    aRates = (-1 + aRates./mean(aRates(1:4)))*100;
    % get pressure time
    aPressureTime = oPressure.TimeSeries.Original;
    aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    aPressureTime = aPressureTime(aSeriesPoints);
    %get pressure data and filter
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    aPressureProcessedData = aPressureProcessedData(aSeriesPoints);
    %get pressure start point
    %find max value and baseline to work out threshold
    [Val Ind] = max(aPressureProcessedData);
    dBaselinePressure = mean(aPressureProcessedData(5000:25000));
    dThreshold = (Val - dBaselinePressure)*0.1 + dBaselinePressure;
    iThresholdInd = find(aPressureProcessedData > dThreshold,1,'first');
    aPressureStartPoint(j) = aPressureTime(iThresholdInd);
    %get pressure slope values
    aSlope = fCalculateMovingSlope(aPressureProcessedData,15,3);
    %find peaks in slope
    [aPeaks, aLocations] = fFindPeaks(aSlope);
    MaxInd = aLocations(find(aPeaks > 0.001,1,'first'));
    aPressureSlope(j,1) = aPressureTime(MaxInd);
    switch (j)
        case 10
            MinInd = 199276;
        case 4
            MinInd = 194591;
        otherwise
            %find troughs in slope
            aInvSlope = -aSlope;
            [aPeaks, aLocations] = fFindPeaks(aInvSlope);
            MinInd = aLocations(find(aPeaks > 0.001,1,'first'));
            [Val MinInd] = max(aInvSlope);
    end
    aPressureSlope(j,2) = aPressureTime(MinInd);
    sColor = oColors(j,:);
    
    
    aPhrenicTime = aPhrenicTime - aPressureTime(MaxInd);
    aTimes = aTimes - aPressureTime(MaxInd);
    aPressureTime = aPressureTime -  aPressureTime(MaxInd);
    
    oHRLine = plot(oAxes{1}, aTimes , aRates, 'Color',sColor);
    set(oHRLine,'DisplayName',sName, 'LineWidth', 1.5);
    oPressureLine = plot(oAxes{2}, aPressureTime, aPressureProcessedData, 'Color',sColor);
    set(oPressureLine,'DisplayName',sName, 'LineWidth', 1.5);
    oPhrenicLine = plot(oAxes{3}, aPhrenicTime, aPhrenicRates, 'Color',sColor);
    set(oPhrenicLine,'DisplayName',sName, 'LineWidth', 1.5);
    hold(oAxes{1}, 'on');
    hold(oAxes{2}, 'on');
    hold(oAxes{3}, 'on');
    figure();
    plotyy(aPressureTime,aPressureProcessedData,aPressureTime,aSlope);
    hold on;
    %plot baseline range
    %     plot(aPressureTime(5000),aPressureProcessedData(5000),'b+');
    %     plot(aPressureTime(25000),aPressureProcessedData(25000),'b+');
    %plot threshold
    plot(aPressureTime(MaxInd),aPressureProcessedData(MaxInd),'r+');
    plot(aPressureTime(MinInd),aPressureProcessedData(MinInd),'r+');
end
hold(oAxes{1}, 'off');
legend(oAxes{1},'show');
hold(oAxes{2}, 'off');
legend(oAxes{2},'show');
hold(oAxes{3}, 'off');
legend(oAxes{3},'show');
%set up labels
set(get(oAxes{3},'xlabel'),'string','Time relative to rate change onset (s)');
set(get(oAxes{1},'ylabel'),'string','% atrial rate change (bpm)');
set(get(oAxes{2},'ylabel'),'string','Pressure (mmHg)');
set(get(oAxes{3},'ylabel'),'string','Phrenic burst rate (bpm)');
set(oAxes{2},'xlim',get(oAxes{1},'xlim'));
set(oAxes{2},'ylim',[60 155]);
set(oAxes{2},'YMinorTick','on');
set(oAxes{3},'xlim',get(oAxes{1},'xlim'));