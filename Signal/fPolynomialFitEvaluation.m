function Y = fPolynomialFitEvaluation(aData, iOrder)
%This function creates a polynomial fit of the potential data currently
%loaded into the global Data variable and then returns the evaluated Y
%values of this polynomial.

X = 1:1:size(aData,1);
%Make vector vertical
X = transpose(X);
P = polyfit(X,aData,iOrder);

Y = polyval(P,X);


