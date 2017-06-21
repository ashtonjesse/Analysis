function [Area, Centroid, SortedLevels] = GetPeakContourAttributes(aContours)
[aLevels aPoints] = SplitContours(aContours);
[SortedLevels IX] = sort(aLevels);
% %  get area of peak contour
if ~isnan(aPoints{IX(end)}(1,1))
    Area = polyarea(aPoints{IX(end)}(1,:),aPoints{IX(end)}(2,:));
    Centroid = transpose(polygonCentroid(aPoints{IX(end)}'));
else
    Area = polyarea(aPoints{IX(end-1)}(1,:),aPoints{IX(end-1)}(2,:));
    Centroid = transpose(polygonCentroid(aPoints{IX(end-1)}'));
end
end