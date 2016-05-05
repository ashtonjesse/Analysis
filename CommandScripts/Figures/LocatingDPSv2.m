%this script draws a figure with two rows of axes that demonstrate the
%process of determining the site of dominant pacemaker
% version 2 does not have any activation maps
close all;
% clear all;
% % % %open data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\';
% sRecording = 'baro001';
% sSubDir = [sBaseDir,sBaseDir(end-8:end-1),sRecording,'\'];
% 
% % % %% read in the optical entities
% sOpticalFileName = [sSubDir,sRecording,'a_3x3_1ms_g10_LP100Hz-waveEach_forfigure.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% [oElectrode1, iIndex] = GetElectrodeByName(oOptical,'16-14');
% [oElectrode2, iIndex] = GetElectrodeByName(oOptical,'16-18');
% [oElectrode3, iIndex] = GetElectrodeByName(oOptical,'26-13');

% % % read in the pressure entity
dWidth = 10;
dHeight = 14;
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
aSubplotPanel.pack('v',{0.45,0.55});
aSubplotPanel(1).pack('h',{0.33 0.33 0.33});
aSubplotPanel(2).pack('h',{0.05 0.02 0.93});
aSubplotPanel(2,3).pack(3,3);
aSubplotPanel.margin = [1 1 1 1]; %left bottom right top
aSubplotPanel(1).margin = [5 5 0 0];
aSubplotPanel(2).margin = [0 0 0 0];
aSubplotPanel.fontsize = 6;

%plot beat 37
iBeat = 37;
iFrames = [30,31,32,33,34,35,36,37,38];
iPrefix = 0; 
iSuffix = 0;
XLim = [8.5 8.6];
YScale = 2200;
iScatterSize = 25;
iAxesOffset = 0.1;
movegui(oFigure,'center');
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\LocatingDPS';
sSchematicPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\20140821Schematic.bmp';
sSchematicPathNoScale = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\20140821Schematic_noscale_noholes.bmp';
 

%% plot schematic
oImageAxes = aSubplotPanel(1,1).select();
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\ImageForFigure.png','Parent', oImageAxes, 'Border', 'tight');
set(oImageAxes,'box','off','color','none');
axis(oImageAxes,'tight');
axis(oImageAxes,'off');

%% plot electrode 
oAxes = aSubplotPanel(1,2).select();
oBaseAxes = oAxes;
aData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'k-','linewidth',1);
hold(oAxes,'on');
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode3.abhsm.Index(iBeat)), aBeatData(oElectrode3.abhsm.Index(iBeat)),iScatterSize,'k','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

%set axes limits
xlim(oAxes,XLim);
YLim = [min(aData)-200 min(aData)+YScale-200];
ylim(oAxes,YLim);
set(oAxes,'box','off');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'3-CT','color','k','fontsize',6,'horizontalalignment','center','parent',oAxes);

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
annotation('arrow',figx,[0.97 0.97],'headstyle','plain','headwidth',4,'headlength',4);

%% plot electrode 
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset+0.06 0 0]);
aData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'r-','linewidth',1);
hold(oAxes,'on');
aBeatData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode2.abhsm.Index(iBeat)), aBeatData(oElectrode2.abhsm.Index(iBeat)),iScatterSize,'r','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
hold(oAxes,'off');

%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'2-Exit','color','r','fontsize',6,'horizontalalignment','center','parent',oAxes);

%% plot electrode 
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
aData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime,aData,'b-','linewidth',1);
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
hold(oAxes,'on');
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode1.aghsm.Index(iBeat)), aBeatData(oElectrode1.aghsm.Index(iBeat)),iScatterSize,'b','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/4,'1-SAN','color','b','fontsize',6,'horizontalalignment','center','parent',oAxes);

%% set xlim
XLim = [XLim(1)+0.012 XLim(1)+0.012+iWidth];

%% Plot upstroke1
oAxes = aSubplotPanel(1,3).select();
oBaseAxes = oAxes;
aData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aIndices = XLim(1) <= aTime & XLim(2) >= aTime;
plot(oAxes,aTime(aIndices),aData(aIndices),'k-','linewidth',1);
hold(oAxes,'on');
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode3.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode3.abhsm.Index(iBeat)), aBeatData(oElectrode3.abhsm.Index(iBeat)),iScatterSize,'k','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(4)) aBeatTime(iFrames(4))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
hold(oAxes,'off');
%set axes limits
xlim(oAxes,XLim);
YLim = [min(aData)-200 min(aData)+YScale-200];
ylim(oAxes,YLim);
set(oAxes,'box','off');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'  3','color','k','fontsize',6,'horizontalalignment','left','parent',oAxes);

%% Plot upstroke2
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset+0.06 0 0]);
aData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime(aIndices),aData(aIndices),'r-','linewidth',1);
hold(oAxes,'on');
aBeatData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode2.abhsm.Index(iBeat)), aBeatData(oElectrode2.abhsm.Index(iBeat)),iScatterSize,'r','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(4)) aBeatTime(iFrames(4))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
hold(oAxes,'off');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/6,'  2','color','r','fontsize',6,'horizontalalignment','left','parent',oAxes);

%% Plot upstroke3
oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
aData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
plot(oAxes,aTime(aIndices),aData(aIndices),'b-','linewidth',1);
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
hold(oAxes,'on');
%plot activation time
oLine = scatter(oAxes,aBeatTime(oElectrode1.aghsm.Index(iBeat)), aBeatData(oElectrode1.aghsm.Index(iBeat)),iScatterSize,'b','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot lines for frame references
oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
oLine = plot(oAxes,[aBeatTime(iFrames(4)) aBeatTime(iFrames(4))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
text(aBeatTime(iFrames(1)),max(aBeatData),'D1','fontsize',8,'parent',oAxes,'horizontalalignment','center');
text(aBeatTime(iFrames(4)),max(aBeatData),'D4','fontsize',8,'parent',oAxes,'horizontalalignment','center');
text(aBeatTime(iFrames(end)),max(aBeatData),sprintf('D%1.0f',numel(iFrames)),'fontsize',8,'parent',oAxes,'horizontalalignment','center');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,[min(aData) min(aData)+YScale]);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');
%label electrode
text(XLim(1),min(aData)+YScale/4,'  1','color','b','fontsize',6,'horizontalalignment','left','parent',oAxes);

%% put on scale
hold(oBaseAxes,'on');
oLine = plot(oBaseAxes,[aBeatTime(oElectrode1.aghsm.Index(iBeat)) aBeatTime(oElectrode1.aghsm.Index(iBeat))+0.01],...
    [YLim(1)+100 YLim(1)+100],'k-','linewidth',2);
text(aBeatTime(oElectrode1.aghsm.Index(iBeat))+0.005,YLim(1),'10 ms','parent',oBaseAxes,'horizontalalignment','center','fontsize',8);
hold(oBaseAxes,'off');

%% create rectangle to surround
figpos = dsxy2figxy(oBaseAxes, [BoxLim(1) YLim(1)+150 iWidth YScale-200]);
annotation('rectangle',figpos,'linestyle','--','facecolor','none','edgecolor','k')

%% plot points on image as well
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
oPointAxes = axes('position',get(oImageAxes,'position'));
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'on');
scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
    'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
    'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'3','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',[aXlim(1)-0.4, aXlim(2)-0.8],'ylim',[aYlim(1), aYlim(2)],'box','off','color','none');
axis(oPointAxes,'off');

%% label panels
annotation('textbox',[0.01,0.89,0.1,0.1],'string','A','edgecolor','none','fontsize',12,'fontweight','bold');
annotation('textbox',[0.3,0.89,0.1,0.1],'string','B','edgecolor','none','fontsize',12,'fontweight','bold');
annotation('textbox',[0.68,0.89,0.1,0.1],'string','C','edgecolor','none','fontsize',12,'fontweight','bold');

%% print
% sThisFile = [strrep(sSavePath,'#','1'),'.png'];
% export_fig(sThisFile,'-png','-r300','-nocrop');
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sThisFile)});
% sChopString = strcat(sChopString, {' -gravity South -chop 0x550'}, {sprintf(' %s',sThisFile)});
% sStatus = dos(char(sChopString{1}));


%% plot Vm fields
oPotential = oOptical.PreparePotentialMap(100, iBeat, 'abhsm', []);
iRow = 1;
iCol = 1;
for i = 1:numel(iFrames)
    oAxes = aSubplotPanel(2,3,iRow,iCol).select();
    aContourRange = [-0.1 1];
    aContours = aContourRange(1):0.1:aContourRange(2);
    %get the interpolation points
    aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
    aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
    oOverlay = axes('position',get(oAxes,'position'));
    oPointAxes = axes('position',get(oAxes,'position'));
    %plot the schematic
    if i > 1
        oImage = imshow(sSchematicPathNoScale,'Parent', oOverlay, 'Border', 'tight');
    else
        oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
    end
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
            'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
        hold(oPointAxes,'on');
        scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
            'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
        scatter(oPointAxes, oElectrode3.Coords(1,:), oElectrode3.Coords(2,:), ...
            'sizedata',36,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
        text(oElectrode3.Coords(1,:), oElectrode3.Coords(2,:),'3','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
        hold(oPointAxes,'off');
    end
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oAxes,'off');
    axis(oPointAxes,'equal');
    set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oPointAxes,'off');
    %label frame
    text(aXlim(1),aYlim(2)-0.5,sprintf('D%1.0f',i),'fontsize',12,'fontweight','bold');
    %label time
    text(aXlim(2)-0.5,aYlim(1)+2,sprintf('%1.1f ms',(aBeatTime(iFrames(i))-aBeatTime(iFrames(1)))*1000),'fontsize',8,'horizontalalignment','right');
    iCol = iCol + 1;
    if ~mod(i,3)
        iRow = iRow + 1;
        iCol = 1;
    end
end
%% draw color bar
aSubplotPanel(2,2).pack('v',{0.3 0.4});
oAxes = aSubplotPanel(2,2,2).select();
aCRange = [0 1];
aContours = 0:0.1:1;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'Vm_n');
aCRange = [0 1];
oLabel = text(-1.5,(aCRange(2)-aCRange(1))/2,'Normalised F.I.','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);


% % %% print
set(oFigure,'resizefcn',[]);
export_fig([sSavePath,'.png'],'-png','-r300','-nocrop');%
print([sSavePath,'.eps'],'-dpsc','-r300');
