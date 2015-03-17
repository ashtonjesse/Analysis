close all;
clear all;
% % % open all the files 
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh006\Pressure.mat' ...
%     };
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh007\Pressure.mat' ...
%     };
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh004\Pressure.mat' ...
%     };
aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh006\Pressure.mat' ...
     };
aPressureData = cell(1,numel(aFiles));
for i = 1:numel(aFiles)
    aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aFiles{i}));
end

% HRCChFunction_GetPressureRange(aFiles,aPressureData);

%loop through the pressure data and save the ranges
% for i = 1:numel(aPressureData)
%     oPressure = aPressureData{i};
%     oPressure.HeartRate.Decrease.Range = aRange(i,2:3);
% end

% get the pressures that correspond to the rate locations and plot the
% relationships

for i = 1:numel(aPressureData)
    sFile = char(aFiles{i});
    oPressure = aPressureData{i};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    if isfield(oPressure.TimeSeries,'Processed')
        aPressureTime = oPressure.TimeSeries.Processed;
    else
        aPressureTime = oPressure.TimeSeries.Original;
    end
    aPressureProcessedData = oPressure.Processed.Data;
    %find the rates that fall within the time range specified0
    if oPressure.HeartRate.Decrease.Range > 0
        aTimePoints = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end) > aPressureTime(oPressure.HeartRate.Decrease.Range(1)) & ...
            oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end) < aPressureTime(oPressure.HeartRate.Decrease.Range(2));
        if size(aTimePoints,1) > size(aTimePoints,2)
            aTimePoints = aTimePoints';
        end
        aBeats = oPressure.oPhrenic.Electrodes.Processed.BeatRates(aTimePoints);
        aTimePoints = [false aTimePoints];
        aBeatTimes = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(aTimePoints);
        %get the corresponding pressure
        aPressures = zeros(1,numel(aBeatTimes));
        for j = 1:numel(aBeatTimes)
            %find the index that is closest to this time
            [MinVal MinIndex] = min(abs(aPressureTime - aBeatTimes(j)));
            aPressures(j) = aPressureProcessedData(MinIndex);
        end
        
        %save to struct
        oPressure.HeartRate.Decrease.BeatRates = aBeats;
        oPressure.HeartRate.Decrease.BeatTimes = aBeatTimes;
        oPressure.HeartRate.Decrease.BeatPressures = aPressures;
    else
        oPressure.HeartRate.Decrease.BeatRates = [];
        oPressure.HeartRate.Decrease.BeatTimes = [];
        oPressure.HeartRate.Decrease.BeatPressures = [];
    end
%     oPressure.Save(sFile);
%     fprintf('Saved: %s\n',sFile);
end

