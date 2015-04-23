%this plots the figure demonstrating RSA, TH waves etc in the results
%section of the methods chapter
% clear all;
close all;
%set variables
dWidth = 15;
dHeight = 10;
oXLim1 = [10 28];
oXLim2 = [2 20];
sRecordingType = 'Extracellular';
sFirstFileName= 'G:\PhD\Experiments\Auckland\InSituPrep\20140417\123811Pressure.mat';
sSecondFileName= 'G:\PhD\Experiments\Auckland\InSituPrep\20140417\130600Pressure.mat';
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\RSA_20140417.eps';
% sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Test.bmp';
% % %load the data
oFirstPressure = GetPressureFromMATFile(Pressure,sFirstFileName,sRecordingType);
oSecondPressure = GetPressureFromMATFile(Pressure,sSecondFileName,sRecordingType);

%create figure
oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack(4,2);
oSubplotPanel.margin = [15 5 5 10];
oSubplotPanel(1).margin = [5 5 0 0];
oSubplotPanel(2).margin = [5 5 0 0];
oSubplotPanel(3).margin = [5 5 0 0];
oSubplotPanel(4).margin = [5 5 0 0];

oSubplotPanel.select('all')
oSubplotPanel.fontsize = 6;
oSubplotPanel.fontweight = 'normal';

%% plot left hand panel
%plot pressure
oAxes = oSubplotPanel(4,1).select();
aData = oFirstPressure.(oFirstPressure.Status).Data;
aTime = oFirstPressure.TimeSeries.(oFirstPressure.TimeSeries.Status);
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim1);
ylim(oAxes,[58 75]);
%set labels
oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim1(1) - 3;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot phrenic
oAxes = oSubplotPanel(3,1).select();
aData = oFirstPressure.oPhrenic.Electrodes.(oFirstPressure.oPhrenic.Electrodes.Status).Data ./ ...
    (oFirstPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aTime = oFirstPressure.oPhrenic.TimeSeries;
plot(oAxes,aTime, aData, 'k');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
ylim(oAxes,[-40 30]);
xlim(oAxes,oXLim1);
%set labels
oYlabel = ylabel(oAxes,['PND', 10, '(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim1(1) - 3;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot phrenic integral
oAxes = oSubplotPanel(2,1).select();
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oFirstPressure.oPhrenic, ...
    oFirstPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oFirstPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6,2);
oFirstPressure.oPhrenic.ComputeIntegral(200,aBurstData);
aData = oFirstPressure.oPhrenic.Electrodes.Processed.Integral;
aTime = oFirstPressure.TimeSeries.(oFirstPressure.TimeSeries.Status);
plot(oAxes,aTime, aData, 'k');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
ylim(oAxes,[0 5]);
xlim(oAxes,oXLim1);
%set labels
oYlabel = ylabel(oAxes,['\intPND', 10, '(\muVs)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim1(1) - 3;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot heart rate
oAxes = oSubplotPanel(1,1).select();
aData = oFirstPressure.oPhrenic.Electrodes.Processed.BeatRateData;
aTime = oFirstPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime, aData, 'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
ylim(oAxes,[310 350]);
xlim(oAxes,oXLim1);
%set labels
oYlabel = ylabel(oAxes,['Heart', 10, 'Rate', 10, '(bpm)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim1(1) - 3;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
%set title
otext = text(oXLim1(1),oYLim(2)+10, 'A.', 'HorizontalAlignment','center','fontsize',14,'fontweight','bold');
set(otext,'parent',oAxes);

%% plot right hand panel
%plot pressure
oAxes = oSubplotPanel(4,2).select();
aData = oSecondPressure.(oSecondPressure.Status).Data;
aTime = oSecondPressure.TimeSeries.(oSecondPressure.TimeSeries.Status);
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1.5);
%set limits
oYLim = [58 75];
xlim(oAxes,oXLim2);
ylim(oAxes,oYLim);
%create scale bar
hold(oAxes,'on');
plot([oXLim2(2)-5; oXLim2(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
text(oXLim2(2)-2.5,oYLim(1)-3, '5 s', 'HorizontalAlignment','center')
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);

%plot phrenic
oAxes = oSubplotPanel(3,2).select();
aData = oSecondPressure.oPhrenic.Electrodes.(oSecondPressure.oPhrenic.Electrodes.Status).Data ./ ...
    (oSecondPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aTime = oSecondPressure.oPhrenic.TimeSeries;
plot(oAxes,aTime, aData, 'k');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
%set limits
ylim(oAxes,[-40 30]);
xlim(oAxes,oXLim2);

%plot phrenic integral
oAxes = oSubplotPanel(2,2).select();
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oSecondPressure.oPhrenic, ...
    oSecondPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oSecondPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6,2);
oSecondPressure.oPhrenic.ComputeIntegral(200,aBurstData);
aData = oSecondPressure.oPhrenic.Electrodes.Processed.Integral;
aTime = oSecondPressure.TimeSeries.(oSecondPressure.TimeSeries.Status);
plot(oAxes,aTime, aData, 'k');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
%set limits
ylim(oAxes,[0 5]);
xlim(oAxes,oXLim2);

%plot heart rate
oAxes = oSubplotPanel(1,2).select();
aData = oSecondPressure.oPhrenic.Electrodes.Processed.BeatRateData;
aTime = oSecondPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime, aData, 'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
%set limits
ylim(oAxes,[310 350]);
xlim(oAxes,oXLim2);
oYLim = get(oAxes,'ylim');
%set title
otext = text(oXLim2(1),oYLim(2)+10, 'B.', 'HorizontalAlignment','center','fontsize',14,'fontweight','bold');
set(otext,'parent',oAxes);
%% print figure
% print(oFigure,'-dbmp','-r600',sSavePath)
print(oFigure,'-dps','-r600',sSavePath)

