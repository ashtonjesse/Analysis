%Read in file and get data
% clear all;
%Define inputs
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\0114_01_ApdMap50.csv';
rowdim = 100;
coldim = 101;
%get data
% [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilesPath,rowdim,coldim);
% aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
%get coords of data points
[rowIndices colIndices] = find(aActivationTimes > 0);
AT = aActivationTimes(aActivationTimes > 0);
%Apply scale
rowlocs = 0.25 .* rowIndices;
collocs = 0.25 .* colIndices;
% Approximate AT
[CVApprox,ConductionVector]=ComputeCV([rowlocs,collocs],AT,24);


% Plot conduction direction
figure(1); axes(); 
quiver(rowlocs,collocs,ConductionVector(:,1),ConductionVector(:,2)); 
axis equal; axis tight;
xlabel('x'); ylabel('y'); title('Conduction direction');

%Plot conduction velocity

%Get the points array that will be used to solve for the interpolation
%coefficients
%First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% I.e x = A^-1 * b where x is ci.
% aPoints = zeros(length(AT),length(AT));
% 
% for m = 1:length(AT);
%     for i = 1:length(AT);
%         %Calc the euclidean distance between each point and every other
%         %point
%         aPoints(m,i) =  (rowlocs(m) - rowlocs(i))^2 + ...
%             (collocs(m) - collocs(i))^2;
%     end
% end
% dInterpDim = 50;
% %Get the interpolated points array
% xlin = linspace(min(aCoords(:,1)), max(aCoords(:,1)), dInterpDim);
% ylin = linspace(min(aCoords(:,2)), max(aCoords(:,2)), dInterpDim);
% 
% %Also the indexes in the interpolation array of the points that are closest to
% %the recording points - will use to calculate the error
% xIndices = zeros(length(aElectrodes),1);
% yIndices = zeros(length(aElectrodes),1);
% %Make an array of arbitrarily large numbers to be replaced with minimums
% aMinPoints = ones(1,length(aElectrodes))*2000;
% %Find the distance from each interpolation point to every data point
% 
% aInterpPoints = zeros(dInterpDim*dInterpDim,length(aElectrodes));
% 
% for i = 1:length(aElectrodes);
%     for m = 1:length(xlin)
%         for n = 1:length(ylin)
%             aInterpPoints((m-1)*length(ylin)+n,i) =  (xlin(m) - aElectrodes(i).Coords(1))^2 + ...
%                 (ylin(n) - aElectrodes(i).Coords(2))^2;
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
% oMapData.Beats = struct();
% 
% %initialise an RMS array
% aRMS = zeros(length(aElectrodes),1);
% 
% %Loop through the beats
% 
% %Get the activation time fields for all time points during this
% %beat
% k = 1;
% oMapData.Beats(k).CVApprox = CVApprox(logical(aAcceptedChannels));
% oMapData.Beats(k).Coefs = linsolve(oMapData.Points,oMapData.Beats(k).CVApprox);
% %Get the interpolated data via matrix multiplication
% oMapData.Beats(k).Interpolated = oMapData.InterpPoints * oMapData.Beats(k).Coefs;
% %Reconstruct field
% oMapData.Beats(k).z = zeros(dInterpDim, dInterpDim);
% for m = 1:dInterpDim
%     oMapData.Beats(k).z(:,m) = oMapData.Beats(k).Interpolated((m-1)*dInterpDim+1:m*dInterpDim,1);
% end
% %Calc the RMS error for this field
% for i = 1:length(aRMS)
%     aRMS(i) =  (oMapData.Beats(k).CVApprox(i) -  oMapData.Beats(k).z(yIndices(i),xIndices(i)))^2;
% end
% oMapData.Beats(k).RMS = sqrt(sum(aRMS)/length(aRMS));
% 
% 
% %check if there is an existing colour bar
% %get figure children
%     %Get a new min and max
% cbarmax = 0;
% cbarmin = 2000; %arbitrary
% ibmax = 0;
% ibmin = 0;
% i = 1;
% %Loop through the beats to find max and min
% dMin = min(min(oMapData.Beats(i).z));
% dMax = max(max(oMapData.Beats(i).z));
% if dMin < cbarmin
%     cbarmin = dMin;
%     ibmin = i;
% end
% if dMax > cbarmax
%     cbarmax = dMax;
%     ibmax = i;
% end
% 
% figure(2); oMapAxes = axes();
% iBeat = 1;
% %Assuming the potential field has been normalised.
% [C, oContour] = contourf(oMapAxes,oMapData.x,oMapData.y,oMapData.Beats(iBeat).z,floor(cbarmin):0.2:ceil(cbarmax));
% colormap(oMapAxes, colormap(flipud(colormap(jet))));
% 
% %if the colour bar should be visible then make
% %a new one
% oColorBar = cbarf([cbarmin cbarmax], floor(cbarmin):0.2:ceil(cbarmax));
% oTitle = get(oColorBar, 'title');
% set(oTitle,'units','normalized');
% set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
% axis(oMapAxes, 'equal');
% PlotLimits = oUnemap.GetSpatialLimits();
% set(oMapAxes,'xlim',PlotLimits(1,:),'ylim',PlotLimits(2,:));