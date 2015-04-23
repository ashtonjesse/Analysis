% % % load an optical data file and a corresponding optical entity
close all;
% % % % %Read in the file containing all the optical data 
% sCSVFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\baro005_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% [path name ext ver] = fileparts(sCSVFileName);
% if strcmpi(ext,'.csv')
%     aThisOAP = ReadOpticalTimeDataCSVFile(sCSVFileName,6);
% elseif strcmpi(ext,'.mat')
%     load(sCSVFileName);
% end
% 
% %%% read in the optical entity
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Optical.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% 
% % % %clear unwanted variables
% clear path name ext ver


%work out the best grid for maps
%Sets the units of your root object (screen) to pixels
set(0,'units','pixels')  
%Obtains this pixel information
Pix_SS = get(0,'screensize');
ratio = Pix_SS(4)/Pix_SS(3);
iCurrentGuess = Pix_SS(3)-1;
dTotal = ratio*(iCurrentGuess^2);
while dTotal > size(oOptical.Electrodes.Processed.BeatIndexes,1)
    iCurrentGuess = iCurrentGuess-1;
    dTotal = ratio*(iCurrentGuess^2);
end
iCurrentGuess = iCurrentGuess + 1;
% % % create a panel with enough subplots
oFigure = figure();
oPanel = panel(oFigure);
iRows = ceil(iCurrentGuess*ratio);
iCols = iCurrentGuess;
oPanel.pack(iRows,iCols);
oPanel.margin = [1 1 1 1];
oPanel.de.margin = 0;
%set dimensions of maps
rowdim = 41;
coldim = 41;
% % initialise array to hold activation times
aThisOAP.ActivationArray = -ones(rowdim,coldim,size(oOptical.Electrodes.Processed.BeatIndexes,1),'int16');
% % % create a variable to store the AT indexes
aThisOAP.ActIndex = zeros(size(aThisOAP.Locations,2),size(oOptical.Electrodes.Processed.BeatIndexes,1),'uint16');
% % %loop through the locations
for j = 1:size(aThisOAP.Locations,2)
    %get location details
    XLoc = aThisOAP.Locations(1,j)+1; %these locations are 0 based so add 1
    YLoc = aThisOAP.Locations(2,j)+1;
    % %     %compute slope for this location
    aSlope = oOptical.CalculateSlope(-aThisOAP.Data(:,j),9,3);
    %     oNewFigure = figure();oAxes = axes('parent',oNewFigure);
    for i = 1:size(oOptical.Electrodes.Processed.BeatIndexes,1)
        % %         %get the slope for this beat
        aSubSlope = aSlope(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2));
        [dMaxVal iMaxIndex] = max(aSubSlope);
        aThisOAP.ActivationIndex(j,i) = iMaxIndex-1+oOptical.Electrodes.Processed.BeatIndexes(i,1); %subtract one so that it can be used to index the time array directly
        aThisOAP.ActivationArray(YLoc,XLoc,i) = aThisOAP.ActivationIndex(j,i);
%         plotyy(oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2)),...
%             -aThisOAP.Data(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2),j),...
%             oOptical.TimeSeries(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2)),...
%             aSlope(oOptical.Electrodes.Processed.BeatIndexes(i,1):oOptical.Electrodes.Processed.BeatIndexes(i,2)));
    end
end

%loop through beats and map them
iAxesRow = 1;
iAxesCol = 1;
for m = 1:size(oOptical.Electrodes.Processed.BeatIndexes,1)
    %do hardy interpolation
    oMapData = fHardy(aThisOAP.ActivationArray(:,:,m),0.19,6,0.001);
    %select the axes
    oATAxes = oPanel(iAxesRow,iAxesCol).select();
    %set colour bar properties
    cbarmin = min(oMapData.RawData);
    cbarmax = max(oMapData.RawData);
    cbarRange = cbarmin:1:cbarmax;
    
    %plot
    contourf(oATAxes, oMapData.x, oMapData.y, oMapData.z, cbarRange);
    caxis(oATAxes,[cbarmin cbarmax]);
    colormap(oATAxes, colormap(flipud(colormap(jet))));
    axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes, 'off');
    sLabelBeat = num2str(m);
    % %create beat label
    aLabelPosition = [min(min(oMapData.x))+0.2, min(min(oMapData.y))+0.5];%for bottom left
    oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sLabelBeat);
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',10,'fontweight','bold');
    set(oBeatLabel,'parent',oATAxes);
    iAxesCol = iAxesCol + 1;
    if iAxesCol > iCols
        iAxesCol = 1;
        iAxesRow = iAxesRow + 1;
    end
end
