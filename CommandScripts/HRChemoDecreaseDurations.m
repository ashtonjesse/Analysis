%this script opens a bunch of pressure files and calculates the mean
%pressure and rate during the plateau phase and plots all these data points
%on a scatter plot

close all;
% clear all;
% % %specify the files
% aControlFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo003\Pressure.mat' ...
%     };
% 
% aIVBFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo006\Pressure.mat' ...
%     };
% 
% 
% % % % %get the data from these files
% aControlPressureData = cell(numel(aControlFiles),1);
% for i = 1:numel(aControlPressureData)
%     aControlPressureData{i} = GetPressureFromMATFile(Pressure,char(aControlFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aControlFiles{i}));
% end
% % aControlPressureData = cell(numel(aControlFiles),1);
% % for i = 1:numel(aControlPressureData)
% %     aFiles = aControlFiles{i};
% %     aCellArray = cell(numel(aFiles),1);
% %     for j = 1:numel(aFiles)
% %         aCellArray{j} = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
% %         fprintf('Got file %s\n',char(aFiles{j}));
% %     end
% %     aControlPressureData{i} = aCellArray;
% % end
% 
% % % %get the data from these files
% aIVBPressureData = cell(numel(aIVBFiles),1);
% for i = 1:numel(aIVBPressureData)
%     aIVBPressureData{i} = GetPressureFromMATFile(Pressure,char(aIVBFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aIVBFiles{i}));
% end

%loop through control files and calculate means
%intialise arrays

aControlHRDuration = zeros(numel(aControlFiles),1);
aControlHRMagnitude = zeros(numel(aControlFiles),1);
aControlHRBaseline = zeros(numel(aControlFiles),1);
for i = 1:numel(aControlFiles)
    oPressure = aControlPressureData{i};
    if isempty(oPressure.HeartRate.Decrease.BeatRates)
        aControlHRDuration(i) = NaN;
        aControlHRMagnitude(i) = NaN;
        aControlHRBaseline(i) = NaN;
    else
        aControlHRDuration(i) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
        aControlHRMagnitude(i) = (oPressure.HeartRate.Decrease.BeatRates(end-2)*0.5 + oPressure.HeartRate.Decrease.BeatRates(end-1) + ...
            oPressure.HeartRate.Decrease.BeatRates(end)*0.5) / 2;
        aControlHRBaseline(i) = 60000/mean(oPressure.Baseline.BeatRates);
    end
end

% % % % aControlHRDuration = cell(size(aControlPressureData));
% % % % for i = 1:numel(aControlPressureData)
% % % %     aCellArray = aControlPressureData{i};
% % % %     aControlHRDuration{i} = zeros(numel(aCellArray),1);
% % % %     for j = 1:numel(aCellArray)
% % % %         oPressure = aCellArray{j};
% % % %         if isempty(oPressure.HeartRate.Decrease.BeatRates)
% % % %             aControlHRDuration{i}(j) = NaN;
% % % %         else
% % % %             aControlHRDuration{i}(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Plateau.BeatTimes(1);
% % % %         end
% % % %     end
% % % % end

% % %repeat for IVB files
aIVBHRDuration = zeros(numel(aIVBFiles),1);
aIVBHRMagnitude = zeros(numel(aIVBFiles),1);
aIVBHRBaseline = zeros(numel(aControlFiles),1);
for j = 1:numel(aIVBFiles)
    oPressure = aIVBPressureData{j};
    if isempty(oPressure.HeartRate.Decrease.BeatRates)
        aIVBHRDuration(j) = NaN;
        aIVBHRMagnitude(j) = NaN;
        aIVBHRBaseline(i) = NaN;
    else
        aIVBHRDuration(j) = oPressure.HeartRate.Decrease.BeatTimes(end) -  oPressure.HeartRate.Decrease.BeatTimes(1);
        aIVBHRMagnitude(j) = (oPressure.HeartRate.Decrease.BeatRates(end-2)*0.5 + oPressure.HeartRate.Decrease.BeatRates(end-1) + ...
            oPressure.HeartRate.Decrease.BeatRates(end)*0.5) / 2;
        aIVBHRBaseline(j) = 60000/mean(oPressure.Baseline.BeatRates);
    end
end

% % %plot results on scatter


% oColors = distinguishable_colors(numel(aControlPressureData));
% for m = 1:numel(aControlPressureData)
%     oScatter = scatter(oMeanRatesAxes,aMeanControlPressure{m},aMeanControlRate{m},'o','sizedata',50,'markeredgecolor',oColors(m,:),'markerfacecolor',oColors(m,:));
%     %     if m == numel(aControlPressureData) - 1
%     %         set(oScatter,'displayname','Pre-IVB');
%     %     elseif m == numel(aControlPressureData)
%     %         set(oScatter,'displayname','Post-IVB');
%     %     else
%     %         [~, ~, ~, ~, ~, ~, splitStr] = regexp(aControlFiles{m}{1}, '\');
%     %         set(oScatter,'displayname',char(splitStr(end-2)));
%     %     end
%     [~, ~, ~, ~, ~, ~, splitStr] = regexp(aControlFiles{m}{1}, '\');
%     set(oScatter,'displayname',char(splitStr(end-2)));
%     hold(oMeanRatesAxes,'on');
% end
% hold(oMeanRatesAxes,'off');
% legend(oMeanRatesAxes,'show');
% figure();
% bplot(aControlPressureDuration,1);
% hold on;
% bplot(aIVBPressureDuration,2,'nolegend');
% hold off;
% oAxes = gca;
% set(oAxes,'xlim',[0.5 2.5]);
% set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
% set(get(oAxes,'ylabel'),'string','Pressure challenge duration (s)');
figure();
oAxes = axes();
bplot(aControlHRDuration,oAxes,1,'width',0.5);
hold(oAxes,'on');
bplot(aIVBHRDuration,oAxes,2,'nolegend','width',0.5);
hold(oAxes,'off');
oAxes = gca;
set(oAxes,'xlim',[0.5 2.5]);
set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
set(get(oAxes,'ylabel'),'string','Time to minimum atrial rate response (s)');
figure();
oAxes = axes();
bplot(aControlHRMagnitude,oAxes,1,'width',0.5);
hold on;
bplot(aIVBHRMagnitude,oAxes,2,'nolegend','width',0.5);
hold off;
oAxes = gca;
set(oAxes,'xlim',[0.5 2.5]);
set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
set(get(oAxes,'ylabel'),'string','Atrial rate response magnitude (bpm)');