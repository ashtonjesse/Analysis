%This script batch processes Unemap .signal files that have been converted
%into .txt files into the .mat file database

close all;
clear all;

%Specify paths
sSignalsPath = 'D:\Users\jash042\Documents\PhD\Data\';
% sSavePath = 'H:/Data/Database/20111124';
sSavePath = 'D:/Users/jash042/Documents/PhD/Analysis/Database/20111124/';


%Get the full path names of all the .txt files in the signal directory
aSignalFileFull = fGetFileNamesOnly(sSignalsPath,'1408.txt');
%aSignalFileFull = fGetFileNamesOnly(sSavePath,'*.mat');
fprintf('Running... \n');
for k = 1:1%length(aSignalFileFull)
    oUnemap = GetUnemapFromTXTFile(Unemap,char(aSignalFileFull(k)));
    oECG = GetECGFromTXTFile(ECG,char(aSignalFileFull(k)));
    %Get current filename fileparts
    [a sFileName c] = fileparts(aSignalFileFull{k});
    %Append _unemap.mat to the end of the filename
    sFileSaveName = strcat(sSavePath,sprintf('%s_unemap.mat',sFileName));
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the unemap entity
    oUnemap.Save(sFileSaveName)
    %Append _ecg.mat to the end of the filename
    sFileSaveName = strcat(sSavePath,sprintf('%s_ecg.mat',sFileName));
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the ECG entity
    oECG.Save(sFileSaveName);
end

close all;
clear all;