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

%get dimension variables
iNumDataPoints = length(aOAP(1).Data(:,1)) - 1;
iNumPixels = size(aOAP(1).Locations,2);
%initialise variables
aPSDXTukey = zeros(iNumDataPoints/2+1,iNumPixels,iNumFiles);
aMeanPSDX = zeros(iNumDataPoints/2+1,iNumFiles);
oWindow = tukeywin(iNumDataPoints,0.5);
oMeanWindow = tukeywin(45,0.5);
iSamplingFreq = 779.76;
for i = 1:iNumFiles
    for j = 1:iNumPixels
        [aPSDXTukey(:,j,i) Fxx] = periodogram(-aOAP(i).Data(1:iNumDataPoints,j),oWindow,iNumDataPoints,iSamplingFreq);
    end
    aMean = filter(oMeanWindow,1,mean(aPSDXTukey(:,:,i),2));
    if i == 1
        aNoiseIndices = find(Fxx > 250);
        dPower = mean(aMean(aNoiseIndices));
    end
    aMeanPSDX(:,i) = aMean/dPower;
end
oFigure = figure();oPowerAxes = axes();
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
%print figure
set(oFigure,'paperunits','centimeters');
set(oFigure,'paperposition',[0 0 10 10])
set(oFigure,'papersize',[10 10])
sSaveFilePath = fullfile(sPathName,'Periodgram.bmp');
print(oFigure,'-dbmp','-r300',sSaveFilePath);
