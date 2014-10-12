close all;
% clear all;
% %% load the signal data
% [sFileName,sPathName]=uigetfile('*.*','Select file(s) that contain optical transmembrane recordings','multiselect','on');
% if iscell(sFileName)
%     % % Make sure the dialogs return char objects
%     if (isempty(sFileName) && ~ischar(sPathName))
%         break
%     end
%     aOAP = [];
%     
%     for i = 1:length(sFileName)
%         sLongDataFileName=strcat(sPathName,char(sFileName{i}));
%         %check the extension
%         [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
%         if strcmpi(ext,'.csv')
%             %read the data and save
%             aThisOAP = ReadOpticalTimeDataCSVFile(sLongDataFileName,6);
%             aOAP = [aOAP aThisOAP];
%             save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
%             fprintf('Opened and saved %s\n',sLongDataFileName);
%         elseif strcmpi(ext,'.mat')
%             %load the .mat file
%             load(sLongDataFileName);
%             aOAP = [aOAP aThisOAP];
%             fprintf('Loaded %s\n',sLongDataFileName);
%         end
%     end
%     iNumFiles = length(sFileName);
% else
%     % % Make sure the dialogs return char objects
%     if (~ischar(sFileName) && ~ischar(sPathName))
%         break
%     end
%     sLongDataFileName=strcat(sPathName,char(sFileName));
%     %check the extension
%     [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
%     if strcmpi(ext,'.csv')
%         %read the data and save
%         aThisOAP = ReadOpticalTimeDataCSVFile(sLongDataFileName,6);
%         aOAP = aThisOAP;
%         save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
%         fprintf('Opened and saved %s\n',sLongDataFileName);
%     elseif strcmpi(ext,'.mat')
%         %load the .mat file
%         load(sLongDataFileName);
%         aOAP = aThisOAP;
%         fprintf('Loaded %s\n',sLongDataFileName);
%     end
%     iNumFiles = 1;
% end
% 
% %% load the beat data
% [sBeatFileName,sBeatPathName]=uigetfile('*.*','Select CSV file(s) that contain optical beat data','multiselect','on');
% % %Make sure the dialogs return char objects
% rowdim = 42;
% coldim = 41;
% if iscell(sBeatFileName)
%     %Make sure the dialogs return char objects
%     if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
%         break
%     end
%     %intialise arrays to hold beat information
%    
%     aAllActivationTimes = zeros(rowdim,coldim,length(sBeatFileName));
%     aAllRepolarisationTimes = zeros(rowdim,coldim,length(sBeatFileName));
%     aAllAPDs = zeros(rowdim,coldim,length(sBeatFileName));
%     %get the beat data
%     for i = 1:length(sBeatFileName)
%         sLongDataFileName=strcat(sBeatPathName,char(sBeatFileName{i}));
%         [aHeaderInfo aAllActivationTimes(:,:,i) aAllRepolarisationTimes(:,:,i) aAllAPDs(:,:,i)] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
%     end
% else
%     if (~ischar(sBeatFileName) && ~ischar(sBeatPathName))
%         break
%     end
%     %get the beat data
%     [aHeaderInfo aAllActivationTimes aAllRepolarisationTimes aAllAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),rowdim,coldim,7);
% end

%% Find new activation times

% % initialise variables
aNewActivationTimes = zeros(size(aAllActivationTimes));

for i = 1:iNumFiles
    % %     loop through the locations in this data
    j = 1;
    while j <= size(aOAP(i).Locations,2)
        % %         get current location info
        dRowLoc = aOAP(i).Locations(2,j)+1;%Data is 0-based, Matlab is 1-based so have to add 1
        dYLoc = aOAP(i).Locations(2,j);
        dColLoc = aOAP(i).Locations(1,j)+1;%Data is 0-based, Matlab is 1-based so have to add 1
        dXLoc = aOAP(i).Locations(1,j);
        aData = -aOAP(i).Data(1:end-1,j);%-1 to make it even for periodogram calculation
                
        % %         Get array subsets
        aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
        %normalise AP
        aThisData = aSubData - min(aSubData);
        aThisData = aThisData / (max(aSubData) - min(aSubData));
        aThisSlope = fCalculateMovingSlope(aThisData,5,3);
        aThisCurvature = fCalculateMovingSlope(aThisSlope,5,3);
        %%remove end segments as these could have errors
        aThisSlope(1:5) = 0;
        aThisSlope(end-5:end) = 0;
        aThisCurvature(1:5) = 0;
        aThisCurvature(end-5:end) = 0;
        
        % %         find peaks and locations of the slope
        [aSlopePeaks, aSlopeLocations] = fFindPeaks(aThisSlope);
        % %         get the value and location of the maximum
        [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
        aNewActivationTimes(dRowLoc, dColLoc,i) = aSlopeLocations(iMaxSlopeIndex) + aHeaderInfo.startframe - 1; %indices that match the format of aActivationTimes
        %%save location
        j = j + 1;
    end
end
%% plot AT maps
for i = 1:iNumFiles
    %get the map name
    if iscell(sBeatFileName)
        sMapName = char(sBeatFileName{i});
    else
        sMapName = char(sBeatFileName);
    end
    %plot the original map
    PlotActivation(aAllActivationTimes(:,:,i),sprintf('Old%s',sMapName),[],[]);
    %plot the new map
    PlotActivation(aNewActivationTimes(:,:,i),sprintf('New%s',sMapName),[],[]);
end
