function aReturnData = fRemoveMedianAndPolynomialFit(aInData,iOrder)
% This function computes the overall median of the signal data (aInData)
% and subtracts this constant from the data. A polynomial fit of order 
% iOrder is then computed and subtracted from the data.

addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Utilities/'));
%Compute the median
dMedian = median(aInData);
%Subtract this from the input data
aRemoveMedian = aInData - dMedian;
%Compute the polynomial fit of order iOrder
[aBaselinePolynomial] = fPolynomialFitEvaluation(aRemoveMedian,iOrder);
%Remove the polynomial approximation to the baseline from the data
aRemoveBaseline = aRemoveMedian-aBaselinePolynomial;
%Return this data
aReturnData = aRemoveBaseline;