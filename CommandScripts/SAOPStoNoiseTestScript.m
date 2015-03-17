close all;
% clear all;
% % load all the pressure files as these contain the beat information
% aPressureFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat' ...
%     };
% aPressureData = cell(1,numel(aPressureFiles));
% for i = 1:numel(aPressureFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aPressureFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aPressureFiles{i}));
% end

% load all the data files as these contain the optical signal data
% aDataFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\baro005_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\baro006_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\baro007_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\baro008_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\baro009_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\baro010_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\baro011_3x3_1ms_7x_g10_LP100Hz-waveEach.mat', ...
%    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\baro012_3x3_1ms_7x_g10_LP100Hz-waveEach.mat' ...
%    };
% aOpticalData = cell(1,numel(aDataFiles));
% for j = 1:numel(aDataFiles)
%     [pathstr, name, ext, versn] = fileparts(char(aDataFiles{j}));
%     if strcmpi(ext,'.csv')
%         aThisOAP = ReadOpticalTimeDataCSVFile(char(aDataFiles{j}),6);
%         save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
%         fprintf('Opened and saved %s\n',char(aDataFiles{j}));
%     elseif strcmpi(ext,'.mat')
%         load(char(aDataFiles{j}));
%         fprintf('Loaded %s\n',char(aDataFiles{j}));
%     end
%     aOpticalData{j} = aThisOAP;
% end

%initialise variables
% aMeanSignaltoNoise = zeros(numel(aDataFiles),1);
%loop through the recordings
for m = 1:numel(aDataFiles)
    %get this optical data
    oOAP = aOpticalData{m};
    oPressure = aPressureData{m};
    %get beat indexes for particular beat
    aBeatIndexes = oPressure.oRecording.Electrodes.Processed.BeatIndexes(4,:);
    %initialise arrays
    aSignaltoNoise = zeros(numel(oOAP.Locations(1,:)),1);
    %loop through the points
    for n = 1:numel(oOAP.Locations(1,:))
        %get the data for this point 
        aData = -oOAP.Data(:,n);
        switch (m)
            case 3
                iStart = 50;
            case 6
                iStart = 200;
            case 8
                iStart = 40;
            otherwise
                iStart = 90;
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
        [C IMaxBeat] = max(aThisBeat);
        [C IMaxCurvature] = max(aThisCurvature(1:IMaxBeat));
        iOffsetStart = 25;
        iOffsetEnd = 5;
        %Calculate S/N
        dBaselineValue = mean(aThisBeat(IMaxCurvature-iOffsetStart:IMaxCurvature-iOffsetEnd));
        dNoise = std(aThisBeat(IMaxCurvature-iOffsetStart:IMaxCurvature-iOffsetEnd));
        dOAPA = max(aThisBeat) - dBaselineValue;
        aSignaltoNoise(n) = dOAPA/dNoise;
        
            plotyy(1:numel(aThisBeat),aThisBeat,1:numel(aThisCurvature),aThisCurvature);
            hold on;
            plot(IMaxCurvature-iOffsetStart,aThisBeat(IMaxCurvature-iOffsetStart),'r+');
            plot(IMaxCurvature-iOffsetEnd,aThisBeat(IMaxCurvature-iOffsetEnd),'r+');
            hold off;
        
        
    end
    %calc mean for this recording
    aMeanSignaltoNoise(m) = mean(aSignaltoNoise);
end
