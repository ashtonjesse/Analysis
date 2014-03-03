% %Get list of files 
% %Loop through files, open and read in the header information, activation
% %times, repolarisation times and APD and close file
% %Put all the APDs into a big array

% clear all;
%Specify paths
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro005\APD50\';
sSavePath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro005\APD50\APDData.txt';
sFormat = 'csv';
%Get the full path names of all the  files in the directory
aFileFull = fGetFileNamesOnly(sFilesPath,strcat('*.',sFormat));
%Initialise arrays to hold info
rowdim = 100;
coldim = 101;
HeaderInfo = struct('startframe',0,'endframe',0,'ActivationTimeMode','maximal dV/dt','RepolarisationMark','%');
aHeaderInfo = repmat(HeaderInfo,length(aFileFull),1);
aActivationTimes = zeros(rowdim,coldim,length(aFileFull),'double');
aRepolarisationTimes = zeros(rowdim,coldim,length(aFileFull),'double');
aAPDs = zeros(rowdim,coldim,length(aFileFull),'double');

%open the first file to get some information about how many sites that have
%APDs
[aHeaderInfo(1) aActivationTimes(:,:,1) aRepolarisationTimes(:,:,1) aAPDs(:,:,1)] = ReadOpticalDataCSVFile(aFileFull{1},rowdim,coldim);
%initialise array to hold data for the csv file
aCurrentAPD = rot90(aAPDs(:,1:end-1,1),-1);
aDataPoints = aCurrentAPD(:,:,1) > 0;
%The row header is the row index and col index appended together (for some
%reason the row index is out by 1, hence adding 100
aRowHeader = find(aDataPoints) + 100;
aRowHeader = aRowHeader';
%convert to cell array of strings
aRowHeader = strread(num2str(aRowHeader),'%s');
aRowHeader = aRowHeader';
%Initialise array to hold loop data
aAPDDataToWrite = zeros(length(aFileFull),length(aRowHeader),'double');
%Select just the data that belongs to a recording point
aAPDDataToWrite(1,:) = aCurrentAPD(aDataPoints);
%loop through the list of files and read in the data
for k = 2:length(aFileFull)
    [aHeaderInfo(k) aActivationTimes(:,:,k) aRepolarisationTimes(:,:,k) aAPDs(:,:,k)] = ReadOpticalDataCSVFile(aFileFull{k},rowdim,coldim);
    aCurrentAPD = rot90(aAPDs(:,1:end-1,k),-1);
    aAPDDataToWrite(k,:) = aCurrentAPD(aDataPoints);
end

%Export the APD data

DataHelper.ExportDataToTextFile(sSavePath,aRowHeader,aAPDDataToWrite);