% Read in file and get data
% clear all;
close all;
% % Define inputs
sDataSource = 'unemap';
switch (sDataSource)
    case 'optical'
        sFilesPath = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\APD30\20140821baro002Apd30_40.csv';
        rowdim = 41;
        coldim = 41;
        % % % get data
        [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilesPath,rowdim,coldim,7);
        aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
        [rowIndices colIndices] = find(aActivationTimes > 0);
        aATPoints = aActivationTimes > 0;
        AT = aActivationTimes(aATPoints);
        AT(AT < 1) = NaN;
        %normalise the ATs to first activation
        [C I] = min(AT);
        AT = single(AT - AT(I));
        AT = double(AT);
        dRes = 0.190;
        x = dRes .* rowIndices;% + (rand(size(rowIndices))./10);
        y = dRes .* colIndices;%+ (rand(size(rowIndices))./10)
        dInterpDim = dRes/6;
        rowlocs = x;
        collocs = y;
        % Find the boundary of the recording points by converting to logical array
        aMask = logical(aActivationTimes + 1);
        %Resize the mask to set the resolution of the interpolated field
        aMask = imresize(aMask,'scale',6,'method', 'bilinear');
        %Dilate this mask and subtract the original to just leave the boundary
        aMask = logical(filter2(true(3),aMask)) - aMask;
        % se = strel('square',3);
        % aMask = imdilate(aMask,se) - aMask;
        
        %Find the indices of the boundary points
        [rowMaskIndices colMaskIndices] = find(aMask);
        %Convert into coordinates
        rowBoundary = dInterpDim .* rowMaskIndices;
        colBoundary = dInterpDim .* colMaskIndices;
        
        %         %Get the interpolation points array
        [xlin ylin] = meshgrid(min(rowBoundary):dInterpDim:max(rowBoundary),min(colBoundary):dInterpDim:max(colBoundary));

        %Create an array from vectors of xlin elements repeated size(ylin,2) times
        %and appended end on end, then concatenated with a repmat of the ylin
        %elements
        aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
        aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
        aMeshPoints = [aXArray,aYArray];
        %Check which of these mesh points is within the boundary of the recording
        %area
        aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),rowBoundary,colBoundary);
    case 'unemap'
        disp('loading unemap...');
        oUnemap = ...
            GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904chemo002\pachemo002_unemap.mat');
        disp('done loading');
        aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
        aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
        
        %...and turn the coords into a 2 column matrix
        aCoords = cell2mat({aElectrodes(:).Coords})';
        rowlocs = aCoords(:,1);
        collocs = aCoords(:,2);
        
        dInterpDim = 100;
        %Get the interpolated points array
        [xlin ylin] = meshgrid(min(aCoords(:,1)):(max(aCoords(:,1)) - min(aCoords(:,1)))/dInterpDim:max(aCoords(:,1)),min(aCoords(:,2)):(max(aCoords(:,2))-min(aCoords(:,2)))/dInterpDim:max(aCoords(:,2)));
        
        aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
        aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
        aMeshPoints = [aXArray,aYArray];
        %Find which points lie within the area of the array
        DT = DelaunayTri(aCoords);
        [V,S] = alphavol(aCoords,1);
        [FF XF] = freeBoundary(TriRep(S.tri,aCoords));
        %         aIndices = pointLocation(DT,aMeshPoints);
        %         aIndices(isnan(aIndices)) = 0;
        %         aInBoundaryPoints = logical(aIndices);
        aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),XF(:,1),XF(:,2));
        clear aIndices;
                
        iEventID = 1;
        %Get the electrode processed data
        aActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), length(aElectrodes));
        aOutActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), length(oUnemap.Electrodes));
        aOutActivationTimes = zeros(size(aOutActivationIndexes));
        %track the number of accepted electrodes
        m = 0;
        for p = 1:length(oUnemap.Electrodes)
            if oUnemap.Electrodes(p).Accepted
                m = m + 1;
                aActivationIndexes(:,m) = aElectrodes(m).SignalEvent(iEventID).Index;
                aOutActivationIndexes(:,p) =  aElectrodes(m).SignalEvent(iEventID).Index + oUnemap.Electrodes(p).Processed.BeatIndexes(:,1);
                aOutActivationTimes(:,p) = oUnemap.TimeSeries(aOutActivationIndexes(:,p));
                
            else
                %hold the unaccepted electrode places with inf
                aOutActivationTimes(:,p) =  NaN;
            end
        end
        k=27;
        aActivationTimes = zeros(size(aActivationIndexes));
        aActivationIndexes(k,:) = aActivationIndexes(k,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(k,1);
        aAcceptedTimes = oUnemap.TimeSeries(aActivationIndexes(k,:));
        aActivationTimes(k,:) = aAcceptedTimes;
        %Convert to ms
        if isfield(oUnemap.Electrodes(1),'Pacing')
            %this is a sequence of paced beats so express the
            %activation time relative to the pacing
            %stimulus
            aActivationTimes(k,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(k,:)) - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(k)));
            aOutActivationTimes(k,:) = 1000*(aOutActivationTimes(k,:)*51*51 - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(k)));
        else
            %this is a sequence of sinus beats so express the
            %activation time relative to the earliest accepted
            %activation
            aActivationTimes(k,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(k,:)) - min(aAcceptedTimes));
            aOutActivationTimes(k,:) = 1000*(aOutActivationTimes(k,:) - min(aOutActivationTimes(k,:)));
        end
        AT = aActivationTimes(k,:)';
end
%calculate interpolant
F = TriScatteredInterp(DT,AT);
qz = F(xlin,ylin);
aQZArray = reshape(qz,size(qz,1)*size(qz,2),1);
aQZArray(~aInBoundaryPoints) = NaN;
NewQz = reshape(aQZArray,size(xlin,1),size(xlin,2));
% % % % Approximate AT
% [CVApprox,ConductionVector]=ReComputeCV([rowlocs,collocs],AT,24,0.1);
% aIndices = ~isnan(CVApprox);
% CVApprox = CVApprox(aIndices);
% ConductionVector = ConductionVector(aIndices);
% rowlocs = rowlocs(aIndices);
% collocs = collocs(aIndices);
% % % Plot conduction direction
% figure(1); axes(); 
% quiver(rowlocs,collocs,ConductionVector(:,1),ConductionVector(:,2)); 
% axis equal; axis tight;
% xlabel('x'); ylabel('y'); title('Conduction direction');

% % %Plot conduction velocity

%Get the points array that will be used to solve for the interpolation
%coefficients
%First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% I.e x = A^-1 * b where x is ci.
aPoints = (repmat(rowlocs,1,size(rowlocs,1)) - repmat(rowlocs',size(rowlocs,1),1)).^2 + ...
    (repmat(collocs,1,size(collocs,1)) - repmat(collocs',size(collocs,1),1)).^2;


figure(2);
scatter(rowlocs,collocs,'filled');
hold on;
scatter(aXArray(aInBoundaryPoints),aYArray(aInBoundaryPoints),'r');
scatter(XF(:,1),XF(:,2),'g','filled');
trimesh(S.tri,aCoords(:,1),aCoords(:,2));
hold off;
axis equal; axis tight;
figure(4);
scatter(rowlocs,collocs,400,AT,'filled');
axis equal; axis tight;colormap(distinguishable_colors(12));colorbar;
%Only keep these mesh points
aMeshPoints = aMeshPoints(aInBoundaryPoints,:);
%Find the distance from each interpolation point to every data point
aInterpPoints = (repmat(aMeshPoints(:,1),1,size(rowlocs,1)) - repmat(rowlocs',size(aMeshPoints(:,1)),1)).^2 + ...
    (repmat(aMeshPoints(:,2),1,size(collocs,1)) - repmat(collocs',size(aMeshPoints(:,2),1),1)).^2;

%Initialise the map data struct
oData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints, 'r2', 0, 'Points', zeros(size(aPoints)), 'InterpPoints', zeros(size(aInterpPoints)), 'CVApprox', AT, ...
    'Coefs', zeros(size(aInterpPoints,2),1), 'Interpolated', zeros(size(aInterpPoints,2),1), 'z', NaN(size(aXArray,1),1), 'RMS', 0);
r2 = 0:0.001:0.02;
oMapData = repmat(oData,length(r2),1);
%clear oData from memory as no longer need it
clear oData;
%loop through all the r2 values
for i = 1:length(r2)
    %save the r2 value
    oMapData(i).r2 = r2(i);
    %Finish calculating the points array
    oMapData(i).Points = sqrt(aPoints + r2(i));
    %Solve the linear system to get the array of coefficients
    oMapData(i).Coefs = linsolve(oMapData(i).Points,oMapData(i).CVApprox);
    %Finish calculating the interpolation points array
    oMapData(i).InterpPoints = sqrt(aInterpPoints + r2(i));
    %Get the interpolated data via matrix multiplication
    oMapData(i).Interpolated = oMapData(i).InterpPoints * oMapData(i).Coefs;
    %Reconstruct field
    oMapData(i).z(oMapData(i).Boundary) = oMapData(i).Interpolated;
    oMapData(i).z = reshape(oMapData(i).z,size(xlin,1),size(xlin,2));
    oMapData(i).z = oMapData(i).z;
end
%Find the indices of the closest interpolation points to each recording
%point
[Vals aMinIndices] = min(aInterpPoints,[],1);
% %Calc the RMS error for this field
aCVPart = cell2mat({oMapData(:).CVApprox});
aInterpPart = cell2mat({oMapData(:).Interpolated});
aInterpPart = aInterpPart(aMinIndices,:);
aRMS = sqrt(sum((aCVPart - aInterpPart).^2,1)/size(aCVPart,1));
aDataToPlot = aRMS;
[C iMinIndex] = min(aDataToPlot);
figure();
plot(r2,aDataToPlot);
hold on
plot(r2(iMinIndex),C,'r+');
% PI = nearestNeighbor(DT,aMeshPoints);
% aQZArray = reshape(qz,size(qz,1)*size(qz,2),1);
% LinearRMS = sqrt(sum((aCVPart(PI,1) - aQZArray(aInBoundaryPoints)).^2,1)/size(PI,1));

%check if there is an existing colour bar
%get figure children
    %Get a new min and max
cbarmax = 0;
cbarmin = 2000; %arbitrary
ibmax = 0;
ibmin = 0;
i = 1;
%Loop through the beats to find max and min
dMin = min(min(oMapData(iMinIndex).z));
dMax = max(max(oMapData(iMinIndex).z));
if dMin < cbarmin
    cbarmin = dMin;
    ibmin = i;
end
if dMax > cbarmax
    cbarmax = dMax;
    ibmax = i;
end

figure(3); oMapAxes = axes();
iBeat = 1;
%Assuming the potential field has been normalised.
[C, oContour] = contourf(oMapAxes,oMapData(iMinIndex).x,oMapData(iMinIndex).y,oMapData(iMinIndex).z,floor(cbarmin):1:ceil(cbarmax));
colormap(oMapAxes, colormap(flipud(colormap(jet))));%
colorbar();
figure(5);oMapAxes = axes();
iBeat = 1;
%Assuming the potential field has been normalised.
[C, oContour] = contourf(oMapAxes,oMapData(1).x,oMapData(1).y,NewQz,floor(cbarmin):1:ceil(cbarmax));
colormap(oMapAxes, colormap(flipud(colormap(jet))));%
colorbar();

%if the colour bar should be visible then make
%a new one
% oColorBar = cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
% oTitle = get(oColorBar, 'title');
% set(oTitle,'units','normalized');
% set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
% axis(oMapAxes, 'equal');axis(oMapAxes, 'tight');

% % visualize CV
% x = rowlocs;
% y = collocs;
% AT = CVApprox;
% F = TriScatteredInterp(x,y,AT);
% [xx,yy]=ndgrid(min(x):0.2:max(x),min(y):0.2:max(y));
% ATI = F(xx,yy);
% figure(5); mesh(xx,yy,ATI); hold on; 
% scatter3(x,y,AT,40,AT,'filled'); hold off; axis tight; colorbar;
% xlabel('x'); ylabel('y'); zlabel('AT'); title('CV function');

