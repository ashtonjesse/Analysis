%loop through the pressure files, load the file, get the rate and duration
%of phrenic bursts that occur before the end of the baseline period of the
%baroreflex challenge and get minimum burst rate

% aControlFiles = {{'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro002\Pressure.mat', ...
%         'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro007\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro009\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'}...
%     };
% 
% %get the experiment data
% aControlPressureData = cell(numel(aControlFiles),1);
% for i = 1:numel(aControlPressureData)
%     aFiles = aControlFiles{i};
%     aCellArray = cell(numel(aFiles),1);
%     for j = 1:numel(aFiles)
%         aCellArray{j} = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
%         fprintf('Got file %s\n',char(aFiles{j}));
%     end
%     aControlPressureData{i} = aCellArray;
% end

%initialise variables
aPhrenicRates = cell(numel(aControlFiles),1);
aMinRates = cell(numel(aControlFiles),1);
aPhrenicDurations = cell(numel(aControlFiles),1);
% %loop through the experiments
for i = 1:numel(aControlPressureData)
    %loop through recordings
    aPressureCellArray = aControlPressureData{i};
    aRateCellArray = cell(numel(aPressureCellArray),1);
    aDurationCellArray = cell(numel(aPressureCellArray),1);
    aMinArray = zeros(numel(aPressureCellArray),1);
    iCount = 1;
    for j = 1:numel(aPressureCellArray)
        %get the rates that are before the end of the baseline period
        oPressure = aPressureCellArray{j};
        aIndices = find(oPressure.oPhrenic.Electrodes.Processed.BurstRateTimes < oPressure.Baseline.BeatTimes(end)+1);
        if ~isempty(aIndices)
            aBurstRates = [NaN oPressure.oPhrenic.Electrodes.Processed.BurstRates];
            aRateCellArray{j} = aBurstRates(aIndices);
            aDurationCellArray{j} = oPressure.oPhrenic.Electrodes.Processed.BurstDurations(aIndices);
        end
        aMinArray(j) = min(oPressure.oPhrenic.Electrodes.Processed.BurstRates);
    end
    aPhrenicRates{i} = aRateCellArray;
    aPhrenicDurations{i} = aDurationCellArray;
    aMinRates{i} = aMinArray;
end