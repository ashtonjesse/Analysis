function [aContours2 newVm] = FindMatchingContourMap(oOptical,oPotential,oAxes,iTimePoint,iBeat,SortedLevels1,Area1,aContourLevels)
%subsample data between timepoints for current beat
delVm = oPotential.Beats(iBeat).Fields(iTimePoint+1).Vm' - oPotential.Beats(iBeat).Fields(iTimePoint).Vm';
delT = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1)+iTimePoint+1)-oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1)+iTimePoint);
NSubSamples = 10;
aNewFields = cell(NSubSamples,1);
bLevelAchieved = false;
for nn = 1:NSubSamples
    newVm = delVm.*((nn*delT/NSubSamples)/delT) + oPotential.Beats(iBeat).Fields(iTimePoint).Vm';
    oInterpolant = TriScatteredInterp(oPotential.DT,newVm);
    oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
    %rearrange to be able to apply boundary
    aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
    %apply boundary
    aQZArray(~oPotential.Boundary) = NaN;
    %save result back in proper format
    aNewFields{nn}  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
    [aContours2, h] = contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields{nn},aContourLevels);
    % %get the peak contour
    [aLevels2 aPoints2] = SplitContours(aContours2);
    [SortedLevels2 IX2] = sort(aLevels2);
    % %  get area of peak contour
    if ~isnan(aPoints2{IX2(end)}(1,1))
        %then use this one
        if SortedLevels1(end)-SortedLevels2(end) < 0.001
            %if the levels are the same then check if the areas are the
            %same
            Area2 = polyarea(aPoints2{IX2(end)}(1,:),aPoints2{IX2(end)}(2,:));
            Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end)}'));
            if Area2 > Area1 || bLevelAchieved
                break;
            else
                bLevelAchieved = true;
            end
        end
    else
        %do as above but for the second to last points as some of the
        %entries are NaNs
        if abs(SortedLevels1(end)-SortedLevels2(end-1)) < 0.001
            Area2 = polyarea(aPoints2{IX2(end-1)}(1,:),aPoints2{IX2(end-1)}(2,:));
            Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end-1)}'));
            if Area2 > Area1 || bLevelAchieved
                break;
            else
                bLevelAchieved = true;
            end
        end
    end
end
end