%This figure has four panels. Top left is an image of the right atrium with
%superimposed schematic and locations of recording points for panel B, as
%well as location of SAN activation map. Panel B shows recordings from
%central SAN and exit site superimposed. Bottom two panels show activation
%maps for SAN and atrial components.

close all;
% clear all;
% % % % %open data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140722\';
% sRecording = 'baro002';
% sSubDir = [sBaseDir,sBaseDir(end-8:end-1),sRecording,'\'];
% 
% % % %% read in the optical entities
% sAvOpticalFileName = [sSubDir,sRecording,'_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
% oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
% sOpticalFileName = [sSubDir,sRecording,'_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % % read in the pressure entity
% oPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

dWidth = 12;
dHeight = 12;
sSavePath1 = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\OpticalMappingProcess.eps';
sSavePath2 = 'D:\Users\jash042\Documents\PhD\Publications\2015\Paper1\Figures\OpticalMappingProcess.bmp';

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
oSubplotPanel.pack('v',{0.44 0.44 0.03});
oSubplotPanel(1).pack('h',{0.5 0.5});
oSubplotPanel(2).pack('h',{0.5 0.5});
oSubplotPanel.margin = [1 1 1 1]; %left bottom right top
oSubplotPanel(1).margin = [0 0 0 0];
oSubplotPanel(2).margin = [1 1 1 10];
% oSubplotPanel(1,1,2).margin = [1 1 1 0];
% oSubplotPanel(1,2,1).margin = [1 0 1 1];
% oSubplotPanel(1,2,2).margin = [1 0 1 1];
movegui(oFigure,'center');

%plot schematic
oImageAxes = oSubplotPanel(1,1).select();
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140722\ImageForFigure.png','Parent', oImageAxes, 'Border', 'tight');
set(oImageAxes,'box','off','color','none');
axis(oImageAxes,'tight');
axis(oImageAxes,'off');


%% plot optical action potentials
oAxes = oSubplotPanel(1,2).select();
%plot electrode 1
% [oElectrode1, iIndex] = GetElectrodeByName(oOptical,'25-10');
%plot beat 10
iBeat = 10;
iPrefix = 10;
iSuffix = 40;
XLim = [2.15 2.28];
YLim = [-50 600];
aData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1)-iPrefix:oOptical.Beats.Indexes(iBeat,2)+iSuffix);
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1)-iPrefix:oOptical.Beats.Indexes(iBeat,2)+iSuffix);
plot(oAxes,aTime,aData,'b-','linewidth',1.5);
hold(oAxes,'on');
aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
aBeatData = oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot lines for activation
oLine = plot(oAxes,[aTime(1) aTime(end)],[oElectrode1.Processed.Data(oElectrode1.aghsm.RangeStart(iBeat,1)) ...
    oElectrode1.Processed.Data(oElectrode1.aghsm.RangeStart(iBeat,1))],'b--');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
oLine = plot(oAxes,[aTime(1) aTime(end)],[oElectrode1.Processed.Data(oElectrode1.aghsm.RangeEnd(iBeat,1)) ...
    oElectrode1.Processed.Data(oElectrode1.aghsm.RangeEnd(iBeat,1))],'b--');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot activation time
oLine = plot(oAxes,[aBeatTime(oElectrode1.aghsm.Index(iBeat)) aBeatTime(oElectrode1.aghsm.Index(iBeat))],...
    [YLim(1)+40 oElectrode1.Processed.Data(oElectrode1.aghsm.RangeEnd(iBeat,1))],'b--');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
oLine = scatter(oAxes,aBeatTime(oElectrode1.aghsm.Index(iBeat)), aBeatData(oElectrode1.aghsm.Index(iBeat)),36,'b','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%label activation time
text(aBeatTime(oElectrode1.aghsm.Index(iBeat)-2), aBeatData(oElectrode1.aghsm.Index(iBeat)),'AP50%',...
    'horizontalalignment','right','parent',oAxes,'color','b');
text(XLim(1)+0.08,aBeatData(oElectrode1.aghsm.Index(iBeat)),'SAN','color','b','parent',oAxes,'horizontalalignment','center','rotation',90);

%plot electrode 2
% [oElectrode2, iIndex] = GetElectrodeByName(oOptical,'29-16');
aData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1)-iPrefix:oOptical.Beats.Indexes(iBeat,2)+iSuffix);
plot(oAxes,aTime,aData,'r-','linewidth',1.5);
aBeatData = oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
%plot lines for activation
oLine = plot(oAxes,[aTime(1) aTime(end)],[oElectrode2.Processed.Data(oElectrode2.abhsm.RangeEnd(iBeat,1)-5) ...
    oElectrode2.Processed.Data(oElectrode2.abhsm.RangeEnd(iBeat,1)-5)],'r--','linewidth',1);
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%plot activation time
oLine = plot(oAxes,[aBeatTime(oElectrode2.abhsm.Index(iBeat)) aBeatTime(oElectrode2.abhsm.Index(iBeat))],...
    [YLim(1)+40 oElectrode2.Processed.Data(oElectrode2.abhsm.RangeEnd(iBeat,1)-5)],'r--');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
oLine = scatter(oAxes,aBeatTime(oElectrode2.abhsm.Index(iBeat)), aBeatData(oElectrode2.abhsm.Index(iBeat)),36,'r','filled');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
%label activation time
text(aBeatTime(oElectrode2.abhsm.Index(iBeat)-2), aBeatData(oElectrode2.abhsm.Index(iBeat)),'AP50%',...
    'horizontalalignment','right','parent',oAxes,'color','r');
text([XLim(1)+0.105],aBeatData(oElectrode2.abhsm.Index(iBeat)),'Atrial','color','r','parent',oAxes,'horizontalalignment','center','rotation',90);
%create legend
oLegend = legend(oAxes,'show',{'1-SAN','2-CT'});
legend('boxoff');
set(oLegend,'position',[0.5019    0.8301    0.2115    0.0925]);
%create time scale
oLine = plot(oAxes,[aBeatTime(oElectrode1.aghsm.Index(iBeat)) aBeatTime(oElectrode1.aghsm.Index(iBeat))+0.05],...
    [YLim(1)+30 YLim(1)+30],'k-','linewidth',2);
text(aBeatTime(oElectrode1.aghsm.Index(iBeat))+0.025,YLim(1),'50 ms','parent',oAxes,'horizontalalignment','center');
hold(oAxes,'off');
%set axes limits
xlim(oAxes,XLim);
ylim(oAxes,YLim);
set(oAxes,'box','off','color','none');
axis(oAxes,'off');

%annotate with arrows
[figx figy] = dsxy2figxy(oAxes, [XLim(1)+0.075 ; XLim(1)+0.075], ...
        [oElectrode1.Processed.Data(oElectrode1.aghsm.RangeStart(iBeat,1)) ;
    oElectrode1.Processed.Data(oElectrode1.aghsm.RangeEnd(iBeat,1))]);
annotation('doublearrow',figx,figy,'headstyle','plain','headwidth',4,'headlength',4,'color','b');
[figx figy] = dsxy2figxy(oAxes, [XLim(1)+0.1 ; XLim(1)+0.1], ...
        [oElectrode1.Processed.Data(oElectrode1.aghsm.RangeStart(iBeat,1)) ;
    oElectrode2.Processed.Data(oElectrode2.abhsm.RangeEnd(iBeat,1)-5)]);
annotation('doublearrow',figx,figy,'headstyle','plain','headwidth',4,'headlength',4,'color','r');

%% Plot SAN activation 
% %plot maps
%plot the schematic
aContourRange = [0 10.8];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'aghsm', 24, iBeat, []);
oAxes = oSubplotPanel(2,1).select();
oOverlay = axes('position',get(oAxes,'position'));
oPointAxes = axes('position',get(oAxes,'position'));
%plot the schematic
oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140722\SchematicForFigure.bmp','Parent', oOverlay, 'Border', 'tight');
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
%plot points
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'on');
scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','none');
text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','k','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
%plot SVC-IVC axis
aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
oAxesElectrodes = oOptical.Electrodes(aAxisData);
aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
scatter(oPointAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
    36,'k','filled');
aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linestyle','--','linewidth',1,'color','k');
z = [1 2 3 4 5 6];
slabels = {'1','2','3','4','5','6'};
scatter(oPointAxes,((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2),...
    ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2),'Marker','+',...
    'sizedata',16,'MarkerEdgeColor','k');
text(((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2)-0.4,...
    ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2)-0.2,slabels,'fontweight','normal','color','k','fontsize',6);
hold(oPointAxes,'off');
axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oPointAxes,'off');
[figx figy] = dsxy2figxy(oPointAxes, [aAxesCoords(1,1)+0.4;aAxesCoords(1,1)-0.05], ...
    [aAxesCoords(2,1)-1;aAxesCoords(2,1)-0.21]);
annotation('textarrow',figx,figy,'string','SVC-IVC axis (mm)','headstyle','plain','headwidth',4,'headlength',4,'color','k','horizontalalignment','right');
%% Plot atrial activation 
% %plot maps
%plot the schematic
aContourRange = [0 10.8];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'abhsm', 24, iBeat, []);
oAxes = oSubplotPanel(2,2).select();
oOverlay = axes('position',get(oAxes,'position'));
oPointAxes = axes('position',get(oAxes,'position'));
%plot the schematic
oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140722\SchematicForFigure.bmp','Parent', oOverlay, 'Border', 'tight');
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
%plot points
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'on');
scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'off');

axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oPointAxes,'off');

%put points on image as well
oPointAxes = axes('position',get(oImageAxes,'position'));
scatter(oPointAxes, oElectrode1.Coords(1,:), oElectrode1.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode1.Coords(1,:), oElectrode1.Coords(2,:),'1','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'on');
scatter(oPointAxes, oElectrode2.Coords(1,:), oElectrode2.Coords(2,:), ...
    'sizedata',49,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','none');
text(oElectrode2.Coords(1,:), oElectrode2.Coords(2,:),'2','color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
hold(oPointAxes,'off');
axis(oPointAxes,'equal');
set(oPointAxes,'xlim',[aXlim(1)-0.2, aXlim(2)-0.2],'ylim',[aYlim(1)+0.3, aYlim(2)+0.3],'box','off','color','none');
axis(oPointAxes,'off');

%% create scale
oSubplotPanel(3).pack('h',{0.1,0.8});
oAxes = oSubplotPanel(3,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'horiz','nonlinear',oAxes,'AT');
aCRange = [0 12];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+(aCRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','horizontalalignment','center');
set(oXlabel,'fontsize',10);

%% create labels
annotation('textbox',[0.04,0.9,0.1,0.1],'string','A.','linestyle','none','fontweight','normal','color','w','fontsize',14);
annotation('textbox',[0.5,0.9,0.1,0.1],'string','B.','linestyle','none','fontweight','normal','color','k','fontsize',14);
annotation('textbox',[0.04,0.48,0.1,0.1],'string','C.   SAN activation','linestyle','none','fontweight','normal','color','k','fontsize',14);
annotation('textbox',[0.5,0.48,0.1,0.1],'string','D.  Atrial activation','linestyle','none','fontweight','normal','color','k','fontsize',14);
print(oFigure,'-dpsc','-r600',sSavePath1)
print(oFigure,'-dbmp','-r300',sSavePath2)
