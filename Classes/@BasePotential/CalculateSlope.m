function aGradient = CalculateSlope(oBasePotential,aData,iNumberofPoints,iModelOrder)
% CalculateSlope calculates a moving average slope of the input data based
% on the input parameters 

% Calculate the first derivative
aGradient = fCalculateMovingSlope(aData,iNumberofPoints,iModelOrder); 

end

