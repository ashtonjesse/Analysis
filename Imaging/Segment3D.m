clear all;
close all;

% Load image stack
sImagesPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20130425\';

%Call built-in file dialog to select filename
[sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing an ImageStack entity',sImagesPath);
%Make sure the dialogs return char objects
if (~ischar(sDataFileName) && ~ischar(sDataPathName))
    return
end

%Get the full file name and save it to string attribute
sLongDataFileName=strcat(sDataPathName,sDataFileName);
[pathstr, name, ext, versn] = fileparts(sLongDataFileName);

%Load the selected file
oImageStack = GetImageStackFromMATFile(ImageStack,sLongDataFileName);
disp('Loaded');

%Convert images into single array 
aData = oImageStack.oImages(:);
aNewData = {aData(:).BinaryImage};
aBinaryImages = cat(3, aNewData{:});
clear aData;
clear aNewData;

%Split up the image volume into smaller volumes for analysis
aBinaryImages = aBinaryImages(1:100,1:100,1:100);

%Find connected components
oConnComps = bwconncomp(aBinaryImages,26);
clear aBinaryImages;
clear oImageStack;
%drop the components that are only 1 pixel in size
aIndicesToDelete = true(oConnComps.NumObjects,1);
for p = 1:oConnComps.NumObjects
    if length(oConnComps.PixelIdxList{p}) < 2
        aIndicesToDelete(p) = 0;
    end
end
oConnComps.PixelIdxList = oConnComps.PixelIdxList(aIndicesToDelete);
oConnComps.NumObjects = length(oConnComps.PixelIdxList);
clear aIndicesToDelete;
disp('Got connected components');

%And make a copy for manipulation

aIndicesToCheck = false(oConnComps.NumObjects,oConnComps.NumObjects);
% %Get properties
oCompCentroids = regionprops(oConnComps, 'centroid');
disp('Got centroids');
% oCompPixels = regionprops(oConnComps, 'pixellist');
%Set threshold for objects that could be considered the same
iCentroidThreshold = 10;
%Set threshold for objects that are close enough to be the same
iClosestThreshold = 5;
%Initialise minimum distance between pixels
dMinDistance = 999;
%loop through all the connected components
for i = 1:oConnComps.NumObjects
    %loop through all other connected components
    for j = 1:oConnComps.NumObjects
        
            %calculate distance between centroids
            dCentroidDistance = sqrt((oCompCentroids(i).Centroid(1) - oCompCentroids(j).Centroid(1))^2 + ...
                (oCompCentroids(i).Centroid(2) - oCompCentroids(j).Centroid(2))^2 + ...
                (oCompCentroids(i).Centroid(3) - oCompCentroids(j).Centroid(3))^2);
            if dCentroidDistance < iCentroidThreshold
                aIndicesToCheck(i,j) = 1;
%             elseif length(oConnComps.PixelIdxList{i}) < 2
%                 %If it is a single isolated pixel then remove it later
%                 aIndicesToDelete(i) = 1;
            end
        
    end
    disp(i);
end
% %Loop through pixels from first component
% for m = 1:size(oCompPixels(i).PixelList,1)
% %     loop through pixels from second component
%     for n = 1:size(oCompPixels(j).PixelList,1)
% %         calculate distance between pixels
%         dPixelDistance = sqrt((oCompPixels(i).PixelList(m,1) - oCompPixels(j).PixelList(n,1))^2 + ...
%             (oCompPixels(i).PixelList(m,2) - oCompPixels(j).PixelList(n,2))^2 + ...
%             (oCompPixels(i).PixelList(m,3) - oCompPixels(j).PixelList(n,3))^2);
%         if dPixelDistance < dMinDistance
% %             Save the minimum distance between the
%             components
%             dMinDistance = dPixelDistance;
%         end
%     end
% end

                
% %If the closest points are below the threshold then these
% %components should actually be connected
% if dMinDistance < iClosestThreshold
%     oNewConnComps.PixelIdxList{i} = [oConnComps.PixelIdxList{i} ; oConnComps.PixelIdxList{j}];
%     aIndicesToDelete(j) = 1;
% end