%this figure plots a right atrial schematic with areas used for comparisons
%of regional differences in CV, APA and delVm
close all;
%set variables
dWidth = 2.5;
dHeight = 2.5;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2017\PacemakerUncoupling\Figures\RegionsForDataAnalysis.png';

%set up figure
oFigure = figure();
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack(1);
movegui(oFigure,'center');
oSubplotPanel.margin = [0,0,0,0];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]

aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);

oAxes = oSubplotPanel(1).select();
%plot the schematic
oOverlay = axes('position',get(oAxes,'position'));
colormap(oOverlay,flipud(jet));
set(oOverlay,'box','off','color','none');
oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
aCData = get(oImage,'cdata');
aBlueData = aCData(:,:,3);
aAlphaData = aCData(:,:,3);
aAlphaData(aBlueData < 100) = 1;
aAlphaData(aBlueData > 100) = 1;
aAlphaData(aBlueData == 100) = 0;
aAlphaData = double(aAlphaData);
set(oImage,'alphadata',aAlphaData);
axis(oOverlay,'tight');
axis(oOverlay,'off');

%get coords of centre points
aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
oAxesElectrodes = oOptical.Electrodes(aAxisData);
aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
% z = [1 4];
% xCoords = ((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2);
% yCoords = ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2);
% % plot the circles
% aColours = [0,0,0;96,96,96;128,128,128;160,160,164;212,212,212]./255;
% for ii = 1:numel(z)
%     th = 0:pi/50:2*pi;
%     xunit = 1 * cos(th) + xCoords(ii);
%     yunit = 1 * sin(th) + yCoords(ii);
%     plot(oAxes,xunit,yunit,'linewidth',1,'linestyle','-','color',aColours(ii,:));
    hold(oAxes,'on');
% end
% aRAALoc = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
%     oOptical.Electrodes,'arsps','Exit');
% aCentrePoint = cell2mat({oOptical.Electrodes(logical(aRAALoc(1,:))).Coords})';
% th = 0:pi/50:2*pi;
% xunit = 1 * cos(th) + aCentrePoint(1);
% yunit = 1 * sin(th) + aCentrePoint(2);
% plot(oAxes,xunit,yunit,'linewidth',1,'linestyle','-','color',aColours(end,:));

z = [0 1 2 3 4 5 6];
xCoords = ((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2);
yCoords = ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2);
% plot SVC-IVC axis
aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linestyle','-','linewidth',1,'color','k','parent',oAxes);
%plot the centre points
scatter(oAxes, xCoords, yCoords,25,'k','marker','+','linewidth',1);
axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');

%get origins
oOriginAxes = axes('position',get(oAxes,'position'));
aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
aCoords = oOptical.Electrodes(aOrigins(38,:)).Coords;
scatter(oOriginAxes, aCoords(1,:), aCoords(2,:), ...
    'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
hold(oOriginAxes,'on');
aCoords = oOptical.Electrodes(aOrigins(56,:)).Coords;
scatter(oOriginAxes, aCoords(1,:), aCoords(2,:), ...
    'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
axis(oOriginAxes,'equal');
set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oOriginAxes,'off');
export_fig(sFileSavePath,'-png','-r300','-nocrop')