%28/01/2017
%this command script loops through files specified in a CSV and creates
%figures of activation time, action potential amplitude, conduction
%velocity for 5 baseline beats and 5 beats leading up to shift
% close all;

%open list of data
CSV = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\BaroCLandLocationData.csv');
%define constants
sFileSavePath = 'G:\PhD\Experiments\Auckland\InSituPrep\Statistics\Figures\APA_CV_AT_';
dWidth = 16;
dHeight = 14;
try 
    close(oFigure);
catch ex
    
end
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
xrange = 6;
yrange = 5;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',2);
oSubplotPanel(1).pack(5,3);
oSubplotPanel(2).pack(5,3);
movegui(oFigure,'center');

oSubplotPanel.margin = [2 5 2 2];
oSubplotPanel(1).margin = [0 0 0 0];
oSubplotPanel(2).margin = [0 0 0 0];

oSubplotPanel(1).fontsize = 4;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(2).fontsize = 4;
oSubplotPanel(2).fontweight = 'normal';

%define contour ranges
aATContourRange = [0 12];
aATContours = aATContourRange(1):1.2:aATContourRange(2);
    
%initialise variables
oOriginAxes = zeros(10,1);
%loop through files specified in CSV
for ii = 1:size(CSV.aData,1)
    %get optical file for this recording
    sDir = ['G:\PhD\Experiments\Auckland\InSituPrep\',...
        num2str(CSV.aData(ii,strcmp(CSV.aHeader,'Experiment'))),'\',...
        num2str(CSV.aData(ii,strcmp(CSV.aHeader,'Experiment'))),'baro',sprintf('%.3d',CSV.aData(ii,strcmp(CSV.aHeader,'Recording'))),'\'];
    sOpticalFile = dir([sDir,'baro',sprintf('%.3d',CSV.aData(ii,strcmp(CSV.aHeader,'Recording'))),'*waveEach.mat']);
    oOptical = GetOpticalFromMATFile(Optical,[sDir,sOpticalFile.name]);
    
    iShiftBeatIndex = CSV.aData(ii,strcmp(CSV.aHeader,'Beat1'));
    sEventID = 'arsps';
   
    % get the average dp sites for the baseline cycles
    aDPCoords = zeros(2,5);
    aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
        oOptical.Electrodes,'aghsm','Origin');
    for nn = 1:5
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(nn,:)).Coords});
        if ~isempty(aOriginCoords)
            aDPCoords(:,nn) = aOriginCoords;
        else
            aDPCoords(:,nn) = aOldDPCoords(:,nn);
        end
    end
    aOldDPCoords = aDPCoords;
    %get electrodes within neighbourhood
    aCoords = [oOptical.Electrodes(:).Coords]';
    RelativeDistVectors = aCoords-repmat([mean(aDPCoords(1,:)),mean(aDPCoords(2,:))],[size(aCoords,1),1]);
    [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
    aLocalRegion = SupportPoints(Dist <= 2.5);
    aPointsToPlot = false(1,numel(oOptical.Electrodes));
    aPointsToPlot(aLocalRegion) = true;
    if isfield(oOptical.Electrodes(1).(sEventID),'Map')
        aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,sEventID,'Map');
        aAcceptedChannels = aAcceptedChannels(1,:);
    else
        aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
    end
    aPointsToPlot = aPointsToPlot & logical(aAcceptedChannels);
    
    %define axes counters
    iPanelIndex = 1;
    iAxesIndex = 0;
   
    %specify beats to loop through
    aBeatIndexes = [1,2,3,4,5,iShiftBeatIndex-5,iShiftBeatIndex-4,iShiftBeatIndex-3,iShiftBeatIndex-2,iShiftBeatIndex-1];
    %initialise  variables
    oActivation = [];
    aElectrodeData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Data');
    oPotential = oOptical.PreparePotentialMap(100,1,sEventID,[],aPointsToPlot);
    aAPAmplitudesToAverage = zeros(size(oPotential.Beats(1).Fields(1).Vm',1),5);
    iCount = 0;
    for jj = aBeatIndexes
        if jj > 5 && iPanelIndex == 1
            iPanelIndex = 2;
            iAxesIndex = 0;
        end
        iAxesIndex = iAxesIndex + 1;
        iBeatIndex = jj;
        iCount = iCount + 1;
        oActivationAxes = oSubplotPanel(iPanelIndex,iAxesIndex,1).select();
        oCVAxes = oSubplotPanel(iPanelIndex,iAxesIndex,2).select();
        oAPAAxes = oSubplotPanel(iPanelIndex,iAxesIndex,3).select();
        %% plot activation
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', sEventID, 24, iBeatIndex, oActivation,aPointsToPlot);
        if ii == 1
            oOriginAxes(iCount) = axes('position',get(oActivationAxes,'position'));
        end
        aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeatIndex,:)).Coords});
        if ~isempty(aOriginCoords)
            scatter(oOriginAxes(iCount), aOriginCoords(1,:), aOriginCoords(2,:), ...
                'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        [~, oContour] = contourf(oActivationAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeatIndex).z,aATContours);
        axis(oActivationAxes,'equal');
        aXlim = get(oActivationAxes,'xlim');
        aYlim = get(oActivationAxes,'ylim');
        set(oActivationAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oActivationAxes,'off');
        axis(oOriginAxes(iCount),'equal');
        set(oOriginAxes(iCount),'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oOriginAxes(iCount),'off');
        cmap = colormap(oActivationAxes, flipud(jet(aATContourRange(2)-aATContourRange(1))));
        caxis(oActivationAxes,aATContourRange);
        
        oLabel = text(aXlim(1)-0.15,aYlim(1)+0.25,num2str(iBeatIndex),'parent',oActivationAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',10);
        
        %% plot CV
        idxCV = find(~isnan(oActivation.Beats(iBeatIndex).CVApprox));
        aCVdata = oActivation.Beats(iBeatIndex).CVApprox(idxCV);
        scatter(oCVAxes,oActivation.CVx(idxCV),oActivation.CVy(idxCV),16,aCVdata,'filled');
        hold(oCVAxes, 'on');
        oQuivers = quiver(oCVAxes,oActivation.CVx(idxCV),oActivation.CVy(idxCV),oActivation.Beats(iBeatIndex).CVVectors(idxCV,1),oActivation.Beats(iBeatIndex).CVVectors(idxCV,2),'color','k','linewidth',0.2);
        hold(oCVAxes, 'off');
        caxis([0 1]);
        axis(oCVAxes,'equal');
        set(oCVAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oCVAxes,'off');
        
        %% plot APA
        oPotential = oOptical.PreparePotentialMap(100,iBeatIndex,sEventID,oPotential,aPointsToPlot);
        aBeatData = aElectrodeData(oOptical.Beats.Indexes(iBeatIndex,1):oOptical.Beats.Indexes(iBeatIndex,2),aPointsToPlot);
        aBaselineData = aElectrodeData(oOptical.Beats.Indexes(iBeatIndex,1):oOptical.Beats.Indexes(iBeatIndex,1)+10,aPointsToPlot);
        [C MaxIndices] = max(aBeatData,[],1);
        aDataBeforePeak = aBeatData(1:MaxIndices(:),:);
        if jj <= 5 && iPanelIndex == 1
            aAPAmplitude = max(aBeatData,[],1) - mean(aBaselineData,1);
            aAPAmplitudesToAverage(:,jj) = aAPAmplitude';
            MeanAPAmplitude = mean(aAPAmplitudesToAverage(:,1:jj),2);
        end
        aAPAmplitude = max(aBeatData,[],1) - mean(aBaselineData,1) - MeanAPAmplitude';
        oInterpolant = TriScatteredInterp(oPotential.DT,aAPAmplitude');
        oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
        %rearrange to be able to apply boundary
        aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
        %apply boundary
        aQZArray(~oPotential.Boundary) = NaN;
        %save result back in proper format
        aNewFields  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
        %plot APA map
        contourf(oAPAAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields,[-120:10:100]);
        axis(oAPAAxes,'equal');
        set(oAPAAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAPAAxes,'off');
        
    end
    oTitle = text(aXlim(2), aYlim(1)-0.35,[num2str(CSV.aData(ii,strcmp(CSV.aHeader,'Experiment'))),'baro',sprintf('%.3d',CSV.aData(ii,strcmp(CSV.aHeader,'Recording')))],...
        'parent',oAPAAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
     set(oTitle,'fontsize',10);
    
    print(oFigure,'-dbmp','-r150',[sFileSavePath,num2str(CSV.aData(ii,strcmp(CSV.aHeader,'Experiment'))),'baro',sprintf('%.3d',CSV.aData(ii,strcmp(CSV.aHeader,'Recording'))),'.bmp'])
    clear oOptical oPotential oActivation;
end



