% close all;
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ... %lots of competition on the way down. worth fitting DD
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ... %another good example of uncoupling
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ... %superior shift prior to inferior 
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
%     }};
% % aControlFiles = {{...
% %      'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...
% %     }};
% % 
% % aControlFiles = {{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001' ...
% %     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ...
% %     }};
% 
% %create the figure
% dWidth = 20;
% if numel(aControlFiles) > 5
%     dHeight = 8;
%     NumCols = 5;
%     NumRows = 2;
% else
%     dHeight = 4;
%     NumCols = 5;
%     NumRows = 1;
% end
% oFigure = figure();
% 
% %set up figure
% set(oFigure,'color','white')
% set(oFigure,'inverthardcopy','off')
% set(oFigure,'PaperUnits','centimeters');
% set(oFigure,'PaperPositionMode','manual');
% set(oFigure,'Units','centimeters');
% set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
% set(oFigure,'Resize','off');
% 
% %set up panel
% oSubplotPanel = panel(oFigure,'no-manage-font');
% oSubplotPanel.pack(NumRows,NumCols);
% oSubplotPanel.margin = [1 1 1 1]; %left bottom right top
% iRowIndex = 1;
% iColIndex = 1;
% for p = 1:numel(aControlFiles)
%     aFolder = aControlFiles{p};
%     [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
%     [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
%     [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
%     sStimulationType = splitStr{end}(1:end-3);
%     
%     for j = 1:numel(aFolder)
%         %load the optical file
%         listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
%         aFilesInFolder = {listing(:).name}; %convert to cell array
%         aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%         aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
%         oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
%         fprintf('Loaded %s\n', aOpticalFileName);
%         %plot the map 
%         oAxes = oSubplotPanel(iRowIndex,iColIndex).select();
%         oOverlay = axes('position',get(oAxes,'position'));
%         %plot the schematic
%         oImage = imshow(['D:\Users\jash042\Documents\DataLocal\Imaging\Prep\',name(1:8),'\',name(1:8),'Schematic_guide.bmp'],'Parent', oOverlay, 'Border', 'tight');
%         %make it transparent in the right places
%         aCData = get(oImage,'cdata');
%         aBlueData = aCData(:,:,3);
%         aAlphaData = aCData(:,:,3);
%         aAlphaData(aBlueData < 100) = 1;
%         aAlphaData(aBlueData > 100) = 1;
%         aAlphaData(aBlueData == 100) = 0;
%         aAlphaData = double(aAlphaData);
%         set(oImage,'alphadata',aAlphaData);
%         set(oOverlay,'box','off','color','none');
%         axis(oOverlay,'tight');
%         axis(oOverlay,'off');
%         % plot SVC-IVC axis
%         aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
%         oAxesElectrodes = oOptical.Electrodes(aAxisData);
%         aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
%         scatter(oAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
%             36,'k','filled');
%         aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linestyle','-','linewidth',1,'color','k','parent',oAxes);
%         axis(oAxes,'equal');
%         aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
%         aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
%         set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
%         axis(oAxes,'off');
%         if p > 4 && iRowIndex < 2
%             iRowIndex = iRowIndex + 1;
%             iColIndex = 1;
%         else
%             iColIndex = iColIndex + 1;
%         end
%         
%     end
%     
% % end
% aData = ans.oGuiHandle.oOptical.Electrodes(255).Processed.Data;
% aSlope = ans.oGuiHandle.oOptical.Electrodes(255).Processed.Slope;
% aBeats = ans.oGuiHandle.oOptical.Beats.Indexes;
% aBaseline = NaN(length(aData),1);
% for ii = 1:size(aBeats,1)-1
%     aBaseline(aBeats(ii,2):aBeats(ii+1,1)) = ...
%         aData(aBeats(ii,2):aBeats(ii+1,1));
% end
% 
% x = inpaint_nans(aBaseline,4);
% N = size(x,1);
% bp = aBeats(:,1);
% bp = unique([0;double(bp(:));N-1]);	% Include both endpoints
% lb = length(bp)-1;
% % Build regressor with linear pieces + DC
% a  = [zeros(N,lb,class(x)) ones(N,1,class(x))];
% for kb = 1:lb
%     M = N - bp(kb);
%     a((1:M)+bp(kb),kb) = (1:M)'/M;
% end
% aDrift = a*(a\x);
% y = aData - aDrift;		% Remove best fit
% aNewSlope = fCalculateMovingSlope(y,7,3);
% hold(ax,'off');
% plot(ax,aSlope,'k');
% hold(ax,'on');
% plot(ax,aNewSlope,'r');

[xlin ylin] = meshgrid(linspace(100,700,10),linspace(0,6,10));
aPoints = horzcat(reshape(xlin,size(xlin,1)*size(xlin,2),1),reshape(ylin,size(ylin,1)*size(ylin,2),1));
DT = DelaunayTri(aPoints);
aData = horzcat(vertcat(aAllInitialCL{:}),vertcat(aAllInitialLocs{:}));
aDensity = zeros(size(DT,1),1);
aValues = zeros(size(aData,1),1);
for jj = 1:size(aData,1)
aDensity(DT.pointLocation(aData(jj,:))) = aDensity(DT.pointLocation(aData(jj,:))) + 1;
end
for jj = 1:size(aData,1)
    aValues(jj) = aDensity(DT.pointLocation(aData(jj,1),aData(jj,2)));
end
scatter(aData(:,1),aData(:,2),18,aValues,'filled');
colormap(hot)
caxis([0 200]);