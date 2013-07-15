%This script loads an image or image sequence into entities and saves these

close all;
clear all;

%Specify paths
sImagesPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\MicroCT\20130613\segmented\';
% sSavePath = 'H:/Data/Database/20111124';
sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\MicroCT\20130613\';
sFormat = 'png';
sName = 'atria_rec';
%Get the full path names of all the  files in the signal directory
%aImageFileFull = fGetFileNamesOnly(sImagesPath,'*deconv00021.png');
aImageFileFull = fGetFileNamesOnly(sImagesPath,strcat('*.',sFormat));

%Initialise Imagestack to hold images
oImageStack = ImageStack();
%get the size of the images
aTempImage = imread(char(aImageFileFull(1)),sFormat);
[m n] = size(aTempImage);
clear aTempImage;
oDataStack = zeros(m,n,length(aImageFileFull),'uint8');
fprintf('Running... \n');
for k = 1:length(aImageFileFull)
    %Create image
    oImage = GetImageEntityFromFile(BaseImage,char(aImageFileFull(k)),sFormat);
    oImageStack.oImages(k) = oImage;
    oDataStack(:,:,k) = imread(char(aImageFileFull(k)),sFormat);
end
%Get current filename fileparts
[a sFileName c] = fileparts(aImageFileFull{k});
%Append .mat to the end of the filename
sFileSaveName = strcat(sSavePath,sName,'.mat');
%Print to the command window that the file is being saved
fprintf('Saving %s\n',sFileSaveName);
%Save the unemap entity
oImageStack.Save(sFileSaveName)

