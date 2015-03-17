function oOutData = ReadCSV(sFile)
%this function returns the data stored in a csv file in a struct called
%oOutData under column headings as fields

%scan the header information in
fid = fopen(sFile,'r');
tline = fgets(fid);
[~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%create struct
oOutData = struct(cell(numel(splitstring),1),splitstring,2);
%loop through fields
for i = 1:numel(splitstring)
    
end
