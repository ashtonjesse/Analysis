%This script opens csv files containing activation and repolarisation times, and APDs
%from optical mapping experiments. The ATs are used to calculate a
%conduction velocity field which is then plotted and the figure is printed
%to file.
% 
clear all;
close all;
% 
% %get a list of the csv files in the directory
sFilesPath = 'F:\PhD\Experiments\Auckland\InSituPrep\20140624\20140624baro004\APD1\';
sSavePath = 'F:\PhD\Experiments\Auckland\InSituPrep\20140624\20140624baro004\APD1\';
sFormat = 'csv';
% %Get the full path names of all the  files in the directory
aFileFull = fGetFileNamesOnly(sFilesPath,strcat('*.',sFormat));

bPrintAPD = false;
iMontageX = 5;%5
iMontageY = 7;%9

iFirstBeat = 90;
iLabelStartBeat = iFirstBeat;
iLastBeat = iFirstBeat  + iMontageX*iMontageY - 1;
iFirstBeatToPlot = iFirstBeat;
iLastBeatToPlot = iLastBeat;
iFirstIndex = 20;
iFirstBeatToPlot = iFirstBeatToPlot - iFirstIndex + 1;
iLastBeatToPlot = iLastBeatToPlot - iFirstIndex + 1;
if iLastBeatToPlot > length(aFileFull)
    iLastBeatToPlot = length(aFileFull);
end
%Used for APDs only
iSecondMapToCompare = 10;
iSecondMapToCompare = iSecondMapToCompare - iFirstIndex + 1;

rowdim = 44;
coldim = 41;%add one to the number of columns in the csv file
%Open the first file to get some info out (assumes that all the maps in
%this directory have the same shape)
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{1},rowdim,coldim,7);
aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
[rowIndices colIndices] = find(aActivationTimes > 0);
aATPoints = aActivationTimes > 0;
AT = aActivationTimes(aATPoints);
AT(AT < 1) = NaN;
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);
dRes = 0.190;
dInterpDim = dRes/4;
x = dRes .* rowIndices;
y = dRes .* colIndices;


%% Plot ATs
% %calculate the grid for plotting
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% % calculate the interpolation so as to produce the reshaped mesh vectors
F=TriScatteredInterp(x,y,AT);
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
cbarmin = max(floor(min(rQAT)),0);
cbarmax = ceil(max(rQAT));
cbarRange = cbarmin:1:cbarmax;
oATFigure = figure(); oATAxes = axes();
set(oATFigure,'paperunits','inches');
%Set figure size

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
aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
set(oATAxes, 'Position', aPosition);
%plot
contourf(oATAxes, xx,yy,QAT,cbarRange);
caxis(oATAxes,[cbarmin cbarmax]);
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
%aLabelPosition = [min(min(xx))+0.2, max(max(yy))-0.5];%for top left
aLabelPosition = [min(min(xx))+0.2, min(min(yy))+0.5];%for bottom left
oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iLabelStartBeat));
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oATAxes);

%clear the axes as I don't actually want to print this map (as it is always
%the first file, not iFirstBeatToPlot)
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{iFirstBeatToPlot},rowdim,coldim,6);
aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
%dispose of the data that has been excluded in the ROI
AT = aActivationTimes(aATPoints);

AT(AT < 1) = NaN;
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);

% %     plot the activation field
F=TriScatteredInterp(x,y,AT);
QAT = F(xx,yy);
contourf(oATAxes, xx,yy,QAT,cbarRange);
caxis(oATAxes, [cbarmin cbarmax]);
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
aLabelPosition = [min(min(xx))+0.2, min(min(yy))+0.5];%for bottom left
oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iLabelStartBeat));
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oATAxes);

%Print figure    
drawnow; pause(.2);
[pathstr, name, ext, versn] = fileparts(aFileFull{iFirstBeatToPlot});
sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
print(oATFigure,'-dbmp','-r300',sSaveFilePath)
fprintf('Printed figure %s\n', sSaveFilePath);
sATMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});

%% Plot CVs
[CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
idxCV = find(~isnan(CV));
aCVdata = CV(idxCV);
aCVdata(aCVdata > 1) = 1;
oCVFigure = figure(); oCVAxes = axes();
set(oCVFigure,'paperunits','inches');
%set up position
set(oCVFigure,'paperposition',[0 0 dWidth dHeight])
set(oCVFigure,'papersize',[dWidth dHeight])
set(oCVAxes,'units','normalized');
set(oCVAxes,'outerposition',[0 0 1 1]);
aTightInset = get(oCVAxes, 'TightInset');
aPosition(1) = aTightInset(1);
aPosition(2) = aTightInset(2);
aPosition(3) = 1- aTightInset(3) - aTightInset(1);
aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
set(oCVAxes, 'Position', aPosition);
%Finish plotting
scatter(oCVAxes,x(idxCV),y(idxCV),14,aCVdata,'filled');
hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oCVAxes, 'off');
caxis(oCVAxes, [0 1]);
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
oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iLabelStartBeat));
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

%% Prepare for CVtxt file 
%The row header is the row index and col index appended together 
rowString = num2str(rowIndices,'%2.2i');
colString = num2str(colIndices,'%2.2i');
aCVRowHeader = horzcat(rowString,colString);
%convert to cell array of strings
aCVRowHeader = cellstr(aCVRowHeader);
%Initialise array to hold loop data
aCVDataToWrite = zeros(iLastBeatToPlot - iFirstBeatToPlot + 1,length(aCVRowHeader),'double');
%Select just the data that belongs to a recording point
aCVDataToWrite(1,:) = CV;

%% Prepare for the APDtxt file
if bPrintAPD
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
    aAPDDataToWrite = zeros(iLastBeatToPlot - iFirstBeatToPlot + 1,length(aAPDRowHeader),'double');
    %Select just the data that belongs to a recording point
    aAPDDataToWrite(1,:) = aCurrentAPD(aDataPoints);
    
    %% plot the APDs
    [rowIndices colIndices] = find(aCurrentAPD(:,:,1) > 0);
    APD = aCurrentAPD(aDataPoints);
    xforAPD = dRes .* rowIndices;
    yforAPD = dRes .* colIndices;
    
    % %calculate the grid for plotting
    [xxforAPD,yyforAPD]=meshgrid(min(xforAPD):dInterpDim:max(xforAPD),min(yforAPD):dInterpDim:max(yforAPD));
    % % calculate the interpolation so as to produce the reshaped mesh vectors
    F=TriScatteredInterp(xforAPD,yforAPD,APD);
    QAPD = F(xxforAPD,yyforAPD);
    rQAPD = reshape(QAPD,[prod(size(QAPD)),1]);
    APDcbarmin = max(floor(min(rQAPD)),0);
    APDcbarmax = ceil(max(rQAPD));
    
    %Get the range of another beat and combine to ensure range fits across all
    %beats
    [a b c aAPDs2] = ReadOpticalDataCSVFile(aFileFull{iSecondMapToCompare},rowdim,coldim,6);
    clear a b c;
    aCurrentAPD = rot90(aAPDs2(:,1:end-1,1),-1);
    APD2 = aCurrentAPD(aDataPoints);
    F=TriScatteredInterp(xforAPD,yforAPD,APD2);
    QAPD2 = F(xxforAPD,yyforAPD);
    rQAPD2 = reshape(QAPD2,[prod(size(QAPD2)),1]);
    APD2cbarmin = max(floor(min(rQAPD2)),0);
    APD2cbarmax = ceil(max(rQAPD2));
    %set range
    APDcbarmin = min(APDcbarmin,APD2cbarmin);
    APDcbarmax = max(APDcbarmax,APD2cbarmax);
    APDcbarRange = APDcbarmin:1:APDcbarmax;
    
    oAPDFigure = figure(); oAPDAxes = axes();
    set(oAPDFigure,'paperunits','inches');
    set(oAPDFigure,'paperposition',[0 0 dWidth dHeight])
    set(oAPDFigure,'papersize',[dWidth dHeight])
    set(oAPDAxes,'units','normalized');
    set(oAPDAxes,'outerposition',[0 0 1 1]);
    aTightInset = get(oAPDAxes, 'TightInset');
    aPosition(1) = aTightInset(1)+0.05;
    aPosition(2) = aTightInset(2);
    aPosition(3) = 1-aTightInset(1)-aTightInset(3);
    aPosition(4) = 1 - aTightInset(2) - aTightInset(4);
    set(oAPDAxes, 'Position', aPosition);
    %plot
    contourf(oAPDAxes, xxforAPD,yyforAPD,QAPD,APDcbarRange);
    caxis(oAPDAxes, [APDcbarmin APDcbarmax]);
    colormap(oAPDAxes, colormap(flipud(colormap(jet))));
    % cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
    axis(oAPDAxes, 'equal'); axis(oATAxes, 'tight');
    set(oAPDAxes,'FontUnits','points');
    set(oAPDAxes,'FontSize',6);
    aYticks = str2num(get(oAPDAxes,'yticklabel'));
    aYticks = aYticks - aYticks(1);
    aYtickstring = cellstr(num2str(aYticks));
    for i=1:length(aYticks)
        %Check if the label has a decimal place and hide this label
        if ~isempty(strfind(char(aYtickstring{i}),'.'))
            aYtickstring{i} = '';
        end
    end
    set(oAPDAxes,'xticklabel',[]);
    set(oAPDAxes,'xtickmode','manual');
    set(oAPDAxes,'yticklabel', char(aYtickstring));
    set(oAPDAxes,'ytickmode','manual');
    set(oAPDAxes,'Box','off');
    % set(get(oATAxes,'ylabel'),'string','Length (mm)','fontunits','points');
    % set(get(oATAxes,'ylabel'),'fontsize',8);
    % oYLabelPosition = get(get(oATAxes,'ylabel'),'position');
    % set(get(oATAxes,'ylabel'),'position',[oYLabelPosition(1)+0.0005,oYLabelPosition(2),oYLabelPosition(3)]);
    % oTitle = title(oATAxes,sprintf('%d',1));
    % set(oTitle,'units','normalized');
    % set(oTitle,'fontsize',14,'fontweight','bold');
    %create beat label
    oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iLabelStartBeat));
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',14,'fontweight','bold');
    set(oBeatLabel,'parent',oAPDAxes);
    
    %Print figure
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{1});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_APD.bmp'));
    print(oAPDFigure,'-dbmp','-r300',sSaveFilePath)
    fprintf('Printed figure %s\n', sSaveFilePath);
    sAPDMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});
end
iBeatCount = 1;
%% loop through the list of files and read in the data
for k = iFirstBeatToPlot+1:iLastBeatToPlot
    iBeatCount = iBeatCount + 1;
%     %get the data from this file 
    [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{k},rowdim,coldim,6);
    %actually turns out the data needs to be rotated for display
    aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
    %dispose of the data that has been excluded in the ROI
    AT = aActivationTimes(aATPoints);

    AT(AT < 1) = NaN;
    %normalise the ATs to first activation
    [C I] = min(AT);
    AT = single(AT - AT(I));
    AT = double(AT);
    
    % %     plot the activation field
    F=TriScatteredInterp(x,y,AT);
    QAT = F(xx,yy);
    contourf(oATAxes, xx,yy,QAT,cbarRange);
    caxis(oATAxes, [cbarmin cbarmax]);
    axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes, 'off');
    oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iFirstIndex+k-1));
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
    aCVDataToWrite(iBeatCount,:) = CV;
    idxCV = find(~isnan(CV));
    aCVdata = CV(idxCV);
    aCVdata(aCVdata > 1) = 1;
       
    %plot the CV 
    scatter(oCVAxes,x(idxCV),y(idxCV),14,aCVdata,'filled');
    hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oCVAxes, 'off');
    axis(oCVAxes, 'equal'); axis(oCVAxes, 'tight'); axis(oCVAxes,'off');
    oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iFirstIndex+k-1));
    set(oBeatLabel,'units','normalized');
    set(oBeatLabel,'fontsize',14,'fontweight','bold');
    set(oBeatLabel,'parent',oCVAxes);
    caxis(oCVAxes, [0 1]);
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{k});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
    print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
    sCVMapDosString = strcat(sCVMapDosString, {sprintf(' %s',sSaveFilePath)});
    
    %Plot APD
    if bPrintAPD
        aCurrentAPD = rot90(aAPDs(:,1:end-1),-1);
        aAPDDataToWrite(iBeatCount,:) = aCurrentAPD(aDataPoints);
        APD = aCurrentAPD(aDataPoints);
        F=TriScatteredInterp(xforAPD,yforAPD,APD);
        QAPD = F(xxforAPD,yyforAPD);
        contourf(oAPDAxes, xxforAPD,yyforAPD,QAPD,APDcbarRange);
        axis(oAPDAxes, 'equal'); axis(oAPDAxes, 'tight'); axis(oAPDAxes, 'off');
        caxis(oAPDAxes, [APDcbarmin APDcbarmax]);
        oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sprintf('%d',iFirstIndex+k-1));
        set(oBeatLabel,'units','normalized');
        set(oBeatLabel,'fontsize',14,'fontweight','bold');
        set(oBeatLabel,'parent',oAPDAxes);
        drawnow; pause(.2);
        [pathstr, name, ext, versn] = fileparts(aFileFull{k});
        sSaveFilePath = fullfile(sSavePath,strcat(name, '_APD.bmp'));
        print(oAPDFigure,'-dbmp','-r300',sSaveFilePath)
        fprintf('Printed figure %s\n', sSaveFilePath);
        sAPDMapDosString = strcat(sAPDMapDosString, {sprintf(' %s',sSaveFilePath)});
    end
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
DataHelper.ExportDataToTextFile(strcat(sSavePath,'Beats',sprintf('%d',iFirstBeat),'to',sprintf('%d',iLastBeat),'_CVData.txt'),aCVRowHeader,aCVDataToWrite,'%5.2f',true);
% % Write out APD data
if bPrintAPD
    DataHelper.ExportDataToTextFile(strcat(sSavePath,'Beats',sprintf('%d',iFirstBeat),'to',sprintf('%d',iLastBeat),'_APDData.txt'),aAPDRowHeader,aAPDDataToWrite,'%5.2f',true);
end

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

%montage the APD maps
if bPrintAPD
    sAPDMapDosString = strcat(sAPDMapDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sSavePath, 'APDMapmontage.png');
    sStatus = dos(char(sAPDMapDosString{1}));
    if ~sStatus
        %     figure();
        %     disp(char(sATMapDosString));
        %     imshow(strcat(sSavePath, 'ATMapmontage.png'));
    end
end

% %montage the CV histograms
% sCVHistDosString = strcat(sCVHistDosString, {' -quality 98 -tile 9x5 -geometry 275x206+0+0 '}, sSavePath, 'CVHistmontage.png');
% sStatus = dos(char(sCVHistDosString{1}));
% if ~sStatus
% %     figure();
% %     disp(char(sCVHistDosString));
% %     imshow(strcat(sSavePath, 'CVHistmontage.png'));
% end

%% Create a colour bar for the AT maps
%get the fileparts of the save path
aPathFolders = regexp(sSavePath,'\\','split'); 
sFigureTitle = strcat(char(aPathFolders{end-2}), {' ('}, char(aPathFolders{end-1}), ')');
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
set(oTitle,'string','Activation Time (ms)','position',[0.5 2]);
oFigureTitle = text('string', sFigureTitle, 'parent', oColorBar);
set(oFigureTitle, 'units', 'normalized');
set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
set(oFigureTitle, 'position', [0 2.5]);
%set the paper size
sSaveFilePath = fullfile(sSavePath,'ATcolorbar.bmp');
print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
sColorBarImage = sSaveFilePath;
sSaveFilePath = fullfile(sSavePath,strcat('Beats',sprintf('%d',iFirstBeat),'to',sprintf('%d',iLastBeat),'_ATMapmontage_cbar.png'));
sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
        {sprintf(' %s', sSavePath)}, 'ATMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sAppend{1}));
sAppend = strcat('del',{sprintf(' %s', sSavePath)}, 'ATMapmontage.png');
sStatus = dos(char(sAppend{1}));

%% Create a colour bar for the CV maps
oCbarFigure = figure(); oAxes = axes();
set(oCbarFigure,'paperunits','inches');
set(oCbarFigure,'paperposition',[0 0 dMontageWidth dMontageHeight]);
set(oCbarFigure,'papersize',[dMontageWidth dMontageHeight]);
scatter(oAxes,x(idxCV),y(idxCV),16,aCVdata,'filled');
    hold(oAxes, 'on'); quiver(oAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',0.6); hold(oAxes, 'off');
axis(oAxes, 'equal'); axis(oAxes, 'tight'); axis(oAxes,'off');
caxis([0 1]);
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));

oColorBar = cbarf([0 1], 0:0.1:1, 'horiz');
oTitle = get(oColorBar, 'title');
set(oTitle,'units','normalized');
set(oTitle,'fontsize',8);
set(oTitle,'string','Velocity (m/s)','position',[0.5 2]);
oFigureTitle = text('string', sFigureTitle, 'parent', oColorBar);
set(oFigureTitle, 'units', 'normalized');
set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
set(oFigureTitle, 'position', [0 2.5]);
%set the paper size
sSaveFilePath = fullfile(sSavePath,'CVcolorbar.bmp');
print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
sColorBarImage = sSaveFilePath;
sSaveFilePath = fullfile(sSavePath,strcat('Beats',sprintf('%d',iFirstBeat),'to',sprintf('%d',iLastBeat),'_CVMapmontage_cbar.png'));
sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
        {sprintf(' %s', sSavePath)}, 'CVMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sAppend{1}));
sAppend = strcat('del',{sprintf(' %s', sSavePath)}, 'CVMapmontage.png');
sStatus = dos(char(sAppend{1}));

%% Create a colour bar for the APD maps
if bPrintAPD
    oCbarFigure = figure(); oAxes = axes();
    set(oCbarFigure,'paperunits','inches');
    set(oCbarFigure,'paperposition',[0 0 dMontageWidth dMontageHeight]);
    set(oCbarFigure,'papersize',[dMontageWidth dMontageHeight]);
    contourf(oAxes, xxforAPD,yyforAPD,QAPD,APDcbarRange);
    caxis([APDcbarmin APDcbarmax]);
    colormap(oAxes, colormap(flipud(colormap(jet))));
    % cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
    axis(oAxes, 'equal'); axis(oAxes, 'tight');
    oColorBar = cbarf([APDcbarmin APDcbarmax], floor(APDcbarmin):1:ceil(APDcbarmax), 'horiz');
    oTitle = get(oColorBar, 'title');
    set(oTitle,'units','normalized');
    set(oTitle,'fontsize',8);
    set(oTitle,'string','Action Potential Duration (ms)','position',[0.5 2]);
    oFigureTitle = text('string', sFigureTitle, 'parent', oColorBar);
    set(oFigureTitle, 'units', 'normalized');
    set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
    set(oFigureTitle, 'position', [0 2.5]);
    %set the paper size
    sSaveFilePath = fullfile(sSavePath,'APDcolorbar.bmp');
    print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
    sStatus = dos(char(sChopString{1}));
    sColorBarImage = sSaveFilePath;
    sSaveFilePath = fullfile(sSavePath,strcat('Beats',sprintf('%d',iFirstBeat),'to',sprintf('%d',iLastBeat),'_APDMapmontage_cbar.png'));
    sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
        {sprintf(' %s', sSavePath)}, 'APDMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
    sStatus = dos(char(sAppend{1}));
    sAppend = strcat('del',{sprintf(' %s', sSavePath)}, 'APDMapmontage.png');
    sStatus = dos(char(sAppend{1}));
end