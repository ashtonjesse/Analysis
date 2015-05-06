%this plots the figure demonstrating RSA, TH waves etc in the results
%section of the methods chapter
% clear all;
close all;
%set variables
dWidth = 15;
dHeight = 12.5;
sRecordingType = 'Extracellular';
sFirstFileName= 'G:\PhD\Experiments\Auckland\InSituPrep\20140417\124815Pressure.mat';
sSecondFileName= 'G:\PhD\Experiments\Auckland\InSituPrep\20140417\133018Pressure.mat';
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ReflexResponses.eps';
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
oSubplotPanel.pack(5,2);
oSubplotPanel.margin = [15 5 5 10];
oSubplotPanel(1).margin = [5 5 0 0];
oSubplotPanel(2).margin = [5 5 0 0];
oSubplotPanel(3).margin = [5 5 0 0];
oSubplotPanel(4).margin = [5 5 0 0];
oSubplotPanel(5).margin = [5 5 0 0];

oSubplotPanel.select('all')
oSubplotPanel.fontsize = 6;
oSubplotPanel.fontweight = 'normal';

%% plot left hand panel
%plot pressure
oAxes = oSubplotPanel(1,1).select();
aData = oFirstPressure.(oFirstPressure.Status).Data;
aTime = oFirstPressure.TimeSeries.(oFirstPressure.TimeSeries.Status);
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
% set(oAxes,'xminortick','on');
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,[5,36]);
ylim(oAxes,[58 140]);
%create annotation
hold(oAxes,'on');
plot(oAxes,[13.2; 14.2], [58; 58], '-k','LineWidth', 2)
hold(oAxes,'off');
text(13.7,46, 'KCN', 'HorizontalAlignment','center','parent',oAxes)
%set labels
oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 5;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
%set title
otext = text(oXLim(1),oYLim(2)+30, '(A)', 'HorizontalAlignment','center','fontsize',14,'fontweight','bold');
set(otext,'parent',oAxes);

%plot phrenic
oAxes = oSubplotPanel(5,1).select();
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
xlim(oAxes,[5,36]);
ylim(oAxes,[-25 20]);
%set labels
oYlabel = ylabel(oAxes,['PND', 10, '(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 5;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot phrenic integral
oAxes = oSubplotPanel(4,1).select();
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oFirstPressure.oPhrenic, ...
    oFirstPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oFirstPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6,2);
oFirstPressure.oPhrenic.ComputeIntegral(200,aBurstData);
aData = oFirstPressure.oPhrenic.Electrodes.Processed.Integral/(200 * (1/oFirstPressure.oExperiment.PerfusionPressure.SamplingRate) * 1000);
aTime = oFirstPressure.TimeSeries.(oFirstPressure.TimeSeries.Status);
plot(oAxes,aTime, aData, 'k');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,[5,36]);
ylim(oAxes,[0 15]);
%set labels
oYlabel = ylabel(oAxes,['\intPND', 10, '(\muVms)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 5;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot phrenic burst rate
oAxes = oSubplotPanel(3,1).select();
aData = oFirstPressure.oPhrenic.Electrodes.Processed.BurstRateData;
aTime = oFirstPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime, aData, 'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,[5,36]);
ylim(oAxes,[0 40]);
%set labels
oYlabel = ylabel(oAxes,['PND', 10, 'Rate', 10, '(bursts',10, 'per', 10, 'min)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 5;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot heart rate
oAxes = oSubplotPanel(2,1).select();
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
xlim(oAxes,[5,36]);
ylim(oAxes,[180 400]);
%set labels
oYlabel = ylabel(oAxes,['HR', 10, '(beats',10,'per',10,'min)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 5;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);


%% plot right hand panel
%plot pressure
oAxes = oSubplotPanel(1,2).select();
aData = oSecondPressure.(oSecondPressure.Status).Data;
aTime = oSecondPressure.TimeSeries.(oSecondPressure.TimeSeries.Status);
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1.5);
%set limits
xlim(oAxes,[0,31]);
ylim(oAxes,[58 140]);
%create scale bar
oXLim = get(oAxes,'xlim');
oYLim = get(oAxes,'ylim');
hold(oAxes,'on');
plot(oAxes,[oXLim(2)-5; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
text(oXLim(2)-2.5,oYLim(1)-12, '5 s', 'HorizontalAlignment','center','parent',oAxes)

%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
oXLim = get(oAxes,'xlim');
oYLim = get(oAxes,'ylim');
%set title
otext = text(oXLim(1),oYLim(2)+30, '(B)', 'HorizontalAlignment','center','fontsize',14,'fontweight','bold');
set(otext,'parent',oAxes);

%plot phrenic
oAxes = oSubplotPanel(5,2).select();
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
xlim(oAxes,[0,31]);
ylim(oAxes,[-25 20]);


%plot phrenic integral
oAxes = oSubplotPanel(4,2).select();
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oSecondPressure.oPhrenic, ...
    oSecondPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oSecondPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6,2);
oSecondPressure.oPhrenic.ComputeIntegral(200,aBurstData);
aData = oSecondPressure.oPhrenic.Electrodes.Processed.Integral/(200 * (1/oFirstPressure.oExperiment.PerfusionPressure.SamplingRate) * 1000);
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
xlim(oAxes,[0,31]);
ylim(oAxes,[0 15]);


%plot phrenic burst rate
oAxes = oSubplotPanel(3,2).select();
aData = oSecondPressure.oPhrenic.Electrodes.Processed.BurstRateData;
aTime = oSecondPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime, aData, 'k');
set(hline,'linewidth',1.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
%set limits
xlim(oAxes,[0,31]);
ylim(oAxes,[0 40]);



%plot heart rate
oAxes = oSubplotPanel(2,2).select();
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
xlim(oAxes,[0,31]);
ylim(oAxes,[180 400]);
oYLim = get(oAxes,'ylim');
oXLim = get(oAxes,'xlim');

%% print figure
% print(oFigure,'-dbmp','-r600',sSavePath)
print(oFigure,'-dps','-r600',sSavePath)

