%This script batch processes Unemap .signal files that have been converted
%into .txt files into the .mat file database

close all;
clear all;

%Specify paths
sExperimentDate = '20111124';
sSignalsPath = 'D:/Users/jash042/Data/TxtFiles/20111124';
sSavePath = 'D:/Users/jash042/Documents/PhD/Analysis/Database/20111124';

%Add paths
addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/)'));
addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Utilities/'));

global Data Experiment;

%Get the full path names of all the .txt files in the signal directory
aSignalFileFull = fGetFileNamesOnly(sSignalsPath,'*.txt');

%Populate the Experiment object
mInitialiseExperiment;
for k = 1:2%length(aSignalFileFull)
    %Load the file contents into aFileContents array
    aFileContents = load(char(aSignalFileFull(k)));
    %Ask for input to fill Data object
    mInitialiseData;    
    %Store Potential array and time array in Data fields
    Data.Unemap.Potential.Original = aFileContents(:,2:Experiment.Unemap.NumberOfElectrodes+1);
    Data.Unemap.Time = [1:1:size(Data.Unemap.Potential.Original,1)]*(1/Experiment.Unemap.ADConversion.SamplingRate);
    %Get current filename fileparts
    [a sFileName c] = fileparts(aSignalFileFull{k});
    %Change to the save directory
    cd(sSavePath);
    %Append .mat to the end of the filename
    sFileSaveName = sprintf('%s.mat',sFileName);
    %Print to the command window that the file is being saved
    fprintf('Saving %s\n',sFileSaveName);
    %Save the file
    save(sFileSaveName, 'Data');
    
    %Clear Data
    clear Data;
      
end

%Save Experiment file
sFileSaveName = sprintf('%s_MetaData.mat',sExperimentDate);
fprintf('Saving %s_MetaData\n',sFileSaveName);
%Save the file
save(sFileSaveName, 'Experiment');
