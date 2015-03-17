function [aDerivative aGridPoints]= EstimateDerivative(u,x,k,iNumGridPoints,iSupportPoints)
%this function uses the LeVeque implementation of the Fornberg algorithm
%for computing coefficients of a general finite difference scheme for estimating 
%a derivative and is suitable for unevenly spaced data points

%u is a column vector that contains the function values at x points
%k is the order of the derivative to return
%iNumGridPoints is the number of grid points to use in the derivative
%estimate
%iSupportPoints is the number of x values used around the grid point of
%interest

%set array for evaluating derivative
xbar = linspace(x(1), x(end), iNumGridPoints);
%loop through the grid points and compute the derivative
aDerivative = zeros(numel(xbar),1);
iEnd = numel(x);
%set the number of support points for the finite difference
for p = 1:numel(aDerivative)
    %find closest support points
    [Val Ind] = min(abs(x - xbar(p)));
    if Ind < iSupportPoints
        xn = x(1:iSupportPoints);
        Un = u(1:iSupportPoints);
    elseif Ind > iEnd - iSupportPoints
        xn = x(end-iSupportPoints+1:end);
        Un = u(end-iSupportPoints+1:end);
    else
        iHalfInterval = double(idivide(iSupportPoints, int8(2), 'floor'));
        xn = x(Ind-iHalfInterval:Ind+iHalfInterval);
        Un = u(Ind-iHalfInterval:Ind+iHalfInterval);
    end
    C = fdcoeffF(k,xbar(p),xn);
    aDerivative(p) = C * Un;
end
aGridPoints = xbar;
end