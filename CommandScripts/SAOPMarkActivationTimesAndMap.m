% % % % load an optical data file and a corresponding optical entity
% close all;
% clear all;
% % % % %Read in the file containing all the optical data 
% sCSVFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% [path name ext ver] = fileparts(sCSVFileName);
% if strcmpi(ext,'.csv')
%     aThisOAP = ReadOpticalTimeDataCSVFile(sCSVFileName,6);
%     save(fullfile(path,strcat(name,'.mat')),'aThisOAP');
% elseif strcmpi(ext,'.mat')
%     load(sCSVFileName);
% end
% %%% read in the experiment file
% sExperimentFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718_experiment.txt';
% oExperiment = GetExperimentFromTxtFile(Experiment, sExperimentFileName);
% % % %% read in the optical entity
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Optical.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % % get needle points
% oNeedlePoints = GetNeedlePointLocationsFromCSV('G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\NeedlePoints.csv',0,0);

% % % % % % % clear unwanted variables
% % % % % % % clear path name ext ver


% % % work out the best grid for maps
% % % Sets the units of your root object (screen) to pixels
set(0,'units','pixels')  
%Obtains this pixel information
Pix_SS = get(0,'screensize');
ratio = Pix_SS(4)/Pix_SS(3);
iCurrentGuess = Pix_SS(3)-1;
dTotal = ratio*(iCurrentGuess^2);
while dTotal > size(oOptical.Electrodes.Processed.BeatIndexes,1)
    iCurrentGuess = iCurrentGuess-1;
    dTotal = ratio*(iCurrentGuess^2);
end
iCurrentGuess = iCurrentGuess + 1;
% % % % create a panel with enough subplots
oFigure = figure();
set(oFigure,'color','white')
oPanel = panel(oFigure);
iRows = ceil(iCurrentGuess*ratio)-1;
iCols = iCurrentGuess;
% iRows = 1;
% iCols = 1;
oPanel.pack(iRows,iCols);
oPanel.margin = [1 1 1 1];
oPanel.de.margin = 0;
% % % % % %set dimensions of maps
% rowdim = 41;
% coldim = 41;
% % % initialise array to hold activation times
% aThisOAP.ActivationArray = -ones(rowdim,coldim,size(oOptical.Electrodes.Processed.BeatIndexes,1),'int16');
% % % % % % create a variable to store the AT indexes
% aThisOAP.ActivationIndex = zeros(size(aThisOAP.Locations,2),size(oOptical.Electrodes.Processed.BeatIndexes,1),'uint16');
% % % % % %loop through the locations
% % iPrevAvrgIndex = 0;
% oNewFigure = figure();oAxes = axes('parent',oNewFigure);
% for j = 1:size(aThisOAP.Locations,2)
%     %get location details
%     XLoc = aThisOAP.Locations(1,j)+1; %these locations are 0 based so add 1
%     YLoc = aThisOAP.Locations(2,j)+1; %yloc refers to the row of the matrix
%     % %     %compute slope for this location
%     aSlope = oOptical.CalculateSlope(-aThisOAP.Data(:,j),5,3);
%     
%     for i = 1:size(oOptical.Electrodes.Processed.BeatIndexes,1)
%         % %         %get the slope for this beat
%         aSubSlope = aSlope(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2));
%         [dMaxVal iMaxIndex] = max(aSubSlope);
%         aThisOAP.ActivationIndex(j,i) = iMaxIndex-1+oOptical.Electrodes.Processed.BeatIndexes(i,1); %subtract one so that it can be used to index the time array directly
%         aThisOAP.ActivationArray(YLoc,XLoc,i) = aThisOAP.ActivationIndex(j,i);
% %         plotyy(oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(i,1)+20:oOptical.Electrodes.Processed.BeatIndexes(i,2)-20),...
% %             -aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(i,1)+20:oOptical.Electrodes.Processed.BeatIndexes(i,2)-20,j),...
% %             oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(i,1)+20:oOptical.Electrodes.Processed.BeatIndexes(i,2)-20),...
% %             aSlope(oOptical.Electrodes.Processed.BeatIndexes(i,1)+20:oOptical.Electrodes.Processed.BeatIndexes(i,2)-20));
%     end
% 
% end


% %loop through beats and map them
iAxesRow = 1;
iAxesCol = 1;
dRes = 0.2;
aCoords = aThisOAP.Locations'.*dRes;
rowlocs = aCoords(:,1);
collocs = aCoords(:,2);
dInterpDim = 100;
%Get the interpolated points array
[xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
    min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
aMeshPoints = [aXArray,aYArray];
aThisOAP.InterpPoints.X = xlin(1,:)';
aThisOAP.InterpPoints.Y = ylin(:,1);
%Find which points lie within the area of the array
[V,ConcaveTri] = alphavol(aCoords,1);
[FF BoundaryLocs] = freeBoundary(TriRep(ConcaveTri.tri,aCoords));
aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),BoundaryLocs(:,1),BoundaryLocs(:,2));
DT = DelaunayTri(aCoords);
aThisOAP.InterpArray = zeros(numel(xlin(1,:)'),numel(ylin(:,1)),size(oOptical.Electrodes.Processed.BeatIndexes,1));

% figure(2);
% scatter(rowlocs,collocs,'filled');
% hold on;
% scatter(aXArray(aInBoundaryPoints),aYArray(aInBoundaryPoints),'r');
% scatter(BoundaryLocs(:,1),BoundaryLocs(:,2),'g','filled');
% trimesh(ConcaveTri.tri,aCoords(:,1),aCoords(:,2));
% hold off;
% axis equal; axis tight;
%set colour bar properties
aContourRange = [0 12];
aContours = aContourRange(1):1:aContourRange(2);
aXlim = [-2.2 9.6];
aYlim = [-1.7 8.8];
%loop through beats and plot contour activation maps
for m = 1:size(oOptical.Electrodes.Processed.BeatIndexes,1)
    %do linear interpolation
    oInterpolant = TriScatteredInterp(DT,oOptical.TimeSeries(aThisOAP.ActivationIndex(:,m))');
    %evaluate interpolant
    oInterpolatedField = oInterpolant(xlin,ylin);
    %rearrange to be able to apply boundary
    aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
    %apply boundary
    aQZArray(~aInBoundaryPoints) = NaN;
    %normalise to first activation, convert to ms and round
    aQZArray = (aQZArray - min(aQZArray))*1000;
    %save result back in proper format
    aThisOAP.InterpArray(:,:,m)  = reshape(aQZArray,size(xlin,1),size(xlin,2));
    aThisOAP.InterpArray(:,:,m) = aThisOAP.InterpArray(:,:,m);
    
    %select the axes
    oAxes = oPanel(iAxesRow,iAxesCol).select();
    oOverlay = axes('position',get(oAxes,'position'));
    % %     draw the schematic on the overlaying axes
    oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140718\20140718Schematic.bmp','Parent', oOverlay, 'Border', 'tight');
    % % %     make it transparent in the right places
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
    [C, oContour] = contourf(oAxes, aThisOAP.InterpPoints.X, aThisOAP.InterpPoints.Y, aThisOAP.InterpArray(:,:,m), aContours);
    caxis(aContourRange);
    colormap(oAxes, colormap(flipud(colormap(jet))));
%     hold(oAxes,'on');
%     for n = 1:numel(oNeedlePoints)
%         plot(oAxes,oNeedlePoints(n).Line1(1:2)*dRes, oNeedlePoints(n).Line1(3:4)*dRes, '-k','LineWidth', 2)
%         plot(oAxes,oNeedlePoints(n).Line2(1:2)*dRes, oNeedlePoints(n).Line2(3:4)*dRes, '-k','LineWidth', 2)
%     end
%     hold(oAxes,'off');
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    set(oOverlay,'position',get(oAxes,'position'));
%     axis(oAxes,'off');
    % % put on needle points
    
    
    %     %create labels
    %     oLabel = text(1.2,6.8,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
    %     set(oLabel,'fontsize',8);
    %     oLabel = text(-1,0.5,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
    %     set(oLabel,'fontsize',8);
    %     oLabel = text(4.7,0.5,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
    %     set(oLabel,'fontsize',8);
    % %     %plot
    
    % %create beat label
    aLabelPosition = [max(max(xlin(1,:))), min(min(ylin(:,1)))+2];%for bottom left
    oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('#%d',m));
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',10,'fontweight','bold','horizontalalignment','right');
    set(oBeatLabel,'parent',oOverlay);
    %create label for heart rate
    aLabelPosition(2) = aLabelPosition(2)-1;
    oHeartRateLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d bpm',round(oOptical.Electrodes.Processed.BeatRates(m))));
    set(oHeartRateLabel,'units','normalized');
    set(oHeartRateLabel,'fontsize',10,'fontweight','bold','horizontalalignment','right');
    set(oHeartRateLabel,'parent',oOverlay);
    % % create label for time frame
    aLabelPosition(2) = aLabelPosition(2)-1;
    oFrameLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',round(mean(aThisOAP.ActivationIndex(:,m)))));
    set(oFrameLabel,'units','normalized');
    set(oFrameLabel,'fontsize',10,'fontweight','bold','horizontalalignment','right');
    set(oFrameLabel,'parent',oOverlay);
    %increment the column count
    iAxesCol = iAxesCol + 1;
    %check if the end of the row has been met
    if iAxesCol > iCols
        iAxesCol = 1;
        iAxesRow = iAxesRow + 1;
    end
end

%save activation data
save(fullfile(path,strcat(name,'.mat')),'aThisOAP');