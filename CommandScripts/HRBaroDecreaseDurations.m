%this script opens a bunch of pressure files and calculates the mean
%pressure and rate during the plateau phase and plots all these data points
%on a scatter plot

close all;
clear all;
% % % %specify the files
% 
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    }};
aIVBFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat'...
    }};
% % % %get the data from these files
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
 
% %loop through control files and calculate means
% %intialise arrays

aControlHRDuration = cell(numel(aControlFiles),1);
for i = 1:numel(aControlHRDuration)
    aThisCell = aControlPressureData{i};
    aControlHRDuration{i} = zeros(numel(aThisCell),1);
    for j = 1:numel(aThisCell)
        oPressure = aThisCell{j};
        if isempty(oPressure.HeartRate.Decrease.BeatRates)
            aControlHRDuration{i}(j) = NaN;
            disp('yep\n');
        else
            aControlHRDuration{i}(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
        end
    end
end

% % %repeat for IVB files
aIVBHRDuration = cell(numel(aIVBFiles),1);
for i = 1:numel(aIVBHRDuration)
    aThisCell = aIVBPressureData{i};
    aIVBHRDuration{i} = zeros(numel(aThisCell),1);
    for j = 1:numel(aThisCell)
        oPressure = aThisCell{j};
        if isempty(oPressure.HeartRate.Decrease.BeatRates)
            aIVBHRDuration{i}(j) = NaN;
            disp('yep\n');
        else
            aIVBHRDuration{i}(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
        end
    end
end
aStackedControl = vertcat(aControlHRDuration{:});
aStackedIVB = vertcat(aIVBHRDuration{:});
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
