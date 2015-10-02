function aCoords = centroid(aPoints)
%finds the x and y coordinates of the centre of cloud of points
aCoords = zeros(2,1);
aCoords(1,1) = mean(aPoints(:,1));
aCoords(2,1) = mean(aPoints(:,2));
end