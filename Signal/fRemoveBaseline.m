function thing = fRemoveBaseline(iPolynomialOrder,iDefaultSignal)
%Add paths
addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Signal/'));

[aBaselinePolynomial] = fPolynomialFitEvaluation(iPolynomialOrder,iDefaultSignal);

oCorrectedOriginal = findobj('tag','CorrectedOriginal');

aRemoveBaseline = Data.Unemap.Potential.Original(:,iDefaultSignal)-baseline;
aRemoveBaselineMean = aRemoveBaseline - mean(aRemoveBaseline);

