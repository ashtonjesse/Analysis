%This script loads an a sequence of images from the VasEx package into entities and saves these

%load saved mat file
sPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\1to89to12\';
sMatFilePath = strcat(sPath,'1to89to12Step4.mat');
load(sMatFilePath);
%Specify paths

aNames = {'imvolffs','imvolffl','imvolffsBW','imvolfflBW','imvolffBW'};
for i = 1:length(aNames)
    sName = char(aNames{i});
    sFilePath = strcat(sPath,sName,'.mat');
    save(sFilePath,sName);
    
    oImageStack = GetImageStackFromDataFile(ImageStack, sFilePath, sName);
    
    %Append .mat to the end of the filename
    sFileSaveName = strcat(sPath,sName,'_stack.mat');
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the unemap entity
    oImageStack.Save(sFileSaveName)
    
end

close all;
clear all;