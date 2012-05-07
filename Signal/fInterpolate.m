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
% Initialise the output array
Y = zeros(aIndexes(1)-1,1);
X = [0 ; 2];
%Loop through the indata points
for k = 2:size(aData,1);
    iStepSize = 2/(aIndexes(k,1)-aIndexes(k-1,1));
    aInterpData = [aData(k-1,1) ; aData(k,1)];
    XEval = 0:iStepSize:(2-iStepSize);
    XEval = transpose(XEval);
    Y = [Y ; interp1(X,aInterpData,XEval)];
%     Y = [Y ; polyval(P,XEval)];
%     P = polyfit(X,aInterpData,iOrder);
end
Y = [Y ; aData(k,1)];
if iDim > size(aData,1);
    Y = [Y ; zeros(iDim - aIndexes(size(aIndexes,1),1),1)];
end
%Make vector vertical
% X = transpose(X);
% XEval = transpose(XEval);

% 
% 
% Y = polyval(P,XEval);
end
