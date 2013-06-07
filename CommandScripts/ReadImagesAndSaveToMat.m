%This script reads all the images from a confocal stack in a directory and saves them in one
%array in a mat file.

close all;
clear all;

%Specify paths
sImagesPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Immuno\20120704\iso010\iso_1\';
% sSavePath = 'H:/Data/Database/20111124';
sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\ManSeg\';
sFormat = 'png';
sName = 'iso010_seg';
%Get the full path names of all the  files in the signal directory
%aImageFileFull = fGetFileNamesOnly(sImagesPath,'*deconv00021.png');
aImageFileFull = fGetFileNamesOnly(sImagesPath,strcat('*Nerve0*.',sFormat));
%get the first image
aImage = imread(aImageFileFull{1});
%get the dimensions of the images
[nrows ncols] = size(aImage);
clear aImage;
%Initialise an array to hold images
aManSegData = logical(zeros(nrows, ncols, length(aImageFileFull)));
fprintf('Running... \n');
for k = 1:length(aImageFileFull)
    aManSegData(:,:,k) = imread(aImageFileFull{k}, sFormat);
end
%Append .mat to the end of the filename
sFileSaveName = strcat(sSavePath,sName,'.mat');
%Print to the command window that the file is being saved
fprintf('Saving %s\n',sFileSaveName);
save(sFileSaveName,'aManSegData');
close all;
clear all;