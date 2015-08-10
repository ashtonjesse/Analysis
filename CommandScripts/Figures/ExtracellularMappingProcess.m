%This figure has three panels at the top showing the interpolation grid and
%triangulation superimposed over the array with some rejected electrodes,
%then with the triangulation area restricted, and then an activation map.
%The lower panel shows a photograph of the tissue and the derivation of the
%schematic, then another panel with the map superimposed over the
%schematic.
close all;
%open the unemap file
% oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\pabaro001_unemap.mat');
% for i = 1:numel(oUnemap.Electrodes)
%     oUnemap.Electrodes(i).SignalEvent(1).Range = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Range, [0 0]);
%     oUnemap.Electrodes(i).SignalEvent(1).Index = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Index, 0);
% end
% oUnemap.RotateArray();
dWidth = 16;
dHeight = 16;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ExtracellularMappingProcess.eps';

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
oSubplotPanel.pack('v',{0.97 0.03});
oSubplotPanel(1).pack('h',{0.33 0.66});
oSubplotPanel(1,1).pack('v',{0.33 0.33 0.33});
oSubplotPanel(1,2).pack('v',{0.66 0.33});
oSubplotPanel(1,2,2).pack('h',{0.25 0.5 0.25});

oSubplotPanel.margin = [8 14 5 2];
oSubplotPanel(1).margin = [5 5 0 0];
% oSubplotPanel(1,2,1).margin = [10 5 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
movegui(oFigure,'center');

%get data
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aAcceptedElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
aRejectedElectrodes = oUnemap.Electrodes(~logical(aAcceptedChannels));
aAllElectrodes = oUnemap.Electrodes;

%...and turn the coords into a 2 column matrix
aCoords = cell2mat({aAllElectrodes(:).Coords})';
aAcceptedCoords = cell2mat({aAcceptedElectrodes(:).Coords})';
rowlocs = aCoords(:,1);
collocs = aCoords(:,2);
dInterpDim = 100;
%Get the interpolated points array
[xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs), ...
    min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
aMeshPoints = [aXArray,aYArray];
%Find which points lie within the area of the array
DT = DelaunayTri(aAcceptedCoords);
[V,S] = alphavol(aAcceptedCoords,1);
[FF XF] = freeBoundary(TriRep(S.tri,aAcceptedCoords));
aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),XF(:,1),XF(:,2));
%get rejected data
aRejectedCoords = cell2mat({aRejectedElectrodes(:).Coords})';
%get activation data
% oActivation = oUnemap.PrepareEventMap(dInterpDim, 1);

%plot left panels
oAxes = oSubplotPanel(1,1,1).select();
scatter(oAxes,rowlocs,collocs,'MarkerFaceColor','k','MarkerEdgeColor','k','SizeData',4);
hold(oAxes,'on');
scatter(oAxes,aRejectedCoords(:,1),aRejectedCoords(:,2),'MarkerFaceColor','r','MarkerEdgeColor','r','SizeData',4);
scatter(oAxes,aXArray,aYArray,'Marker','.','MarkerEdgeColor','k','sizedata',1);
hold(oAxes,'off');
axis(oAxes,'equal');axis(oAxes,'tight');axis(oAxes,'off');
set(oAxes,'box','off','color','none')
oLabel = text(-0.9,4.2,'(A)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oLabel,'fontsize',14);
oLabel = text(5.3,4.2,'(D)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oLabel,'fontsize',14);

oAxes = oSubplotPanel(1,1,2).select();
scatter(oAxes,rowlocs,collocs,'MarkerFaceColor','k','MarkerEdgeColor','k','SizeData',4);
hold(oAxes,'on');
scatter(oAxes,aRejectedCoords(:,1),aRejectedCoords(:,2),'MarkerFaceColor','r','MarkerEdgeColor','r','SizeData',4);
scatter(oAxes,aXArray(aInBoundaryPoints),aYArray(aInBoundaryPoints),'Marker','.','MarkerEdgeColor','k','sizedata',1);
trimesh(S.tri,aAcceptedCoords(:,1),aAcceptedCoords(:,2),'Color','k','parent',oAxes);
hold(oAxes,'off');
axis(oAxes,'equal');axis(oAxes,'tight');axis(oAxes,'off');
set(oAxes,'box','off','color','none')
oLabel = text(-0.9,4.2,'(B)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oLabel,'fontsize',14);

oAxes = oSubplotPanel(1,1,3).select();
aContourRange = [0 11];
aContours = aContourRange(1):1:aContourRange(2);
[C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(34).z,aContours);
caxis(aContourRange);
colormap(oAxes, colormap(flipud(colormap(jet))));
hold(oAxes,'on');
scatter(oAxes,rowlocs,collocs,'MarkerFaceColor','k','MarkerEdgeColor','k','SizeData',4);
scatter(oAxes,aRejectedCoords(:,1),aRejectedCoords(:,2),'MarkerFaceColor','r','MarkerEdgeColor','r','SizeData',4);
%plot earliest activation
oFirstElectrodes = oUnemap.Electrodes(~logical(oActivation.Beats(34).FullActivationTimes));
aTheseCoords = cell2mat({oFirstElectrodes(:).Coords});
aTheseCoords = aTheseCoords';
scatter(oAxes, aTheseCoords(:,1), aTheseCoords(:,2), ...
    'SizeData',40,'MarkerEdgeColor','k','MarkerFaceColor','w');
hold(oAxes,'off');
axis(oAxes,'equal');axis(oAxes,'tight');axis(oAxes,'off');
set(oAxes,'box','off','color','none');
%draw scale bar
aPosition = get(oAxes,'position');
aPosition(2) = aPosition(2) - 0.1;
oOverlay = axes('position',aPosition);
plot(oOverlay,[0 2],[1.3 1.3],'-k','LineWidth', 4);
axis(oOverlay,'equal');
set(oOverlay,'xlim',get(oAxes,'xlim'),'ylim',get(oAxes,'ylim'),'box','off','color','none');
axis(oOverlay,'off');
oLabel = text(-0.9,4.2,'(C)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oLabel,'fontsize',14);
oLabel = text(5.3,4.2,'(E)','parent',oAxes,'fontunits','points','fontweight','bold');
set(oLabel,'fontsize',14);


aXlim = [-2 7.2];
aYlim = [-2.5 6.7];
oAxes = oSubplotPanel(1,2,1).select();
oOverlay = axes('position',get(oAxes,'position'));
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130904\20130904SchematicOnImage_resized.bmp','Parent', oAxes, 'Border', 'tight');
set(oAxes,'box','off','color','none');
axis(oAxes,'tight');
axis(oAxes,'off');
scatter(oOverlay,rowlocs,collocs,'MarkerFaceColor','k','MarkerEdgeColor','k','SizeData',4);
hold(oOverlay,'on');
scatter(oOverlay,aRejectedCoords(:,1),aRejectedCoords(:,2),'MarkerFaceColor','r','MarkerEdgeColor','r','SizeData',4);
hold(oOverlay,'off');
axis(oOverlay,'equal');
set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oOverlay,'off');
%create labels
oLabel = text(3.5,5,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
set(oLabel,'fontsize',14);
oLabel = text(-1,0,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
set(oLabel,'fontsize',14);
oLabel = text(5.5,1.5,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
set(oLabel,'fontsize',14);
oLabel = text(2,-2,'RV','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
set(oLabel,'fontsize',14);

aXlim = [-2 6.4];
aYlim = [-2 6.4];
oAxes = oSubplotPanel(1,2,2,2).select();
oOverlay = axes('position',get(oAxes,'position'));
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130904\20130904Schematic.bmp','Parent', oAxes);
set(oAxes,'box','off','color','none');
axis(oAxes,'tight');
axis(oAxes,'off');
[C, oContour] = contourf(oOverlay,oActivation.x,oActivation.y,oActivation.Beats(34).z,aContours);
caxis(aContourRange);
colormap(oOverlay, colormap(flipud(colormap(jet))));
hold(oOverlay,'on');
%plot earliest activation
oFirstElectrodes = oUnemap.Electrodes(~logical(oActivation.Beats(34).FullActivationTimes));
aTheseCoords = cell2mat({oFirstElectrodes(:).Coords});
aTheseCoords = aTheseCoords';
scatter(oOverlay, aTheseCoords(:,1), aTheseCoords(:,2), ...
    'SizeData',40,'MarkerEdgeColor','k','MarkerFaceColor','w');
hold(oOverlay,'off');
axis(oOverlay,'equal');
set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oOverlay,'off');
%create labels
oLabel = text(3,6,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
set(oLabel,'fontsize',8);
oLabel = text(-0.7,-0.3,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
set(oLabel,'fontsize',8);
oLabel = text(5.2,1.5,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
set(oLabel,'fontsize',8);

oAxes = oSubplotPanel(2).select();
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes);
oXlabel = text(((aContourRange(2)-aContourRange(1))/2)-abs(aContourRange(1)),-2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);

annotation('arrow',[0.66,0.66],[0.55 0.42],'headstyle','vback1','headwidth',22,'linewidth',1);
annotation('arrow',[0.36,0.52],[0.28 0.28],'headstyle','vback1','headwidth',22,'linewidth',1);

print(oFigure,'-dpsc','-r600',sSavePath)