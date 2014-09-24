clear all;

% % % %Read in the file containing all the optical data 
[sFileName,sPathName]=uigetfile('*.*','Select a file that contain optical transmembrane recordings');
sFileName = strcat(sPathName,sFileName);
% % Make sure the dialogs return char objects
if (isempty(sFileName) && ~ischar(sFileName))
    break
end
%check the extension
[pathstr, name, ext, versn] = fileparts(sFileName);
if strcmpi(ext,'.csv')
    aOAP = ReadOpticalTimeDataCSVFile(sFileName,6);
elseif strcmpi(ext,'.mat')
    load(sFileName);
end

%load the beat data because at first I want the baseline range as defined
%by this file
[sBeatFileName,sBeatPathName]=uigetfile('*.*','Select a CSV files that contain optical beat data');
%Make sure the dialogs return char objects
if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
    break
end
%Get the beat information
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),40,41,7);

%loop through the locations in this data and adjust the activation times
for i = 1:length(aOAP.Locations(1,:))
    %get current location info
    dRowLoc = aOAP.Locations(1,i);
    dColLoc = aOAP.Locations(2,i);
    aData = -aOAP.Data(:,i);
    aSlope = fCalculateMovingSlope(aData,5,3);
    aCurvature = fCalculateMovingSlope(aSlope,5,3);
        
    % %Replace arrays with subsets
    aThisData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
    aThisSlope = aSlope(aHeaderInfo.startframe:aHeaderInfo.endframe);
    aThisCurvature = aCurvature(aHeaderInfo.startframe:aHeaderInfo.endframe);
    %find peaks and locations of the slope
    [aSlopePeaks, aSlopeLocations] = fFindPeaks(aThisSlope);
    %get the value and location of the maximum
    [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
    %find peaks and locations of the curvature
    [aCurvaturePeaks, aCurvatureLocations] = fFindPeaks(aThisCurvature);
    %get the value and location of the curvature
    [dMaxCurvaturePeak iMaxCurvatureIndex] = max(aCurvaturePeaks);
    
    %     %Get the boolean results to test whether there is a curvature peak between
    %     %the max slope peak and the slope peak following this one
    %     bResult1 = aCurvatureLocations > aSlopeLocations(iMaxSlopeIndex);
    %     bResult2 = aCurvatureLocations < aSlopeLocations(iMaxSlopeIndex+1);
    %     bResult = and(bResult1,bResult2);
    
    %get current AT for this beat based on BV algorithm
    dCurrentAT = aActivationTimes(dRowLoc, dColLoc) - aHeaderInfo.startframe + 2;
    %     aActivationTimes(dXLoc, dYLoc) = aSlopeLocations(iMaxSlopeIndex) +
    %     aHeaderInfo.startframe - 1;
    
    figure();
    oDataAxes = subplot(3,1,1);
    plot(aThisData,'k');
    title(sprintf('Location %s',sprintf('%d%d',dRowLoc,dColLoc)));
    hold on;
    % %     plot a green marker for the 50%AP AT
    plot(dCurrentAT, aThisData(dCurrentAT), 'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',8);
    % %     plot a red marker for the slope based estimation of AT
    plot(aSlopeLocations(iMaxSlopeIndex), aThisData(aSlopeLocations(iMaxSlopeIndex)),'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',6);
    % %     Calculate what half max amplitude should be and plot this
    dBaselineValue = mean(aData(aHeaderInfo.BaselineRange(1):aHeaderInfo.BaselineRange(2)));
    [dMaxData iMaxDataIndex] = max(aThisData);
    dDiff = dBaselineValue + (dMaxData - dBaselineValue)/2;
    aDiffResult = aThisData - dDiff;
    [dMin iNewAT] = min(abs(aDiffResult(1:iMaxDataIndex)));
    plot(iNewAT, aThisData(iNewAT),'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','b','MarkerSize',2);
    line([1 length(aThisData)],[max(aThisData) max(aThisData)],'parent',oDataAxes,'color','b','linestyle','-');
    line([1 length(aThisData)],[dBaselineValue dBaselineValue],'parent',oDataAxes,'color','b','linestyle','-');
    hold off;
    subplot(3,1,2);
    plot(aThisSlope,'r');
    subplot(3,1,3);
    plot(aThisCurvature,'b');
    
    
end

% aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);

% iMontageX = 4;
% iMontageY = 4;
% rowdim = 44;
% coldim = 41;
% 
% [rowIndices colIndices] = find(aActivationTimes > 0);
% aATPoints = aActivationTimes > 0;
% AT = aActivationTimes(aATPoints);
% AT(AT < 1) = NaN;
% %normalise the ATs to first activation
% [C I] = min(AT);
% AT = single(AT - AT(I));
% AT = double(AT);
% dRes = 0.190;
% dInterpDim = dRes/4;
% x = dRes .* rowIndices;
% y = dRes .* colIndices;
% %% Plot ATs
% % %calculate the grid for plotting
% [xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% % % calculate the interpolation so as to produce the reshaped mesh vectors
% F=TriScatteredInterp(x,y,AT);
% QAT = F(xx,yy);
% rQAT = reshape(QAT,[prod(size(QAT)),1]);
% cbarmin = max(floor(min(rQAT)),0);
% cbarmax = ceil(max(rQAT));
% cbarRange = cbarmin:1:cbarmax;
% oATFigure = figure(); oATAxes = axes();
% set(oATFigure,'paperunits','inches');
% %Set figure size
% 
% dMontageWidth = 8.27 - 2; %in inches, with borders 
% dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
% dWidth = dMontageWidth/(iMontageX); %in inches
% dHeight = dMontageHeight/iMontageY; %in inches
% set(oATFigure,'paperposition',[0 0 dWidth dHeight])
% set(oATFigure,'papersize',[dWidth dHeight])
% set(oATAxes,'units','normalized');
% set(oATAxes,'outerposition',[0 0 1 1]);
% aTightInset = get(oATAxes, 'TightInset');
% aPosition(1) = aTightInset(1)+0.05;
% aPosition(2) = aTightInset(2);
% aPosition(3) = 1-aTightInset(1)-aTightInset(3)-0.05;
% aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
% set(oATAxes, 'Position', aPosition);
% %plot
% contourf(oATAxes, xx,yy,QAT,cbarRange);
% caxis(oATAxes,[cbarmin cbarmax]);
% colormap(oATAxes, colormap(flipud(colormap(jet))));
% % cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
% axis(oATAxes, 'equal'); axis(oATAxes, 'tight');
% set(oATAxes,'FontUnits','points');
% set(oATAxes,'FontSize',6);
% aYticks = str2num(get(oATAxes,'yticklabel'));
% aYticks = aYticks - aYticks(1);
% aYtickstring = cellstr(num2str(aYticks));
% for i=1:length(aYticks)
%     %Check if the label has a decimal place and hide this label
%     if ~isempty(strfind(char(aYtickstring{i}),'.'))
%         aYtickstring{i} = '';
%     end
% end
% set(oATAxes,'xticklabel',[]);
% set(oATAxes,'xtickmode','manual');
% set(oATAxes,'yticklabel', char(aYtickstring));
% set(oATAxes,'ytickmode','manual');
% set(oATAxes,'Box','off');
% 
% %create beat label
% %get beat number from name
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(sBeatFileName, '_');
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
% iLabelStartBeat = char(splitStr{1});
% %aLabelPosition = [min(min(xx))+0.2, max(max(yy))-0.5];%for top left
% aLabelPosition = [min(min(xx))+0.2, min(min(yy))+0.5];%for bottom left
% oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), iLabelStartBeat);
% set(oBeatLabel,'units','normalized');
% set(oBeatLabel,'fontsize',14,'fontweight','bold');
% set(oBeatLabel,'parent',oATAxes);
