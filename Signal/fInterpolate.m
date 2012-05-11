function Y = fInterpolate(varargin)
%This function interpolates between points in the indata array. It loops
%through these points and creates a new array that holds these points in
%at the indexes specified by aIndexes and fills in the gaps up to iDim with
%linear interpolated points

%Do some checks
switch size(varargin,2)
    case 2
        aIndexes = cell2mat(varargin{1,1}(1));
        aData = cell2mat(varargin{1,1}(2));
        iOrder = cell2mat(varargin{1,2});
        iDim = size(aData,1);
    case 3
        aIndexes = cell2mat(varargin{1,1}(1));
        aData = cell2mat(varargin{1,1}(2));
        iOrder = cell2mat(varargin(1,2));
        iDim = cell2mat(varargin(1,3));
    otherwise
        error('fInterpolation:WrongNumberOfInputs','Wrong number of inputs');
end
if size(aIndexes,1) ~=  size(aData,1)
    error('fInterpolation:WrongInputs','The indexes and data arrays need to be of the same length');
end
% Initialise the output array by filling in a straight line to the first
% point
%Work out the points to interpolate at
iStepSize = 2/aIndexes(1,1);
%Get the first point interpolate between
%these
aInterpData = [aData(1,1) ; aData(1,1)];
%The interpolation points array
XEval = 0:iStepSize:(2-iStepSize);
XEval = transpose(XEval);
%Start the output array
X = [0 ; 2];
Y = [interp1(X,aInterpData,XEval)];

%Loop through the indata points
for k = 2:size(aData,1);
    %Work out the points to interpolate at
    iStepSize = 2/(aIndexes(k,1)-aIndexes(k-1,1));
    %Get the current column and the last column and interpolate between
    %these
    aInterpData = [aData(k-1,1) ; aData(k,1)];
    %The interpolation points array
    XEval = 0:iStepSize:(2-iStepSize);
    XEval = transpose(XEval);
    %Add the interpolation to the output array
    Y = [Y ; interp1(X,aInterpData,XEval)];
%     Y = [Y ; polyval(P,XEval)];
%     P = polyfit(X,aInterpData,iOrder);
end
%Add the last interpolation point to the array
Y = [Y ; aData(k,1)];
Y = Y(2:size(Y,1),:);

%If a dimension has been supplied then add zeros to the end of this array
% if iDim > size(Y,1);
%     Y = [Y ; zeros(iDim - aIndexes(size(aIndexes,1),1),1)];
% end

end
