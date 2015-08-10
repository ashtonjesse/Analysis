%%%% This script reads in optical data, normalises the signal intensity and
%%%% plots the resultant Vm in time

close all;
% clear all;
% % % %Read in the file containing all the optical data 
% sCSVFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% [path name ext ver] = fileparts(sCSVFileName);
% if strcmpi(ext,'.csv')
%     aThisOAP = ReadOpticalTimeDataCSVFile(sCSVFileName,6);
%     save(fullfile(path,strcat(name,'.mat')),'aThisOAP');
% elseif strcmpi(ext,'.mat')
%     load(sCSVFileName);
% end
% %% read in the experiment file
% sExperimentFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718_experiment.txt';
% oExperiment = GetExperimentFromTxtFile(Experiment, sExperimentFileName);
% % %% read in the optical entity
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Optical.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);


% %%% set save path
sSavePath = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Vm';

oFigure = figure();
dWidth = 30;
dHeight = 15;
%set up figure
set(oFigure,'color','white')
% set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Resize','off');

oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',{0.66 0.33});
oSubplotPanel(1).pack();
iNumRows = 4;
iNumCols = 2;
oSubplotPanel(2).pack(iNumRows,iNumCols);
oSubplotPanel.margin = [5 12 5 5];
oSubplotPanel(1).margin = [0 0 0 0];
oSubplotPanel(2).margin = [5 0 0 0];
movegui(oFigure,'center');
%select beat
iBeat = 21;
%get data for this beat
aData = -aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1):...
    oOptical.Electrodes.Processed.BeatIndexes(iBeat,2),:);
%initialise array to hold normalised data
aNormalisedData = zeros(size(aData,1),size(aThisOAP.Data,2));
%loop through locations and normalise vm
for j = 1:size(aThisOAP.Data,2)
    aData = -aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1):...
        oOptical.Electrodes.Processed.BeatIndexes(iBeat,2),j);
    %get the baseline and peak values
    dBaseLine = mean(-aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1):...
        oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20,j));
    aNormalisedData(:,j) = (aData+sign(dBaseLine)*(-1)*abs(dBaseLine));
    dPeak = max(aNormalisedData(:,j));
    aNormalisedData(:,j) = aNormalisedData(:,j)./dPeak;
end
% ofigure2 = figure();
% oDataAxes = axes(); 
% oSlopeAxes = axes('position',get(oDataAxes,'position'));
% oCurvatureAxes = axes('position',get(oDataAxes,'position'));
% %plot locations
aLocationsToPlot = [17,21;12,15;9,11;6,7;28,5;18,8;13,9;5,10];
% for p = 1:size(aLocationsToPlot,1)
%     %get location details
%     % %     %compute slope for this location
%     iLocColIndex = find(aThisOAP.Locations(2,:) == aLocationsToPlot(p,1));
%     iLocIndex = find(aThisOAP.Locations(1,iLocColIndex) == aLocationsToPlot(p,2));
%     aSlope = oOptical.CalculateSlope(-aThisOAP.Data(:,iLocColIndex(iLocIndex)),5,3);
%     aCurvature = oOptical.CalculateSlope(aSlope,5,3);
%     plot(oDataAxes, oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64),...
%         -aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64,iLocColIndex(iLocIndex)),'k');
%     plot(oSlopeAxes, oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64),...
%         aSlope(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64),'r');
%     set(oSlopeAxes,'box','off','color','none'); 
%     axis(oSlopeAxes,'off');
%     plot(oCurvatureAxes, oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64),...
%         aCurvature(oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+20:oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+64),'g');
%     set(oCurvatureAxes,'box','off','color','none'); 
%     axis(oCurvatureAxes,'off');
%     set(get(oDataAxes,'title'),'string',num2str(p));
% end

aColors = distinguishable_colors(size(aLocationsToPlot,1));
%loop through locations and plot normalised data
iAxesRow = 1;
iAxesCol = 1;
sPointTags = cell(size(aLocationsToPlot,1),1);
oSidePlots = zeros(size(aLocationsToPlot,1),1);
oXLim = [30,80];
oYLim = [-0.2 1.1];
for i = 1:size(aLocationsToPlot,1)
    oAxes = oSubplotPanel(2,iAxesRow,iAxesCol).select();
    iLocColIndex = find(aThisOAP.Locations(2,:) == aLocationsToPlot(i,1));
    iLocIndex = find(aThisOAP.Locations(1,iLocColIndex) == aLocationsToPlot(i,2));
    %plot the normalised optical data
    plot(oAxes, [1:size(aNormalisedData,1)].*(1000/oExperiment.Optical.SamplingRate),aNormalisedData(:,iLocColIndex(iLocIndex)),'color',aColors(i,:),'linewidth',2);
    %plot the activation time as well
    hold(oAxes,'on');
    dTime = (aThisOAP.ActivationIndex(iLocColIndex(iLocIndex),iBeat)-oOptical.Electrodes.Processed.BeatIndexes(iBeat,1)+1)*(1000/oExperiment.Optical.SamplingRate);
    plot(oAxes,[dTime dTime],[0 1],'r-');
    hold(oAxes,'off');
    axis(oAxes,'tight');axis(oAxes,'off');
    set(oAxes,'xlim',oXLim); set(oAxes,'ylim',oYLim);
    oPlotLabel = text(oXLim(1),oYLim(2),num2str(i),'color',aColors(i,:),'parent',oAxes,'fontweight','bold','FontUnits','points');
    set(oPlotLabel ,'FontSize',14);
    %increment the row count
    iAxesRow = iAxesRow + 1;
    sPointTags{i} = num2str(i);
    %check if the end of the row has been met
    if iAxesRow > iNumRows
        iAxesRow = 1;
        iAxesCol = iAxesCol + 1;
        hold(oAxes,'on');
        plot([oXLim(1); oXLim(1)+20], [oYLim(1)+0.05; oYLim(1)+0.05], '-k','LineWidth', 2)
        hold(oAxes,'off');
        oScaleLabel = text(oXLim(1)+10,oYLim(1)-0.1, '20 ms', 'parent',oAxes, ...
            'FontUnits','points','horizontalalignment','center','fontweight','bold');
        set(oScaleLabel ,'FontSize',14);
    end
    %save handle
    oSidePlots(i) = oAxes;
end
aCoords = aThisOAP.Locations';
rowlocs = aCoords(:,1);
collocs = aCoords(:,2);
dInterpDim = 100;
dRes=0.2;
%Get the interpolated points array
[xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
    min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
aMeshPoints = [aXArray,aYArray];
%Find which points lie within the area of the array
[V,ConcaveTri] = alphavol(aCoords,1);
[FF BoundaryLocs] = freeBoundary(TriRep(ConcaveTri.tri,aCoords));
aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),BoundaryLocs(:,1),BoundaryLocs(:,2));
DT = DelaunayTri(aCoords);
InterpArray = zeros(numel(xlin(1,:)'),numel(ylin(:,1)),size(aData,1));

aContourRange = [-0.2 1];
aContours = aContourRange(1):0.1:aContourRange(2);
aXlim = [-2.2 9.6];
aYlim = [-1.7 8.8];
dTextXAlign = 1;

oAxes = oSubplotPanel(1,1).select();
oOverlay = axes('position',get(oAxes,'position'));
oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140718\20140718Schematic.bmp','Parent', oOverlay, 'Border', 'tight');
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
%loop through beats and plot contour activation maps
for m = oXLim(1):oXLim(2)%size(aNormalisedData,1)
    %find index of this timepoint relative to start of recording
    iIndexPoint = m - 1 + oOptical.Electrodes.Processed.BeatIndexes(iBeat,1);
    %do linear interpolation
    oInterpolant = TriScatteredInterp(DT,aNormalisedData(m,:)');
    %evaluate interpolant
    oInterpolatedField = oInterpolant(xlin,ylin);
    %rearrange to be able to apply boundary
    aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
    %apply boundary
    aQZArray(~aInBoundaryPoints) = NaN;
    %save result back in proper format
    InterpArray(:,:,m)  = reshape(aQZArray,size(xlin,1),size(xlin,2));
    [C, oContour] = contourf(oAxes, aThisOAP.InterpPoints.X, aThisOAP.InterpPoints.Y, InterpArray(:,:,m), aContours);
    caxis(aContourRange);
    colormap(oAxes, colormap(jet));
    hold(oAxes,'on');
    %         for n = 1:numel(oNeedlePoints)
    %             plot(oAxes,oNeedlePoints(n).Line1(1:2)*dRes, oNeedlePoints(n).Line1(3:4)*dRes, '-k','LineWidth', 2)
    %             plot(oAxes,oNeedlePoints(n).Line2(1:2)*dRes, oNeedlePoints(n).Line2(3:4)*dRes, '-k','LineWidth', 2)
    %         end
    % % plot locations and labels
    scatter(oAxes,aLocationsToPlot(:,2)*dRes,aLocationsToPlot(:,1)*dRes,40,aColors,'filled');
    aLabels = text((aLocationsToPlot(:,2)-2)*dRes,aLocationsToPlot(:,1)*dRes,sPointTags,'parent',oAxes);
    set(aLabels,'fontunits','points');
    set(aLabels,'fontsize',16,'fontweight','bold');
    % % plot activation points
    bActivatedPoints = find(aThisOAP.ActivationIndex(:,iBeat) <= iIndexPoint);
    oPlottedPoints = [];
    if ~isempty(bActivatedPoints)
        oPlottedPoints = scatter(oAxes,aThisOAP.Locations(1,bActivatedPoints)*dRes,aThisOAP.Locations(2,bActivatedPoints)*dRes,20,'k','filled');
    end
    hold(oAxes,'off');
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oAxes,'off');
    dTime = m*1000*(1/oExperiment.Optical.SamplingRate);
    sTimeStamp = sprintf('%3.1f ms',dTime);
    oLabel = text(aXlim(2)-dTextXAlign,aYlim(1)+3.5, sTimeStamp,'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
    set(oLabel,'fontsize',12);
    %create indicator for time on side plots
    iAxesRow = 1;
    iAxesCol = 1;
    aLines = zeros(size(aLocationsToPlot,1),1);
    for i = 1:size(aLocationsToPlot,1)
        hold(oSidePlots(i),'on');
        aLines(i) = plot(oSidePlots(i),[dTime dTime],oYLim,'k--');
        hold(oSidePlots(i),'off');
        %increment the row count
        iAxesRow = iAxesRow + 1;
        if iAxesRow > iNumRows
            iAxesRow = 1;
            iAxesCol = iAxesCol + 1;
        end
    end
    print(oFigure,'-djpeg','-r150',[sSavePath,'\',num2str(m),'.jpg']);
    delete(aLines);
    if ~isempty(oPlottedPoints)
        delete(oPlottedPoints);
    end
end

