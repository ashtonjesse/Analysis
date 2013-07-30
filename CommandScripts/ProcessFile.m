%This script batch processes Unemap .signal files that have been converted
%into .txt files into the .mat file database

close all;
clear all;

%Specify paths
sFile = 'D:\Users\jash042\Documents\PhD\Experiments\ElectrodeArray\Array_20130429_layout.cnfg';
sOutFile = 'D:\Users\jash042\Documents\PhD\Experiments\ElectrodeArray\Array_20130429_layout_locations.cnfg';
fid = fopen(sFile);
fout = fopen(sOutFile, 'w');
%Get and discard the first 2 lines
tline1 = fgets(fid);
fprintf(fout,'%s',tline1);
tline2 = fgets(fid);
fprintf(fout,'%s',tline2);
tline = fgets(fid);
%Loop while there are new lines
yloc = 19;
xloc = 1;
while ischar(tline)
    fprintf(fout,'%s',tline);
    %Split the current line on the :
    [~,~,~,~,~,~,splitstring] = regexpi(tline,':');
    %Trim any white space off the split strings
    sField = strtrim(char(splitstring(1,1)));
    oValue  = strtrim(char(splitstring(1,2)));
    if strcmpi(sField,'position')
        yloc = yloc - 1;
        if yloc < 1
            yloc = 18;
            xloc = xloc + 1;
            if xloc > 16
                xloc = 1;
            end
        end
        sPrintString = strcat({'location: x = '},sprintf('%d',xloc),{', y = '},sprintf('%d',yloc));
        fprintf(fout,'%s\n',char(sPrintString));
    end
    tline = fgets(fid);
end
fclose(fid);
fclose(fout);
close all;
clear all;