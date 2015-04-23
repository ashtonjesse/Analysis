close all;
% % clear all;
% % 
% % %Select the files we want to plot
% % [sDataFileNames,sDataPathName]=uigetfile('*.*','Select CSV file(s) that contains optical beat information','MultiSelect','on');
% % %Make sure the dialogs return char objects
% % if (isempty(sDataFileNames) && ~ischar(sDataPathName))
% %     break
% % end
% 
% %initialise variables
% rowdim = 41;
% coldim = 41;
% dRes = 0.190;
% iScaleFactor = 6;
% r2 = 0.001;
% 
% %get file names
% aFileFull = strcat(sDataPathName,sDataFileNames);
% sSavePath = sDataPathName;
% %do hardy interpolation
% oMapData = fHardy(aFileFull{1},rowdim,coldim,dRes,iScaleFactor,r2);
% 
% %create the figure and axes
% oATFigure = figure(); oATAxes = axes();
% 
% %Set montage size
% dMontageWidth = 9.47; %in inches
% dMontageHeight = 4.78; %in inches
% iMontageX = 8;
% iMontageY = 3;
% dWidth = dMontageWidth/(iMontageX); %in inches
% dHeight = dMontageHeight/iMontageY; %in inches
% set(oATFigure,'paperunits','inches');
% set(oATFigure,'paperposition',[0 0 dWidth dHeight])
% set(oATFigure,'papersize',[dWidth dHeight])
% set(oATAxes,'units','normalized');
% set(oATAxes,'outerposition',[0 0 1 1]);
% aTightInset = get(oATAxes, 'TightInset');
% aPosition(1) = aTightInset(1)+0.1;
% aPosition(2) = aTightInset(2)-0.1;
% aPosition(3) = 1-aTightInset(1)-aTightInset(3)-0.1;
% aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
% set(oATAxes, 'Position', aPosition);
% 
% %set colour bar properties
% cbarmin = min(oMapData.RawData);
% cbarmax = max(oMapData.RawData);
% cbarRange = cbarmin:1:cbarmax;
% 
% %plot
% contourf(oATAxes, oMapData.x, oMapData.y, oMapData.z, cbarRange);
% caxis(oATAxes,[cbarmin cbarmax]);
% colormap(oATAxes, colormap(flipud(colormap(jet))));
% axis(oATAxes, 'equal'); axis(oATAxes, 'tight'); axis(oATAxes, 'off');
% %find index of first site of activation
% [C iMinRowIndices] = min(oMapData.zraw); %row indices
% [C2 iMinColIndex] = min(C); %column index
% hold(oATAxes,'on');
% plot(oATAxes, oMapData.x(iMinColIndex), oMapData.y(iMinRowIndices(iMinColIndex)), ...
%     'MarkerSize',8,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
% hold(oATAxes,'off');
% % set(get(oATAxes,'ylabel'),'string','Length (mm)','fontunits','points');
% % set(get(oATAxes,'ylabel'),'fontsize',8);
% % oYLabelPosition = get(get(oATAxes,'ylabel'),'position');
% % set(get(oATAxes,'ylabel'),'position',[oYLabelPosition(1)+0.0005,oYLabelPosition(2),oYLabelPosition(3)]);
% % oTitle = title(oATAxes,sprintf('%d',1));
% % set(oTitle,'units','normalized');
% % set(oTitle,'fontsize',14,'fontweight','bold');
% 
% % %create beat label
% % %get beat number from name
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(sDataFileNames{1}), '_');
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
% sLabelBeat = char(splitStr{1});
% oTitle = title(oATAxes,sLabelBeat);
% set(oTitle,'units','normalized');
% set(oTitle,'fontsize',26,'fontweight','bold');
% %aLabelPosition = [min(min(xx))+0.2, max(max(yy))-0.5];%for top left
% % aLabelPosition = [min(min(oMapData.x))+0.2, min(min(oMapData.y))+0.5];%for bottom left
% % oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sLabelBeat);
% % set(oBeatLabel,'units','normalized');
% % set(oBeatLabel,'fontsize',14,'fontweight','bold');
% % set(oBeatLabel,'parent',oATAxes);
% 
% 
% %Print figure
% drawnow; pause(.2);
% [pathstr, name, ext, versn] = fileparts(aFileFull{1});
% sSaveFilePath = fullfile(sSavePath ,strcat(name, '_AT.bmp'));
% print(oATFigure,'-dbmp','-r300',sSaveFilePath)
% fprintf('Printed figure %s\n', sSaveFilePath);
% sATMapDosString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ', {sprintf(' %s',sSaveFilePath)});
% 
% iBeatCount = 1;
% %% loop through the list of files and read in the data
% for k = 2:numel(sDataFileNames)
%     %increment counter
%     iBeatCount = iBeatCount + 1;
%     %do hardy interpolation
%     oMapData = fHardy(aFileFull{k},rowdim,coldim,dRes,iScaleFactor,r2);
%     %plot
%     contourf(oATAxes, oMapData.x, oMapData.y, oMapData.z, cbarRange);
%     caxis(oATAxes, [cbarmin cbarmax]);
%     axis(oATAxes, 'equal'); axis(oATAxes, 'tight');
%     %find index of first site of activation
%     [C iMinRowIndices] = min(oMapData.zraw); %row indices
%     [C2 iMinColIndex] = min(C); %column index
%     hold(oATAxes,'on');
%     plot(oATAxes, oMapData.x(iMinColIndex), oMapData.y(iMinRowIndices(iMinColIndex)), ...
%         'MarkerSize',8,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
%     hold(oATAxes,'off');
%     %get the beat number from the file name
%     [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(sDataFileNames{k}), '_');
%     [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
%     sLabelBeat = char(splitStr{1});
%     oTitle = title(oATAxes,sLabelBeat);
%     set(oTitle,'units','normalized');
%     set(oTitle,'fontsize',26,'fontweight','bold');
%     %     oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), sLabelBeat);
%     %     set(oBeatLabel,'units','normalized');
%     %     set(oBeatLabel,'fontsize',14,'fontweight','bold');
%     %     set(oBeatLabel,'parent',oATAxes);
%     
%     %     %check if this map needs axes
%     dLabelBeat = str2double(sLabelBeat);
%     if dLabelBeat == 56
%         set(oATAxes,'FontUnits','points');
%         set(oATAxes,'FontSize',12);
%         aYticks = str2num(get(oATAxes,'yticklabel'));
%         aYticks = aYticks - aYticks(1);
%         aYtickstring = cellstr(num2str(aYticks));
%         aXticks = str2num(get(oATAxes,'xticklabel'));
%         aXtickstring = cellstr(num2str(aXticks));
%         [aXtickstring{:}] = deal('');
%         for i=1:length(aYticks)
%             %Check if the label has a decimal place and hide this label
%             if ~isempty(strfind(char(aYtickstring{i}),'.'))
%                 aYtickstring{i} = '';
%             elseif ~mod(i,2)
%                 aYtickstring{i} = '';
%             end
%         end
%         set(oATAxes,'xticklabel', char(aXtickstring));
%         set(oATAxes,'xtickmode','manual');
%         set(oATAxes,'yticklabel', char(aYtickstring));
%         set(oATAxes,'ytickmode','manual');
%         set(oATAxes,'Box','off');
%         set(oATAxes,'ticklength',[0.04 0]);
%         set(oATAxes,'linewidth',1.5);
%     else
%         axis(oATAxes, 'off');
%     end
%          
%     drawnow; pause(.2);
%     %save to file
%     [pathstr, name, ext, versn] = fileparts(aFileFull{k});
%     sSaveFilePath = fullfile(sSavePath,strcat(name, '_AT.bmp'));
%     print(oATFigure,'-dbmp','-r300',sSaveFilePath)
%     fprintf('Printed figure %s\n', sSaveFilePath);
%     sATMapDosString = strcat(sATMapDosString, {sprintf(' %s',sSaveFilePath)});
% 
% end
% %get the numbers for the first and last beats
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(sDataFileNames{1}), '_');
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
% sFirstBeat = char(splitStr{1});
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(sDataFileNames{end}), '_');
% [~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
% sLastBeat = char(splitStr{1});
% 
% %montage the AT maps
% iPixelWidth = dWidth*300;
% iPixelHeight = dHeight*300;
% sATMapDosString = strcat(sATMapDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sSavePath, 'ATMapmontage.png');
% sStatus = dos(char(sATMapDosString{1}));

%% Create a colour bar for the AT maps
%get the fileparts of the save path
aPathFolders = regexp(sSavePath,'\\','split'); 
sFigureTitle = strcat(char(aPathFolders{end-2}), {' ('}, char(aPathFolders{end-1}), ')');
oCbarFigure = figure(); oAxes = axes();
set(oCbarFigure,'paperunits','inches');
set(oCbarFigure,'paperposition',[0 0 dMontageWidth dMontageHeight+0.78]);
set(oCbarFigure,'papersize',[dMontageWidth dMontageHeight+0.78]);
set(oAxes,'outerposition',[0 0 1 1]);
contourf(oAxes, oMapData.x, oMapData.y, oMapData.z, cbarRange);
caxis([cbarmin cbarmax]);
colormap(oAxes, colormap(flipud(colormap(jet))));
% cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oAxes, 'equal'); axis(oAxes, 'tight');
oColorBar = cbarf([cbarmin cbarmax], cbarRange, 'vert');
oTitle = get(oColorBar, 'title');
set(oTitle,'units','normalized');
set(oTitle,'fontsize',18);
set(oTitle,'fontweight','bold');
set(oTitle,'string','Time (ms)');
%set the paper size
sSaveFilePath = fullfile(sSavePath,'ATcolorbar.bmp');
print(oCbarFigure,'-dbmp','-r300',sSaveFilePath);
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveFilePath)}, ...
%         {' -gravity North -chop 0x2070'},{' -gravity South -chop 0x143'}, {sprintf(' %s', sSaveFilePath)});
% sStatus = dos(char(sChopString{1}));
% sColorBarImage = sSaveFilePath;
% sSaveFilePath = fullfile(sSavePath,strcat('Beats',sFirstBeat,'to',sLastBeat,'_ATMapmontage_cbar.png'));
% sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sColorBarImage)}, ...
%         {sprintf(' %s', sSavePath)}, 'ATMapmontage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
% sStatus = dos(char(sAppend{1}));
% sAppend = strcat('del',{sprintf(' %s', sSavePath)}, 'ATMapmontage.png');
% sStatus = dos(char(sAppend{1}));