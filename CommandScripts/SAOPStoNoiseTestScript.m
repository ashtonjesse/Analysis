close all;
clear all;
% load all the pressure files as these contain the beat information
aPressureFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat' ...
    };
aPressureData = cell(1,numel(aPressureFiles));
for i = 1:numel(aPressureFiles)
    aPressureData{i} = GetPressureFromMATFile(Pressure,char(aPressureFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aPressureFiles{i}));
end

%load all the data files as these contain the optical signal data
aDataFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\baro002_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\baro003_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\baro004_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\baro005_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\baro006_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\baro007_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\baro008_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\baro009_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
   };
aOpticalData = cell(1,numel(aDataFiles));
for j = 1:numel(aDataFiles)
    [pathstr, name, ext, versn] = fileparts(char(aDataFiles{j}));
    if strcmpi(ext,'.csv')
        aThisOAP = ReadOpticalTimeDataCSVFile(char(aDataFiles{j}),6);
        save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
        fprintf('Opened and saved %s\n',char(aDataFiles{j}));
    elseif strcmpi(ext,'.mat')
        load(char(aDataFiles{j}));
        fprintf('Loaded %s\n',char(aDataFiles{j}));
    end
    aOpticalData{j} = aThisOAP;
end

%initialise variables
aMeanSignaltoNoise = zeros(numel(aDataFiles),1);

%loop through the recordings
for m = 1:numel(aDataFiles)
    %get this optical data
    oOAP = aOpticalData{m};
    oPressure = aPressureData{m};
    %get beat indexes for 2nd beat
    aBeatIndexes = oPressure.oRecording.Electrodes.Processed.BeatIndexes(4,:);
    %initialise arrays
    aSignaltoNoise = zeros(numel(oOAP.Locations(1,:)),1);
    %loop through the points
    for n = 1:numel(oOAP.Locations(1,:))
        %get the data for this point 
        aData = -oOAP.Data(:,n);
        switch (m)
            case 8
                iStart = 80;
            otherwise
                iStart = 0;
        end
        aThisBeat = -oOAP.Data(aBeatIndexes(1)+iStart:aBeatIndexes(2)+iStart,n);
        aThisSlope = fCalculateMovingSlope(aThisBeat,11,3);
        aThisCurvature = fCalculateMovingSlope(aThisSlope,11,3);
        aThisSlope(1:10) = 0;
        aThisSlope(end-10:end) = 0;
        aThisCurvature(1:10) = 0;
        aThisCurvature(end-10:end) = 0;
        %get max curvature which should be located at turning point from
        %baseline to the max data point
        [C I] = max(aThisBeat);
        [C I] = max(aThisCurvature(30:I));
        I = I + 30 - 1;

        %Calculate S/N
        dBaselineValue = mean(aThisBeat(I-30:I-10));
        dNoise = std(aThisBeat(I-30:I-10));
        dOAPA = max(aThisBeat) - dBaselineValue;
        aSignaltoNoise(n) = dOAPA/dNoise;
    end
    %calc mean for this recording
    aMeanSignaltoNoise(m) = mean(aSignaltoNoise);
end
