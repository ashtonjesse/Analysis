%this script plots with a specified number of scales removed (or kept) from
%the original signal
% close all;
iNumScales = 10;

%create axes
oFigure = figure();
aPanel = panel(oFigure,'no-manage-font');
aPanel.pack(iNumScales+1,1);
oAxes = cell(iNumScales+1,1);
oAxes{1} = aPanel(1,1).select();
set(oAxes{1},'xticklabel',[]);
set(oAxes{1},'ytick',[]);
axis(oAxes{1},'auto');
%plot the original data
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\baro008_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');
[oElectrode, iIndex] = GetElectrodeByName(oOptical,'11-25');
aData = oElectrode.Processed.Data;
aTimes = oOptical.TimeSeries;
plot(oAxes{1},aTimes,aData,'k');
%get wavelet info
aFilteredSignals = oOptical.ComputeDWTFilteredSignalsKeepingScales(aData, 0:iNumScales);

%plot
for i = 1:iNumScales
    oAxes{i+1} = aPanel(i+1,1).select();
    plot(oAxes{i+1},aTimes,aFilteredSignals(:,i),'r');
    set(oAxes{i+1},'xticklabel',[]);
    set(oAxes{i+1},'ytick',[]);
    axis(oAxes{i+1},'auto');
    %     if i == 4 || i == 10
    %         aData = aFilteredSignals(:,i);
    %         aMean = mean(aData);
    %         hold(oAxes{i+1},'on');
    %         plot(oAxes{i+1},aTimes(aData>aMean),aData(aData>aMean),'g+');
    %     end
end
aPanel.de.margin = 0;
aPanel.de.marginbottom = 0;
