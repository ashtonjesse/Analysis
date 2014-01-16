%Calculate slope around frames of beat 2: frame 306 to 476
%Apply adjustment
% close all;
% clear all;
% 
% fid=fopen('G:\PhD\Experiments\Bordeaux\Data\20131129\RA1129-069_rotated.dhb','r','l');
% fdata1=fread(fid,8,'int16=>int32')';
% fdata2=fread(fid,'int16=>int32')';
% fclose(fid);
% cmosData = CMOSconverter( 'G:\PhD\Experiments\Bordeaux\Data\20131129','RA1129-069_rotated.dhb');
%start of ventricular activation is frame 409
% cmosData = CMOSconverter( 'G:\PhD\Experiments\Bordeaux\20131129Backup','RA1129-069.rsh');
% oData = load('G:\PhD\Experiments\Bordeaux\Data\20131129\RA1129-069.mat');
%Initialise array to hold slope information
iStartFrame = 210;
iEndFrame = 598;
iLength = 1 + iEndFrame - iStartFrame;
% % aCurvature = zeros(100,100,iLength);
% % aSlope = zeros(100,100,iLength);
% 
%Loop through the pixels and calculate the slope
% for i = 1:100;
%     for j = 1:100;
% 
%         % Calculate the first derivative
%         aGradient = fCalculateMovingSlope(double(squeeze(cmosData(i,j,iStartFrame:iEndFrame))),10,3);
%         % Calculate the second derivative
%         aGradient2 = fCalculateMovingSlope(aGradient,5,3);
%         
%         for k = 1:iLength
%             aCurvature(i,j,k) = abs(aGradient2(k)) / ((1 + aGradient(k)^2))^(3/2);
%         end
%         aSlope(i,j,:) = aGradient;
%         
%     end
% end
% 
%Find point of max curvature in segment of signal before
xIndex = 100-57;
yIndex = 100-62;
%Find the index of the peak and trough of the potential
[dMaxVal iMaxIndex] = max(double(squeeze(cmosData(xIndex,yIndex,iStartFrame:iEndFrame))));
[dMinVal iMinIndex] = min(double(squeeze(cmosData(xIndex,yIndex,325:500))));
iMaxIndex = iMaxIndex + iStartFrame;
iMinIndex = iMinIndex + 325;
%Find the mean of the diastolic potential as an estimate of the baseline 
dBaseline = mean(double(squeeze(cmosData(xIndex,yIndex,275:325))));
iRVActIndex = iMinIndex;
oSlopeAxes = axes();
% plot(oSlopeAxes,iStartFrame:1:iEndFrame,squeeze(aSlope(xIndex,yIndex,:)),'r');
set(oSlopeAxes, 'YTick',[],'XTick',[]);
oDataAxes = axes('Position',get(oSlopeAxes,'Position'),'color','none');
line(iStartFrame:1:iEndFrame,squeeze(cmosData(xIndex,yIndex,iStartFrame:iEndFrame)),'parent',oDataAxes);
% oCurvatureAxes = axes('Position',get(oSlopeAxes,'Position'),'color','none','XTick',[],'YTick',[]);
% line(iStartFrame:1:iEndFrame,squeeze(aCurvature(xIndex,yIndex,:)),'parent',oCurvatureAxes,'color','k');
% oMaxCurvatureLine = line([iMaxIndex iMaxIndex], [dMaxVal, dMinVal]);
% set(oMaxCurvatureLine,'color', 'c', 'parent',oCurvatureAxes, 'linewidth',2);
% oRVActLine = line([iRVActIndex iRVActIndex], [dMaxVal, dMinVal]);
% set(oRVActLine,'color', 'c', 'parent',oCurvatureAxes, 'linewidth',2);


m = (double(cmosData(xIndex,yIndex,iRVActIndex))-dBaseline) / (iRVActIndex-iMaxIndex);
b = dBaseline - m*iMaxIndex;
aStraightLine = nan(1,iLength);
aNewData = zeros(iLength,1);
aNewData(1:(iMaxIndex-iStartFrame+1),1) = double(squeeze(cmosData(xIndex,yIndex,iStartFrame:iMaxIndex)));
for i = 1:(iRVActIndex-iMaxIndex)
    %Calculate point y = mx + b
    iPointIndex = iMaxIndex+i;
    aStraightLine(iPointIndex-iStartFrame) = m*iPointIndex + b;
    aNewData(iPointIndex-iStartFrame) = double(squeeze(cmosData(xIndex,yIndex,iPointIndex))) + aStraightLine(iMaxIndex+1-iStartFrame) - aStraightLine(iPointIndex-iStartFrame);
end
aNewData(iPointIndex+1-iStartFrame:end) = double(squeeze(cmosData(xIndex,yIndex,iRVActIndex:iEndFrame)));
oCorrectedLine = line(iStartFrame:1:iEndFrame, aStraightLine);
set(oCorrectedLine,'color', 'c', 'parent',oDataAxes, 'linewidth',2);
oCorrectedData = line(iStartFrame:1:iEndFrame, aNewData);
set(oCorrectedData,'color', 'g', 'parent',oDataAxes, 'linewidth',2);

% % Initialise arrays
% aStraightLine = nan(1,iLength);
% % % Loop through all pixels
% NewcmosData = cmosData;
% for i = 1:100;
%     for j = 1:100;
%         % %         Find the index of the peak and trough of the potential
%         [dMaxVal iMaxIndex] = max(double(squeeze(cmosData(i,j,iStartFrame:iEndFrame))));
%         iMaxIndex = iMaxIndex + iStartFrame;
%         %         disp([iMaxIndex, i, j]);
%         [dMinVal iMinIndex] = min(double(squeeze(cmosData(i,j,325:500))));
%         iMinIndex = iMinIndex + 325;
%         iRVActIndex= iMinIndex;
%         % %         Find the mean of the diastolic potential as an estimate of the baseline
%         dBaseline = mean(double(squeeze(cmosData(i,j,275:325))));
%         % %         Calculate the straight line
%         m = (double(cmosData(i,j,iRVActIndex))-dBaseline) / (iRVActIndex-iMaxIndex);
%         b = dBaseline - m*iMaxIndex;
%         
%         for k = 1:(iRVActIndex-iMaxIndex)
%             % %             Calculate point y = mx + b
%             iPointIndex = iMaxIndex+k;
%             aStraightLine(iPointIndex-iStartFrame) = m*iPointIndex + b;
%             aNewData = double(squeeze(cmosData(i,j,iPointIndex))) + aStraightLine(iMaxIndex+1-iStartFrame) - aStraightLine(iPointIndex-iStartFrame);
%             NewcmosData(i,j,iPointIndex) = int32(aNewData);
%         end
%         
%         
%     end
% end
% CMOSwriter('G:\PhD\Experiments\Bordeaux\20131129Backup\RA1129-069.rsh','G:\PhD\Experiments\Bordeaux\Data\20131129',NewcmosData);