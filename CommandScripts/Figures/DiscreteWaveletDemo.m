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
oSubplotPanel = panel(oFigure,'no-manage-font');
oSubplotPanel.pack('h',2);
oSubplotPanel(1).pack('v',3);
oSubplotPanel(2).pack('v',{0.3, 0.5, 0.2});
oSubplotPanel.margin = [8 0 5 5];
oSubplotPanel(1).margin = [0 0 0 0];
oSubplotPanel(2).margin = [10 0 0 0];

iStart = 1400;
iEnd = 62100;
aBeatRange = oUnemap.Electrodes(151).Processed.BeatIndexes(41,1):...
    oUnemap.Electrodes(151).Processed.BeatIndexes(41,2);
aBeatTimes = [oUnemap.TimeSeries(aBeatRange(1)), oUnemap.TimeSeries(aBeatRange(end))];
%% plot top panel
%plot original data
oAxes = oSubplotPanel(1,1).select();
aData = oUnemap.Electrodes(151).Potential.Data;
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd),aData(iStart:iEnd),'k');
set(hline,'linewidth',1);
%set axes colour
axis(oAxes,'off');
set(oAxes,'color','none','box','off');
axis(oAxes,'tight');
%set limits
xlim(oAxes,[0,10]);
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
oYlabel = text('string','(D)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oYlabel,'fontsize',14);
set(oYlabel,'position',[10 oPosition(2)]);
rectangle('Position',[aBeatTimes(1)-(aBeatTimes(2)-aBeatTimes(1))*10/2 oYLim(1)+(oYLim(2)-oYLim(1))/2 (aBeatTimes(2)-aBeatTimes(1))*10 (oYLim(2)-oYLim(1))/2],...
    'parent',oAxes,'edgecolor','k','erasemode','xor');

%plot discrete wavelet decomposition
oAxes = oSubplotPanel(1,2).select();
aData = oUnemap.FilterData(oUnemap.Electrodes(151).Potential.Data, 'DWTFilterRemoveScales', 10);
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd), aData(iStart:iEnd), 'k');
set(hline,'linewidth',1);
%set axes colour
axis(oAxes,'off');
set(oAxes,'color','none','box','off');
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
oAxes = oSubplotPanel(1,3).select();
aData = oUnemap.FilterData(oUnemap.Electrodes(151).Potential.Data, 'DWTFilterKeepScales', 10);
aData = oUnemap. FilterData(aData, 'SovitzkyGolay', 3,9);
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime(iStart:iEnd), aData(iStart:iEnd), 'k');
set(hline,'linewidth',1);
%set axes colour
axis(oAxes,'off');
set(oAxes,'color','none','box','off');
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
%create rectangle for beat window
rectangle('Position',[aBeatTimes(1)-(aBeatTimes(2)-aBeatTimes(1))*10/2 oYLim(1)+(oYLim(2)-oYLim(1))/2 (aBeatTimes(2)-aBeatTimes(1))*10 (oYLim(2)-oYLim(1))/2],...
    'parent',oAxes,'edgecolor','r','erasemode','xor');
%create scale bar
hold(oAxes,'on')
plot(oAxes,[oXLim(1) oXLim(1)+2],[oYLim(1)+15 oYLim(1)+15],'k','linewidth',3);
hold(oAxes,'off')
text(oXLim(1)+1,oYLim(1)+10,'2 s','horizontalalignment','center','fontsize',10,'fontweight','bold','parent',oAxes,'color','k');

%plot comparison of beats 
oAxes = oSubplotPanel(2,2).select();
oXLim = [6.616 6.623];
aData = oUnemap.Electrodes(151).Potential.Data(aBeatRange);
aTime = oUnemap.TimeSeries(aBeatRange);
hline1 = plot(oAxes,aTime, aData, 'k');
set(hline1,'linewidth',1);
axis(oAxes,'tight');
set(oAxes,'xlim',oXLim);
oYLim = get(oAxes,'ylim');
axis(oAxes,'off');
set(oAxes,'color','none','box','off');

%plot slope
oOverlay = axes('position',get(oAxes,'position'));
aData = CalculateSlope(oUnemap,oUnemap.Electrodes(151).Potential.Data,5,3);
aData = aData(aBeatRange);
hline2 = plot(oOverlay,aTime, aData, 'k--');
set(hline2,'linewidth',1);
axis(oOverlay,'tight');
set(oOverlay,'xlim',oXLim);
axis(oOverlay,'off');
set(oOverlay,'color','none','box','off');

%plot reconstructed data
oOverlay = axes('position',get(oAxes,'position'));
aData = oUnemap.Electrodes(151).Processed.Data(aBeatRange);
aTime = oUnemap.TimeSeries(aBeatRange);
hline3 = plot(oOverlay,aTime, aData, 'r');
set(hline3,'linewidth',1);
axis(oOverlay,'tight');
set(oOverlay,'xlim',oXLim);
axis(oOverlay,'off');
set(oOverlay,'color','none','box','off');

%plot slope
oOverlay = axes('position',get(oAxes,'position'));
aData = oUnemap.Electrodes(151).Processed.Slope(aBeatRange);
hline4 = plot(oOverlay,aTime, aData, 'r--','displayname','Gradient');
set(hline4,'linewidth',1);
axis(oOverlay,'tight');
set(oOverlay,'xlim',oXLim);
axis(oOverlay,'off');
set(oOverlay,'color','none','box','off');

%create scale bar
oPosition = get(oAxes,'position');
oPosition(2) = oPosition(2) - 0.1;
oScaleAxes = axes('position',oPosition);

plot(oScaleAxes,[oXLim(1) oXLim(1)+0.002],[-2.89 -2.89],'k','linewidth',3);
text(oXLim(1)+0.001,-3.44,'2 ms','horizontalalignment','center','fontsize',10,'fontweight','bold','parent',oScaleAxes);
set(oScaleAxes,'xlim',oXLim,'ylim',oYLim);
axis(oScaleAxes,'off');
set(oScaleAxes,'color','none','box','off');

%create legend
oAxes = oSubplotPanel(2,1).select();
legend(oAxes,[hline1 hline2 hline3 hline4],'Original','Gradient','Processed','Gradient','location','northeast')
axis(oAxes,'off');
set(oAxes,'color','none','box','off');

movegui(oFigure,'center');
print(oFigure,'-dpsc2','-r600',sSavePath)