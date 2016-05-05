%this script opens a bunch of pressure files and calculates the mean
%pressure and rate during the plateau phase and plots all these data points
%on a scatter plot

close all;
clear all;
% %specify the files
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh002\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh002\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\Pressure.mat' ...
    }};

aIVBFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh004\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh003\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh005\Pressure.mat' ...
    }};

% % % % %get the data from these files
aControlPressureData = cell(numel(aControlFiles),1);
for i = 1:numel(aControlPressureData)
    aFiles = aControlFiles{i};
    aCellArray = cell(numel(aFiles),1);
    for j = 1:numel(aFiles)
        aCellArray{j} = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
    end
    aControlPressureData{i} = aCellArray;
end

% % %get the data from these files
aIVBPressureData = cell(numel(aIVBFiles),1);
for i = 1:numel(aIVBPressureData)
    aFiles = aIVBFiles{i};
    aCellArray = cell(numel(aFiles),1);
    for j = 1:numel(aFiles)
        aCellArray{j} = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
    end
    aIVBPressureData{i} = aCellArray;
end

aControlHRDecreaseDuration = cell(numel(aControlFiles),1);
aControlHRBaseline = cell(numel(aControlFiles),1);
% aControlHRPlateauMagnitude = cell(numel(aControlFiles),1);
for i = 1:numel(aControlFiles)
    ThisCell = aControlFiles{i};
    aControlHRDecreaseDuration{i} = zeros(numel(ThisCell),1);
    aControlHRBaseline{i} = zeros(numel(ThisCell),1);
    %     aControlHRPlateauMagnitude{i} = zeros(numel(ThisCell),1);
    for j = 1:numel(ThisCell)
        oPressure = aControlPressureData{i}{j};
        try
            if isempty(oPressure.HeartRate.Decrease.BeatRates)
                aControlHRDecreaseDuration{i}(j) = NaN;
                aControlHRBaseline{i}(j) = NaN;
                %                 aControlHRPlateauMagnitude{i}(j) = NaN;
            else
                aControlHRDecreaseDuration{i}(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
                aControlHRBaseline{i}(j) = 60000/mean(oPressure.Baseline.BeatRates);
                %                 aControlHRPlateauMagnitude{i}(j) = mean(oPressure.HeartRate.Plateau.BeatRates);
            end
        catch ex
            aControlHRDecreaseDuration{i}(j) = NaN;
            aControlHRBaseline{i}(j) = NaN;
            %             aControlHRPlateauMagnitude{i}(j) = NaN;
        end
    end
end

% % %repeat for IVB files
aIVBHRDecreaseDuration = cell(numel(aIVBFiles),1);
aIVBHRHRBaseline = cell(numel(aIVBFiles),1);
% aIVBHRPlateauMagnitude = cell(numel(aIVBFiles),1);
for i = 1:numel(aIVBFiles)
    ThisCell = aIVBFiles{i};
    aIVBHRDecreaseDuration{i} = zeros(numel(ThisCell),1);
    aIVBHRHRBaseline{i} = zeros(numel(ThisCell),1);
    %     aIVBHRPlateauMagnitude{i} = zeros(numel(ThisCell),1);
    for j = 1:numel(ThisCell)
        oPressure = aIVBPressureData{i}{j};
        try
            if isempty(oPressure.HeartRate.Decrease.BeatRates)
                aIVBHRDecreaseDuration{i}(j) = NaN;
                aIVBHRHRBaseline{i}(j) = NaN;
                %                 aIVBHRPlateauMagnitude{i}(j) = NaN;
            else
                aIVBHRDecreaseDuration{i}(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
                aIVBHRHRBaseline{i}(j) = 60000/mean(oPressure.Baseline.BeatRates);
                %                 aIVBHRPlateauMagnitude{i}(j) = mean(oPressure.HeartRate.Plateau.BeatRates);
            end
        catch ex
            aIVBHRDecreaseDuration{i}(j) = NaN;
            aIVBHRHRBaseline{i}(j) = NaN;
            %             aIVBHRPlateauMagnitude{i}(j) = NaN;
        end
    end
end
% % %plot results on scatter

aStackedControl = vertcat(aControlHRDecreaseDuration{:});
aStackedIVB = vertcat(aIVBHRDecreaseDuration{:});
% % %plot results on scatter
figure();
oAxes = axes();
bplot(aStackedControl,oAxes,1,'width',0.5);
hold(oAxes,'on');
bplot(aStackedIVB,oAxes,2,'nolegend','width',0.5);
hold(oAxes,'off');
oAxes = gca;
set(oAxes,'xlim',[0.5 2.5]);
set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
set(get(oAxes,'ylabel'),'string','Time to minimum atrial rate response (s)');
