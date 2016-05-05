% this file goes through and applies processing steps to pressure files
close all;
clear all;

%define files to process
sFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo006\Pressure.mat' ...
    };

for i = 1:numel(sFiles)
    oPressure = GetPressureFromMATFile(Pressure,sFiles{i},'Optical');
    %load recording
    %reset data to be processed
    oPressure.ResetData();
    %smooth the pressure
    oPressure.SmoothData(1);
%     %smooth the beat detection signal
%     aInOptions = struct('Procedure','','Inputs',cell(1,1));
%     aInOptions.Procedure = 'FilterData';
%     aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
%     %     oPressure.RefSignal.Processed = FilterData(oPressure.oRecording, ...
%     %         oPressure.RefSignal.(oPressure.RefSignal.Status), ...
%     %         aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
%     aProcessed = FilterData(oPressure.oRecording, ...
%             oPressure.oPhrenic.Electrodes.Processed.Data, ...
%             aInOptions.Inputs{1}, aInOptions.Inputs{2},aInOptions.Inputs{3});
%     %Status should now be processed
%     %smooth again
%     aProcessed = FilterData(oPressure.oRecording, aProcessed, ...
%         aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
%     %get heart rate data
%     thresh = 0.3;
%     [aHolder,aLocations] = oPressure.oPhrenic.GetPeaks(aProcessed, thresh);
%     [aRateData dPeaks] = oPressure.oPhrenic.GetHeartRateData(aLocations);
    %compute phrenic integral
    aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, ...
        oPressure.oPhrenic.Electrodes.Processed.Data,2);
    %calc bin integral of this
    aBurstData = oPressure.oPhrenic.ComputeRectifiedBinIntegral(aBurstData, 200);
    %get phrenic bursts
    aIndices = find(aBurstData > 2);
    aIndices = [1 ; aIndices];
    aIndices = [aIndices ; numel(aBurstData)];
    oPressure.oPhrenic.CalculateBurstRate(aIndices);
    %drop the first and last to be safe
    oPressure.oPhrenic.Electrodes.Processed.BurstRates = oPressure.oPhrenic.Electrodes.Processed.BurstRates(1:end-1);
    oPressure.oPhrenic.Electrodes.Processed.BurstRateTimes = oPressure.oPhrenic.Electrodes.Processed.BurstRateTimes(2:end-1);
    oPressure.oPhrenic.Electrodes.Processed.BurstDurations = oPressure.oPhrenic.Electrodes.Processed.BurstDurations(2:end-1);
    %save file
    %get file name
    oPressure.Save(sFiles{i});
    fprintf('Have saved file to folder %s\n',sFiles{i});
end

