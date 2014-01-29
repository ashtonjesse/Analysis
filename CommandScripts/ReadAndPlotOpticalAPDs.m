% %Get list of files 
% %Loop through files, open and read in the header information, activation
% %times, repolarisation times and APD and close file
% %Calculate the average APD and std dev
% %plot using errorbar
clear all;
%Specify paths
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\';
sSavePath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\';
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

%loop through the list of files and read in the data
for k = 1:length(aFileFull)
    [aHeaderInfo(k) aActivationTimes(:,:,k) aRepolarisationTimes(:,:,k) aAPDs(:,:,k)] = ReadOpticalDataCSVFile(aFileFull{k},rowdim,coldim);
end
% %initialise array
aAverageAPDs = zeros(length(aFileFull),1,'double');
aAPDstd = zeros(length(aFileFull),1,'double');
% %calculate average APD
for i = 1:length(aFileFull)
    aThisAPD = double(aAPDs(:,:,i));
    aAverageAPDs(i) = mean(aThisAPD(aThisAPD>0));
    aAPDstd(i) = std(aThisAPD(aThisAPD>0));
end

figure(1);
oHandle = errorbar(aAverageAPDs,aAPDstd);
oAxes = get(oHandle,'parent');
set(get(oAxes,'xlabel'),'string','Beat #');
set(get(oAxes,'ylabel'),'string','Average APD (ms)');
set(get(oAxes,'title'), 'string', ['Average APD ' char(177) ' 1SD (ms) during Baroreflex test #3 29/10']);

figure(2);
oHandle = plot(aAPDstd);
oSDAxes = get(oHandle,'parent');
set(get(oSDAxes,'xlabel'),'string','Beat #');
set(get(oSDAxes,'ylabel'),'string','APD standard deviation (ms)');
set(get(oSDAxes,'title'), 'string', ['Standard deviation of APD during Baroreflex test #3 29/10']);