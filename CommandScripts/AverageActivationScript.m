% clear all
% 
% disp('loading unemap...');
% oUnemap = ...
% GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130221\pa_baropacetest001_unemap2.mat');
% disp('done loading');

%get the accepted electrodes
% aAccepted = logical(MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted'));
% oElectrodes = oUnemap.Electrodes(aAccepted);
% %get the event indices
% aIndices = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oElectrodes,'SignalEvent','Index');
% aBeatIndexes = oElectrodes(1).Processed.BeatIndexes;
% 
% aAverages = zeros(length(oElectrodes),3);
% aSDs = zeros(length(oElectrodes),3);
% aVariance = zeros(length(oElectrodes),3);
% 
% %get other data
% aTimeSeries = oUnemap.TimeSeries;
% aPacingTimes = aTimeSeries(oElectrodes(1).Pacing.Index); 
% %loop through electrodes
% for i = 1:length(oElectrodes)
%     %get activation times
%     aPreActivationTimes = 1000*(aTimeSeries(aIndices(1:23,i) + aBeatIndexes(1:23,1)) - aPacingTimes(1:23));
%     aBaroActivationTimes = 1000*(aTimeSeries(aIndices(24:59,i) + aBeatIndexes(24:59,1)) - aPacingTimes(24:59));
%     aPostActivationTimes = 1000*(aTimeSeries(aIndices(60:end,i) + aBeatIndexes(60:end,1)) - aPacingTimes(60:end));
%     aAverages(i,1) = mean(aPreActivationTimes);
%     aAverages(i,2) = mean(aBaroActivationTimes);
%     aAverages(i,3) = mean(aPostActivationTimes);
%     aSDs(i,1) = std(aPreActivationTimes);
%     aSDs(i,2) = std(aBaroActivationTimes);
%     aSDs(i,3) = std(aPostActivationTimes);
% end
% dInterpDim = 50;
% %Get the points array that will be used to solve for the interpolation
% %coefficients
% %First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% % I.e x = A^-1 * b where x is ci.
% aPoints = zeros(length(oElectrodes),length(oElectrodes));
% %...and turn the coords into a 2 column matrix
% aCoords = zeros(length(oElectrodes),2);
% 
% for m = 1:length(oElectrodes);
%     for i = 1:length(oElectrodes);
%         %Calc the euclidean distance between each point and every other
%         %point
%         aPoints(m,i) =  (oElectrodes(m).Coords(1) - oElectrodes(i).Coords(1))^2 + ...
%             (oElectrodes(m).Coords(2) - oElectrodes(i).Coords(2))^2;
%     end
%     %Save the coordinates
%     aCoords(m,1) = oElectrodes(m).Coords(1);
%     aCoords(m,2) = oElectrodes(m).Coords(2);
% end
% 
% %Get the interpolated points array
% xlin = linspace(min(aCoords(:,1)), max(aCoords(:,1)), dInterpDim);
% ylin = linspace(min(aCoords(:,2)), max(aCoords(:,2)), dInterpDim);
% 
% %Also the indexes in the interpolation array of the points that are closest to
% %the recording points - will use to calculate the error
% xIndices = zeros(length(oElectrodes),1);
% yIndices = zeros(length(oElectrodes),1);
% %Make an array of arbitrarily large numbers to be replaced with minimums
% aMinPoints = ones(1,length(oElectrodes))*2000;
% aInterpPoints = zeros(dInterpDim*dInterpDim,length(oElectrodes));
% 
% for i = 1:length(oElectrodes);
%     for m = 1:length(xlin)
%         for n = 1:length(ylin)
%             aInterpPoints((m-1)*length(ylin)+n,i) =  (xlin(m) - oElectrodes(i).Coords(1))^2 + ...
%                 (ylin(n) - oElectrodes(i).Coords(2))^2;
%             if aInterpPoints((m-1)*length(xlin)+n,i) < aMinPoints(1,i)
%                 aMinPoints(1,i) = aInterpPoints((m-1)*length(xlin)+n,i);
%                 xIndices(i) = m;
%                 yIndices(i) = n;
%             end
%         end
%     end
% end
% 
% %Initialise the map data struct
% oMapData = struct('x', xlin, 'y', ylin, 'r2', 0.005);
% %Finish calculating the points array
% oMapData.Points = sqrt(aPoints + oMapData.r2);
% %Finish calculating the interpolation points array
% oMapData.InterpPoints = sqrt(aInterpPoints + oMapData.r2);
% oMapData.Averages = struct();
% oMapData.Stds = struct();
% 
% %initialise an RMS array
% aAvRMS = zeros(length(oElectrodes),1);
% aStdRMS = zeros(length(oElectrodes),1);
% %Loop through the sets of beats
% for k = 1:size(aAverages,2)
%     
%     oMapData.Averages(k).Field = aAverages(:,k);
%     oMapData.Stds(k).Field = aSDs(:,k);
%     oMapData.Averages(k).Coefs = linsolve(oMapData.Points,oMapData.Averages(k).Field);
%     oMapData.Stds(k).Coefs = linsolve(oMapData.Points,oMapData.Stds(k).Field);
%     %Get the interpolated data via matrix multiplication
%     oMapData.Averages(k).Interpolated = oMapData.InterpPoints * oMapData.Averages(k).Coefs;
%     oMapData.Stds(k).Interpolated = oMapData.InterpPoints * oMapData.Stds(k).Coefs;
%     %Reconstruct field
%     oMapData.Averages(k).z = zeros(dInterpDim, dInterpDim);
%     oMapData.Stds(k).z = zeros(dInterpDim, dInterpDim);
%     for m = 1:dInterpDim
%         oMapData.Averages(k).z(:,m) = oMapData.Averages(k).Interpolated((m-1)*dInterpDim+1:m*dInterpDim,1);
%         oMapData.Stds(k).z(:,m) = oMapData.Stds(k).Interpolated((m-1)*dInterpDim+1:m*dInterpDim,1);
%     end
%     %Calc the RMS error for this field
%     for i = 1:length(aAvRMS)
%         aAvRMS(i) =  (oMapData.Averages(k).Field(i) -  oMapData.Averages(k).z(yIndices(i),xIndices(i)))^2;
%         aStdRMS(i) =  (oMapData.Stds(k).Field(i) -  oMapData.Stds(k).z(yIndices(i),xIndices(i)))^2;
%     end
%     oMapData.Averages(k).RMS = sqrt(sum(aAvRMS)/length(aAvRMS));
%     oMapData.Averages(k).RMS = sqrt(sum(aStdRMS)/length(aStdRMS));
%     
%     
% end

%Get a new min and max
figure();
aData = oMapData.Stds(3).z;
cbarmax = max(max(aData));
cbarmin = min(min(aData));
%Get a new min and max
% cbarmax = 0;
% cbarmin = 2000; %arbitrary
% ibmax = 0;
% ibmin = 0;
% for i = 1:size(aAverages,2)
%     dMin = min(min(oMapData.Stds(i).z));
%     dMax = max(max(oMapData.Stds(i).z));
%     if dMin < cbarmin
%         cbarmin = dMin;
%         ibmin = i;
%     end
%     if dMax > cbarmax
%         cbarmax = dMax;
%         ibmax = i;
%     end
% end
dStep = 0.2;
% oLeftAxes = subplot(1,3,1);
oAxes = axes();
contourf(oAxes,oMapData.x,oMapData.y,aData,floor(cbarmin):dStep:ceil(cbarmax));
hold(oAxes, 'on');
for i = 1:length(oUnemap.Electrodes);
    %Plot the electrode point
    
    
    %Just plotting the electrodes so add a text label
    plot(oAxes, oUnemap.Electrodes(i).Coords(1), oUnemap.Electrodes(i).Coords(2), '.', ...
        'MarkerSize',12);
    %Label the point with the channel name
    oLabel = text(oUnemap.Electrodes(i).Coords(1) - 0.1, oUnemap.Electrodes(i).Coords(2) + 0.07, ...
        oUnemap.Electrodes(i).Name);
    set(oLabel,'FontWeight','bold','FontUnits','normalized');
    set(oLabel,'FontSize',0.015);
    set(oLabel,'parent',oAxes);
    if ~oUnemap.Electrodes(i).Accepted
        %Just the label is red if the electrode is
        %rejected
        set(oLabel,'color','r');
    end
    
end
axis(oAxes, 'equal');

% contourf(oLeftAxes,oMapData.x,oMapData.y,aData,floor(cbarmin):dStep:ceil(cbarmax));
% axis(oLeftAxes, 'equal');
% oMidAxes = subplot(1,3,2);
% contourf(oMidAxes,oMapData.x,oMapData.y,oMapData.Stds(2).z,floor(cbarmin):dStep:ceil(cbarmax));
% axis(oMidAxes, 'equal');
% oRightAxes = subplot(1,3,3);
% contourf(oRightAxes,oMapData.x,oMapData.y,oMapData.Stds(3).z,floor(cbarmin):dStep:ceil(cbarmax));
% axis(oRightAxes, 'equal');
oColorBar = cbarf([cbarmin cbarmax], floor(cbarmin):dStep:ceil(cbarmax));

