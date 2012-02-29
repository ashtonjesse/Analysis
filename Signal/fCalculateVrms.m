function [aVrms] = fCalculateVrms(aData)
% This function calculates the Vrms of all the signals in a data file and 
% then smoothes this with a moving average over a iNumberofPoints point 
% window using Savitzky-Golay FIR filtering.

% Get the size of the input data array
[x y] = size(aData);
% Initialise the aVrms array
aVrms = zeros(x,1);

for k = 1:x;
    %aVrms(k) = sqrt(sum(DATA.Unemap.Pot.OrigBase(k,:).^2) / sd2);
    %Calculate the Vrms for signal k
    aVrms(k) = sqrt(sum(aData(k,:).^2) / y);
end

