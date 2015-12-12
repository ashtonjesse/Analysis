function [aHeader aData] = ReadCSV(sFile)
%this function returns the data stored in a csv file 

%scan the header information in
fid = fopen(sFile,'r');
tline = fgets(fid);
[~,~,~,~,~,~,splitstring] = regexpi(tline,',');
fclose(fid);
%loop through fields
aHeader = strtrim(splitstring);
aData = dlmread(sFile, ',', 1, 0);

