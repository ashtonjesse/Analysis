close all;
% clear all;

dWidth = 16;
dHeight = 8;
oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
% set(oFigure, 'WindowStyle', 'Docked');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',2);
aSubplotPanel.margin = [15 10 15 10];%left bottom right top
aSubplotPanel.de.margin = [0 0 30 0];
aSubplotPanel.de.fontsize = 8;
movegui(oFigure,'center');

oAxes = aSubplotPanel(1).select();
oOverlay = axes('position',get(oAxes,'position'),'parent',oFigure,'fontsize',8);
aTime = [0	2.52	5.04	7.56	10.08	12.6	15.12	17.64	20.16	22.68	25.2	27.72	30.24	32.76 ...
    35.28	37.8	40.32	42.84	45.36	47.88	50.4	51.32	55.27	60.85	63.3	65.82	68.34	68.77];
aRates = [302	300	297	295	292	288	282	276	274	271	267	264	...
    261	259	256	255	253	248	246	244	243	242	240	238	238	235	235	234];
aPercentage = (1 - aRates./ max(aRates))*100;

plot(oOverlay,aTime,aRates,'linewidth',1.5);
set(get(oOverlay,'xlabel'),'string','Time (min)','fontsize',8);
set(get(oOverlay,'ylabel'),'string','Heart rate (bpm)','fontsize',8);
set(oOverlay,'ylim',[220 310],'box','off','color','none','xlim',[-1 80]);

plot(oAxes,aTime,aPercentage);
set(oAxes,'yaxislocation','right');
aytick = get(oOverlay,'ytick');
aylim = (1- [aytick(end) aytick(1)] ./ max(aRates))*100;
set(oAxes,'ylim',aylim,'xlim',[-1 80],'xtick',[],'xticklabel',[],'xcolor','w','ydir','reverse');
set(get(oAxes,'ylabel'),'string','Decrease in heart rate (%)')

%annotate
[figx figy] = dsxy2figxy(oOverlay, [0;0],[315;302]);
annotation('textarrow',figx,figy,'string','+1 \muM','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);

[figx figy] = dsxy2figxy(oOverlay, [11;11],[303;290]);
annotation('textarrow',figx,figy,'string','+2 \muM','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);

[figx figy] = dsxy2figxy(oOverlay, [24;24],[283;270]);
annotation('textarrow',figx,figy,'string','+2 \muM','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);

[figx figy] = dsxy2figxy(oOverlay, [40.32;40.32],[266;253]);
annotation('textarrow',figx,figy,'string','+2 \muM','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);

set(oFigure,'resizefcn',[]);


%plot second panel
sFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb180313_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb180544_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb180815_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb181045_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb181316_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb181547_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb181818_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb182049_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb182320_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb182550_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb182821_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb183052_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb183323_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb183554_HR.txt' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140724\lb183825_HR.txt' ...
    };

% aData = cell(1,numel(sFiles));
% for i = 1:numel(sFiles)
%     %read data
%     aData{i} = dlmread(sFiles{i}, '\t', 0, 0);
% end
%stack the data
aStackedData = vertcat(aData{:});
%select the points to plot
aPoints = aStackedData(1:4000:end,2); 
%generate the time data
aTimeData = 0:1:size(aStackedData,1);
%based on sampling rate of 10k
aTimeData = aTimeData.*(1/10000);
aTimes = aTimeData(1:4000:end);
%remove the outlier points
aPointstoPlot = aPoints > 50 & aPoints < 280;
aPointstoPlot(1) = 0;

%select the axes
oAxes = aSubplotPanel(2).select();
%overlay percentage axes
oOverlay = axes('position',get(oAxes,'position'),'parent',oFigure,'fontsize',8);
aPercentage = (1 - aPoints(aPointstoPlot)./ aPointstoPlot(2))*100;
plot(oOverlay,aTimes(aPointstoPlot),aPoints(aPointstoPlot),'linewidth',1.5);
set(get(oOverlay,'xlabel'),'string','Time (min)','fontsize',8);
set(get(oOverlay,'ylabel'),'string','Heart rate (bpm)','fontsize',8);
set(oOverlay,'ylim',[200 270],'box','off','color','none','xlim',[-1 50]);

plot(oAxes,aTimes(aPointstoPlot),aPercentage);
set(oAxes,'yaxislocation','right');
aytick = get(oOverlay,'ytick');
aylim = (1- [aytick(end) aytick(1)] ./ aPoints(2))*100;
set(oAxes,'ylim',aylim,'xlim',[-1 50],'xtick',[],'xticklabel',[],'xcolor','w','ydir','reverse');
set(get(oAxes,'ylabel'),'string','Decrease in heart rate (%)')

%annotate
[figx figy] = dsxy2figxy(oOverlay, [0.5;0.5],[274;260]);
annotation('textarrow',figx,figy,'string','+10 \muM','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);
[figx figy] = dsxy2figxy(oOverlay, [29.5;29.5],[230;215]);
annotation('textarrow',figx,figy,'string','Washout','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);
%put panel titles on 
annotation('textbox',[0.02,0.9,0.1,0.1],'string','A','fontsize',12,'fontweight','bold','edgecolor','none');
annotation('textbox',[0.52,0.9,0.1,0.1],'string','B','fontsize',12,'fontweight','bold','edgecolor','none');

print(oFigure,'-dpsc','-r300','D:\Users\jash042\Documents\PhD\Thesis\Figures\IvabradineTitration.eps')
export_fig('D:\Users\jash042\Documents\PhD\Thesis\Figures\IvabradineTitration.png','-png','-r300','-nocrop','-painters');
