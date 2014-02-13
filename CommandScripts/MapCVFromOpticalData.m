%This script opens csv files containing activation and repolarisation times, and APDs
%from optical mapping experiments. The ATs are used to calculate a
%conduction velocity field which is then plotted and the figure is printed
%to file.

clear all;
close all;
% 
% %get a list of the csv files in the directory
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro006\';
sSavePath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro006\';
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
AT = aActivationTimes(aActivationTimes > 0);
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
contourf(oATAxes, xx,yy,QAT,cbarRange);
colormap(oATAxes, colormap(flipud(colormap(jet))));
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes,'off');
oTitle = title(oATAxes,sprintf('%d',1));
set(oTitle,'units','normalized');
set(oTitle,'fontsize',26,'fontweight','bold');
drawnow; pause(.2);
[pathstr, name, ext, versn] = fileparts(aFileFull{1});
sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
print(oATFigure,'-dbmp','-r300',sSaveFilePath)
fprintf('Printed figure %s\n', sSaveFilePath);
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
    {' -gravity West -chop 470x0 -gravity East -chop 412x0 -gravity South -chop 0x120'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
if sStatus
    disp('error');
    break;
end
sATMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});

%Plot CVs
[CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
idxCV = find(~isnan(CV));
aCVdata = CV(idxCV);
aCVdata(aCVdata > 2) = 2;
oCVFigure = figure(); oCVAxes = axes();
caxis([0 2]);
scatter(oCVAxes,x(idxCV),y(idxCV),60,aCVdata,'filled');
hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',1); hold(oCVAxes, 'off');
axis(oCVAxes, 'equal'); axis(oCVAxes, 'tight'); axis(oCVAxes,'off');
oTitle = title(oCVAxes,sprintf('%d',1));
set(oTitle,'units','normalized');
set(oTitle,'fontsize',26,'fontweight','bold');
[pathstr, name, ext, versn] = fileparts(aFileFull{1});
sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
drawnow; pause(.2);
print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
    {' -gravity West -chop 470x0 -gravity East -chop 412x0 -gravity South -chop 0x120'}, {sprintf(' %s', sSaveFilePath)});
sStatus = dos(char(sChopString{1}));
if sStatus
    disp('error');
    break;
end
sCVMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});

%Plot a histogram of the CVs
oHistFigure = figure(); oHistAxes = axes();
aCVRange = 0:0.1:2;
aHistData = CV(idxCV);
hist(oHistAxes,aHistData(aHistData<=2),aCVRange);
set(oHistAxes, 'ylim', [0 250]);
oHistTitle = title(oHistAxes,sprintf('%d',1));
set(oHistTitle,'units','normalized');
set(oHistTitle,'fontsize',26,'fontweight','bold');
drawnow; pause(.2);
sSaveFilePath = fullfile(sSavePath,strcat(name, '_CVDist.bmp'));
print(oHistFigure,'-dbmp','-r300',sSaveFilePath)
sCVHistDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});
fprintf('Printed data for %s\n', name);

%loop through the list of files and read in the data
for k = 2:length(aFileFull)
    %get the data from this file 
    [aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(aFileFull{k},rowdim,coldim);
    %actually turns out the data needs to be rotated for display
    aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
    %dispose of the data that has been excluded in the ROI
    [rowIndices colIndices] = find(aActivationTimes > 0);
    AT = aActivationTimes(aActivationTimes > 0);
    %normalise the ATs to first activation
    [C I] = min(AT);
    AT = single(AT - AT(I));
    AT = double(AT);
    x = dRes .* rowIndices;
    y = dRes .* colIndices;
    
    %plot the activation field
    F=TriScatteredInterp(x,y,AT);
    QAT = F(xx,yy);
    contourf(oATAxes, xx,yy,QAT,cbarRange);
    axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes, 'off');
    oTitle = title(oATAxes,sprintf('%d',k));
    set(oTitle,'units','normalized');
    set(oTitle,'fontsize',26,'fontweight','bold');
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{k});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
    print(oATFigure,'-dbmp','-r300',sSaveFilePath)
    fprintf('Printed figure %s\n', sSaveFilePath);
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity West -chop 470x0 -gravity East -chop 412x0 -gravity South -chop 0x120'}, {sprintf(' %s', sSaveFilePath)});
    sStatus = dos(char(sChopString{1}));
    if sStatus
        disp('error');
        break;
    end
    sATMapDosString = strcat(sATMapDosString, {sprintf(' %s',sSaveFilePath)});
    
    %Get Cv data
    [CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
    idxCV = find(~isnan(CV));
    aCVdata = CV(idxCV);
    aCVdata(aCVdata > 2) = 2;

    %plot the CV with neighbourhood 24
    scatter(oCVAxes,x(idxCV),y(idxCV),60,aCVdata,'filled');
    hold(oCVAxes, 'on'); quiver(oCVAxes,x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',1); hold(oCVAxes, 'off');
    axis(oCVAxes, 'equal'); axis(oCVAxes, 'tight'); axis(oCVAxes,'off');
    oTitle = title(oCVAxes,sprintf('%d',k));
    set(oTitle,'units','normalized');
    set(oTitle,'fontsize',26,'fontweight','bold');
    aHistData = CV(idxCV);
    hist(oHistAxes,aHistData(aHistData<=2),aCVRange);
    set(oHistAxes, 'ylim', [0 250]);
    oHistTitle = title(oHistAxes,sprintf('%d',k));
    set(oHistTitle,'units','normalized');
    set(oHistTitle,'fontsize',26,'fontweight','bold');
    drawnow; pause(.2);
    [pathstr, name, ext, versn] = fileparts(aFileFull{k});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_CV.bmp'));
    print(oCVFigure,'-dbmp','-r300',sSaveFilePath)
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
        {' -gravity West -chop 470x0 -gravity East -chop 412x0 -gravity South -chop 0x120'}, {sprintf(' %s', sSaveFilePath)});
    sStatus = dos(char(sChopString{1}));
    if sStatus
        disp('error');
        break;
    end
    sCVMapDosString = strcat(sCVMapDosString, {sprintf(' %s',sSaveFilePath)});
    sSaveFilePath = fullfile(sSavePath,strcat(name, '_CVDist.bmp'));
    print(oHistFigure,'-dbmp','-r300',sSaveFilePath)
    sCVHistDosString = strcat(sCVHistDosString, {sprintf(' %s',sSaveFilePath)});
    fprintf('Printed data for %s\n', name);
end
%montage the AT maps
sATMapDosString = strcat(sATMapDosString, {' -quality 98 -tile 9x5 -geometry 275x302+0+0 '}, sSavePath, 'ATMapmontage.png');
sStatus = dos(char(sATMapDosString{1}));
if ~sStatus
%     figure();
%     disp(char(sATMapDosString));
%     imshow(strcat(sSavePath, 'ATMapmontage.png'));
end

%montage the CV maps
sCVMapDosString = strcat(sCVMapDosString, {' -quality 98 -tile 9x5 -geometry 275x302+0+0 '}, sSavePath, 'CVMapmontage.png');
sStatus = dos(char(sCVMapDosString{1}));
if ~sStatus
%     figure();
%     disp(char(sCVMapDosString));
%     imshow(strcat(sSavePath, 'CVMapmontage.png'));
end

%montage the CV histograms
sCVHistDosString = strcat(sCVHistDosString, {' -quality 98 -tile 9x5 -geometry 275x206+0+0 '}, sSavePath, 'CVHistmontage.png');
sStatus = dos(char(sCVHistDosString{1}));
if ~sStatus
%     figure();
%     disp(char(sCVHistDosString));
%     imshow(strcat(sSavePath, 'CVHistmontage.png'));
end

% hold on; scatter(x,y,50,AT,'filled'); hold off;



%plot the CV with neighbourhood 8
% [CV,Vect]=ReComputeCV([x,y],AT,8,0.1);
% idx = find(~isnan(CV));
% F=TriScatteredInterp(x(idx),y(idx),CV(idx));
% [xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% QAT = F(xx,yy);
% rQAT = reshape(QAT,[prod(size(QAT)),1]);
% rxx = reshape(xx,[prod(size(QAT)),1]);
% ryy = reshape(yy,[prod(size(QAT)),1]);
% figure(); oAxes = axes(); 
% scatter(x(idx),y(idx),60,CV(idx),'filled'); 
% axis(oAxes, 'equal'); axis(oAxes, 'tight'); %hold on; scatter(x,y,10,'k','filled'); hold off; 
% caxis([0 2]);
% cbarf([0 2], 0:0.1:2); 
% %get the histogram of the CVs
% figure(); hist(CV(idx),0:0.1:2);

%plot the CV with neighbourhood 24
% [CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
% idxCV = find(~isnan(CV));
% figure(); oAxes = axes(); 
% scatter(x(idxCV),y(idxCV),60,CV(idxCV),'filled'); 
% hold on; quiver(x(idxCV),y(idxCV),Vect(idxCV,1),Vect(idxCV,2),'color','k','linewidth',2); hold off;
% caxis([0 2]);
% cbarf([0 2], 0:0.2:2); 
% axis(oAxes, 'equal'); axis(oAxes, 'tight'); 
% %hold on; scatter(x,y,10,'k','filled'); hold off; 
% figure(); hist(CV(idxCV),0:0.1:max(CV(idxCV)));

% for i = 1:size(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
%     %Get the full file name and save it to string attribute
%     sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
%     oFigure.oParentFigure.SelectedBeat = i;
%     oFigure.PlotData();
%     
%     oFigure.PrintFigureToFile(sLongDataFileName);
%     sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sLongDataFileName)});
%     sChopString = strcat(sChopString, {' -gravity South -chop 0x100'}, {sprintf(' %s',sLongDataFileName)});
%     sStatus = dos(char(sChopString{1}));
%     if sStatus
%         break
%     end
% end
