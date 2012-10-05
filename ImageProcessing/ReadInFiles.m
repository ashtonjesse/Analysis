%This script loads an image or image sequence into entities and saves these

close all;
clear all;

%Specify paths
sImagesPath = 'D:\Users\jash042\Documents\PhD\Experiments\Immuno\20120706\Series007Processed\iso007\';
% sSavePath = 'H:/Data/Database/20111124';
sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120706\';
sFormat = 'png';
sName = 'Series007Iso';
%Get the full path names of all the  files in the signal directory
%aImageFileFull = fGetFileNamesOnly(sImagesPath,'*deconv00021.png');
aImageFileFull = fGetFileNamesOnly(sImagesPath,strcat('*.',sFormat));

%Initialise Imagestack to hold images
oImageStack = ImageStack();
fprintf('Running... \n');
for k = 1:length(aImageFileFull)
    %Create image
    oImage = GetImageEntityFromFile(BaseImage,char(aImageFileFull(k)),sFormat);
    oImageStack.oImages(k) = oImage;
end
%Get current filename fileparts
[a sFileName c] = fileparts(aImageFileFull{k});
%Append .mat to the end of the filename
sFileSaveName = strcat(sSavePath,sName,'.mat');
%Print to the command window that the file is being saved
fprintf('Saving %s\n',sFileSaveName);
%Save the unemap entity
oImageStack.Save(sFileSaveName)

close all;
clear all;