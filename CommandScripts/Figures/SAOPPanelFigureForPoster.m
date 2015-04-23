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
%     sFiles{1} = sFileName{3};
%     sFiles{2} = sFileName{1};
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
%     % % Make sure the dialogs return char objects
%     if (isempty(sFileName) && ~ischar(sFileName))
%         break
%     end
%     sFileName = strcat(sPathName,sFileName);
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
% else
%     % % Make sure the dialogs return char objects
%     if (isempty(sBeatFileName) && ~ischar(sBeatFileName))
%         break
%     end
%     sLongDataFileName=strcat(sBeatPathName,sBeatFileName);
%     rowdim = 42;
%     coldim = 41;
%     %get the beat data
%     [aHeaderInfo aAllActivationTimes aAllRepolarisationTimes aAllAPDs] = ReadOpticalDataCSVFile(sLongDataFileName,rowdim,coldim,7);
% end

%% set up figure and panel
oFigure = figure();
set(oFigure,'paperunits','centimeters');
set(oFigure,'paperposition',[0 0 10.84 8.0])
set(oFigure,'papersize',[10.84 8.0])

%% select panel and plot AP upstroke and data
oAxes = axes();
set(oAxes,'fontunits','points');
set(oAxes,'fontsize',12);

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
h = plot(oAxes,aTime,aThisData);
set(h,'Color',[0.5 0.5 0.5]);
set(h,'linewidth',1.5);
axis tight;
%get data
%plot
aData = -aOAP(3).Data(:,aFirstIndices(aSecondIndices));
aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
aThisData = aSubData - min(aSubData);
aThisData = aThisData / (max(aSubData) - min(aSubData));
hold on;
h = plot(oAxes,aTime,aThisData,'k');
set(h,'linewidth',1.5);
%get data
%plot
aData = fCalculateMovingSlope(aData,9,3); 
aSubData = aData(aHeaderInfo.startframe:aHeaderInfo.endframe);
aThisData = aSubData - min(aSubData);
aThisData = aThisData / (max(aSubData) - min(aSubData));
h = plot(oAxes,aTime,aThisData,'r');
set(h,'linewidth',1.5);
hold off;
xlabel('Time (ms)');
set(get(oAxes,'xlabel'),'fontweight','bold');
ylabel('Normalised amplitude');
set(get(oAxes,'ylabel'),'fontweight','bold');
aYticks = str2num(get(oAxes,'yticklabel'));
aYtickstring = cellstr(num2str(aYticks));
[aYtickstring{1:end-1}] = deal('');
set(oAxes,'yticklabel', char(aYtickstring));
set(oAxes,'ytickmode','manual');
oLegend = legend('Raw signal',sprintf('%s\n%s\n%s','Spatial &', 'temporal','filtering'),'Gradient');
set(oLegend,'fontunits','points');
set(oLegend,'fontsize',12);
legend(oAxes,'show');
legend(oAxes,'boxoff')
set(oLegend,'position',[0.658 0.67 0.2393 0.2444]);
set(oAxes,'box','off');
set(oAxes,'linewidth',1.5);
set(oAxes,'fontweight','bold');
hLegendText = findobj(oLegend, 'type', 'text');
set(hLegendText(3),'color', [0.5 0.5 0.5]);
set(hLegendText(1),'color', 'r');
%% print figure
sSaveFilePath = fullfile(sPathName,'FilteredDataPanel.bmp');
print(oFigure,'-dbmp','-r300',sSaveFilePath);