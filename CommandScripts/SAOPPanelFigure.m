close all;
% clear all;
% 
% % % % %Read in the file containing all the optical data 
% [sFileName,sPathName]=uigetfile('*.*','Select file(s) that contain optical transmembrane recordings','multiselect','on');
% 
% if iscell(sFileName)
%     %Make sure the dialogs return char objects
%     if (isempty(sFileName) && ~ischar(sFileName))
%         break
%     end
%     %remap file indices
%     sFiles = cell(size(sFileName));
%     sFiles{1} = sFileName{1};
%     sFiles{2} = sFileName{3};
%     sFiles{3} = sFileName{2};
%     sFileName = sFiles;
%     aOAP = [];
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
%     sFileName = strcat(sPathName,sFileName);
%     % % Make sure the dialogs return char objects
%     if (isempty(sFileName) && ~ischar(sFileName))
%         break
%     end
%     %check the extension
%     [pathstr, name, ext, versn] = fileparts(sFileName);
%     if strcmpi(ext,'.csv')
%         aOAP = ReadOpticalTimeDataCSVFile(sFileName,6);
%     elseif strcmpi(ext,'.mat')
%         load(sFileName);
%         aOAP = aThisOAP;
%     end
%     iNumFiles = 1;
% end
% 
% %% load the beat data
% [sBeatFileName,sBeatPathName]=uigetfile('*.*','Select CSV file(s) that contain optical beat data','multiselect','on');
% % %Make sure the dialogs return char objects
% 
% if iscell(sBeatFileName)
%     %Make sure the dialogs return char objects
%     if (isempty(sBeatFileName) && ~ischar(sBeatPathName))
%         break
%     end
%     sFiles = cell(size(sBeatFileName));
%     sFiles{1} = sBeatFileName{1};
%     sFiles{2} = sBeatFileName{2};
%     sBeatFileName = sFiles;    
%     %intialise arrays to hold beat information
%     rowdim = 42;
%     coldim = 41;
%     aAllActivationTimes = zeros(rowdim,coldim,length(sBeatFileName));
%     aAllRepolarisationTimes = zeros(rowdim,coldim,length(sBeatFileName));
%     aAllAPDs = zeros(rowdim,coldim,length(sBeatFileName));
%     %get the beat data
%     for i = 1:length(sBeatFileName)
%         sLongDataFileName=strcat(sBeatPathName,char(sBeatFileName{i}));
%         [aHeaderInfo aAllActivationTimes(:,:,i) aAllRepolarisationTimes(:,:,i) aAllAPDs(:,:,i)] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
%     end
% end

%% set up figure and panel
oFigure = figure();
set(oFigure,'paperunits','centimeters');
set(oFigure,'paperposition',[0 0 13.5 16])
set(oFigure,'papersize',[13.5 16])
aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(2,1);

% %% compute and plot power spectra
% %get dimension variables
% iNumDataPoints = length(aOAP(1).Data(:,1)) - 1;
% iNumPixels = size(aOAP(1).Locations,2);
% %initialise variables
% aPSDXTukey = zeros(iNumDataPoints/2+1,iNumPixels,iNumFiles);
% aMeanPSDX = zeros(iNumDataPoints/2+1,iNumFiles);
% oWindow = tukeywin(iNumDataPoints,0.5);
% oMeanWindow = tukeywin(45,0.5);
% iSamplingFreq = 779.76;
% for i = 1:iNumFiles
%     for j = 1:iNumPixels
%         [aPSDXTukey(:,j,i) Fxx] = periodogram(-aOAP(i).Data(1:iNumDataPoints,j),oWindow,iNumDataPoints,iSamplingFreq);
%     end
%     aMean = filter(oMeanWindow,1,mean(aPSDXTukey(:,:,i),2));
%     if i == 1
%         aNoiseIndices = find(Fxx > 250);
%         dPower = mean(aMean(aNoiseIndices));
%     end
%     aMeanPSDX(:,i) = aMean/dPower;
% end

%% select panel and plot AP upstroke and data
oAxes = aSubplotPanel(1,1).select();
%get data
dXLoc = 15;
dYLoc = 16;
aFirstIndices = find(aOAP(1).Locations(1,:) == dXLoc);
aSecondIndices = find(aOAP(1).Locations(2,aFirstIndices) == dYLoc);
aData = -aOAP(1).Data(:,aFirstIndices(aSecondIndices));
aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
aThisData = aSubData - min(aSubData);
aThisData = aThisData / (max(aSubData) - min(aSubData));
aTime = (0:length(aThisData)-1)*(1/iSamplingFreq)*1000;
%plot
h = plot(aTime,aThisData);
set(h,'Color',[0.7 0.7 0.7]);
axis tight;
%get data
%plot
aData = -aOAP(3).Data(:,aFirstIndices(aSecondIndices));
aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
aThisData = aSubData - min(aSubData);
aThisData = aThisData / (max(aSubData) - min(aSubData));
hold on;
h = plot(aTime,aThisData,'k');
hold off;
oTitle = title('A');
aPosition = get(oTitle,'position');
aPosition(1) = -4;
aPosition(2) = aPosition(2) - 0.08;
set(oTitle,'position',aPosition);
set(oTitle,'fontunits','points');
set(oTitle,'fontsize',16);
set(oTitle,'fontweight','bold');
xlabel('Time (ms)');
ylabel('Normalised amplitude');
aYticks = str2num(get(oAxes,'yticklabel'));
aYtickstring = cellstr(num2str(aYticks));
[aYtickstring{1:end-1}] = deal('');
set(oAxes,'yticklabel', char(aYtickstring));
set(oAxes,'ytickmode','manual');
oTitle = text('string','B');
set(oTitle,'fontunits','points');
set(oTitle,'fontsize',16);
set(oTitle,'fontweight','bold');
aPosition = [-5 -0.2 1];
set(oTitle,'position',aPosition);
oLegend = legend('Raw recording',sprintf('%s\n%s','Spatial averaging and', 'temporal filtering'));
set(oLegend,'fontsize',8);
legend(oAxes,'show');
%% plot periodogram
oPowerAxes = aSubplotPanel(2,1).select();
set(oPowerAxes,'NextPlot','replacechildren');
oPowerLines = plot(oPowerAxes,Fxx,aMeanPSDX); 
aLineStyles = {'--',':','-','-.'};
for i = 1:iNumFiles
    [pathstr, name, ext, versn] = fileparts(char(sFileName{i}));
    set(oPowerLines(i),'LineStyle',char(aLineStyles{i}));
    set(oPowerLines(i),'Color','k');
end
oLegend = legend('Raw recording','Spatial averaging',sprintf('%s\n%s','Spatial averaging and', 'temporal filtering'));
set(oLegend,'fontsize',8);
legend(oPowerAxes,'show');
set(get(oPowerAxes,'xlabel'),'string','Frequency (Hz)');
set(get(oPowerAxes,'ylabel'),'string','Normalised Power (P/P_n)');
axis([0 max(Fxx)+50 0 2.5]);

%% print figure
sSaveFilePath = fullfile(sPathName,'FilteredDataPanel.bmp');
print(oFigure,'-dbmp','-r300',sSaveFilePath);