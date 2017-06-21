function oCSVFile = ReadCSV(sFile)
%this function returns the data stored in a csv file 

%scan the header information in
fid = fopen(sFile,'r');
tline = fgets(fid);
[~,~,~,~,~,~,splitstring] = regexpi(tline,',');
fclose(fid);
oCSVFile = struct();
oCSVFile.aHeader = strtrim(splitstring);
oCSVFile.aData = dlmread(sFile,',',1,0);
