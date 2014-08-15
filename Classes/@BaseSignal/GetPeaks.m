function [aPeaks,aPeakLocations] = GetPeaks(oBasePotential,aInData,dThreshold)
%   ThresholdData calculates a threshold value and applies it to the data
%   supplied in aInData and returns the peak values and locations of the peaks 
%   by wrapping a call to /Signal/fFindPeaks.
[aFirstPeaks, aFirstLocations] = fFindPeaks(aInData);%, 'MINPEAKDISTANCE', 100
aPeaks = aFirstPeaks(aFirstPeaks > dThreshold);
aPeakLocations = aFirstLocations(aFirstPeaks > dThreshold);
end

