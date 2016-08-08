function oCSVFile = ReadCSV(sFile,sFormat)
%this function returns the data stored in a csv file 

%scan the header information in
fid = fopen(sFile,'r');
tline = fgets(fid);
[~,~,~,~,~,~,splitstring] = regexpi(tline,',');

oCSVFile = struct();
oCSVFile.aHeader = strtrim(splitstring);
oCSVFile.aData = textscan(fid,sFormat);
fclose(fid);
