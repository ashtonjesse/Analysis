%load data
% close all;
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
oOptical = ans.oGuiHandle.oOptical;

%set variables
dWidth = 16;
dHeight = 14;
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareCVs_20140828baro001';
sSchematicPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140828\20140828Schematic_noholes.bmp';
% sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Test.bmp';
%Create plot panel that has 3 rows at top to contain pressure, phrenic and
%heart rate 
oFigure2 = figure();
oSummaryAxes = axes('parent',oFigure2);

oFigure = figure();
%set up figure1
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
xrange = 6;
yrange = 5;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',2);
oSubplotPanel(1).pack(5,3);
oSubplotPanel(2).pack(5,3);
movegui(oFigure,'center');

oSubplotPanel.margin = [2 5 2 2];
oSubplotPanel(1).margin = [5 8 0 0];
oSubplotPanel(2).margin = [5 8 0 0];

oSubplotPanel(1).fontsize = 4;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(2).fontsize = 4;
oSubplotPanel(2).fontweight = 'normal';

iBeatIndex = 1;
sEventID = 'arsps';
%find the earliest activation sites
if isfield(oOptical.Electrodes(1).(sEventID),'Map')
    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,sEventID,'Map');
    aAcceptedChannels = aAcceptedChannels(iBeatIndex,:);
else
    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
end
aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));
aCoords = [aElectrodes(:).Coords]';
bNewFigure = true;
sPlotColour = 'k';
iPanelIndex = 1;
iAxesIndex = 0;
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
%[1,2,3,4,5,22,23,24,25,26]
for i = [1,2,3,4,5,31,32,34,35,36]

    if i > 5 && bNewFigure
        sPlotColour = 'r';
        bNewFigure = false;
        iPanelIndex = 2;
        iAxesIndex = 0;
    end
    iAxesIndex = iAxesIndex + 1;
    iBeatIndex = i;
    oActivationAxes = oSubplotPanel(iPanelIndex,iAxesIndex,1).select();
    oCVAxes = oSubplotPanel(iPanelIndex,iAxesIndex,2).select();
    oCVSpaceAxes = oSubplotPanel(iPanelIndex,iAxesIndex,3).select();
    
    %% plot activation
    oActivation = oOptical.PrepareActivationMap(100, 'Contour', sEventID, 24, iBeatIndex, []);
    oOverlay = axes('position',get(oActivationAxes,'position'));
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
    oOriginAxes = axes('position',get(oActivationAxes,'position'));
    aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
    aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeatIndex,:)).Coords});
    if ~isempty(aOriginCoords)
%         scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
%             'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
    end
    hold(oOriginAxes,'on');
    [C, oContour] = contourf(oActivationAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeatIndex).z,aContours);
    axis(oActivationAxes,'equal');
    set(oActivationAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oActivationAxes,'off');
    axis(oOriginAxes,'equal');
    set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oOriginAxes,'off');
    cmap = colormap(oActivationAxes, flipud(jet(aContourRange(2)-aContourRange(1))));
    caxis(oActivationAxes,aContourRange);
    oLabel = text(aXlim(1)+1,aYlim(2)-0.5,num2str(iBeatIndex),'parent',oActivationAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
    set(oLabel,'fontsize',10);
    
    %% plot CV
    oOverlay = axes('position',get(oCVAxes,'position'));
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
    idxCV = find(~isnan(oActivation.Beats(iBeatIndex).CVApprox));
    aCVdata = oActivation.Beats(iBeatIndex).CVApprox(idxCV);
    scatter(oCVAxes,oActivation.CVx(idxCV),oActivation.CVy(idxCV),4,aCVdata,'filled');
    hold(oCVAxes, 'on');
    oQuivers = quiver(oCVAxes,oActivation.CVx(idxCV),oActivation.CVy(idxCV),oActivation.Beats(iBeatIndex).CVVectors(idxCV,1),oActivation.Beats(iBeatIndex).CVVectors(idxCV,2),'color','k','linewidth',0.2);
    hold(oCVAxes, 'off');
    caxis([0 1]);
    axis(oCVAxes,'equal');
    set(oCVAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oCVAxes,'off');
    
    %% Plot spatial CV
    if isfield(oOptical.Electrodes(1).(sEventID),'Exit')
        aExitData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
            oOptical.Electrodes,sEventID,'Exit');
        aEarlyCoords = cell2mat({oOptical.Electrodes(aExitData(iBeatIndex,:)).Coords});
        if isempty(aEarlyCoords)
            aEarlySites = find(oActivation.Beats(iBeatIndex).FullActivationTimes == min(oActivation.Beats(iBeatIndex).FullActivationTimes));
            aEarlyCoords = [oOptical.Electrodes(aEarlySites).Coords];
            %find centre of mass
            Mx = mean(aEarlyCoords(1,:));
            My = mean(aEarlyCoords(2,:));
            [val Ox] = min(abs(aEarlyCoords(1,:)-Mx));
            [val Oy] = min(abs(aEarlyCoords(2,:)-My));
        else
            Ox = 1; Oy = 1;
        end
        
    else
        aEarlySites = find(oActivation.Beats(iBeatIndex).FullActivationTimes == min(oActivation.Beats(iBeatIndex).FullActivationTimes));
        aEarlyCoords = [oOptical.Electrodes(aEarlySites).Coords];
        %find centre of mass
        Mx = mean(aEarlyCoords(1,:));
        My = mean(aEarlyCoords(2,:));
        [val Ox] = min(abs(aEarlyCoords(1,:)-Mx));
        [val Oy] = min(abs(aEarlyCoords(2,:)-My));
    end

    scatter(oOriginAxes,aEarlyCoords(1,Ox),aEarlyCoords(2,Oy), ...
         'sizedata',12,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
    %find min and max CVs from an area of 9x9 not include the central 3x3
    %get CVs for accepted electrodes
    aCVs = oActivation.Beats(iBeatIndex).CVApprox(logical(aAcceptedChannels));
    aCVVectors = oActivation.Beats(iBeatIndex).CVVectors(logical(aAcceptedChannels),:);
    %restrict to local 7x7 neighbourhood
    RelativeDistVectors = aCoords-repmat([aEarlyCoords(1,Ox),aEarlyCoords(2,Oy)],[size(aCoords,1),1]);
    [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
    aLocalRegion = sort(SupportPoints(1:49),1,'ascend');
    %don't remove central 3x3
    aCentralRegion = sort(SupportPoints(1:9),1,'ascend');
    aPointsToPlot = false(1,numel(aElectrodes));
    aPointsToPlot(aLocalRegion) = true;
    aPointsToPlot(aCentralRegion) = true;
    %get CVs of interest
    aLocalCVs = aCVs(aPointsToPlot);
    aLocalCVVectors = aCVVectors(aPointsToPlot,:);
    aLocalCoords = aCoords(aPointsToPlot,:);
            
    scatter(oCVSpaceAxes, aLocalCVs.*aLocalCVVectors(:,1), aLocalCVs.*aLocalCVVectors(:,2),6,sPlotColour, 'filled');
    hold(oCVSpaceAxes,'on');
    plot(oCVSpaceAxes,[-1.5 1.5],[0 0],'k');
    plot(oCVSpaceAxes,[0 0],[1.5 -1.5],'k');
    axis(oCVSpaceAxes,'equal');
    set(oCVSpaceAxes,'xlim',[-1.5 1.5],'ylim',[-1.5 1.5],'box','off');
    if i == 1
        set(get(oCVSpaceAxes,'ylabel'),'string','CV (m/s)');
        set(get(oCVSpaceAxes,'xlabel'),'string','CV (m/s)');
    end
    
    %plot onto summary axes
    scatter(oSummaryAxes, aLocalCVs.*aLocalCVVectors(:,1), aLocalCVs.*aLocalCVVectors(:,2),6,sPlotColour, 'filled');
    hold(oSummaryAxes,'on');
end
plot(oSummaryAxes,[-1.5 1.5],[0 0],'k');
plot(oSummaryAxes,[0 0],[1.5 -1.5],'k');
axis(oSummaryAxes,'equal');
set(oSummaryAxes,'xlim',[-1.5 1.5],'ylim',[-1.5 1.5],'box','off');
set(get(oSummaryAxes,'ylabel'),'string','CV (m/s)');
set(get(oSummaryAxes,'xlabel'),'string','CV (m/s)');

print(oFigure,'-dbmp','-r600',[sFileSavePath,'.bmp'])
print(oFigure2,'-dbmp','-r600',[sFileSavePath,'_summary.bmp'])
