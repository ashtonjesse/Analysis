function oMapData = fHardy(aActivationTimes,dRes,iScaleFactor,r2)

%get activation data
% [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilesPath,rowdim,coldim,7);
% aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
aActivationTimes = rot90(aActivationTimes,-1);
[rowIndices colIndices] = find(aActivationTimes > 0);
aATPoints = aActivationTimes > 0;
AT = aActivationTimes(aATPoints);
AT(AT < 1) = NaN;
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);
%convert locations into spatial coordinates
rowlocs = dRes .* rowIndices;
collocs = dRes .* colIndices;
%calculate dimension for interpolation
dInterpDim = dRes/iScaleFactor;

% Find the boundary of the recording points by converting to logical array
aMask = logical(aActivationTimes + 1);
%Resize the mask to set the resolution of the interpolated field
aMask = imresize(aMask,'scale',iScaleFactor,'method', 'bilinear');
%Dilate this mask and subtract the original to just leave the boundary
aMask = logical(filter2(true(3),aMask)) - aMask;

%Find the indices of the boundary points
[rowMaskIndices colMaskIndices] = find(aMask);
%Convert into coordinates
rowBoundary = dInterpDim .* rowMaskIndices;
colBoundary = dInterpDim .* colMaskIndices;

%Get the interpolation points array
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

%Get the points array that will be used to solve for the interpolation
%coefficients by finding the distance from each point to every other point
aPoints = (repmat(rowlocs,1,size(rowlocs,1)) - repmat(rowlocs',size(rowlocs,1),1)).^2 + ...
    (repmat(collocs,1,size(collocs,1)) - repmat(collocs',size(collocs,1),1)).^2;

%Only keep these mesh points
aMeshPoints = aMeshPoints(aInBoundaryPoints,:);

%Find the distance from each interpolation point to every data point
aInterpPoints = (repmat(aMeshPoints(:,1),1,size(rowlocs,1)) - repmat(rowlocs',size(aMeshPoints(:,1)),1)).^2 + ...
    (repmat(aMeshPoints(:,2),1,size(collocs,1)) - repmat(collocs',size(aMeshPoints(:,2),1),1)).^2;

%Initialise the map data struct
oMapData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints, ...
    'r2', r2, 'Points', zeros(size(aPoints)), 'InterpPoints', zeros(size(aInterpPoints)), ...
    'RawData', AT, 'Coefs', zeros(size(aInterpPoints,2),1), 'Interpolated', ...
    zeros(size(aInterpPoints,2),1), 'z', NaN(size(aXArray,1),1), 'zraw', NaN(size(aXArray,1),1),'RMS', 0);

%First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% I.e x = A^-1 * b where x is ci.
%Finish calculating the points array
oMapData.Points = sqrt(aPoints + r2);
%Solve the linear system to get the array of coefficients
oMapData.Coefs = linsolve(oMapData.Points,oMapData.RawData);
%Finish calculating the interpolation points array
oMapData.InterpPoints = sqrt(aInterpPoints + r2);
%Get the interpolated data via matrix multiplication
oMapData.Interpolated = oMapData.InterpPoints * oMapData.Coefs;
%Reconstruct field
oMapData.zraw(oMapData.Boundary) = oMapData.Interpolated;
oMapData.zraw = reshape(oMapData.zraw,size(xlin,1),size(xlin,2));
%round the data to smooth out small changes in data 
oMapData.z = round(oMapData.zraw);

% %Calc the RMS error for this field
[Vals aMinIndices] = min(aInterpPoints,[],1);
aRawPart = oMapData.RawData;
aInterpPart = oMapData.Interpolated(aMinIndices);
oMapData.RMS = sqrt(sum((aRawPart - aInterpPart).^2,1)/size(aRawPart,1));

end