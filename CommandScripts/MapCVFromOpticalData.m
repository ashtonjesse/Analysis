%This script opens csv files containing activation and repolarisation times, and APDs
%from optical mapping experiments. The ATs are used to calculate a
%conduction velocity field which is then plotted and the figure is printed
%to file.
% 
clear all;
close all;
% 
% %get a list of the csv files in the directory
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\APD50\';
sSavePath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\APD50\';
sFormat = 'csv';
% %Get the full path names of all the  files in the directory
aFileFull = fGetFileNamesOnly(sFilesPath,strcat('*.',sFormat));
rowdim = 100;
coldim = 101;
%Open the first file to get some info out (assumes that all the maps in
%this directory have the same shape)
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{1},rowdim,coldim);
aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
[rowIndices colIndices] = find(aActivationTimes > 0);
aATPoints = aActivationTimes > 0;
AT = aActivationTimes(aATPoints);
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);
dRes = 0.25;
dInterpDim = dRes/4;
x = dRes .* rowIndices;
y = dRes .* colIndices;


% %Plot ATs
% %calculate the grid for plotting
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% % calculate the interpolation so as to produce the reshaped mesh vectors
F=TriScatteredInterp(x,y,AT);
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
rxx = reshape(xx,[prod(size(QAT)),1]);
ryy = reshape(yy,[prod(size(QAT)),1]);
cbarmin = max(floor(min(rQAT)),0);
cbarmax = ceil(max(rQAT));
cbarRange = cbarmin:1:cbarmax;
oATFigure = figure(); oATAxes = axes();
set(oATFigure,'paperunits','inches');
%Set figure size
iMontageX = 5;%5
iMontageY = 9;%9
dMontageWidth = 8.27 - 2; %in inches, with borders 
dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
dWidth = dMontageWidth/iMontageX; %in inches
dHeight = dMontageHeight/iMontageY; %in inches
set(oATFigure,'paperposition',[0 0 dWidth dHeight])
set(oATFigure,'papersize',[dWidth dHeight])
set(oATAxes,'units','normalized');
set(oATAxes,'outerposition',[0 0 1 1]);
aTightInset = get(oATAxes, 'TightInset');
aPosition(1) = aTightInset(1);
aPosition(2) = aTightInset(2);
aPosition(3) = 1-aTightInset(1)-aTightInset(3);
aPosition(4) = 1 - aTightInset(2) - aTightInset(4);
set(oATAxes, 'Position', aPosition);
%plot
contourf(oATAxes, xx,yy,QAT,cbarRange);
caxis([cbarmin cbarmax]);
colormap(oATAxes, colormap(flipud(colormap(jet))));
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oATAxes, 'equal'); axis(oATAxes, 'tight');
set(oATAxes,'FontUnits','points');
set(oATAxes,'FontSize',6);
aYticks = str2num(get(oATAxes,'yticklabel'));
aYticks = aYticks - aYticks(1);
aYtickstring = cellstr(num2str(aYticks));
for i=1:length(aYticks)
    %Check if the label has a decimal place and hide this label
    if ~isempty(strfind(char(aYtickstring{i}),'.'))
        aYtickstring{i} = '';
    end
end
set(oATAxes,'xticklabel',[]);
set(oATAxes,'xtickmode','manual');
set(oATAxes,'yticklabel', char(aYtickstring));
set(oATAxes,'ytickmode','manual');
set(oATAxes,'Box','off');
% set(get(oATAxes,'ylabel'),'string','Length (mm)','fontunits','points');
% set(get(oATAxes,'ylabel'),'fontsize',8);
% oYLabelPosition = get(get(oATAxes,'ylabel'),'position');
% set(get(oATAxes,'ylabel'),'position',[oYLabelPosition(1)+0.0005,oYLabelPosition(2),oYLabelPosition(3)]);
% oTitle = title(oATAxes,sprintf('%d',1));
% set(oTitle,'units','normalized');
% set(oTitle,'fontsize',14,'fontweight','bold');
%create beat label
oBeatLabel = text(min(min(xx))+0.5,max(max(yy))-0.5, sprintf('%d',1));
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oATAxes);

%Print figure    
drawnow; pause(.2);
[pathstr, name, ext, versn] = fileparts(aFileFull{1});
sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
print(oATFigure,'-dbmp','-r300',sSaveFilePath)
fprintf('Printed figure %s\n', sSaveFilePath);
sATMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});

%Plot CVs
[CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
idxCV = find(~isnan(CV));
aCVdata = CV(idxCV);
aCVdata(aCVdata > 2) = 2;
oCVFigure = figure(); oCVAxes = axes();
set(oCVFigure,'paperunits','inches');
%set up position
set(oCVFigure,'paperposition',[0 0 dWidth dHeight])
set(oCVFigure,'papersize',[dWidth dHeight])
set(oCVAxes,'units','normalized');
set(oCVAxes,'outerposition',[0 0 1 1]);
aTightInset = get(oCVAxes, 'TightInset');
aPosition(1) = aTightInset(1)-0.1;
aPosition(2) = aTightInset(2);
aPosition(3) = 1+0.1;
aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
set(oCVAxes, 'Position', aPosition);
%Finish plotting
caxis([0 2]);
scatter(oCVAxes,x(idxCV),y(idxCV),16,aCVdata,'filled');
hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oCVAxes, 'off');
axis(oCVAxes, 'equal'); axis(oCVAxes, 'tight');
%set up axis label
set(oCVAxes,'FontUnits','points');
set(oCVAxes,'FontSize',6);
aYticks = str2num(get(oCVAxes,'yticklabel'));
aYticks = aYticks - aYticks(1);
aYtickstring = cellstr(num2str(aYticks));
for i=1:length(aYticks)
    %Check if the label has a decimal place and hide this label
    if ~isempty(strfind(char(aYtickstring{i}),'.'))
        aYtickstring{i} = '';
    end
end
set(oCVAxes,'xticklabel',[]);
set(oCVAxes,'xtickmode','manual');
set(oCVAxes,'yticklabel', char(aYtickstring));
set(oCVAxes,'ytickmode','manual');
set(oCVAxes,'Box','off');
%set up beat label
oBeatLabel = text(min(min(xx))+0.5,max(max(yy))-0.5, sprintf('%d',1));
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oCVAxes);

[pathstr, name, ext, versn] = fileparts(aFileFull{1});
sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
drawnow; pause(.2);
print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
sCVMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});

% %Plot a histogram of the CVs
% oHistFigure = figure(); oHistAxes = axes();
% aCVRange = 0:0.1:2;
% aHistData = CV(idxCV);
% hist(oHistAxes,aHistData(aHistData<=2),aCVRange);
% set(oHistAxes, 'ylim', [0 250]);
% oHistTitle = title(oHistAxes,sprintf('%d',1));
% set(oHistTitle,'units','normalized');
% set(oHistTitle,'fontsize',26,'fontweight','bold');
% drawnow; pause(.2);
% sSaveFilePath = fullfile(sSavePath,strcat(name, '_CVDist.bmp'));
% print(oHistFigure,'-dbmp','-r300',sSaveFilePath)
% sCVHistDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});
% fprintf('Printed data for %s\n', name);

%Prepare for CVtxt file 
%The row header is the row index and col index appended together 
rowString = num2str(rowIndices);
colString = num2str(colIndices);
aCVRowHeader = horzcat(rowString,colString);
%convert to cell array of strings
aCVRowHeader = cellstr(aCVRowHeader);
%Initialise array to hold loop data
aCVDataToWrite = zeros(length(aFileFull),length(aCVRowHeader),'double');
%Select just the data that belongs to a recording point
aCVDataToWrite(1,:) = CV;

%Prepare for the APDtxt file
aCurrentAPD = rot90(aAPDs(:,1:end-1,1),-1);
aDataPoints = aCurrentAPD(:,:,1) > 0;
%The row header is the row index and col index appended together (for some
%reason the row index is out by 1, hence adding 100
aAPDRowHeader = find(aDataPoints) + 100;
aAPDRowHeader = aAPDRowHeader';
%convert to cell array of strings
aAPDRowHeader = strread(num2str(aAPDRowHeader),'%s');
aAPDRowHeader = aAPDRowHeader';
%Initialise array to hold loop data
aAPDDataToWrite = zeros(length(aFileFull),length(aAPDRowHeader),'double');
%Select just the data that belongs to a recording point
aAPDDataToWrite(1,:) = aCurrentAPD(aDataPoints);

%plot the APDs

%loop through the list of files and read in the data
for k = 2:length(aFileFull)
%     %get the data from this file 
    [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{k},rowdim,coldim);
    %actually turns out the data needs to be rotated for display
    aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
    aCurrentAPD = rot90(aAPDs(:,1:end-1),-1);
    aAPDDataToWrite(k,:) = aCurrentAPD(aDataPoints);
    %dispose of the data that has been excluded in the ROI
    AT = aActivationTimes(aATPoints);
    
    AT(AT < 0) = NaN;
    %normalise the ATs to first activation
    [C I] = min(AT);
    AT = single(AT - AT(I));
    AT = double(AT);
    
% %     plot the activation field
    F=TriScatteredInterp(x,y,AT);
    QAT = F(xx,yy);
    contourf(oATAxes, xx,yy,QAT,cbarRange);
    axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes, 'off');
    caxis([cbarmin cbarmax]);
    oBeatLabel = text(min(min(xx))+0.5,max(max(yy))-0.5, sprintf('%d',k));
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',14,'fontweight','bold');
    set(oBeatLabel,'parent',oATAxes);
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{k});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
    print(oATFigure,'-dbmp','-r300',sSaveFilePath)
    fprintf('Printed figure %s\n', sSaveFilePath);
    sATMapDosString = strcat(sATMapDosString, {sprintf(' %s',sSaveFilePath)});
    
    
    
    %Get Cv data with neighbourhood 24
    [CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
    aCVDataToWrite(k,:) = CV;
    idxCV = find(~isnan(CV));
    aCVdata = CV(idxCV);
    aCVdata(aCVdata > 2) = 2;
       
    %plot the CV 
    scatter(oCVAxes,x(idxCV),y(idxCV),16,aCVdata,'filled');
    hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oCVAxes, 'off');
    axis(oCVAxes, 'equal'); axis(oCVAxes, 'tight'); axis(oCVAxes,'off');
    oBeatLabel = text(min(min(xx))+0.5,max(max(yy))-0.5, sprintf('%d',k));
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',14,'fontweight','bold');
    set(oBeatLabel,'parent',oCVAxes);
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{k});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
    print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
    sCVMapDosString = strcat(sCVMapDosString, {sprintf(' %s',sSaveFilePath)});
%     aHistData = CV(idxCV);
%     hist(oHistAxes,aHistData(aHistData<=2),aCVRange);
%     set(oHistAxes, 'ylim', [0 250]);
%     oHistTitle = title(oHistAxes,sprintf('%d',k));
%     set(oHistTitle,'units','normalized');
%     set(oHistTitle,'fontsize',26,'fontweight','bold');
%     drawnow; pause(.2);
%     [pathstr, name, ext, versn] = fileparts(aFileFull{k});
%     sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
%     print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
%     sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
%         {' -gravity West -chop 470x0 -gravity East -chop 412x0 -gravity South -chop 0x120'}, {sprintf(' %s', sSaveFilePath)});
%     sStatus = dos(char(sChopString{1}));
%     if sStatus
%         disp('error');
%         break;
%     end
%     sCVMapDosString = strcat(sCVMapDosString, {sprintf(' %s',sSaveFilePath)});
%     sSaveFilePath = fullfile(sSavePath,strcat(name, '_CVDist.bmp'));
%     print(oHistFigure,'-dbmp','-r300',sSaveFilePath)
%     sCVHistDosString = strcat(sCVHistDosString, {sprintf(' %s',sSaveFilePath)});
%     fprintf('Printed data for %s\n', name);
end
% % Write out CV data
DataHelper.ExportDataToTextFile(strcat(sSavePath,'CVData.txt'),aCVRowHeader,aCVDataToWrite);
% % Write out APD data
DataHelper.ExportDataToTextFile(strcat(sSavePath,'APDData.txt'),aAPDRowHeader,aAPDDataToWrite);

%montage the AT maps
iPixelWidth = dWidth*300;
iPixelHeight = dHeight*300;
sATMapDosString = strcat(sATMapDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sSavePath, 'ATMapmontage.png');
sStatus = dos(char(sATMapDosString{1}));
if ~sStatus
%     figure();
%     disp(char(sATMapDosString));
%     imshow(strcat(sSavePath, 'ATMapmontage.png'));
end

%montage the CV maps
sCVMapDosString = strcat(sCVMapDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sSavePath, 'CVMapmontage.png');
sStatus = dos(char(sCVMapDosString{1}));
if ~sStatus
%     figure();
%     disp(char(sCVMapDosString));
%     imshow(strcat(sSavePath, 'CVMapmontage.png'));
end

% %montage the CV histograms
% sCVHistDosString = strcat(sCVHistDosString, {' -quality 98 -tile 9x5 -geometry 275x206+0+0 '}, sSavePath, 'CVHistmontage.png');
% sStatus = dos(char(sCVHistDosString{1}));
% if ~sStatus
% %     figure();
% %     disp(char(sCVHistDosString));
% %     imshow(strcat(sSavePath, 'CVHistmontage.png'));
% end

%Create a colour bar for the AT maps
oCbarFigure = figure(); oAxes = axes();
set(oCbarFigure,'paperunits','inches');
set(oCbarFigure,'paperposition',[0 0 dMontageWidth dMontageHeight]);
set(oCbarFigure,'papersize',[dMontageWidth dMontageHeight]);
contourf(oAxes, xx,yy,QAT,cbarRange);
caxis([cbarmin cbarmax]);
colormap(oAxes, colormap(flipud(colormap(jet))));
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oAxes, 'equal'); axis(oAxes, 'tight');
oColorBar = cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax), 'horiz');
oTitle = get(oColorBar, 'title');
set(oTitle,'units','normalized');
set(oTitle,'fontsize',8);
set(oTitle,'string','Time (ms)','position',[0.5 2]);
%set the paper size
sSaveFilePath = fullfile(sSavePath,'colorbar.bmp');
print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
sColorBarImage = sSaveFilePath;
sSaveFilePath = fullfile(sSavePath,'ATMapmontage_cbar.png');
sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
        {sprintf(' %s', sSavePath)}, 'ATMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sAppend{1}));

%Create a colour bar for the CV maps
oCbarFigure = figure(); oAxes = axes();
set(oCbarFigure,'paperunits','inches');
set(oCbarFigure,'paperposition',[0 0 dMontageWidth dMontageHeight]);
set(oCbarFigure,'papersize',[dMontageWidth dMontageHeight]);
scatter(oAxes,x(idxCV),y(idxCV),16,aCVdata,'filled');
    hold(oAxes, 'on'); quiver(oAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oAxes, 'off');
axis(oAxes, 'equal'); axis(oAxes, 'tight'); axis(oAxes,'off');
caxis([0 2]);
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));

oColorBar = cbarf([0 2], 0:0.2:2, 'horiz');
oTitle = get(oColorBar, 'title');
set(oTitle,'units','normalized');
set(oTitle,'fontsize',8);
set(oTitle,'string','Velocity (m/s)','position',[0.5 2]);
%set the paper size
sSaveFilePath = fullfile(sSavePath,'colorbar.bmp');
print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
sColorBarImage = sSaveFilePath;
sSaveFilePath = fullfile(sSavePath,'CVMapmontage_cbar.png');
sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
        {sprintf(' %s', sSavePath)}, 'CVMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sAppend{1}));