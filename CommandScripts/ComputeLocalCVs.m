%load data
% close all;
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
oOptical = ans.oGuiHandle.oOptical;
iBeatIndex = 1;
sEventID = 'arsps';
%find the earliest activation sites
oFigure = figure();
oAxes = axes();
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
for i = [1,2,3,4,5,22,23,24,25,26]
    iBeatIndex = i;
    oActivation = oOptical.PrepareActivationMap(100, 'Contour', sEventID, 24, iBeatIndex, []);
    aEarlySites = find(oActivation.Beats(iBeatIndex).FullActivationTimes == min(oActivation.Beats(iBeatIndex).FullActivationTimes));
    aEarlyCoords = [oOptical.Electrodes(aEarlySites).Coords];
    
    %find centre of mass
    Mx = mean(aEarlyCoords(1,:));
    My = mean(aEarlyCoords(2,:));
    [val Ox] = min(abs(aEarlyCoords(1,:)-Mx));
    [val Oy] = min(abs(aEarlyCoords(2,:)-My));
    
    %find min and max CVs from an area of 9x9 not include the central 3x3
    %get CVs for accepted electrodes
    aCVs = oActivation.Beats(iBeatIndex).CVApprox(logical(aAcceptedChannels));
    aCVVectors = oActivation.Beats(iBeatIndex).CVVectors(logical(aAcceptedChannels),:);
    %restrict to local 7x7 neighbourhood
    RelativeDistVectors = aCoords-repmat([aEarlyCoords(1,Ox),aEarlyCoords(2,Oy)],[size(aCoords,1),1]);
    [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
    aLocalRegion = sort(SupportPoints(1:49),1,'ascend');
    %remove central 3x3
    aCentralRegion = sort(SupportPoints(1:9),1,'ascend');
    aPointsToPlot = false(1,numel(aElectrodes));
    aPointsToPlot(aLocalRegion) = true;
    aPointsToPlot(aCentralRegion) = false;
    %get CVs of interest
    aLocalCVs = aCVs(aPointsToPlot);
    aLocalCVVectors = aCVVectors(aPointsToPlot,:);
    aLocalCoords = aCoords(aPointsToPlot,:);
    
    % scatter(oAxes, aLocalCoords(:,1), aLocalCoords(:,2), 44,aLocalCVs,'filled');
    %get coords of new points
    % oFigure2 = figure();
    % oAxes2 = axes();
    
    scatter(oAxes, aLocalCVs.*aLocalCVVectors(:,1), aLocalCVs.*aLocalCVVectors(:,2),10,sPlotColour, 'filled');
    hold(oAxes,'on');
    if i > 17 && bNewFigure
        sPlotColour = 'r';
        bNewFigure = false;
    end
end
plot(oAxes,[-1.5 1.5],[0 0],'k');
plot(oAxes,[0 0],[1.5 -1.5],'k');
% scatter(oAxes, 0,0, 'sizedata',250,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');
