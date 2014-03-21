%rearrange electrodes from a previous config file to the current list
clear all;
%read in unemap files
oOldUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130221\0221baro001\old\pabarotest_1755_unemap.mat');
oNewUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro004\pbaro004_unemap.mat');

%Create a copy of the old electrodes array
oOldElectrodes = oOldUnemap.Electrodes;

%get the names of the old electrodes
oNewNames = {oNewUnemap.Electrodes(:).Name};
%loop through the old electrodes
for i = 1:length(oOldUnemap.Electrodes)
    %find the electrode with the name of the current old electrode
    Indices = strcmp(oOldUnemap.Electrodes(i).Name, oNewNames);
    oOldElectrodes(Indices) = oOldUnemap.Electrodes(i);
end
%update location info
for i = 1:length(oOldElectrodes)
    oOldElectrodes(i).Coords = oNewUnemap.Electrodes(i).Coords;
    oOldElectrodes(i).Location = oNewUnemap.Electrodes(i).Location;
end

%save to new file
oOldUnemap.Electrodes = [];
oOldUnemap.Electrodes = oOldElectrodes;
oOldUnemap.Save('G:\PhD\Experiments\Auckland\InSituPrep\20130221\0221baro001\pbaro001_unemap.mat');