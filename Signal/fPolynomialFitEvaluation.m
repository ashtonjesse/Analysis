function Y = fPolynomialFitEvaluation(varargin)
%This function creates a polynomial fit of the potential data currently
%loaded into the global Data variable and then returns the evaluated Y
%values of this polynomial.

%Do some checks
switch size(varargin,2)
    case 2
        aData = cell2mat(varargin(1,1));
        iOrder = cell2mat(varargin(1,2));
        iDim = size(aData,1);
    case 3
        aData = cell2mat(varargin(1,1));
        iOrder = cell2mat(varargin(1,2));
        iDim = cell2mat(varargin(1,3));
    otherwise
        error('fPolynomialFitEvaluation:WrongNumberOfInputs','Wrong number of inputs');
end
X = 1:1:size(aData,1);
XEval = 1:1:iDim;
%Make vector vertical
X = transpose(X);
XEval = transpose(XEval);
P = polyfit(X,aData,iOrder);

Y = polyval(P,XEval);


