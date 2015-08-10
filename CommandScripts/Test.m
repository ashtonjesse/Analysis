% oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\pabaro001_unemap.mat');
% for i = 1:numel(oUnemap.Electrodes)
%     oUnemap.Electrodes(i).SignalEvent(1).Range = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Range, [0 0]);
%     oUnemap.Electrodes(i).SignalEvent(1).Index = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Index, 0);
% end
close all;
oFigure = figure();
oAxes = axes();
aRange = oUnemap.RMS.HeartRate.Peaks(1,2):oUnemap.RMS.HeartRate.Peaks(2,2);
plot(oAxes,oUnemap.TimeSeries(aRange),oUnemap.Electrodes(151).Processed.Data(aRange),'k');
% 
% for i = 1:numel(oUnemap.Electrodes)
% % [x b] = oUnemap.CalculateSinusRate(i);
% % oUnemap.Electrodes(i).Processed.BeatRateData = oUnemap.Electrodes(i).Processed.BeatRateData';
% % oUnemap.Electrodes(i).Processed.BeatRates = oUnemap.Electrodes(i).Processed.BeatRates';
% end
% hold(oAxes,'on');
% % plot(oAxes,oUnemap.TimeSeries,oUnemap.Electrodes(1).Processed.BeatRateData,'b');
% % plot(oAxes,oUnemap.TimeSeries,oUnemap.Electrodes(151).Processed.BeatRateData,'r');
% 
% % aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
% % aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
% % aRates = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'Processed','BeatRates');
% % aMeanRateData = mean(aRateData,2);
% plot(oAxes,oUnemap.TimeSeries,aMeanRateData,'g');