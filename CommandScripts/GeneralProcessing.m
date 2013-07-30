clear all;

disp('loading unemap...');
oUnemap = ...
GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130724\baroreflex003\pabaroreflex003_unemap_1.mat');
disp('done loading');

for i = 1:length(oUnemap.Electrodes)
    oUnemap.Electrodes(i).Location = [oUnemap.Electrodes(i).Location(2) ; oUnemap.Electrodes(i).Location(1)];
%     switch (oUnemap.Electrodes(i).Name)
%         case {'22-20','23-01','23-06','23-11','23-16','23-21','24-02','24-07','24-12','24-17','24-22','25-03','25-08','25-13','25-18','25-23','26-04','26-09','26-14'}
%             if isfield(oUnemap.Electrodes(i),'SignalEvent')
%                 oUnemap.Electrodes(i).SignalEvent = oUnemap.Electrodes(i+5).SignalEvent;
%             end
%             oUnemap.Electrodes(i).Potential = oUnemap.Electrodes(i+5).Potential;
%             if isfield(oUnemap.Electrodes(i),'Processed')
%                 oUnemap.Electrodes(i).Processed = oUnemap.Electrodes(i+5).Processed;
%             end
%         case {'26-19','12-23','13-04'}
%             oUnemap.Electrodes(i).Accepted = 0;
%     end
end

%Call built-in file dialog to select filename
[sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the unemap .mat file');
%Make sure the dialogs return char objects
if (~ischar(sDataFileName))
    return
end

%Get the full file name
sLongDataFileName=strcat(sDataPathName,sDataFileName);

%Save
oUnemap.Save(sLongDataFileName);