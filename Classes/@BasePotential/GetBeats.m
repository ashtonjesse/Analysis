function aOutData = GetBeats(oBasePotential, aInData, aPeaks)
%   GetBeats 
%   Get the seg ments of the data that correspond to the beats
%   indicated between the peaks in aPeaks and fill in gaps with NaNs.

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
%Loop through the peaks
for j = 2:n;
    %If the next peak is greater than 100 more than the current
    %peak then the next group of peaks must be reached so save
    %the first and last peaks of the last group in aBeats.
    if aPeaks(2,j) < (iCurrentPeak + 100)
        iLastPeak = aPeaks(2,j);
    else
        aThisBeat = aInData(iFirstPeak:iLastPeak,:);
        aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
        aBeats = [aBeats ; aThisGap ; aThisBeat];
        iFirstPeak = aPeaks(2,j);
        iOldLastPeak = iLastPeak;
    end
    iCurrentPeak = aPeaks(2,j);
end
%Run for the last beat
aThisBeat = aInData(iFirstPeak:iLastPeak,:);
aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
aBeats = [aBeats ; aThisGap ; aThisBeat];

%Fill in the end of the vector with NaNs if required
if size(aBeats,1) < p
    aBeats = [aBeats ; NaN(p - size(aBeats,1),q)];
end
%output the beats.
aOutData = aBeats;

end

