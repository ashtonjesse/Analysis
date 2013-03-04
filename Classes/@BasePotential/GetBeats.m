function [aOutData aMaxPeaks] = GetBeats(oBasePotential, aInData, aPeaks)
%   GetBeats 
%   Get the segments of the data that correspond to the beats
%   indicated between the peaks in aPeaks and fill in gaps with NaNs.
%   Returns a cell array with the beats and the start and end times of each
%   and an array that contains the locations of the maximum peaks in each
%   window

%Get the number of peak locations n
[m,n] = size(aPeaks);
%Get the number of signals q
[p,q] = size(aInData);
%Save the first peak location
iFirstPeak = aPeaks(2,1);
iFirstIndex = 1;
%Initialise the loop variables
iCurrentPeak = iFirstPeak;
iLastPeak = 0;
iOldLastPeak = 1;
iPeakCount = 0;
iStimArtifactSpace = 30;
iBlank = 40;
aBeats = NaN(1,q);
aBeatIndices = zeros(1,2);
aMaxPeaks = zeros(1,1);
%Loop through the peaks
for j = 2:n;
    %If the next peak is greater than 150 more than the current
    %peak then the next group of peaks must be reached so save
    %the first and last peaks of the last group in aBeats.
    if aPeaks(2,j) < (iCurrentPeak + 50)
        iLastPeak = aPeaks(2,j);
        iPeakCount = iPeakCount + 1;
    else
        if iPeakCount > 3
            %Only take a sequence of peaks that has more than 3 peaks in
            %it.
            %must have found the end of a beat
            iFirstPeak = iFirstPeak + iStimArtifactSpace;
            iLastPeak = iLastPeak + iBlank;
            aThisBeat = aInData(iFirstPeak:iLastPeak,:);
            aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
            aBeats = [aBeats ; aThisGap ; aThisBeat];
            aBeatIndices = [aBeatIndices ; iFirstPeak, iLastPeak];
            %Get the index of the maximum peak in this block
            [Val, iIndex] = max(aPeaks(1,iFirstIndex:j-1));
            %Insert this index + the first index into the MaxPeaks array
            aMaxPeaks = [aMaxPeaks ; aPeaks(2,iFirstIndex+iIndex-1)];
            iOldLastPeak = iLastPeak;
        end
        iFirstPeak = aPeaks(2,j);
        iFirstIndex = j;
        iPeakCount = 0;
    end
    iCurrentPeak = aPeaks(2,j);
end
%Run for the last beat
iFirstPeak = iFirstPeak + iStimArtifactSpace;
iLastPeak = iLastPeak + iBlank;
aThisBeat = aInData(iFirstPeak:iLastPeak,:);
aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
aBeats = [aBeats ; aThisGap ; aThisBeat];
aBeatIndices = [aBeatIndices ; iFirstPeak, iLastPeak];
[Val, iIndex] = max(aPeaks(1,iFirstIndex:j));
aMaxPeaks = [aMaxPeaks ; aPeaks(2,iFirstIndex+iIndex-1)];
%Fill in the end of the vector with NaNs if required
if size(aBeats,1) < p
    aBeats = [aBeats ; NaN(p - size(aBeats,1),q)];
end
%Remove the first set of zeros from indices
aBeatIndices = aBeatIndices(2:size(aBeatIndices,1),:);
aMaxPeaks = aMaxPeaks(2:size(aMaxPeaks,1),:);
%output the beats.
aOutData = {aBeats,aBeatIndices};

end

