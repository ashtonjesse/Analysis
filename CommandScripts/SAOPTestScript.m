% clear all;
close all;
% % % % %Read in the file containing all the optical data 
% [sFileName,sPathName]=uigetfile('*.*','Select a file that contain optical transmembrane recordings');
% sFileName = strcat(sPathName,sFileName);
% % % Make sure the dialogs return char objects
% if (isempty(sFileName) && ~ischar(sFileName))
%     break
% end
% %check the extension
% [pathstr, name, ext, versn] = fileparts(sFileName);
% if strcmpi(ext,'.csv')
%     aOAP = ReadOpticalTimeDataCSVFile(sFileName,6);
% elseif strcmpi(ext,'.mat')
%     load(sFileName);
% end
% 
% %load the beat data because at first I want the baseline range as defined
% %by this file
% [sBeatFileName,sBeatPathName]=uigetfile('*.*','Select a CSV files that contain optical beat data');
% %Make sure the dialogs return char objects
% if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
%     break
% end
% % %Get the beat information
% [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),40,41,7);
% %Save locations where the AT is updated
aScatterPointsToPlot = zeros(size(aActivationTimes));
aLocationsToPlot = zeros(size(aOAP.Locations));
iCandidateCount = 1;
iCount = 1;
aCurvatureValues = zeros(size(aOAP.Locations,2),1);
aSlopeValues = zeros(size(aOAP.Locations,2),2);
%loop through the locations in this data and adjust the activation times
for i = 1:length(aOAP.Locations(1,:))
    %get current location info
    dRowLoc = aOAP.Locations(1,i)+1;%Data is 0-based, Matlab is 1-based so have to add 1
    dYLoc = aOAP.Locations(1,i);
    dColLoc = aOAP.Locations(2,i)+1;
    dXLoc = aOAP.Locations(2,i);
    aData = -aOAP.Data(:,i);
    %     aSlope = fCalculateMovingSlope(aData,5,3);
    %     aCurvature = fCalculateMovingSlope(aSlope,5,3);
        
    % %Replace arrays with subsets
    aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
    %     aSubSlope = aSlope(aHeaderInfo.startframe:aHeaderInfo.endframe);
    %     aSubCurvature = aCurvature(aHeaderInfo.startframe:aHeaderInfo.endframe);
    % %scale data
    aThisData = aSubData - min(aSubData);
    aThisData = aThisData / (max(aSubData) - min(aSubData));
    aThisSlope = fCalculateMovingSlope(aThisData,5,3);
    aThisCurvature = fCalculateMovingSlope(aThisSlope,5,3);
    %find peaks and locations of the slope
    [aSlopePeaks, aSlopeLocations] = fFindPeaks(aThisSlope);
    %get the value and location of the maximum
    [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
    %find peaks and locations of the curvature
    [aCurvaturePeaks, aCurvatureLocations] = fFindPeaks(aThisCurvature);
    %get the value and location of the curvature
    [dMaxCurvaturePeak iMaxCurvatureIndex] = max(aCurvaturePeaks);
    
    %Get the boolean results to test whether there is a curvature peak between
    %the max slope peak and the slope peak following this one
    bResult1 = aCurvatureLocations > aSlopeLocations(iMaxSlopeIndex);
    bResult2 = aCurvatureLocations < aSlopeLocations(iMaxSlopeIndex+1);
    bResult = and(bResult1,bResult2);
       
    %get current AT for this beat based on BV algorithm
    if aActivationTimes(dRowLoc, dColLoc) > 0
        dCurrentAT = aActivationTimes(dRowLoc, dColLoc) - aHeaderInfo.startframe + 2;
        
        if length(find(bResult)) == 1
            if (aCurvaturePeaks(bResult) > 0.06) && (aCurvaturePeaks(find(bResult)-1) > 0.13) 
                aCurvatureValues(iCandidateCount) = aCurvaturePeaks(bResult);
                aSlopeValues(iCandidateCount,1) = aSlopePeaks(iMaxSlopeIndex);
                aSlopeValues(iCandidateCount,2) = aSlopePeaks(iMaxSlopeIndex+1);
                iCandidateCount = iCandidateCount + 1;
                if (aSlopePeaks(iMaxSlopeIndex) > 0.15) && (aSlopePeaks(iMaxSlopeIndex+1) > 0.1)
                    aScatterPointsToPlot(dRowLoc,dColLoc) = 1;
                    aLocationsToPlot(:,iCount) = [dRowLoc ; dColLoc];
                    iCount = iCount + 1;
%                     if ~mod(i,4)
                        figure();
                        oDataAxes = subplot(3,1,1);
                        plot(aThisData,'k');
                        title(sprintf('Location %s',sprintf('%d%d',dYLoc,dXLoc)));%print title in native coordinates
                        hold on;
                        % %     plot a green marker for the 50%AP AT
                        plot(dCurrentAT, aThisData(dCurrentAT), 'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',8);
                        % %     plot a red marker for the slope based estimation of AT
                        plot(aSlopeLocations(iMaxSlopeIndex), aThisData(aSlopeLocations(iMaxSlopeIndex)),'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',6);
                        hold off;
                        subplot(3,1,2);
                        plot(aThisSlope,'r');
                        hold on;
                        plot(aSlopeLocations(iMaxSlopeIndex), aThisSlope(aSlopeLocations(iMaxSlopeIndex)), ...
                            aSlopeLocations(iMaxSlopeIndex+1) , aThisSlope(aSlopeLocations(iMaxSlopeIndex+1)) ,'Marker', '+', 'MarkerEdgeColor','g','MarkerSize',6);
                        hold off;
                        subplot(3,1,3);
                        plot(aThisCurvature,'b');
                        hold on;
                        plot(aCurvatureLocations(bResult), ...
                            aThisCurvature(aCurvatureLocations(bResult)),'Marker', '+', 'MarkerEdgeColor','k','MarkerSize',6);
                        hold off;
%                     end
                end
            end
        end
    end
    
    
end
%rotate for display purposes
% aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
% aScatterPointsToPlot = rot90(aScatterPointsToPlot(:,1:end-1),-1);
aLocationsToPlot = aLocationsToPlot(:,1:iCount-1);
aCurvatureValues = aCurvatureValues(1:iCandidateCount-1);
aSlopeValues = aSlopeValues(1:iCandidateCount-1,:);

iMontageX = 4;
iMontageY = 4;

[rowIndices colIndices] = find(aActivationTimes > 0);
aATPoints = aActivationTimes > 0;
AT = aActivationTimes(aATPoints);
AT(AT < 1) = NaN;
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);
dRes = 0.190;
dInterpDim = dRes/4;
x = dRes .* rowIndices;
y = dRes .* colIndices;
%% Plot ATs
% %calculate the grid for plotting
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% % calculate the interpolation so as to produce the reshaped mesh vectors
F=TriScatteredInterp(x,y,AT);
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
cbarmin = max(floor(min(rQAT)),0);
cbarmax = ceil(max(rQAT));
cbarRange = cbarmin:1:cbarmax;
oATFigure = figure(); oATAxes = axes();
set(oATFigure,'paperunits','inches');
%Set figure size

dMontageWidth = 8.27 - 2; %in inches, with borders 
dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
dWidth = dMontageWidth/(iMontageX); %in inches
dHeight = dMontageHeight/iMontageY; %in inches
set(oATFigure,'paperposition',[0 0 dWidth dHeight])
set(oATFigure,'papersize',[dWidth dHeight])
set(oATAxes,'units','normalized');
set(oATAxes,'outerposition',[0 0 1 1]);
aTightInset = get(oATAxes, 'TightInset');
aPosition(1) = aTightInset(1)+0.05;
aPosition(2) = aTightInset(2);
aPosition(3) = 1-aTightInset(1)-aTightInset(3)-0.05;
aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
set(oATAxes, 'Position', aPosition);
%plot
contourf(oATAxes, xx,yy,QAT,cbarRange);
caxis(oATAxes,[cbarmin cbarmax]);
colormap(oATAxes, colormap(flipud(colormap(jet))));
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oATAxes, 'equal');
set(oATAxes,'FontUnits','points');
set(oATAxes,'FontSize',6);
aYticks = str2num(get(oATAxes,'yticklabel'));
aYticks = aYticks - aYticks(1);
aYtickstring = cellstr(num2str(aYticks));
for i=1:length(aYticks)
    %Check if the label has a decimal place and hide this label
    if ~isempty(strfind(char(aYtickstring{i}),'.'))
        aYtickstring{i} = '';
    end
end
% set(oATAxes,'xticklabel',[]);
set(oATAxes,'xtickmode','manual');
set(oATAxes,'yticklabel', char(aYtickstring));
set(oATAxes,'ytickmode','manual');
set(oATAxes,'Box','off');

%create beat label
%get beat number from name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(sBeatFileName, '_');
[~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
iLabelStartBeat = char(splitStr{1});
%aLabelPosition = [min(min(xx))+0.2, max(max(yy))-0.5];%for top left
aLabelPosition = [min(min(xx))+0.2, min(min(yy))+0.5];%for bottom left
oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), iLabelStartBeat);
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oATAxes);

%%overlay a plot with the updated points
oOverlayAxes = axes('parent',oATFigure);
% [row col] = find(aScatterPointsToPlot);
xLocs = dRes .* aLocationsToPlot(2,:);
yLocs = dRes .* aLocationsToPlot(1,:);
% aScatterPointsToPlot = rot90(aScatterPointsToPlot,1);
% [row col] = find(aScatterPointsToPlot);
set(oOverlayAxes,'units','normalized');
set(oOverlayAxes,'outerposition',[0 0 1 1]);
set(oOverlayAxes, 'Position', get(oATAxes,'position'));
scatter(oOverlayAxes, xLocs, yLocs,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k');
axis(oOverlayAxes, 'equal');axis(oOverlayAxes,[get(oATAxes,'xlim'),get(oATAxes,'ylim')]);
set(oOverlayAxes,'xticklabel',[]);
set(oOverlayAxes,'yticklabel', []);
set(oOverlayAxes,'Box','off');
set(oOverlayAxes,'color','none');
hold(oOverlayAxes,'on');
for i = 1:size(aLocationsToPlot,2)
    oLabel = text(xLocs(i) - 0.2, yLocs(i) + 0.1, ...
        sprintf('%d,%d',aLocationsToPlot(1,i)-1,aLocationsToPlot(2,i)-1));
    set(oLabel,'FontWeight','bold','FontUnits','normalized');
    set(oLabel,'FontSize',0.015);
    set(oLabel,'parent',oOverlayAxes);
end

figure(); aCurveAxes = axes();
hist(aCurveAxes, aCurvatureValues);
set(get(aCurveAxes,'title'),'string','Distribution of curvature values');
figure(); aFirstSlopeAxes = axes();
hist(aFirstSlopeAxes , aSlopeValues(:,1));
set(get(aFirstSlopeAxes ,'title'),'string','Distribution of first peak slope values');
figure(); aSecondSlopeAxes = axes();
hist(aSecondSlopeAxes , aSlopeValues(:,2));
set(get(aSecondSlopeAxes ,'title'),'string','Distribution of second peak slope values');