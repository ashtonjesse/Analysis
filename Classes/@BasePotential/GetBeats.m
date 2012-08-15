function aOutData = GetBeats(oBasePotential, aInData, aPeaks)
%   GetBeats 
%   Get the segments of the data that correspond to the beats
%   indicated between the peaks in aPeaks and fill in gaps with NaNs.
%   Returns a cell array with the beats and the start and end times of each

%Get the number of peak locations n
[m,n] = size(aPeaks);
%Get the number of signals q
[p,q] = size(aInData);
%Save the first peak location
iFirstPeak = aPeaks(2,1);
%Initialise the loop variables
iCurrentPeak = iFirstPeak;
iLastPeak = 0;
iOldLastPeak = 1;
aBeats = NaN(1,q);
aBeatIndices = zeros(1,2);
%Loop through the peaks
for j = 2:n;
    %If the next peak is greater than 100 more than the current
    %peak then the next group of peaks must be reached so save
    %the first and last peaks of the last group in aBeats.
    if aPeaks(2,j) < (iCurrentPeak + 150)
        iLastPeak = aPeaks(2,j);
    else
        %must have found the end of a beat
        aThisBeat = aInData(iFirstPeak:iLastPeak,:);
        aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
        aBeats = [aBeats ; aThisGap ; aThisBeat];
        aBeatIndices = [aBeatIndices ; iFirstPeak, iLastPeak];
        iFirstPeak = aPeaks(2,j);
        iOldLastPeak = iLastPeak;
    end
    iCurrentPeak = aPeaks(2,j);
end
%Run for the last beat
aThisBeat = aInData(iFirstPeak:iLastPeak,:);
aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
aBeats = [aBeats ; aThisGap ; aThisBeat];
aBeatIndices = [aBeatIndices ; iFirstPeak, iLastPeak];
%Fill in the end of the vector with NaNs if required
if size(aBeats,1) < p
    aBeats = [aBeats ; NaN(p - size(aBeats,1),q)];
end
%Remove the first set of zeros from indices
aBeatIndices = aBeatIndices(2:size(aBeatIndices,1),:);
%output the beats.
aOutData = {aBeats,aBeatIndices};

end

