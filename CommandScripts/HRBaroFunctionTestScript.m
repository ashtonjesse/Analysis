close all;
% clear all;
% open all the files 
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

% HRBaroFunction_GetPressureRange(aFiles,aPressureData);

% %loop through the pressure data and save the ranges
% for i = 1:numel(aPressureData)
%     oPressure = aPressureData{i};
%     oPressure.Increase.Range = aRange(i,2:3);
% end

%get the pressures that correspond to the rate locations and plot the
%relationships
oColors = distinguishable_colors(numel(aFiles));
oFigure = figure();
oAxes = axes();
for i = 1:numel(aPressureData)
    sFile = char(aFiles{i});
    oPressure = aPressureData{i};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    %get pressure data and filter
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    %find the rates that fall within the time range specified
    aTimePoints = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end) > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
        oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end) < oPressure.TimeSeries.Original(oPressure.Increase.Range(2));
    aBeats = oPressure.oRecording(1).Electrodes.Processed.BeatRates(aTimePoints);
    aBeatTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(aTimePoints);
    %get the corresponding pressure
    aPressures = zeros(1,numel(aBeatTimes));
    for j = 1:numel(aBeatTimes)
        %find the index that is closest to this time
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Original - aBeatTimes(j)));
        aPressures(j) = aPressureProcessedData(MinIndex);
    end
    %save to struct
    oPressure.Increase.BeatRates = aBeats;
    oPressure.Increase.BeatTimes = aBeatTimes;
    oPressure.Increase.BeatPressures = aPressures;
    %     plot
    sColor = oColors(i,:);
    oLine = plot(oAxes, oPressure.Increase.BeatPressures, oPressure.Increase.BeatRates, 'Color',sColor);
    set(oLine,'DisplayName',sName, 'LineWidth', 1.5);
    hold(oAxes, 'on');
end
hold(oAxes,'off');
legend(oAxes,'show');
%set up labels
set(get(oAxes,'xlabel'),'string','Pressure (mmHg)');
set(get(oAxes,'ylabel'),'string','Atrial rate (bpm)');
