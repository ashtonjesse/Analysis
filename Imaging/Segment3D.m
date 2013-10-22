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
oData = oImageStack.oImages(:);

%Find connected components
% CC = bwconncomp(oImageStack.oImages(100).ThresholdedImage.Data,26);