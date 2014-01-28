function [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilePath,rowdim,coldim)
%This function reads the specified CSV file which contains output from
%BVAna with details of the activation time, repolarisation time and APD at
%pixels for a given beat

%Initialise the output arrays
aHeaderInfo = struct('startframe',0,'endframe',0,'ActivationTimeMode','maximal dV/dt','RepolarisationMark','%');
aActivationTimes = zeros(rowdim,coldim,'int16');
aRepolarisationTimes = zeros(rowdim,coldim,'int16');
aAPDs = zeros(rowdim,coldim,'int16');

fid = fopen(sFilePath,'r');
%scan the header information in
for i = 1:7;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    switch (splitstring{1})
        case 'start frm'
            aHeaderInfo.startframe = str2double(splitstring{2});
        case 'end frm'
            aHeaderInfo.endframe = str2double(splitstring{2});
        case 'Repolarization Time(%)'
            aHeaderInfo.RepolarisationMark = char(splitstring{2});
    end
end

%Get activation times
for i = 1:rowdim;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData = str2double(splitstring);
    aActivationTimes(i,:,k) = aData;
end
%get and discard line
tline = fgets(fid);
%Get the repolarisation times
for i = 1:rowdim;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData = str2double(splitstring);
    aRepolarisationTimes(i,:,k) = aData;
end
%get and discard line
tline = fgets(fid);
%Get the APDs
for i = 1:rowdim;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData = str2double(splitstring);
    aAPDs(i,:,k) = aData;
end
[pathstr, name, ext, versn] = fileparts(aFileFull{k});
fprintf('Got data for file %s\n',name);
fclose(fid);

end
