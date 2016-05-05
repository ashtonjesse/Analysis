% this file creates pressure.mat files and processes for beats and phrenic
% bursts 
close all;
clear all;

sRefOpticalSignal = 'G:\PhD\Experiments\Auckland\InSituPrep\20140522\test_wave.csv';
%define files to process
sFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb164956.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb165227.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb165458.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb165729.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb170000.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\lb170928_1.txt' ...
    };

for i = 1:numel(sFiles)
    oPressure = GetPressureFromTXTFile(Pressure,sFiles{i});
    %load recording
    oPressure.RecordingType = 'Optical';
    oPressure.oRecording = GetOpticalRecordingFromCSVFile(Optical, sRefOpticalSignal, oPressure.oExperiment);
    oPressure.oRecording.Name = '';
    %reset data to be processed
    oPressure.ResetData();
    %smooth the pressure
    oPressure.SmoothData(1);
    %smooth the beat detection signal
    aInOptions = struct('Procedure','','Inputs',cell(1,1));
    aInOptions.Procedure = 'FilterData';
    aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
    %     oPressure.RefSignal.Processed = FilterData(oPressure.oRecording, ...
    %         oPressure.RefSignal.(oPressure.RefSignal.Status), ...
    %         aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
        oPressure.RefSignal.Processed = FilterData(oPressure.oRecording, ...
            oPressure.oPhrenic.Electrodes.Processed.Data, ...
            aInOptions.Inputs{1}, aInOptions.Inputs{2},aInOptions.Inputs{3});
    %Status should now be processed
    oPressure.RefSignal.Status = 'Processed';
    %smooth again
    oPressure.RefSignal.Processed = FilterData(oPressure.oRecording, ...
        oPressure.RefSignal.(oPressure.RefSignal.Status), ...
        aInOptions.Inputs{1}, aInOptions.Inputs{2}, aInOptions.Inputs{3});
    %get heart rate data
    
            thresh = 0.2;
    
    [aHolder,aLocations] = oPressure.oPhrenic.GetPeaks(oPressure.RefSignal.(oPressure.RefSignal.Status), thresh);
    [aRateData dPeaks] = oPressure.oPhrenic.GetHeartRateData(aLocations);
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
    sFolderName = strrep(sFiles{i}, 'lb', '');
    sFolderName = strrep(sFolderName, '.txt', '');
    mkdir(sFolderName);
    oPressure.Save([sFolderName,'\Pressure.mat']);
    fprintf('Have saved file to folder %s\n',sFolderName);
end

