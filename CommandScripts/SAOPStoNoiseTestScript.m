clear all;
close all;
% % % %Read in the file containing all the optical data 
[sFileName,sPathName]=uigetfile('*.*','Select a file that contain optical transmembrane recordings');
sFileName = strcat(sPathName,sFileName);
% % Make sure the dialogs return char objects
if (isempty(sFileName) && ~ischar(sFileName))
    break
end
%check the extension
[pathstr, name, ext, versn] = fileparts(sFileName);
if strcmpi(ext,'.csv')
    aOAP = ReadOpticalTimeDataCSVFile(sFileName,6);
elseif strcmpi(ext,'.mat')
    load(sFileName);
end

%load the beat data because at first I want the baseline range as defined
%by this file
[sBeatFileName,sBeatPathName]=uigetfile('*.*','Select a CSV files that contain optical beat data');
%Make sure the dialogs return char objects
if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
    break
end
% %Get the beat information
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),40,41,7);

aSignaltoNoise = zeros(size(aOAP.Locations,2),1);
%loop through the locations in this data and adjust the activation times
for i = 1:length(aOAP.Locations(1,:))
    %get current location info
    dRowLoc = aOAP.Locations(1,i)+1;%Data is 0-based, Matlab is 1-based so have to add 1
    dYLoc = aOAP.Locations(1,i);
    dColLoc = aOAP.Locations(2,i)+1;
    dXLoc = aOAP.Locations(2,i);
    aData = -aOAP.Data(:,i);
        
    % %Replace arrays with subsets
    aThisData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
    
    %Calculate S/N
    dBaselineValue = mean(aData(aHeaderInfo.BaselineRange(1):aHeaderInfo.BaselineRange(2)));
    dNoise = std(aData(aHeaderInfo.BaselineRange(1):aHeaderInfo.BaselineRange(2)));
    dOAPA = max(aThisData) - dBaselineValue;
    aSignaltoNoise(i) = dOAPA/dNoise;
    
end
%rotate for display purposes
dSignaltoNoise = mean(aSignaltoNoise)
