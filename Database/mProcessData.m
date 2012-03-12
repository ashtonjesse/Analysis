%This script batch processes Unemap .signal files that have been converted
%into .txt files into the .mat file database

close all;
clear all;

%Specify paths
sSignalsPath = 'H:/Data/TxtFiles/20111124';
sSavePath = 'H:/Data/Database/20111124';

%Add paths
addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/'));

%Get the full path names of all the .txt files in the signal directory
%aSignalFileFull = fGetFileNamesOnly(sSignalsPath,'*.txt');
aSignalFileFull = fGetFileNamesOnly(sSavePath,'*.mat');

for k = 1:2%length(aSignalFileFull)
    %oPotentialModel = GetEntityFromTXTFile(PotentialModel,char(aSignalFileFull(k)));
    oPotentialModel = GetEntityFromMATFile(PotentialModel,char(aSignalFileFull(k)));
    %Get current filename fileparts
    [a sFileName c] = fileparts(aSignalFileFull{k});
    %Append .mat to the end of the filename
    sFileSaveName = strcat(sSavePath,sprintf('/%s.mat',sFileName));
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the entity
    oPotentialModel.Save(sFileSaveName)
end