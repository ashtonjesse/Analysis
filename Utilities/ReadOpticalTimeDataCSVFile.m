function aOAP = ReadOpticalTimeDataCSVFile(sFilePath,iHeaderLines)
%This function reads the specified CSV file which contains output from
%BVAna with details of the activation time, repolarisation time and APD at
%pixels for a given beat

%Initialise the output arrays
aHeaderInfo = struct('frm_num',0,'ROI',0);

fid = fopen(sFilePath,'r');
%scan the header information in
for i = 1:iHeaderLines;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    switch (splitstring{1})
        case 'frm_num'
            aHeaderInfo.(char(splitstring{1})) = str2double(splitstring{2});
        case '[ROI 1]'
            [~,~,~,~,~,~,splitstring] = regexpi(splitstring{2},'p');
            aHeaderInfo.ROI = str2double(splitstring{1});
    end
end
%Initialise output variable
aOAP = struct('HeaderInfo',aHeaderInfo,'Locations',zeros(2,aHeaderInfo.ROI),'Data',zeros(aHeaderInfo.frm_num,aHeaderInfo.ROI));
%Get the pixel locations
tline = fgets(fid);
[~,~,~,~,~,~,splitstring] = regexpi(tline,',');
for i = 2:length(splitstring)-1
    sPixel = regexprep(char(splitstring{i}),'[','');
    [~,~,~,~,~,~,sPixel] = regexpi(sPixel,']');
    aOAP.Locations(1,i-1) = str2double(sPixel{2}); 
    aOAP.Locations(2,i-1) = str2double(sPixel{1}); 
end
%get and discard line
tline = fgets(fid);

iLineCount = 1;
while ~feof(fid)
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    if length(splitstring) > 1
        aData = str2double(splitstring);
        aOAP.Data(iLineCount,:) = aData(2:end-1);
    end
    iLineCount = iLineCount + 1;
end
fprintf('Got data for file %s\n',sFilePath);
fclose(fid);
end
