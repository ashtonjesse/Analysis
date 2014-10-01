function [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilePath,rowdim,coldim,iHeaderLines)
%This function reads the specified CSV file which contains output from
%BVAna with details of the activation time, repolarisation time and APD at
%pixels for a given beat

%Initialise the output arrays
aHeaderInfo = struct('startframe',0,'endframe',0,'BaselineRange',0,'ActivationTimeMode','half-maximal amplitude','RepolarisationMark','%');
aActivationTimes = zeros(rowdim,coldim,'double');
aRepolarisationTimes = zeros(rowdim,coldim,'double');
aAPDs = zeros(rowdim,coldim,'double');

fid = fopen(sFilePath,'r');
%scan the header information in
for i = 1:iHeaderLines;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    switch (splitstring{1})
        case 'start frm'
            aHeaderInfo.startframe = str2double(splitstring{2}) + 1;
        case 'end frm'
            aHeaderInfo.endframe = str2double(splitstring{2}) + 1;
        case 'BaseLine setting'
            aHeaderInfo.BaselineRange = cell2mat(textscan(char(splitstring{2}),' Range(%d-%d)Mean'));
            aHeaderInfo.BaselineRange = aHeaderInfo.BaselineRange + 1; %data is 0 based, matlab is 1 based.
        case 'Repolarization Time(%)'
            aHeaderInfo.RepolarisationMark = char(splitstring{2});
        case 'Start'
            [~,~,~,~,~,~,splitstring] = regexpi(tline,' ');
            aHeaderInfo.startframe = str2double(splitstring{4});
        case 'End'
            [~,~,~,~,~,~,splitstring] = regexpi(tline,' ');
            aHeaderInfo.endframe = str2double(splitstring{4});
    end
end

%Get activation times
for i = 1:rowdim;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData = str2double(splitstring);
    aActivationTimes(i,:) = aData;
end
%get and discard line
tline = fgets(fid);
if ~feof(fid)
    %Get the repolarisation times
    for i = 1:rowdim;
        tline = fgets(fid);
        [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
        aData = str2double(splitstring);
        aRepolarisationTimes(i,:) = aData;
    end
    %get and discard line
    tline = fgets(fid);
    %Get the APDs
    for i = 1:rowdim;
        tline = fgets(fid);
        [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
        aData = str2double(splitstring);
        aAPDs(i,:) = aData;
    end
end
fprintf('Got data for file %s\n',sFilePath);
fclose(fid);
end
