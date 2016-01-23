%figure for HRS 2016 abstract

%create layout
%load data
%plot data
%save to file as gif

close all;
% clear all;
% % % % %Read in the file containing all the optical data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140826\';
% sSubDir = [sBaseDir,'20140826chemo001\'];
% 
% %% read in the optical entities
% sAvOpticalFileName = [sSubDir,'chemo001a_3x3_1ms_g10_LP100Hz-wave.mat'];
% oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
% sOpticalFileName = [sSubDir,'chemo001a_3x3_1ms_g10_LP100Hz-waveEach-forpaper.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
% oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 16;
dHeight = 18;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\ChemoData_#';

%Create plot panel that has 3 rows at top to contain pressure, phrenic and
%heart rate 

oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
xrange = 6;
yrange = 1;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('v',{0.5 0.5});
oSubplotPanel(1).pack('v',{0.6,0.4});
oSubplotPanel(1,1).pack('h',{0.1,0.9});
oSubplotPanel(1,1,2).pack(3);
oSubplotPanel(1,2).pack('h',{0.02,0.98});
oSubplotPanel(1,2,2).pack(yrange,xrange);
oSubplotPanel(1,2,1).pack('v',{0.2,0.65});

movegui(oFigure,'center');
oSubplotPanel.margin = [12,2,2,2];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
oSubplotPanel(1,1).de.margin = [0 5 0 0];
oSubplotPanel(1,1).de.fontsize = 8;
oSubplotPanel(1,2,1).margin = [0 0 2 0];
oSubplotPanel(1,2,2).margin = [0 0 0 0];
% oSubplotPanel(2).margin = [2 4 2 2];
% oSubplotPanel(3).margin = [0 2 0 2];

%% plot top panel
% dlabeloffset = 3;
% 
% %plot phrenic
% oAxes = oSubplotPanel(1,1,2,3).select();
% aData = oThisPressure.oPhrenic.Electrodes.Processed.Data./ ...
%     (oThisPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
% aBurstData = ComputeDWTFilteredSignalsKeepingScales(oThisPressure.oPhrenic, ...
%     aData,2);
% oThisPressure.oPhrenic.ComputeIntegral(200,aBurstData);
% % aData = oThisPressure.oPhrenic.Electrodes.Processed.Data ./ ...
% %     (oThisPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
% aData = oThisPressure.oPhrenic.Electrodes.Processed.Integral(200:end-5000)/1000;
% aTime = oThisPressure.oPhrenic.TimeSeries(200:end-5000);
% hline = plot(oAxes,aTime,aData,'k');
% set(hline,'linewidth',0.5);
% %set limits
% axis(oAxes,'tight');
% oYLim = get(oAxes,'ylim');
% oXLim = [0 35];
% xlim(oAxes,oXLim);
% axis(oAxes,'off');
% %plot time scale
% oScaleAxes = axes('position',get(oAxes,'position')-[0 0.02 0 0]);
% plot(oScaleAxes,[oXLim(2)-5; oXLim(2)], [oYLim(1)+0.1; oYLim(1)+0.1], '-k','LineWidth', 2)
% xlim(oScaleAxes,oXLim);
% ylim(oScaleAxes,oYLim);
% axis(oScaleAxes,'off');
% oLabel = text(oXLim(2)-2.5,oYLim(1)-0.05, '5 s', 'parent',oScaleAxes, ...
%         'FontUnits','points','horizontalalignment','center');
% set(oLabel,'FontSize',10);
% 
% % %set labels
% oYlabel = ylabel(oAxes,'\intPND');
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
% set(oYlabel,'position',oPosition);
% oNewYLabel = text(oPosition(1),oPosition(2),'\intPND','parent',oAxes,'fontsize',8,'horizontalalignment','center');
% axis(oAxes,'off');
% 
% %plot HR
% oAxes = oSubplotPanel(1,1,2,2).select();
% %convert rates into coupling intervals
% aCouplingIntervals = 60000 ./ oThisPressure.oRecording(1).Electrodes.Processed.BeatRates;
% aTimes = oThisPressure.oRecording(1).TimeSeries(oThisPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
% scatter(oAxes,aTimes,aCouplingIntervals,16,'k','filled');
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% set(oAxes,'yminortick','on');
% 
% %set limits
% xlim(oAxes,oXLim);
% ylim(oAxes,[200 800]);
% %set labels
% oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1);% + (oYLim(2) - oYLim(1)) / 10
% set(oYlabel,'position',oPosition);
% iBeats = [22,29,32,36,37,39];
% sLabel = {'1','2','3','4','5','6'};
% dIncremements = [100,100,-150,200,100,220];
% dLineIncrements = [30,30,-30,30,30,30];
% hold(oAxes,'on');
% for k = 1:numel(iBeats)
%     iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
%     oBeatLabel = text(aTimes(iIndex), ...
%         aCouplingIntervals(iIndex)+dIncremements(k), sLabel{k},'parent',oAxes, ...
%         'FontWeight','bold','FontUnits','points','horizontalalignment','center');
%     set(oBeatLabel,'FontSize',8);
%     
%     oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)],...
%         [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
%     set(oLine,'color',[0.5 0.5 0.5]);
%     
% end
% 
% 
% %plot pressure data
% oAxes = oSubplotPanel(1,1,2,1).select();
% aData = oThisPressure.FilterData(oThisPressure.Processed.Data, 'LowPass', oThisPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
% aData(1:10000) = NaN;
% aTime = oThisPressure.TimeSeries.Processed;
% hline = plot(oAxes,aTime,aData,'k');
% set(hline,'linewidth',0.5);
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% %set limits
% xlim(oAxes,oXLim);
% ylim(oAxes,[50 80]);
% %set labels
% oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1);
% set(oYlabel,'position',oPosition);
% %put indication of stimulus timing
% hold(oAxes,'on');
% plot(oAxes,[4.051 4.923], [65 65], 'k-','linewidth',2);
% text(4.051+(4.923-4.051)/2,60,'KCN','fontsize',8,'horizontalalignment','center');
% hold(oAxes,'off');
% 
% % %plot maps
% %plot the schematic
% aContourRange = [0 12];
% aContours = aContourRange(1):1.2:aContourRange(2);
% %get the interpolation points
% dTextXAlign = 0;
% aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
% aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
% iCount = 0;
% for i = 1:yrange
%     for j = 1:xrange
%         iCount = iCount + 1;
%         oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'abhsm', 24, iBeats(iCount), []);
%         oAxes = oSubplotPanel(1,2,2,i,j).select();
%              %plot the schematic
%         oOverlay = axes('position',get(oAxes,'position'));
%         colormap(oOverlay,flipud(jet));
%         set(oOverlay,'box','off','color','none');
%         if iCount == 1
%             oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140826\20140826Schematic_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
%         else
%             oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140826\20140826Schematic_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
%         end
%         %         %make it transparent in the right places
%         aCData = get(oImage,'cdata');
%         aBlueData = aCData(:,:,3);
%         aAlphaData = aCData(:,:,3);
%         aAlphaData(aBlueData < 100) = 1;
%         aAlphaData(aBlueData > 100) = 1;
%         aAlphaData(aBlueData == 100) = 0;
%         aAlphaData = double(aAlphaData);
%         set(oImage,'alphadata',aAlphaData);
%         axis(oOverlay,'tight');
%         axis(oOverlay,'off');
%         
%         oOriginAxes = axes('position',get(oAxes,'position'));
%         aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
%         aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats(iCount),:)).Coords});
%         if ~isempty(aOriginCoords)
%             scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
%                 'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
%         end
%         [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats(iCount)).z,aContours);
%         axis(oAxes,'equal');
%         set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
%         axis(oAxes,'off');
%         axis(oOriginAxes,'equal');
%         set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
%         axis(oOriginAxes,'off');
%         cmap = colormap(oAxes, flipud(jet(aContourRange(2)-aContourRange(1))));
%         caxis(oAxes,aContourRange);
%                
%    
%         
%         if (i == 1) && (j == 1)
%             %create labels
%             %             oLabel = text(aXlim(1)+0.8,aYlim(2)-3.5,'SVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
%             %             set(oLabel,'fontsize',6);
%             %             oLabel = text(aXlim(2)-0.5,aYlim(1)+0.5,'IVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
%             %             set(oLabel,'fontsize',6);
%             %             oLabel = text(aXlim(1)+6,aYlim(2)-5.3,'CT','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
%             %             set(oLabel,'fontsize',6,'color','w');
%             oLabel = text(aXlim(2)-2.2,aYlim(1)+1,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
%             set(oLabel,'fontsize',8);
%         end
%         % % %         label beat number, rate and pressure
%         % % %         get pressure
%         oLabel = text(aXlim(1)+3,aYlim(2)-1,sLabel{iCount},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
%         set(oLabel,'fontsize',10);
%         oLabel = text(aXlim(1)+0.5,aYlim(1)+0.4,sprintf('%4.0f ms',aCouplingIntervals(iBeats(iCount))),...
%             'parent',oOriginAxes,'fontunits','points','HorizontalAlignment','left','backgroundcolor','w','margin',0.001);
%         set(oLabel,'fontsize',8);
%     end
% end
% 
% oAxes = oSubplotPanel(1,2,1,2).select();
% aCRange = [0 10.8];
% aContours = 0:1.2:10.8;
% cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT');
% aCRange = [0 12];
% oLabel = text(-2.8,(aCRange(2)-aCRange(1))/2,'Atrial AT (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center','rotation',90);
% set(oLabel,'fontsize',8);
% 
% %create text labels
% oLabel = annotation('textbox','position',[0 0.9 0.1 0.1],'string','A','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0 0.8 0.1 0.1],'string','B','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0 0.69 0.1 0.1],'string','C','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0 0.59 0.1 0.1],'string','D','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0 0.4 0.1 0.1],'string','E','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0 0.2 0.1 0.1],'string','F','linestyle','none','fontsize',12,'fontweight','bold');
% export_fig(strrep(sFileSavePath, '#', '1'),'-png','-r300','-nocrop')

%% create second panel

% % get data
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ...
    };
aPressureData = cell(1,numel(aFolders));
for i = 1:numel(aFolders)
    sFileName = [aFolders{i},'\Pressure.mat'];
    oPressure = GetPressureFromMATFile(Pressure,sFileName,'Optical');
    aPressureData{i} = oPressure;
    fprintf('Got file %s\n',sFileName);
end


% set up axes
oSubplotPanel(2).pack('v',{0.8,0.1,0.03});
oSubplotPanel(2,1).pack(numel(aFolders));
oSubplotPanel(2).de.margin = [0 0 0 0];

iScatterSize = 16;
aYlim = [100 900];
aXlim = [-8 20];
aCRange = [0 7];
aIndices = [1 1];
for j = 1:numel(aPressureData)
    aFile = aFolders{j};
    [pathstr, name, ext, versn] = fileparts(char(aFile));
    load([pathstr,'\ChemoLocationData.mat']);
    p = 1;
    oPressure = aPressureData{j};
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    aAdjustedTimes = cell(1,numel(aDistance{aIndices(j)}));
        %set up axes
    oSubplotPanel(2,1,numel(aFolders)-j+1).pack('v',{0.2,0.03,0.54,0.03,0.2});
    oAxes = oSubplotPanel(2,1,numel(aFolders)-j+1,3).select();
    oPhrenicAxes = oSubplotPanel(2,1,numel(aFolders)-j+1,5).select();
    if j == 1
        oBaseAxes = oAxes;
        oDummyAxes = oSubplotPanel(2,1,numel(aFolders)-j+1,1).select();
        oPressureAxes = axes('position',get(oDummyAxes,'position')-[0 0.05 0 0]);
        axis(oDummyAxes,'off');
    else
        oPressureAxes = oSubplotPanel(2,1,numel(aFolders)-j+1,1).select();
    end

    
    iRecordingIndex = 1;
    aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
    aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
    aAdjustedTimes{p} = aTimes - oPressure.HeartRate.Decrease.BeatTimes(1);
    hold(oAxes, 'on');
    %plot baseline
    if p == 1 && j == 1
        iMinIdx = 2;
        dBaseline = aCouplingIntervals(iMinIdx);
        [dTopline iMaxIdx] = max(aCouplingIntervals);
    elseif p == 1
        [dBaseline iMinIdx] = min(aCouplingIntervals);
        [dTopline iMaxIdx] = max(aCouplingIntervals);
    end
    if j == 1
        oLine = plot(oAxes,[aAdjustedTimes{p}(2); aAdjustedTimes{p}(42)], [dBaseline-30; dBaseline-30], '--k','LineWidth', 0.5);
        oLine = plot(oAxes,[aAdjustedTimes{p}(52); aAdjustedTimes{p}(end-1)], [dBaseline-30; dBaseline-30], '--k','LineWidth', 0.5);
    else
        oLine = plot(oAxes,[aAdjustedTimes{p}(2); aAdjustedTimes{p}(end-1)], [dBaseline-30; dBaseline-30], '--k','LineWidth', 0.5);
    end
    % % %     %get locations
    try
        aLocs =  aDistance{aIndices(j)}{p}(:,1);
        a2ndLocs = aDistance{aIndices(j)}{p}(:,2);
        a1stLocIndex = isnan(aDistance{aIndices(j)}{p}(:,2));
        a2ndLocIndex = ~isnan(aDistance{aIndices(j)}{p}(:,2));
    catch ex
        aLocs =  aDistance{aIndices(j)}(:,1);
        a2ndLocs = aDistance{aIndices(j)}(:,2);
        a1stLocIndex = isnan(aDistance{aIndices(j)}(:,2));
        a2ndLocIndex = ~isnan(aDistance{aIndices(j)}(:,2));
    end
        
    if size(aLocs,1) ~= numel(aCouplingIntervals);
        x = 1;
    end
    
    %plot 1st locs
    scatter(oAxes, aAdjustedTimes{p}(a1stLocIndex), aCouplingIntervals(a1stLocIndex),iScatterSize,aLocs(a1stLocIndex),'filled');
    %plot 1st locs offset
    scatter(oAxes, aAdjustedTimes{p}(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)+25,iScatterSize,aLocs(a2ndLocIndex),'filled');
    %plot 2nd locs offset
    scatter(oAxes, aAdjustedTimes{p}(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)-25,iScatterSize,a2ndLocs(a2ndLocIndex),'filled');
    cmap = colormap(oAxes, jet(aCRange(2)-aCRange(1)));
    caxis(oAxes, aCRange);
    
    set(oAxes,'ylim',aYlim);
    set(oAxes,'xlim',aXlim);
    
    %put y axis on and label ends
    oLine = plot(oAxes,[aXlim(1)+1; aXlim(1)+1], [dBaseline; dBaseline+200], '-k','LineWidth', 2);
    if j == 1
        olabel = text(aXlim(1)+0.7,dBaseline+100, '200 ms', 'HorizontalAlignment','right',...
            'parent',oAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',10);
    end
    
    offset = 0;
    Index = 1;
    %need to label the shortest and longest coupling intervals but also
    %some need labels during the main part of the response
    switch (j)
        case 1
            olabel = text(aAdjustedTimes{1}(Index)+offset,aCouplingIntervals(2)+80, sprintf('%4.0f ms',aCouplingIntervals(2)), 'HorizontalAlignment','left','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
            set(olabel,'fontsize',8);
            olabel = text(aAdjustedTimes{1}(iMaxIdx),max(aCouplingIntervals)+80, sprintf('%4.0f ms',max(aCouplingIntervals)), 'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
            set(olabel,'fontsize',8);
            [figx figy] = dsxy2figxy(oAxes, [7.586 ; 8.506], [min(aCouplingIntervals)-60;min(aCouplingIntervals)-10]);
            annotation('textarrow',figx,figy,'string',sprintf('%3.0f ms',min(aCouplingIntervals)),...
                'headstyle','plain','headwidth',4,'headlength',4,'headstyle','plain','fontweight','bold','fontsize',8);
        otherwise
            olabel = text(aAdjustedTimes{1}(Index)+offset,dBaseline+80, sprintf('%4.0f ms',dBaseline), 'HorizontalAlignment','left','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
            set(olabel,'fontsize',8);
            olabel = text(aAdjustedTimes{1}(iMaxIdx),dTopline+80, sprintf('%4.0f ms',dTopline), 'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
            set(olabel,'fontsize',8);
    end
        
    hold(oAxes, 'off');
    set(oAxes,'color','none','box','off');
    axis(oAxes,'off');
    
    %     %plot pressure data
    aTimeToPlot = oPressure.TimeSeries.Original(25000:end-20000) - oPressure.HeartRate.Decrease.BeatTimes(1);
    aDataToPlot = aPressureProcessedData(25000:end-20000);
    [PressureMax iPressureMaxIdx] = max(aDataToPlot);
    plot(oPressureAxes, aTimeToPlot, aDataToPlot, 'linewidth',0.5,'color','k');
    olabel = text(aTimeToPlot(1),aDataToPlot(1), sprintf('%4.0f',aDataToPlot(1)), ...
        'HorizontalAlignment','right','parent',oPressureAxes,'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',8);
    axis(oPressureAxes,'tight');
    ylimits = get(oPressureAxes,'ylim')+[-1 1];
    set(oPressureAxes,'ylim',ylimits);
    set(oPressureAxes,'xlim',aXlim);
    hold(oPressureAxes,'on');
    %put y axis on and label ends
    oLine = plot(oPressureAxes,[aXlim(1)+1; aXlim(1)+1], [ylimits(1); ylimits(1)+15], 'LineWidth', 2,'color','k');
    if j == 1
        olabel = text(aXlim(1)+0.7,ylimits(1)+7.5, '15 mmHg', 'HorizontalAlignment','right',...
            'parent',oPressureAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',10);
        %indicate stimulus timing
        oLine = plot(oPressureAxes,[-2.91085,-2.91085+(2.91085-2.10)], [82; 82],'k-','LineWidth', 2);
        text(-2.10-(2.91085-2.10)/2, 76,'KCN','fontsize',8,'parent',oPressureAxes,'horizontalalignment','center');
    elseif j == 2
        %indicate stimulus timing
        oLine = plot(oPressureAxes,[-2.694,-2.694+(2.694-1.49)], [76; 76],'k-','LineWidth', 2);
        text(-1.49-(2.694-1.49)/2, 70,'KCN','fontsize',8,'parent',oPressureAxes,'horizontalalignment','center');
    end
    
    hold(oPressureAxes, 'off');
    %put arrow on to indicate stimulus timing 
    set(oPressureAxes,'color','none','box','off');
    axis(oPressureAxes,'off');
    
    % %     %plot phrenic data
    aData =  oPressure.oPhrenic.Electrodes.Processed.Data./ ...
        (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
    aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, aData,2);
    oPressure.oPhrenic.ComputeIntegral(200,aBurstData);
    aData = oPressure.oPhrenic.Electrodes.Processed.Integral/1000;
    aTimeToPlot = oPressure.oPhrenic.TimeSeries - oPressure.HeartRate.Decrease.BeatTimes(1);
    aPointsToPlot = aTimeToPlot > aXlim(1)+1;
    plot(oPhrenicAxes,aTimeToPlot(aPointsToPlot),aData(aPointsToPlot),'-','linewidth',0.5,'color','k');
    axis(oPhrenicAxes,'tight');
    set(oPhrenicAxes,'xlim',aXlim);
    oYLim = get(oPhrenicAxes,'ylim');
    set(oPhrenicAxes,'color','none','box','off');
    axis(oPhrenicAxes,'off');
    hold(oPhrenicAxes,'on');
    %put y axis on and label ends
    if j == 1
        olabel = text(aXlim(1)+0.7,oYLim(1)+(oYLim(2)-oYLim(1))/2, '\intPND', 'HorizontalAlignment','right',...
            'parent',oPhrenicAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',10);
    end
    hold(oPhrenicAxes,'off');
end
%create time scale
oScaleAxes = axes('parent',oFigure);
plot(oScaleAxes,[aXlim(1)+1; aXlim(1)+6], [aYlim(1); aYlim(1)], '-k','LineWidth', 4)
aPosition = get(oBaseAxes,'position');
set(oScaleAxes,'position',[aPosition(1) aPosition(2)-0.06 aPosition(3) aPosition(4)]);
aXlim = get(oBaseAxes,'xlim');
aYlim = get(oBaseAxes,'ylim');
set(oScaleAxes,'xlim',aXlim);
set(oScaleAxes,'ylim',aYlim);
%label the scale
olabel = text(aXlim(1)+1+5/2,aYlim(1)-100, '5 s', 'HorizontalAlignment','center','parent',oScaleAxes,'color','k','fontunits','points');
set(olabel,'fontsize',10);
axis(oScaleAxes,'off');

%create scalebar
oSubplotPanel(2,3).pack('h',{0.1,0.75});
oBarAxes = oSubplotPanel(2,3,2).select();
aCRange = [aCRange(1) aCRange(2)-1];
aContours = aCRange(1):1:aCRange(2);
cbarf_edit(aCRange, aContours,'horiz','linear',oBarAxes,'Distance');
aCRange = [aCRange(1) aCRange(2)+1];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+abs(aCRange(1)),-2.5,'DPS (mm)','parent',oBarAxes,'fontunits','points','horizontalalignment','center');
set(oXlabel,'fontsize',8);
dcm_obj = datacursormode(oFigure);
set(dcm_obj,'UpdateFcn',@ScatterCursorCallback);

set(oFigure,'resizefcn',[]);
set(oFigure,'color','none');
% print(oFigure,'-dpsc','-r600',sFileSavePath)
% printgif(oFigure,'-r600',sFileSavePath)

export_fig(strrep(sFileSavePath, '#', '2'),'-png','-r300','-nocrop','-transparent','-painters')
% %crop the images
sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.png',strrep(sFileSavePath, '#', '1'))}, ...
    {sprintf(' %s.png',strrep(sFileSavePath, '#', '2'))}, {' -gravity center -composite'},{sprintf(' %s.png', strrep(sFileSavePath, '_#', ''))});
sStatus = dos(char(sChopString{1}));
% % delete(sprintf('%s.png',strrep(sFileSavePath, '#','1')),sprintf('%s.png',strrep(sFileSavePath, '#', '2')));