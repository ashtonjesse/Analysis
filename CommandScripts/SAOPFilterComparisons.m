close all;
clear all;
%% load the signal data
[sFileName,sPathName]=uigetfile('*.*','Select file(s) that contain optical transmembrane recordings','multiselect','on');
if iscell(sFileName)
    % % Make sure the dialogs return char objects
    if (isempty(sFileName) && ~ischar(sPathName))
        break
    end
    aOAP = [];
    %remap file indices
    sFiles = cell(size(sFileName));
    sFiles{1} = sFileName{5};
    sFiles{2} = sFileName{4};
    sFiles{3} = sFileName{1};
    sFiles{4} = sFileName{2};
    sFiles{5} = sFileName{3};
    sFiles{6} = sFileName{9};
    sFiles{7} = sFileName{6};
    sFiles{8} = sFileName{7};
    sFiles{9} = sFileName{8};
    %     sFiles{1} = sFileName{3};
    %     sFiles{2} = sFileName{8};
    %     sFiles{3} = sFileName{7};
    %     sFiles{4} = sFileName{6};
    %     sFiles{5} = sFileName{5};
    %     sFiles{6} = sFileName{4};
    %     sFiles{7} = sFileName{2};
    %     sFiles{8} = sFileName{1};
    sFileName = sFiles;
    for i = 1:length(sFileName)
        sLongDataFileName=strcat(sPathName,char(sFileName{i}));
        %check the extension
        [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
        if strcmpi(ext,'.csv')
            %read the data and save
            aThisOAP = ReadOpticalTimeDataCSVFile(sLongDataFileName,6);
            aOAP = [aOAP aThisOAP];
            save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
            fprintf('Opened and saved %s\n',sLongDataFileName);
        elseif strcmpi(ext,'.mat')
            %load the .mat file
            load(sLongDataFileName);
            aOAP = [aOAP aThisOAP];
            fprintf('Loaded %s\n',sLongDataFileName);
        end
    end
    
end
%% load the beat data
[sBeatFileName,sBeatPathName]=uigetfile('*.*','Select CSV file(s) that contain optical beat data','multiselect','on');
% %Make sure the dialogs return char objects

if iscell(sBeatFileName)
    %Make sure the dialogs return char objects
    if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %remap file indices
    sFiles = cell(size(sBeatFileName));
    sFiles{1} = sBeatFileName{5};
    sFiles{2} = sBeatFileName{4};
    sFiles{3} = sBeatFileName{1};
    sFiles{4} = sBeatFileName{2};
    sFiles{5} = sBeatFileName{3};
    sFiles{6} = sBeatFileName{9};
    sFiles{7} = sBeatFileName{6};
    sFiles{8} = sBeatFileName{7};
    sFiles{9} = sBeatFileName{8};
    %     sFiles{1} = sBeatFileName{3};
    %     sFiles{2} = sBeatFileName{8};
    %     sFiles{3} = sBeatFileName{7};
    %     sFiles{4} = sBeatFileName{6};
    %     sFiles{5} = sBeatFileName{5};
    %     sFiles{6} = sBeatFileName{4};
    %     sFiles{7} = sBeatFileName{2};
    %     sFiles{8} = sBeatFileName{1};
    sBeatFileName = sFiles;
    
    %intialise arrays to hold beat information
    rowdim = 42;
    coldim = 41;
    aAllActivationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllRepolarisationTimes = zeros(rowdim,coldim,length(sBeatFileName));
    aAllAPDs = zeros(rowdim,coldim,length(sBeatFileName));
    %get the beat data
    for i = 1:length(sBeatFileName)
        sLongDataFileName=strcat(sBeatPathName,char(sBeatFileName{i}));
        [aHeaderInfo aAllActivationTimes(:,:,i) aAllRepolarisationTimes(:,:,i) aAllAPDs(:,:,i)] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
    end
else
    if (~ischar(sBeatFileName) && ~ischar(sBeatPathName))
        break
    end
    %get the beat data
    [aHeaderInfo aAllActivationTimes aAllRepolarisationTimes aAllAPDs] = ReadOpticalDataCSVFile(strcat(sBeatPathName,sBeatFileName),rowdim,coldim,7);
end

%% Get S/N, power spectra and candidates for dVdtMax

% % initialise variables
iNumDataPoints = length(aOAP(1).Data(:,1)) - 1;
iNumPixels = size(aOAP(1).Locations,2);
iNumFiles = length(sFileName);
aATs = cell(size(aAllActivationTimes,3),1);
aNewATs = cell(size(aAllActivationTimes,3),1);
aSignaltoNoise = zeros(size(aAllActivationTimes,3),iNumPixels);
adVdtMax = zeros(size(aAllActivationTimes,3),iNumPixels);
aPSDX = zeros(iNumDataPoints/2+1,iNumPixels,iNumFiles);

aSlopePeakDistance = zeros(size(aAllActivationTimes,3),iNumPixels);

oWindow = tukeywin(iNumDataPoints,0.5);
iSamplingFreq = 779.76;

aAllNewActivationTimes = aAllActivationTimes;
aPaceSettersToPlot = cell(iNumFiles,1);
aNewPaceSettersToPlot = cell(iNumFiles,1);
aLocationsToPlot = cell(iNumFiles,1);

aCount = ones(iNumFiles,1);
aPlotCount = ones(iNumFiles,1);
aActivationTimes =  aAllActivationTimes(:,:,1);
aATPoints = aActivationTimes > 0;
for i = 1:iNumFiles
    aActivationTimes =  aAllActivationTimes(:,:,i);
    AT = aActivationTimes(aATPoints);
    AT(AT < 1) = NaN;
    % %     normalise the ATs to first activation
    [C I] = min(AT);
    AT = single(AT - AT(I));
    AT = double(AT);
    aATs{i} = AT';
    
    %     if i > 2
    %         oSubPlotFigure = figure();
    %         aSubPlotAxes = panel(oSubPlotFigure);
    %         aSubPlotAxes.pack(10,1);
    %     end
    %     aLocationsToPlot{i} = zeros(2,iNumPixels);
    %     aPaceSettersToPlot{i} = [aOAP(i).Locations(2,AT == 0)+1 ; aOAP(i).Locations(1,AT == 0)+1];
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
        aThisData = aSubData - min(aSubData);
        aThisData = aThisData / (max(aSubData) - min(aSubData));
        aThisSlope = fCalculateMovingSlope(aThisData,5,3);
        aThisCurvature = fCalculateMovingSlope(aThisSlope,5,3);
        aThisSlope(1:5) = 0;
        aThisSlope(end-5:end) = 0;
        aThisCurvature(1:5) = 0;
        aThisCurvature(end-5:end) = 0;
        aTime = (0:length(aThisData)-1)*(1/iSamplingFreq)*1000;
        
        % %         find peaks and locations of the slope
        [aSlopePeaks, aSlopeLocations] = fFindPeaks(aThisSlope);
        % %         get the value and location of the maximum
        [dMaxSlopePeak iMaxSlopeIndex] = max(aSlopePeaks);
        % %         Save maximum slope value to variable
        adVdtMax(i,j) = dMaxSlopePeak*(1/iSamplingFreq)*1000;
        % %         Save the distance between the two max peaks
        [aSortedPeaks aPermutation] = sort(aSlopePeaks);
        aSortedLocations = aSlopeLocations(aPermutation);
        dCurrentAT = aAllActivationTimes(dRowLoc, dColLoc,i) - aHeaderInfo.startframe + 2;
        if abs(aSortedLocations(end) - dCurrentAT) <= 3 && 0 < (aSortedLocations(end-1) - dCurrentAT) ...
                && (aSortedLocations(end-1) - dCurrentAT) <= 4 ...
                && (aSortedLocations(end-1) - aSortedLocations(end)) > 0
            aSlopePeakDistance(i,j) = aSortedLocations(end-1) - aSortedLocations(end);
        else
            aSlopePeakDistance(i,j) = NaN;
        end
        % %         find peaks and locations of the curvature
        [aCurvaturePeaks, aCurvatureLocations] = fFindPeaks(aThisCurvature);
        % %         get the value and location of the curvature
        [dMaxCurvaturePeak iMaxCurvatureIndex] = max(aCurvaturePeaks);
        %         if i > 2 && (iMaxSlopeIndex < numel(aSlopeLocations))
        %             % %             Get the boolean results to test whether there is a curvature peak between
        %             % %             the max slope peak and the slope peak following this one
        %             bResult1 = aCurvatureLocations > aSlopeLocations(iMaxSlopeIndex);
        %             bResult2 = aCurvatureLocations < aSlopeLocations(iMaxSlopeIndex+1);
        %             bResult = and(bResult1,bResult2);
        %             if aActivationTimes(dRowLoc, dColLoc) > 0
        %                 if length(find(bResult)) == 1
        %                     if (aCurvaturePeaks(bResult) > 0.06) && (aCurvaturePeaks(find(bResult)-1) > 0.13)
        %                         if (aSlopePeaks(iMaxSlopeIndex) > 0.15) && (aSlopePeaks(iMaxSlopeIndex+1) > 0.1)
        %                             aLocationsToPlot{i}(:,aCount(i)) = [dRowLoc ; dColLoc];
        %                             aAllNewActivationTimes(dRowLoc,dColLoc,i) = aSlopeLocations(iMaxSlopeIndex) + aHeaderInfo.startframe - 1;
        %                             aNewATs{i}(j) = aSlopeLocations(iMaxSlopeIndex) + aHeaderInfo.startframe - 1;
        %                             if (aPlotCount(i) <= 10) && logical(randi([0 3]))
        %                                 aSubPlotAxes(aPlotCount(i),1).select();
        %                                 %                                 set(aSubP
        %                                 %                                 lotAxes,'
        %                                 %                                 parent',oSubPlotFigure);
        %                                 [aSubPlots h1 h2] = plotyy(aTime,aThisData,aTime,aThisSlope);
        %                                 oTitle = title(sprintf('%s Location %s',strrep(char(sFileName{i}),'_','\_'),sprintf('%d%d',dXLoc,dYLoc)));%print title in native coordinates
        %                                 aSubPlotAxes.fontsize = 6;
        %                                 hold(aSubPlots(1),'on');
        %                                 % %     plot a green marker for the 50%AP AT
        %                                 dCurrentAT = aAllActivationTimes(dRowLoc, dColLoc,i) - aHeaderInfo.startframe + 2;
        %                                 plot(aSubPlots(1),aTime(dCurrentAT), aThisData(dCurrentAT), 'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',4);
        %                                 % %     plot a red marker for the slope based estimation of AT
        %                                 plot(aSubPlots(1),aTime(aSlopeLocations(iMaxSlopeIndex)), aThisData(aSlopeLocations(iMaxSlopeIndex)),'Marker', 'o', 'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',2);
        %                                 hold(aSubPlots(1),'off');
        %                                 XTick = get(aSubPlots(1),'xtick');
        %                                 set(aSubPlots(1),'xtick',[]);
        %                                 set(aSubPlots(2),'xtick',[]);
        %                                 set(aSubPlots(1),'ytick',[]);
        %                                 set(aSubPlots(2),'ytick',[]);
        %                                 axis(aSubPlots(1),'auto');
        %                                 axis(aSubPlots(2),'auto');
        %                                 aSubPlotAxes.de.margin = 2;
        %                                 aSubPlotAxes.de.marginbottom = 4;
        %                                 aPlotCount(i) = aPlotCount(i) + 1;
        %                             end
        %                             aCount(i) = aCount(i) + 1;
        %                         end
        %                     end
        %                 end
        %             end
        %         end
        %         %         Calculate S/N
        dBaselineValue = mean(aThisData(aHeaderInfo.BaselineRange(1) - aHeaderInfo.startframe + 1: ...
            aHeaderInfo.BaselineRange(2) - aHeaderInfo.startframe + 1));
        dNoise = std(aThisData(aHeaderInfo.BaselineRange(1) - aHeaderInfo.startframe + 1: ...
            aHeaderInfo.BaselineRange(2) - aHeaderInfo.startframe + 1));
        dOAPA = max(aThisData) - dBaselineValue;
        aSignaltoNoise(i,j) = dOAPA/dNoise;
        
        % %                         Calculate power spectra
        [aPSDX(:,j,i) Fxx] = periodogram(aData,oWindow,iNumDataPoints,iSamplingFreq);
        j = j + 1;
    end
    %     if i > 2 && ~isempty(aSubPlots)
    %         set(aSubPlots(1),'xtick',XTick);
    %         set(get(aSubPlots(1),'xlabel'),'string','Time (ms)');
    %     end
    iStoN = mean(aSignaltoNoise,2);
    fprintf('Mean signal to noise for %s is %0.2f\n', char(sFileName{i}), iStoN(i));
    
    %     %normalise new ATs
    %     NewAT = aActivationTimes(aATPoints);
    %     NewAT(NewAT < 1) = NaN;
    %     [C I] = min(NewAT);
    %     NewAT = single(NewAT - NewAT(I));
    %     NewAT = double(NewAT);
    %     aNewATs{i} = NewAT';
    %     aNewPaceSettersToPlot{i} = [aOAP(i).Locations(2,NewAT == 0)+1 ; aOAP(i).Locations(1,NewAT == 0)+1];
end
%% plot AT information
% % Convert back to matrix
aATs = cell2mat(aATs);
% aNewATs = cell2mat(aNewATs);
% % transpose to get into right shape for hist
aATs = aATs';
iNAT = hist(aATs,0:12);
figure();oATAxes = axes();
set(oATAxes,'ColorOrder',distinguishable_colors(iNumFiles));
oATBar = bar(oATAxes,0:12,iNAT);
for i = 1:iNumFiles
    set(oATBar(i),'DisplayName',strrep(char(sFileName{i}),'_','\_'));
end
legend(oATAxes,'show');
set(get(oATAxes,'title'),'string','Frequency distribution of activation times (AT50) for filtered data');
set(get(oATAxes,'xlabel'),'string','Normalised activation time (ms)');
set(get(oATAxes,'ylabel'),'string','Frequency');
% %repeat for newATs
% aNewATs = aNewATs';
% iNewNAT = hist(aNewATs,0:12);
% figure();oNewATAxes = axes();
% oNewATBar = bar(oNewATAxes,0:12,iNewNAT);
% for i = 1:iNumFiles
%     set(oNewATBar(i),'DisplayName',strrep(char(sFileName{i}),'_','\_'));
% end
% legend(oNewATAxes,'show');
% set(get(oNewATAxes,'title'),'string','Adjusted Frequency distribution of activation times (AT50) for filtered data');
% set(get(oNewATAxes,'xlabel'),'string','Normalised activation time (ms)');
% set(get(oNewATAxes,'ylabel'),'string','Frequency');

%% plot dVdtmax information
adVdtMax = adVdtMax';
[iNdVdtMax iXOut] = hist(adVdtMax);
figure();odVdTAxes = axes();
set(odVdTAxes,'ColorOrder',distinguishable_colors(iNumFiles));
odVdTMaxBar = bar(odVdTAxes,iXOut,iNdVdtMax);
for i = 1:iNumFiles
    set(odVdTMaxBar(i),'DisplayName',strrep(char(sFileName{i}),'_','\_'));
end
legend(odVdTAxes,'show');
set(get(odVdTAxes,'title'),'string','Frequency distribution of maximum gradients during upstroke');
set(get(odVdTAxes,'xlabel'),'string','Gradient (ms^-^1)');
set(get(odVdTAxes,'ylabel'),'string','Frequency');
%% plot peak distances
aDistanceData = aSlopePeakDistance';
[iNDistance iXOutDistance] = hist(aDistanceData);
figure();oDistanceAxes = axes();
set(oDistanceAxes,'ColorOrder',distinguishable_colors(iNumFiles));
oDistanceBar = bar(oDistanceAxes,iXOutDistance,iNDistance);
for i = 1:iNumFiles
    set(oDistanceBar(i),'DisplayName',strrep(char(sFileName{i}),'_','\_'));
end
legend(oDistanceAxes,'show');
set(get(oDistanceAxes,'title'),'string','Frequency distribution of samples between max peak and next peak');
set(get(oDistanceAxes,'xlabel'),'string','Number of samples');
set(get(oDistanceAxes,'ylabel'),'string','Frequency');
%% plot power spectra
figure();oPowerAxes = axes();
set(oPowerAxes,'ColorOrder',distinguishable_colors(iNumFiles));
set(oPowerAxes,'NextPlot','replacechildren');
iRawFileIndex = 3;
aMeanPSDX = zeros(iNumDataPoints/2+1,iNumFiles);
for i = 1:iNumFiles
    aMeanPSDX(:,i) = mean(aPSDX(:,:,i),2);
end
oPowerLines = plot(oPowerAxes,Fxx,10*log10(aMeanPSDX)); grid on;
for i = 1:iNumFiles
    set(oPowerLines(i),'DisplayName',strrep(char(sFileName{i}),'_','\_'));
end
legend(oPowerAxes,'show');
set(get(oPowerAxes,'title'),'string','Estimate of power spectral density using FFT and tukey window');
set(get(oPowerAxes,'xlabel'),'string','Frequency');
set(get(oPowerAxes,'ylabel'),'string','Power/Frequency (dB/Hz)');
%% plot first three activation time contours for each file 
% for i = 1:iNumFiles
%     aLocations = aLocationsToPlot{i};
%     PlotActivation(aAllActivationTimes(:,:,i),char(sBeatFileName{i}),aPaceSettersToPlot{i},aLocations(:,1:aCount(i)-1));
%     PlotActivation(aAllNewActivationTimes(:,:,i),char(strcat({'Adjusted '},char(sBeatFileName{i}))),aNewPaceSettersToPlot{i},aLocations(:,1:aCount(i)-1));
% end