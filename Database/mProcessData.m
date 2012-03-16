%This script batch processes Unemap .signal files that have been converted
%into .txt files into the .mat file database

close all;
clear all;

%Specify paths
sSignalsPath = 'H:/Data/TxtFiles/20111124';
sSavePath = 'H:/Data/Database/20111124';

%Get the full path names of all the .txt files in the signal directory
aSignalFileFull = fGetFileNamesOnly(sSignalsPath,'*.txt');
%aSignalFileFull = fGetFileNamesOnly(sSavePath,'*.mat');
fprintf('Running... \n');
for k = 1:2%length(aSignalFileFull)
    oUnemap = GetUnemapFromTXTFile(Unemap,char(aSignalFileFull(k)));
    %oUnemap = GetEntityFromMATFile(Unemap,char(aSignalFileFull(k)));
    %Get current filename fileparts
    [a sFileName c] = fileparts(aSignalFileFull{k});
    %Append .mat to the end of the filename
    sFileSaveName = strcat(sSavePath,sprintf('/%s.mat',sFileName));
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the entity
    oUnemap.Save(sFileSaveName)
end

close all;
clear all;