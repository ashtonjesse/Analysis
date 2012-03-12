function [aVrms] = fCalculateVrms(aData)
% This function calculates the Vrms of all the signals in a data file 

% Get the size of the input data array
[x y] = size(aData);
% Initialise the aVrms array
aVrms = zeros(x,1);

for k = 1:x;
    %Calculate the Vrms for signal k
    aVrms(k) = sqrt(sum(aData(k,:).^2) / y);
end

return