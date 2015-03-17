%this script plots with a specified number of scales removed (or kept) from
%the original signal
close all;
iNumScales = 5;

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
% oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat','Optical');
aData = oPressure.oPhrenic.Electrodes.Processed.Data;
aTimes = oPressure.oPhrenic.TimeSeries;
plot(oAxes{1},aTimes,aData,'k');
%get wavelet info
aFilteredSignals = oPressure.oPhrenic.ComputeDWTFilteredSignalsRemovingScales(aData, 0:iNumScales);

%plot
for i = 1:iNumScales
    oAxes{i+1} = aPanel(i+1,1).select();
    plot(oAxes{i+1},aTimes,aFilteredSignals(:,i),'r');
    set(oAxes{i+1},'xticklabel',[]);
    set(oAxes{i+1},'ytick',[]);
    axis(oAxes{i+1},'auto');
end
aPanel.de.margin = 0;
aPanel.de.marginbottom = 0;
