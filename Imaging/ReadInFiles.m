close all;
clear all;

%Specify paths
sImagesPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Immuno\20130425\v28bitblock\v28bitblock_cropped\';
sThresholdedPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Immuno\20130425\v28bitblock\v28bitblock_cropped\v28bitblock_image_1\';
% sSavePath = 'H:/Data/Database/20111124';
sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20130425\';
sFormat = 'png';
sName = 'CholinergicNerves';

%Get the full path names of all the  files in the image directory
%aImageFileFull = fGetFileNamesOnly(sImagesPath,'*deconv00021.png');
aImageFileFull = fGetFileNamesOnly(sImagesPath,strcat('*.',sFormat));
aThresholdedImages = fGetFileNamesOnly(sThresholdedPath,strcat('*Nerve0*.',sFormat));
%Initialise Imagestack to hold images
oImageStack = ImageStack(length(aImageFileFull),'uint8');
% %get the size of the images
% aTempImage = imread(char(aImageFileFull(1)),sFormat);
% [m n] = size(aTempImage);
% clear aTempImage;
% oDataStack = zeros(m,n,length(aImageFileFull),'uint8');
fprintf('Running... \n');
for k = 1:length(aImageFileFull)
    %Create image
    oImageStack.oImages(k) = oImageStack.oImages(k).GetImageEntityFromFile(char(aImageFileFull(k)),sFormat);
    oImageStack.oImages(k) = oImageStack.oImages(k).GetBinaryImageFromFile(char(aThresholdedImages(k)), sFormat);
    disp(k);
end
%Get current filename fileparts
[a sFileName c] = fileparts(aImageFileFull{k});
%Append .mat to the end of the filename
sFileSaveName = strcat(sSavePath,sName,'.mat');
%Print to the command window that the file is being saved
fprintf('Saving %s\n',sFileSaveName);
%Save the unemap entity
oImageStack.Save(sFileSaveName)

