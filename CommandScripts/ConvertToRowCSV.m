%this script converts a csv with data in columns to data in rows
clear all;
%load in the csv
oFile = ReadCSV('V:\baro\aPhaseDataTable.csv');
APA = reshape(oFile.aData(:,3:end),size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Experiment = str2double(repmat(oFile.aHeader(3:end),size(oFile.aData,1),1));
Experiment = reshape(Experiment,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Cycle = repmat(oFile.aData(:,1),1,size(oFile.aData,2)-2);
Cycle = reshape(Cycle,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Region = repmat(oFile.aData(:,2),1,size(oFile.aData,2)-2);
Region = reshape(Region,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Atropine = zeros(size(APA,1),1);
aDataToWrite = horzcat(Experiment,Region,Atropine,Cycle,APA);
dlmwrite('V:\baro\aPhaseDataRows.csv',aDataToWrite,'precision',8);

oFile = ReadCSV('V:\baro\aPhaseDataTableAtropine.csv');
APA = reshape(oFile.aData(:,3:end),size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Experiment = str2double(repmat(oFile.aHeader(3:end),size(oFile.aData,1),1));
Experiment = reshape(Experiment,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Cycle = repmat(oFile.aData(:,1),1,size(oFile.aData,2)-2);
Cycle = reshape(Cycle,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Region = repmat(oFile.aData(:,2),1,size(oFile.aData,2)-2);
Region = reshape(Region,size(oFile.aData,1)*(size(oFile.aData,2)-2),1);
Atropine = ones(size(APA,1),1);
aDataToWrite = horzcat(Experiment,Region,Atropine,Cycle,APA);
dlmwrite('V:\baro\aPhaseDataRows.csv',aDataToWrite,'-append','precision',8);
