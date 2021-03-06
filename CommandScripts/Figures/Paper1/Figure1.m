%this script draws a figure with two rows of axes that demonstrate the
%process of determining the site of dominant pacemaker
close all;
% clear all;
% % %open data
sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\';
sRecording = 'baro001';
sSubDir = [sBaseDir,sBaseDir(end-8:end-1),sRecording,'\'];

% % %% read in the optical entities
sOpticalFileName = [sSubDir,sRecording,'a_3x3_1ms_g10_LP100Hz-waveEach_forfigure.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% [oElectrode1, iIndex] = GetElectrodeByName(oOptical,'16-14');
% [oElectrode2, iIndex] = GetElectrodeByName(oOptical,'16-18');
% [oElectrode3, iIndex] = GetElectrodeByName(oOptical,'26-13');

% % % read in the pressure entity
dWidth = 17;
dHeight = 5.8;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('v',2);
aSubplotPanel(1).pack('h',{0.18 0.04 0.01 0.18 0.18 0.18 0.18});
aSubplotPanel(2).pack('h',{0.05 0.01 0.15 0.15 0.15 0.15 0.15 0.15});
aSubplotPanel.margin = [1 1 1 1]; %left bottom right top
aSubplotPanel(1).margin = [0 0 2 0];
aSubplotPanel(2).margin = [0 0 1 0];
aSubplotPanel.fontsize = 8;

%plot beat 37
iBeat = 37;
iFrames = [30,31,32,33,34,36];
iPrefix = 0; 
iSuffix = 0;
XLim = [8.5 8.6];
YScale = 1800;
iScatterSize = 25;
iAxesOffset = 0.1;
movegui(oFigure,'center');
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure1\LocatingDPS_#';
sSchematicPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\20140821Schematic_highres_noscale.bmp';
 

% plot schematic
oImageAxes = aSubplotPanel(1,1).select();
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\ImageForFigure_2.png','Parent', oImageAxes, 'Border', 'tight');
set(oImageAxes,'box','off','color','none');
axis(oImageAxes,'tight');
axis(oImageAxes,'off');

%% plot electrode 
oAxes = aSubplotPanel(1,6).select();
oBaseAxes = oAxes;
aData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'b-','linewidth',1);
hold(oAxes,'on');
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode1.aghsm.Index(iBeat)), aBeatData(oElectrode1.aghsm.Index(iBeat)),iScatterSize,'b','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

%set axes limits
xlim(oAxes,XLim);
YLim = [min(aData)-200 min(aData)+YScale-200];
ylim(oAxes,YLim);
set(oAxes,'box','off');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'1-SAN','color','b','fontsize',8,'horizontalalignment','center','parent',oAxes);

%% create time scale
hold(oBaseAxes,'on');
oLine = plot(oBaseAxes,[aBeatTime(oElectrode3.aghsm.Index(iBeat)) aBeatTime(oElectrode3.aghsm.Index(iBeat))+0.02],...
    [YLim(1)+100 YLim(1)+100],'k-','linewidth',2);
text(aBeatTime(oElectrode3.aghsm.Index(iBeat))+0.01,YLim(1),'20 ms','parent',oBaseAxes,'horizontalalignment','center','fontsize',8);
hold(oBaseAxes,'off');

%% plot box around upstrokes
iWidth = 0.026;
BoxLim = [XLim(1)+0.012 XLim(1)+0.012+iWidth];
figpos = dsxy2figxy(oBaseAxes, [BoxLim(1) YLim(1)+150 iWidth YScale-200]);
annotation('rectangle',figpos,'linestyle','--','facecolor','none','edgecolor','k')
[figx figy] = dsxy2figxy(oBaseAxes, [BoxLim(2) ; 8.605],[YLim(2)-100;YLim(2)-100]);
annotation('arrow',figx,[0.97 0.97],'headstyle','plain','headwidth',5,'headlength',5);

%% plot electrode 
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset+0.06 0 0]);
aData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'r-','linewidth',1);
hold(oAxes,'on');
aBeatData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode2.arsps.Index(iBeat)), aBeatData(oElectrode2.arsps.Index(iBeat)),iScatterSize,'r','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
hold(oAxes,'off');

%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'2-Exit','color','r','fontsize',8,'horizontalalignment','center','parent',oAxes);

%% plot electrode 
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
aData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'k-','linewidth',1);
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
hold(oAxes,'on');
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode3.arsps.Index(iBeat)), aBeatData(oElectrode3.arsps.Index(iBeat)),iScatterSize,'k','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/4,'3-CT','color','k','fontsize',8,'horizontalalignment','center','parent',oAxes);

%% set xlim
XLim = [XLim(1)+0.012 XLim(1)+0.012+iWidth];

%% Plot upstroke1
oAxes = aSubplotPanel(1,7).select();
oBaseAxes = oAxes;
aData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aIndices = XLim(1) <= aTime & XLim(2) >= aTime;
plot(oAxes,aTime(aIndices),aData(aIndices),'b-','linewidth',1);
hold(oAxes,'on');
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode1.aghsm.Index(iBeat)), aBeatData(oElectrode1.aghsm.Index(iBeat)),iScatterSize,'b','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
text(aBeatTime(iFrames(1)),min(aBeatData),'F1','fontsize',8,'parent',oAxes,'horizontalalignment','center');
text(aBeatTime(iFrames(end)),min(aBeatData),'F6','fontsize',8,'parent',oAxes,'horizontalalignment','center');
hold(oAxes,'off');
%set axes limits
xlim(oAxes,XLim);
YLim = [min(aData)-200 min(aData)+YScale-200];
ylim(oAxes,YLim);
set(oAxes,'box','off');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'  1-SAN','color','b','fontsize',8,'horizontalalignment','left','parent',oAxes);

%% Plot upstroke2
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset+0.06 0 0]);
aData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime(aIndices),aData(aIndices),'r-','linewidth',1);
hold(oAxes,'on');
aBeatData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode2.arsps.Index(iBeat)), aBeatData(oElectrode2.arsps.Index(iBeat)),iScatterSize,'r','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
hold(oAxes,'off');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'  2-Exit','color','r','fontsize',8,'horizontalalignment','left','parent',oAxes);

%% Plot upstroke3
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
aData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime(aIndices),aData(aIndices),'k-','linewidth',1);
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
hold(oAxes,'on');
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode3.arsps.Index(iBeat)), aBeatData(oElectrode3.arsps.Index(iBeat)),iScatterSize,'k','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','-','color',[0.5 0.5 0.5]);
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/4,'  3-CT','color','k','fontsize',8,'horizontalalignment','left','parent',oAxes);

%% put on scale
hold(oBaseAxes,'on');
aTimeToPlot=aTime(aIndices);
oLine = plot(oBaseAxes,[aTimeToPlot(end) aTimeToPlot(end)-0.005],...
    [YLim(1)+100 YLim(1)+100],'k-','linewidth',2);
text(aTimeToPlot(end)-0.0025,YLim(1),'5 ms','parent',oBaseAxes,'horizontalalignment','center','fontsize',8);
hold(oBaseAxes,'off');

%% create rectangle to surround
figpos = dsxy2figxy(oBaseAxes, [BoxLim(1) YLim(1)+150 iWidth YScale-200]);
annotation('rectangle',figpos,'linestyle','--','facecolor','none','edgecolor','k')

%% Plot atrial activation 
aContourRange = [0 10.8];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
oActivation = oOptical.PrepareEventData(100, 'Contour', 'arsps', iBeat, []);
oActivation = GetEventMap(oOptical, oActivation, iBeat);
oAxes = aSubplotPanel(1,5).select();
oOverlay = axes('position',get(oAxes,'position'));
oPointAxes = axes('position',get(oAxes,'position'));
%plot the schematic
oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
%make it transparent in the right places
aCData = get(oImage,'cdata');
aBlueData = aCData(:,:,3);
aAlphaData = aCData(:,:,3);
aAlphaData(aBlueData < 100) = 1;
aAlphaData(aBlueData > 100) = 1;
aAlphaData(aBlueData == 100) = 0;
aAlphaData = double(aAlphaData);
set(oImage,'alphadata',aAlphaData);
set(oOverlay,'box','off','color','none');
axis(oOverlay,'tight');
axis(oOverlay,'off');
[C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeat).z,aContours);
caxis(oAxes,aContourRange);
colormap(oAxes, colormap(flipud(colormap(jet))));
% %plot points
% scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
% text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',14,'horizontalalignment','center','fontweight','bold');
% hold(oPointAxes,'on');
% scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
% text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',14,'horizontalalignment','center');
% scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','none');
% text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'3','color','k','parent',oPointAxes,'fontsize',14,'horizontalalignment','center');
hold(oPointAxes,'off');
axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oPointAxes,'off');
% set(get(oAxes,'title'),'string',['Atrial component',10,'AP50%'],'fontweight','bold');

%% Plot SAN activation 
aContourRange = [0 10.8];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
oActivation = oOptical.PrepareEventData(100, 'Contour', 'aghsm', iBeat, []);
oActivation = GetEventMap(oOptical, oActivation, iBeat);
oAxes = aSubplotPanel(1,4).select();
oOverlay = axes('position',get(oAxes,'position'));
oPointAxes = axes('position',get(oAxes,'position'));
%plot the schematic
oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
%make it transparent in the right places
aCData = get(oImage,'cdata');
aBlueData = aCData(:,:,3);
aAlphaData = aCData(:,:,3);
aAlphaData(aBlueData < 100) = 1;
aAlphaData(aBlueData > 100) = 1;
aAlphaData(aBlueData == 100) = 0;
aAlphaData = double(aAlphaData);
set(oImage,'alphadata',aAlphaData);
set(oOverlay,'box','off','color','none');
axis(oOverlay,'tight');
axis(oOverlay,'off');
[C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeat).z,aContours);
caxis(oAxes,aContourRange);
colormap(oAxes, colormap(flipud(colormap(jet))));
% %plot points
% scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
% text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'A','color','w','parent',oPointAxes,'fontsize',14,'horizontalalignment','center');
hold(oPointAxes,'on');
% scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
% text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'B','color','w','parent',oPointAxes,'fontsize',14,'horizontalalignment','center');
% scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
%     'sizedata',196,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','none');
% text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'C','color','k','parent',oPointAxes,'fontsize',14,'horizontalalignment','center');
% % plot SVC-IVC axis
aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
oAxesElectrodes = oOptical.Electrodes(aAxisData);
aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
scatter(oPointAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
    36,'k','filled');
aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linestyle','--','linewidth',1,'color','k');
z = [0 1 2 3 4 5 6];
slabels = {'','','','','','',''};
scatter(oPointAxes,((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2),...
    ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2),'Marker','+',...
    'sizedata',16,'MarkerEdgeColor','k');
text(((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2)-0.6,...
    ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2)-0.5,slabels,'fontweight','normal','color','k','fontsize',8);
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',144,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');
axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oPointAxes,'off');


%% plot points on image as well
% aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
% aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
oPointAxes = axes('position',get(oImageAxes,'position'));
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
hold(oPointAxes,'on');
scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
    'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
    'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'3','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
hold(oPointAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',[aXlim(1)-0.4, aXlim(2)-0.8],'ylim',[aYlim(1), aYlim(2)],'box','off','color','none');
axis(oPointAxes,'off');

%% draw color bar
aSubplotPanel(1,3).pack('v',{0.2 0.6});
oAxes = aSubplotPanel(1,3,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',8);
aCRange = [0 12];
oLabel = text(-4,(aCRange(2)-aCRange(1))/2,'AT (ms)','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);
%% label panels
% annotation('textbox',[0.01,0.88,0.1,0.1],'string','A','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.25,0.88,0.1,0.1],'string','B','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.42,0.88,0.1,0.1],'string','C','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.6,0.88,0.1,0.1],'string','D','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.8,0.88,0.1,0.1],'string','E','edgecolor','none','fontsize',12,'fontweight','bold');

%% print
sThisFile = [strrep(sSavePath,'#','1'),'.eps'];
print(sThisFile,'-dpsc2','-r600','-painters');
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sThisFile)});
% sChopString = strcat(sChopString, {' -gravity South -chop 0x600'}, {sprintf(' %s',sThisFile)});
% sStatus = dos(char(sChopString{1}));


% %% plot Vm fields
oPotential = oOptical.PreparePotentialMap(100, iBeat, 'arsps', [],[]);
for i = 1:numel(iFrames)
    oAxes = aSubplotPanel(2,2+i).select();
    aContourRange = [-0.1 1];
    aContours = aContourRange(1):0.1:aContourRange(2);
    %get the interpolation points
    aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
    aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
    oOverlay = axes('position',get(oAxes,'position'));
    oPointAxes = axes('position',get(oAxes,'position'));
    %plot the schematic
    oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
    %make it transparent in the right places
    aCData = get(oImage,'cdata');
    aBlueData = aCData(:,:,3);
    aAlphaData = aCData(:,:,3);
    aAlphaData(aBlueData < 100) = 1;
    aAlphaData(aBlueData > 100) = 1;
    aAlphaData(aBlueData == 100) = 0;
    aAlphaData = double(aAlphaData);
    set(oImage,'alphadata',aAlphaData);
    set(oOverlay,'box','off','color','none');
    axis(oOverlay,'tight');
    axis(oOverlay,'off');
    [C, oContour] = contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),oPotential.Beats(iBeat).Fields(iFrames(i)).z,aContours);
    caxis(oAxes,aContourRange);
    colormap(oAxes, colormap(jet));
    if i == 1
        % %plot points
        scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
            'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
        hold(oPointAxes,'on');
        scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
            'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
        scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
            'sizedata',64,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'3','color','w','parent',oPointAxes,'fontsize',8,'horizontalalignment','center');
        hold(oPointAxes,'off');
    end
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oAxes,'off');
    axis(oPointAxes,'equal');
    set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oPointAxes,'off');
end
%% draw color bar
aSubplotPanel(2,2).pack('v',{0.1 0.7});
oAxes = aSubplotPanel(2,2,2).select();
aCRange = [0 1];
aContours = 0:0.1:1;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'Vm_n',8);
aCRange = [0 1];
oLabel = text(-3,(aCRange(2)-aCRange(1))/2,'Normalised F.I.','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);

%% label panels
% annotation('textbox',[0.08,0.35,0.1,0.1],'string','F1','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.23,0.35,0.1,0.1],'string','F2','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.37,0.35,0.1,0.1],'string','F3','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.52,0.35,0.1,0.1],'string','F4','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.67,0.35,0.1,0.1],'string','F5','edgecolor','none','fontsize',12,'fontweight','bold');
% annotation('textbox',[0.81,0.35,0.1,0.1],'string','F6','edgecolor','none','fontsize',12,'fontweight','bold');

%% print
set(oFigure,'resizefcn',[]);
sThisFile = [strrep(sSavePath, '#', '2'),'.eps'];
print(sThisFile,'-dpsc2','-r600','-painters');%
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sThisFile)});
% sChopString = strcat(sChopString, {' -gravity North -chop 0x780 -gravity South -chop 0x20'}, {sprintf(' %s',sThisFile)});
% sStatus = dos(char(sChopString{1}));
% % sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe',{' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sSavePath, 'APDMapmontage.png');
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.png',strrep(sSavePath, '#', '1'))}, ...
%         {sprintf(' %s.png',strrep(sSavePath, '#', '2'))}, {' -append'}, {sprintf(' %s.png', strrep(sSavePath, '_#', ''))});
% sStatus = dos(char(sChopString{1}));

