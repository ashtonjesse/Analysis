close all;
%Open unemap file
% oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\pabaro001_unemap.mat');

%set variables
dWidth = 15;
dHeight = 10;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\DiscreteWaveletDemo.eps';
%Create plot panel that has 3 rows containing the original signal, the
%scale to be removed and the reconstructed signal
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
oSubplotPanel.pack(3,1);
oSubplotPanel.margin = [15 0 5 5];
oSubplotPanel(1).margin = [0 0 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 0 0 0];

iStart = 1400;
iEnd = 62100;
%% plot top panel
%plot original data
oAxes = oSubplotPanel(1,1).select();
aData = oUnemap.Electrodes(151).Potential.Data;
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd),aData(iStart:iEnd),'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
axis(oAxes,'tight');
%set limits
% xlim(oAxes,[5,36]);
% ylim(oAxes,[58 140]);
%set labels
oYlabel = text('string','(A)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oYlabel,'fontsize',14);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 1;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(2);
set(oYlabel,'position',oPosition);

%plot discrete wavelet decomposition
oAxes = oSubplotPanel(2,1).select();
aData = oUnemap.FilterData(oUnemap.Electrodes(151).Potential.Data, 'DWTFilterRemoveScales', 10);
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd), aData(iStart:iEnd), 'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,oYLim);
%set labels
oYlabel = text('string','(B)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oYlabel,'fontsize',14);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 1;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(2);
set(oYlabel,'position',oPosition);

%plot recomposition
oAxes = oSubplotPanel(3,1).select();
aData = oUnemap.FilterData(oUnemap.Electrodes(151).Potential.Data, 'DWTFilterKeepScales', 10);
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd), aData(iStart:iEnd), 'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ycolor',[1 1 1]);
set(oAxes,'ytick',[]);
set(oAxes,'yticklabel',[]);
xlim(oAxes,oXLim);
ylim(oAxes,oYLim);
%set labels
oYlabel = text('string','(C)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oYlabel,'fontsize',14);
oPosition = get(oYlabel,'position');
oXLim = get(oAxes,'xlim');
oPosition(1) = oXLim(1) - 1;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(2);
set(oYlabel,'position',oPosition);

print(oFigure,'-dps','-r600',sSavePath)