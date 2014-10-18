function [aOutData aMaxPeaks] = GetSinusBeats(oBasePotential, aInData, aPeaks)
%   GetSinusBeats 
%   Get the segments of the data that correspond to the beats
%   indicated between the peaks in aPeaks and fill in gaps with NaNs.
%   Returns a cell array with the beats and the start and end times of each
%   and an array that contains the locations of the maximum peaks in each
%   window. Does not look for a stimulus artifact

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
iPeakCount = 1;
iBeatCount = 1;
%Initialise the array to hold the index of first and last peak of every
%beat. There will be less beats than number of peaks so use n as a first
%estimate. This will be trimmed at the end. 
aBeatIndices = zeros(n,2);
%Initialise the array to hold the values of aInData that sit within the
%limits of each beat with nans in between
aBeats = NaN(p,q);
%Initialise an array to hold the maximum values of each beat
aMaxPeaks = zeros(n,1);
iBlank = 40;
%Loop through the peaks
for j = 2:n;
    %If the next peak is greater than 150 more than the current
    %peak then the next group of peaks must be reached so save
    %the first and last peaks of the last group in aBeats.
    if aPeaks(2,j) < (iCurrentPeak + 70)
        iLastPeak = aPeaks(2,j);
        iPeakCount = iPeakCount + 1;
    else
        if iPeakCount >= 2
            %must have found the end of a beat
            %Add some padding to the beginning and end 
            iLastPeak = iLastPeak + iBlank;
            iFirstPeak = iFirstPeak - iBlank/2;
            iFirstPeak = max(1,iFirstPeak);
            aThisBeat = aInData(iFirstPeak:iLastPeak,:);
            %aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
            aBeats(iFirstPeak:iLastPeak,:) = aThisBeat;
            aBeatIndices(iBeatCount,:) = [iFirstPeak, iLastPeak];
            %Get the index of the maximum peak in this block
            [Val, iIndex] = max(aPeaks(1,iFirstIndex:j-1));
            %Insert this index + the first index into the MaxPeaks array
            aMaxPeaks(iBeatCount) = aPeaks(2,iFirstIndex+iIndex-1);
            iOldLastPeak = iLastPeak;
            iBeatCount = iBeatCount + 1;
        end
        iFirstPeak = aPeaks(2,j);
        iFirstIndex = j;
        iPeakCount = 1;
    end
    iCurrentPeak = aPeaks(2,j);
end
%Run for the last beat
if iPeakCount >= 2
    iLastPeak = min(iLastPeak + iBlank,length(aInData));
    iFirstPeak = iFirstPeak - iBlank/2;
    aThisBeat = aInData(iFirstPeak:iLastPeak,:);
    %     aThisGap = NaN(iFirstPeak - iOldLastPeak - 1,q);
    %     aBeats = [aBeats ; aThisGap ; aThisBeat];
    %     aBeatIndices = [aBeatIndices ; iFirstPeak, iLastPeak];
    aBeats(iFirstPeak:iLastPeak,:) = aThisBeat;
    aBeatIndices(iBeatCount,:) = [iFirstPeak, iLastPeak];
    [Val, iIndex] = max(aPeaks(1,iFirstIndex:j));
    %     aMaxPeaks = [aMaxPeaks ; aPeaks(2,iFirstIndex+iIndex-1)];
    aMaxPeaks(iBeatCount) = aPeaks(2,iFirstIndex+iIndex-1);
    iBeatCount = iBeatCount + 1;
end
%Fill in the end of the vector with NaNs if required
% if size(aBeats,1) < p
%     aBeats = [aBeats ; NaN(p - size(aBeats,1),q)];
% end
%Trim the zeros from the end
aBeatIndices = aBeatIndices(1:iBeatCount-1,:); 
aMaxPeaks = aMaxPeaks(1:iBeatCount-1); 
%output the beats.
aOutData = {aBeats,aBeatIndices};

end