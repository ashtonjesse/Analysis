function aOutData = fSteepestSlope(aXData,aYData,aIntervals)
% This function loops through the intervals provided and returns an array
% of values from the aXData array that correspond with the maximum values
% in the aYData array within these intervals

[a b] = size(aIntervals);
aOutData = zeros(a,1);
for i = 1:a;
    [dMax, iMaxIndex] = max(aYData(aIntervals(i,1):aIntervals(i,2)));
    aOutData(i) = iMaxIndex;
end

