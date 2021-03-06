 function CMOSwriter(sHeaderFile,sSavePath,cmosData,iStartFrame)
%This function writes out a series of rsd files containing the input data cmosData for use with BVAna

%Open the header file
fid=fopen(sHeaderFile,'r','b');
fstr=fread(fid,'int8=>char')';
fclose(fid);
sampind2=strfind(fstr,'msec');
sampind1=find(fstr(1:sampind2(1))==' ',1,'last');
r=str2double(fstr(sampind1+1:sampind2(1)-1));%ratio of optical and analog samle rate
% locate the Data-File-List
Dindex = find(fstr == 'D');
for i = 1:length(Dindex)
    if isequal(fstr(Dindex(i):Dindex(i)+13),'Data-File-List')
        origin = Dindex(i)+14+2; % there are two blank char between each line
        break;
    end
end

% Get the data file paths
len = length(fstr);
N = 1000;  % assume file list < 1000 files
dataPaths = cell(N,1);
pointer = origin;

seq = 0;
while origin<len
    seq = seq+1;
    pointer = origin;
    while (strcmp(fstr(pointer:pointer+3),'.rsd') || strcmp(fstr(pointer:pointer+3),'.rsm'))==0
        pointer = pointer + 1;
    end
    dataPaths{seq,1} = fstr(origin:pointer+3);%-+1
    origin = pointer+4+2;
end
dataPaths = dataPaths(1:seq);
num = length(dataPaths);
%get the file path
[pathstr,name,ext] = fileparts(sHeaderFile);

%Loop through each data file, read in the data and write out a combination
%of this and the new data from cmosData

%find the data files we need
iFileNumber = idivide(int32(iStartFrame),int32(256)) + 1;
iStartIndex = 12800*(iStartFrame - (iFileNumber-1)*256 - 1);
iDataFileNumber = iFileNumber + 1;
%Open the first file to get the data size
fpath = fullfile(pathstr,dataPaths{iDataFileNumber});
fid=fopen(fpath,'r','l');       % use little-endian format
fdata=fread(fid,'*int16')'; %
fclose(fid);
%Make copy of the data
aDataToWrite = fdata;
iNewDataIndex = iStartIndex;
cmosData = int16(cmosData);
%Loop through the frames
for n = iStartFrame:(iFileNumber)*256
    %Loop through the columns
    for i = 1:100
        aDataToWrite(iNewDataIndex+21:iNewDataIndex+120) = -cmosData(i,:,n);
        iNewDataIndex = iNewDataIndex+128;
    end
end
fpath = fullfile(sSavePath,dataPaths{iDataFileNumber});
fid = fopen(fpath,'w','l');
fwrite(fid,aDataToWrite,'int16','l');
disp(['Saving ',fpath])
fclose(fid);

iDataFileNumber = iDataFileNumber + 1;
%Open the second file to get the data size
fpath = fullfile(pathstr,dataPaths{iDataFileNumber});
fid=fopen(fpath,'r','l');       % use little-endian format
fdata=fread(fid,'*int16')'; %
fclose(fid);
%Make copy of the data
aDataToWrite = fdata;
iNewDataIndex = 0;
cmosData = int16(cmosData);
%Loop through the frames
for n = (iFileNumber)*256+1:(iFileNumber+1)*256
    %Loop through the columns
    for i = 1:100
        aDataToWrite(iNewDataIndex+21:iNewDataIndex+120) = -cmosData(i,:,n);
        iNewDataIndex = iNewDataIndex+128;
    end
end
fpath = fullfile(sSavePath,dataPaths{iDataFileNumber});
fid = fopen(fpath,'w','l');
fwrite(fid,aDataToWrite,'int16','l');
disp(['Saving ',fpath])
fclose(fid);

iDataFileNumber = iDataFileNumber + 1;
%Open the third file to get the data size
fpath = fullfile(pathstr,dataPaths{iDataFileNumber});
fid=fopen(fpath,'r','l');       % use little-endian format
fdata=fread(fid,'*int16')'; %
fclose(fid);
%Make copy of the data
aDataToWrite = fdata;
iNewDataIndex = 0;
cmosData = int16(cmosData);
%Loop through the frames
for n = (iFileNumber+1)*256+1:(iFileNumber+2)*256
    %Loop through the columns
    for i = 1:100
        aDataToWrite(iNewDataIndex+21:iNewDataIndex+120) = -cmosData(i,:,n);
        iNewDataIndex = iNewDataIndex+128;
    end
end
fpath = fullfile(sSavePath,dataPaths{iDataFileNumber});
fid = fopen(fpath,'w','l');
fwrite(fid,aDataToWrite,'int16','l');
disp(['Saving ',fpath])
fclose(fid);
end