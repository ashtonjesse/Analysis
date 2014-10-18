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

%% load the beat data
% [sBeatFileName,sBeatPathName]=uigetfile('*.*','Select CSV file(s) that contain optical beat data','multiselect','on');
sBeatFileName = {'20140821baro004g10LP100HzAT50Apd30_48.csv','20140821baro002g10LP100HzAT50Apd30_40.csv'};
sBeatPathName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\APD30\';
% %Make sure the dialogs return char objects
rowdim = 42;
coldim = 41;
if iscell(sBeatFileName)
    %Make sure the dialogs return char objects
    if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %intialise arrays to hold beat information
   
    aAllActivationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllRepolarisationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllAPDs = zeros(rowdim,coldim,length(sBeatFileName));
    aHeaderInfoStruct = [];
    %get the beat data
    for i = 1:length(sBeatFileName)
        sLongDataFileName=strcat(sBeatPathName,char(sBeatFileName{i}));
        [aHeaderInfo aAllActivationTimes(:,:,i) aAllRepolarisationTimes(:,:,i) aAllAPDs(:,:,i)] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
        aHeaderInfoStruct = [aHeaderInfoStruct aHeaderInfo];
    end
    aHeaderInfo = aHeaderInfoStruct;
else
    if (~ischar(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %get the beat data
    [aHeaderInfo aAllActivationTimes aAllRepolarisationTimes aAllAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),rowdim,coldim,7);
end

%% Plot SAOP locations
%initialise variables
iSamplingFreq = 779.76;
aATs = cell(size(aAllActivationTimes,3),1);
aPaceSettersToPlot = cell(iNumFiles,1);
aLocationsToPlot = cell(iNumFiles,1);
aAllData = cell(iNumFiles,1);
aAllSlope = cell(iNumFiles,1);
aAllCurvature = cell(iNumFiles,1);
aATs = cell(size(aAllActivationTimes,3),1);
aCount = ones(iNumFiles,1);
for i = 1:iNumFiles
    
    %initialise variables
    aLocationsToPlot{i} = zeros(3,size(aOAP(i).Locations,2));
    aAllData{i} = zeros(length(aHeaderInfo(i).startframe:aHeaderInfo(i).endframe),size(aOAP(i).Locations,2));
    aAllSlope{i} = zeros(length(aHeaderInfo(i).startframe:aHeaderInfo(i).endframe),size(aOAP(i).Locations,2));
    aAllCurvature{i} = zeros(length(aHeaderInfo(i).startframe:aHeaderInfo(i).endframe),size(aOAP(i).Locations,2));
    
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
        aSubData = aData(aHeaderInfo(i).startframe:aHeaderInfo(i).endframe);
        aThisData = aSubData - min(aSubData);
        aThisData = aThisData / (max(aSubData) - min(aSubData));
        aThisSlope = fCalculateMovingSlope(aThisData,5,3);
        aThisCurvature = fCalculateMovingSlope(aThisSlope,5,3);
        aThisSlope(1:5) = 0;
        aThisSlope(end-5:end) = 0;
        aThisCurvature(1:5) = 0;
        aThisCurvature(end-5:end) = 0;
        
        % %         find peaks and locations of the slope
        [aSlopePeaks, aSlopeLocations] = fFindPeaks(aThisSlope);
        % %         get the value and location of the maximum
        [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
        %find peaks and locations of the curvature
        [aCurvaturePeaks, aCurvatureLocations] = fFindPeaks(aThisCurvature);
        %get the value and location of the curvature
        [dMaxCurvaturePeak iMaxCurvatureIndex] = max(aCurvaturePeaks);
        %Get the boolean results to test whether there is a curvature peak between
        %the max slope peak and the slope peak following this one
        
        dCurrentAT = aAllActivationTimes(dRowLoc, dColLoc,i) - aHeaderInfo(i).startframe + 2;
        %make sure max slope has a peak in the slope after it (so isnt the
        %last one...
        if iMaxSlopeIndex < numel(aSlopeLocations)
            bResult1 = aCurvatureLocations > aSlopeLocations(iMaxSlopeIndex);
            bResult2 = aCurvatureLocations < aSlopeLocations(iMaxSlopeIndex+1);
            bResult = and(bResult1,bResult2);
            if length(find(bResult)) == 1
                if aCurvaturePeaks(bResult) > 0.012
                    if aSlopePeaks(iMaxSlopeIndex) > 0.08 && (dCurrentAT - aSlopeLocations(iMaxSlopeIndex)) > 0 && ...
                            abs(dCurrentAT- aSlopeLocations(iMaxSlopeIndex+1)) < 6
                        % save details of this location
                        aLocationsToPlot{i}(:,aCount(i)) = [dRowLoc ; dColLoc ; 1];
                        aAllData{i}(:,aCount(i)) = aThisData;
                        aAllSlope{i}(:,aCount(i)) = aThisSlope;
                        aAllCurvature{i}(:,aCount(i)) = aThisCurvature;
                        aCount(i) = aCount(i) + 1;
                    end
                end
            end
        end
        j = j + 1;
    end
    aCount(i) = aCount(i) - 1;
end

%create array to hold subplot figure handles
aSubplotFigures = cell(iNumFiles,1);

%loop through files and plot data
for m = 1:iNumFiles
    %drop unnecessary zeros
    aAllData{m} = aAllData{m}(:,1:aCount(m));
    aAllSlope{m} = aAllSlope{m}(:,1:aCount(m));
    aAllCurvature{m} = aAllCurvature{m}(:,1:aCount(m));
    aLocationsToPlot{m} = aLocationsToPlot{m}(:,1:aCount(m));
    %create new figure and subplot panel
    iPlotsPerFigure = 10;
    iNumFigures = ceil((aCount(m)) / iPlotsPerFigure);
    aSubplotFigures{m} = zeros(iNumFigures,1);
    aPanels = cell(iNumFigures,1);
    for n = 1:iNumFigures
        aSubplotFigures{m}(n) = figure();
        aPanels{m} = panel(aSubplotFigures{m}(n),'no-manage-font');
        %select the subplot panel
        oPanel = aPanels{m};
        oPanel.pack(iPlotsPerFigure,1);
        %loop through the locations
        for p = 1:iPlotsPerFigure
            iIndex = (n - 1)*iPlotsPerFigure + p;
            %check if we are at the end of the locations
            if iIndex > aCount(m)
                break;
            end
            %create axes for data, slope and curvature
            oDataAxes = axes(); 
            oSlopeAxes = axes(); 
            oCurvatureAxes = axes();
            %select the dataaxes and plot
            oPanel(p,1).select([oDataAxes oSlopeAxes oCurvatureAxes]);
            aTime = (0:length(aAllData{m}(:,iIndex))-1)*(1/iSamplingFreq)*1000;
            plot(oDataAxes,aTime,aAllData{m}(:,iIndex),'k');
            axis(oDataAxes, [0 max(aTime) 0 1]);
            aXticklabel = get(oDataAxes,'xticklabel');
            set(oDataAxes,'xticklabel',[]);
            set(oDataAxes,'ytick',[]);
            set(oDataAxes,'fontunits','points');
            set(oDataAxes,'fontsize',8);
            ylabel(oDataAxes,sprintf('%d%d',aLocationsToPlot{m}(2,iIndex)-1,aLocationsToPlot{m}(1,iIndex)-1));
            %plot into slope axes
            plot(oSlopeAxes,aTime,aAllSlope{m}(:,iIndex),'r');
            axis(oSlopeAxes, [0 max(aTime) -0.3 0.3]);
            hold(oSlopeAxes,'on');
            % %         find peaks and locations of the slope
            [aSlopePeaks, aSlopeLocations] = fFindPeaks(aAllSlope{m}(:,iIndex));
            % %         get the value and location of the maximum
            [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
            line([aTime(aSlopeLocations(iMaxSlopeIndex)) aTime(aSlopeLocations(iMaxSlopeIndex))],...
                [-0.3 0.3],'color','r','parent',oSlopeAxes);
            hold(oSlopeAxes,'off');
            set(oSlopeAxes,'color','none');
            set(oSlopeAxes,'xtick',[]);
            set(oSlopeAxes,'ytick',[]);
            %plot into curvature axes
            plot(oCurvatureAxes,aTime,aAllCurvature{m}(:,iIndex),'b');
            axis(oCurvatureAxes, [0 max(aTime) -0.2 0.2]);
            set(oCurvatureAxes,'color','none');
            set(oCurvatureAxes,'xtick',[]);
            set(oCurvatureAxes,'ytick',[]);
            %             %find peaks and locations of the curvature
            %             [aCurvaturePeaks, aCurvatureLocations] = fFindPeaks(aThisCurvature);
            %             %get the value and location of the curvature
            %             [dMaxCurvaturePeak iMaxCurvatureIndex] = max(aCurvaturePeaks);
            oPanel.de.margin = 0;
        end
        set(oDataAxes,'xticklabel',aXticklabel);
        set(get(oDataAxes,'xlabel'),'string','Times (ms)');
        set(get(oDataAxes,'xlabel'),'fontunits','points');
        set(get(oDataAxes,'xlabel'),'fontsize',8);
    end
end

%% load the beat data
% [sBeatFileName,sBeatPathName]=uigetfile('*.*','Select CSV file(s) that contain optical beat data','multiselect','on');
sBeatFileName = {'20140821baro004g10LP100HzdVdtMaxApd30_48.csv','20140821baro002g10LP100HzdVdtMaxApd30_40.csv'};
sBeatPathName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\APD30\';
% %Make sure the dialogs return char objects
rowdim = 42;
coldim = 41;
if iscell(sBeatFileName)
    %Make sure the dialogs return char objects
    if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %intialise arrays to hold beat information
   
    aAllActivationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllRepolarisationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllAPDs = zeros(rowdim,coldim,length(sBeatFileName));
    aHeaderInfoStruct = [];
    %get the beat data
    for i = 1:length(sBeatFileName)
        sLongDataFileName=strcat(sBeatPathName,char(sBeatFileName{i}));
        [aHeaderInfo aAllActivationTimes(:,:,i) aAllRepolarisationTimes(:,:,i) aAllAPDs(:,:,i)] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
        aHeaderInfoStruct = [aHeaderInfoStruct aHeaderInfo];
    end
    aHeaderInfo = aHeaderInfoStruct;
else
    if (~ischar(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %get the beat data
    [aHeaderInfo aAllActivationTimes aAllRepolarisationTimes aAllAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),rowdim,coldim,7);
end

%% plot AT maps
for i = 1:iNumFiles
    aActivationTimes =  aAllActivationTimes(:,:,i);
    aATPoints = aActivationTimes > 0;
    AT = aActivationTimes(aATPoints);
    AT(AT < 1) = NaN;
    % %     normalise the ATs to first activation
    [C I] = min(AT);
    AT = single(AT - AT(I));
    AT = double(AT);
    aATs{i} = AT';
    aPaceSettersToPlot{i} = [aOAP(i).Locations(2,AT == 0)+1 ; aOAP(i).Locations(1,AT == 0)+1];
    %get the map name
    if iscell(sBeatFileName)
        sMapName = char(sBeatFileName{i});
    else
        sMapName = char(sBeatFileName);
    end
    %plot the original map
    PlotActivation(aAllActivationTimes(:,:,i),sprintf('%s',sMapName),aPaceSettersToPlot{i},aLocationsToPlot{i});
end
