function oNeedlePoints = GetNeedlePointLocationsFromCSV(sFilePath,startrow,startcol)
% % % This function reads the locations of needle points saved from a
% optical mapping file in format of two columns (x location, y location) in
% a csv file

aPointData = dlmread(sFilePath, ',', startrow, startcol);
%create an array of structs to hold the locations
oPoint = struct('Line1',[0 0 0 0],'Line2',[0 0 0 0]);
oNeedlePoints = repmat(oPoint,size(aPointData,1)/2,1);
%loop through the points
iCount = 1;
iLineCount = 1;
for i = 1:size(aPointData,1)
    switch (iLineCount)
        case 1
            oNeedlePoints(iCount).Line1 = aPointData(i,:);
            iLineCount = 2;
        case 2
            oNeedlePoints(iCount).Line2 = aPointData(i,:);
            iLineCount = 1;
            iCount = iCount + 1;
    end
end
end
