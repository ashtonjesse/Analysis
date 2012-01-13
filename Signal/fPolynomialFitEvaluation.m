function Y = fPolynomialFitEvaluation(iOrder, iChannel)
%This function creates a polynomial fit of the potential data currently
%loaded into the global Data variable and then returns the evaluated Y
%values of this polynomial.
global Data;

X = 1:1:size(Data.Unemap.Potential.Original(:,iChannel),1);
%Make vector vertical
X = transpose(X);
P = polyfit(X,Data.Unemap.Potential.Original(:,iChannel),iOrder);

Y = polyval(P,X);


