function aCurvature = CalculateCurvature(oBaseSignal,aData,iNumberofPoints,iModelOrder)
% This function calculates the Curvature of the signal stored in aData

% Calculate the first derivative
aGradient = fCalculateMovingSlope(aData,iNumberofPoints,iModelOrder); 
% Calculate the second derivative
aCurvature = fCalculateMovingSlope(aGradient,iNumberofPoints,iModelOrder);

% % Get the size of the input data array
% [x y] = size(aData);
% % Initialise the aCurvature array
% aCurvature = zeros(x,1);
% 
% for k = 1:x
%     aCurvature(k) = abs(aGradient2(k)) / ((1 + aGradient(k)^2))^(3/2);
% end

return