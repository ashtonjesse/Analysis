%This figure shows the marking of activation time for a beat that is good,
%the slope and signal for a beat that shows fractionation, the slope and
%signal for a beat that shows low amplitude, and a signal that displays
%saturation - 3 plots across the top and one large one along the bottom

close all;
%Open unemap file
% oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130619\0619baro001\pabaro001_unemap.mat');
% oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20130619\0619baro001\baro001_pressure.mat','Extracellular');
%set variables
dWidth = 16;
dHeight = 12;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ElectrogramComparison.eps';

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
oSubplotPanel.pack({0.4 0.6});
oSubplotPanel(1).pack({0.1 0.9});
oSubplotPanel(1,2).pack('h',3);
oSubplotPanel(2).pack({0.1 0.9});
oSubplotPanel(2,2).pack('h',{0.12 0.88});
oSubplotPanel(2,2,2).pack('v',2)

oSubplotPanel.margin = [5 5 2 10];
oSubplotPanel(1).margin = [5 5 5 5];
oSubplotPanel(2).margin = [0 5 0 0];
movegui(oFigure,'center');

xstart = 20;
xoffset = 40;
%% plot top panel
%plot good electrode
oAxes = oSubplotPanel(1,2,1).select();
oOverlay = axes('position',get(oAxes,'position'),'box','off','color','none');
[oElectrode iIndex] = oUnemap.GetElectrodeByName('14-02');
aData = oElectrode.Processed.Data(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aSlope = oElectrode.Processed.Slope(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aTime = oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
hDataLine = plot(oAxes,aTime,aData,'k');
hSlopeLine = plot(oOverlay,aTime,aSlope,'r');
axis(oAxes,'tight');
axis(oOverlay,'tight');
set(oOverlay,'xlim',get(oAxes,'xlim'));
%set title
oTitle = get(oAxes,'title');
set(oTitle,'string',['Accepted',10],'fontsize',12,'fontweight','bold');
%create scales
oXLim = get(oAxes,'xlim');
oYLim = get(oAxes,'ylim');
hold(oAxes,'on');
plot(oAxes,[oXLim(1)+0.0008; oXLim(1)+0.0008], [oYLim(1); oYLim(1)+1], '-k','LineWidth', 3)
hold(oAxes,'off');
text(oXLim(1)+0.001,oYLim(1)+0.5, '1 mV', 'HorizontalAlignment','left','parent',oAxes)
axis(oAxes,'off');
oOverlayXLim = get(oOverlay,'xlim');
oOverlayYLim = get(oOverlay,'ylim');
hold(oOverlay,'on');
plot(oOverlay,[oOverlayXLim(1)+0.0004; oOverlayXLim(1)+0.0004], [oOverlayYLim(1); oOverlayYLim(1)+1], '-r','LineWidth', 3)
hold(oOverlay,'off');
text(oOverlayXLim(1)+0.001,oOverlayYLim(1)+0.7, '1 mV/s', 'HorizontalAlignment','left','parent',oOverlay,'color','r')
axis(oOverlay,'off');
%create label
oAxes = oSubplotPanel(1,1).select();
axis(oAxes,'off');
oLabel = text(-0.02,2.5,'(A)','parent',oAxes, ...
    'fontweight','bold','fontunits','points','horizontalalignment','left');
set(oLabel,'fontsize',14);


%plot fractionated electrode
oAxes = oSubplotPanel(1,2,2).select();
oOverlay = axes('position',get(oAxes,'position'),'box','off','color','none');
[oElectrode iIndex] = oUnemap.GetElectrodeByName('12-23');
aData = oElectrode.Processed.Data(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aSlope = oElectrode.Processed.Slope(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aTime = oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
hDataLine = plot(oAxes,aTime,aData,'k');
hSlopeLine = plot(oOverlay,aTime,aSlope,'r');
axis(oAxes,'tight');
axis(oOverlay,'tight');
set(oAxes,'ylim',oYLim);
set(oOverlay,'xlim',oXLim);
set(oOverlay,'ylim',oOverlayYLim);
%set title
oTitle = get(oAxes,'title');
set(oTitle,'string',['Excluded',10,'(fractionated)'],'fontsize',12,'fontweight','bold');
axis(oAxes,'off');
axis(oOverlay,'off');

%plot low amplitude electrode
oAxes = oSubplotPanel(1,2,3).select();
oOverlay = axes('position',get(oAxes,'position'),'box','off','color','none');
[oElectrode iIndex] = oUnemap.GetElectrodeByName('11-01');
aData = oElectrode.Processed.Data(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aSlope = oElectrode.Processed.Slope(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
aTime = oUnemap.TimeSeries(oElectrode.Processed.BeatIndexes(1,1)+xstart:oElectrode.Processed.BeatIndexes(1,2)-xoffset);
hDataLine = plot(oAxes,aTime,aData,'k');
hSlopeLine = plot(oOverlay,aTime,aSlope,'r');
axis(oAxes,'tight');
axis(oOverlay,'tight');
set(oAxes,'ylim',oYLim);
set(oOverlay,'xlim',oXLim);
set(oOverlay,'ylim',oOverlayYLim);
%set title
oTitle = get(oAxes,'title');
set(oTitle,'string',['Excluded',10,'(low amplitude)'],'fontsize',12,'fontweight','bold');
%create scales
hold(oAxes,'on');
plot(oAxes,[oXLim(2); oXLim(2)-0.005], [oYLim(1)+0.8; oYLim(1)+0.8], '-k','LineWidth', 3)
hold(oAxes,'off');
text(oXLim(2)-0.0025,oYLim(1), '5 ms', 'HorizontalAlignment','center','parent',oAxes)
axis(oAxes,'off');
axis(oOverlay,'off');



%% plot bottom panel
oAxes = oSubplotPanel(2,2,2,2).select();
[oElectrode iIndex] = oUnemap.GetElectrodeByName('26-06');
aTime = oUnemap.TimeSeries;
aData = oElectrode.Potential.Data;
hDataLine = plot(oAxes,aTime,aData,'k');
axis(oAxes,'tight');
oXLim = get(oAxes,'xlim');
set(oAxes,'xcolor',[1 1 1]);
%set labels
oYlabel = ylabel(oAxes,['Electrogram', 10,'(mV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.2;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 2.5;
set(oYlabel,'position',oPosition,'fontsize',8);
%create scales
hold(oAxes,'on');
YLoc = oYLim(1)+15;
plot(oAxes,[oXLim(2); oXLim(2)-2], [YLoc; YLoc], '-k','LineWidth', 3)
hold(oAxes,'off');
text(oXLim(2)-1,oYLim(1), '2 s', 'HorizontalAlignment','center','parent',oAxes)
%create annotation
hold(oAxes,'on');
plot(oAxes,[11.32; 15.5], [YLoc; YLoc], '-k','LineWidth', 2)
plot(oAxes,[11.32; 11.32], [YLoc-5; YLoc+5], '-k','LineWidth', 2)
plot(oAxes,[15.5; 15.5], [YLoc-5; YLoc+5], '-k','LineWidth', 2)
hold(oAxes,'off');
text(11.24+(15.5-11.24)/2,oYLim(1), 'Period of saturation', 'HorizontalAlignment','center','parent',oAxes)

oAxes = oSubplotPanel(2,2,2,1).select();
aTime = oPressure.TimeSeries.Processed;
aData = oPressure.Processed.Data;
hDataLine = plot(oAxes,aTime,aData,'k');
axis(oAxes,'tight');
set(oAxes,'xlim',oXLim,'xcolor',[1 1 1]);
%set labels
oYlabel = ylabel(oAxes,['Pressure', 10,'(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.2;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 2.5;
set(oYlabel,'position',oPosition,'fontsize',8);

%create label
oAxes = oSubplotPanel(2,1).select();
axis(oAxes,'off');
oLabel = text(-0.02,0,'(B)','parent',oAxes, ...
    'fontweight','bold','fontunits','points','horizontalalignment','left');
set(oLabel,'fontsize',14);

print(oFigure,'-dpsc','-r600',sSavePath)