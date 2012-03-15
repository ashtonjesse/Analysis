function aOut = PerformCorrection(aIn,iOrder)
%Perform baseline correction

addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/'));
%Compute the median
dMedian = median(aIn);
%Subtract this from the input data
aRemoveMedian = aIn - dMedian;
%Compute the polynomial fit of order iOrder
aBaselinePolynomial = fPolynomialFitEvaluation(aRemoveMedian,iOrder);
%Remove the polynomial approximation to the baseline from the
%data 
aOut = aRemoveMedian-aBaselinePolynomial;

return
