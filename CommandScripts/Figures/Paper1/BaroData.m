%figure for HRS 2016 abstract

%create layout
%load data
%plot data
%save to file as gif
% 
close all;
% clear all;
% % % %Read in the file containing all the optical data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\';
% sSubDir = [sBaseDir,'20140723baro007\'];
% 
% %% read in the optical entities
% sAvOpticalFileName = [sSubDir,'baro007_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
% oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
% sOpticalFileName = [sSubDir,'baro007_3x3_1ms_7x_g10_LP100Hz-waveEach-forpaper.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
% oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 16;
dHeight = 18;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\BaroData_#';

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

%% plot top panel
% dlabeloffset = 3.5;
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
% aData = oThisPressure.oPhrenic.Electrodes.Processed.Integral(5000:end-5000)/1000;
% aTime = oThisPressure.oPhrenic.TimeSeries(5000:end-5000);
% hline = plot(oAxes,aTime,aData,'k');
% set(hline,'linewidth',0.5);
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% set(oAxes,'yminortick','on');
% %set limits
% axis(oAxes,'tight');
% % ylim(oAxes,[-55 55]);
% ylim(oAxes,[0 1]);
% oXLim = get(oAxes,'xlim');
% 
% %set labels
% oYlabel = ylabel(oAxes,['\intPND', 10, '(mV)']);
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 6;
% set(oYlabel,'position',oPosition);
% 
% %plot time scale
% hold(oAxes,'on');
% plot([oXLim(2)-5; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
% hold(oAxes,'off');
% oLabel = text(oXLim(2)-2.5,oYLim(1)-0.18, '5 s', 'parent',oAxes, ...
%         'FontUnits','points','horizontalalignment','center');
% set(oLabel,'FontSize',10);
% 
% 
% %plot HR
% oAxes = oSubplotPanel(1,1,2,2).select();
% %convert rates into coupling intervals
% aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(1).Electrodes.Processed.BeatRates];
% aTimes = oThisPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
% scatter(oAxes,aTimes,aCouplingIntervals,16,'k','filled');
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% set(oAxes,'yminortick','on');
% 
% %set limits
% xlim(oAxes,oXLim);
% ylim(oAxes,[150 600]);
% %set labels
% oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1);% + (oYLim(2) - oYLim(1)) / 10
% set(oYlabel,'position',oPosition);
% iBeats = [40,49,50,51,52,74];
% sLabels = {'1','2','3','4','5','6'};
% dIncremements = [100,-100,100,140,100,180];
% dLineIncrements = [30,-30,20,30,20,30];
% dLineAngle = [0,0,-0.4,0,0.4,0,0];
% hold(oAxes,'on');
% for k = 1:numel(iBeats)
%     iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
%     oBeatLabel = text(aTimes(iIndex)+dLineAngle(k), ...
%         aCouplingIntervals(iIndex)+dIncremements(k), sLabels{k},'parent',oAxes, ...
%         'FontWeight','bold','FontUnits','points','horizontalalignment','center');
%     set(oBeatLabel,'FontSize',8);
%     
%     oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle(k)],...
%         [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
%     set(oLine,'color',[0.5 0.5 0.5]);
%     
% end
% 
% %plot pressure data
% oAxes = oSubplotPanel(1,1,2,1).select();
% aData = oThisPressure.Processed.Data;
% aTime = oThisPressure.TimeSeries.Processed;
% hline = plot(oAxes,aTime,aData,'k');
% set(hline,'linewidth',0.5);
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% %set limits
% xlim(oAxes,oXLim);
% ylim(oAxes,[70 140]);
% %set labels
% oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
% set(oYlabel,'fontsize',8);
% set(oYlabel,'rotation',0);
% oPosition = get(oYlabel,'position');
% oPosition(1) = oXLim(1) - dlabeloffset;
% oYLim = get(oAxes,'ylim');
% oPosition(2) = oYLim(1);% + (oYLim(2) - oYLim(1)) / 3;
% set(oYlabel,'position',oPosition);
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
%         
%         set(oOverlay,'box','off','color','none');
%         if iCount == 1
%             oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
%         else
%             oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
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
%             oLabel = text(aXlim(2)-4.8,aYlim(1)-1.2,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
%             set(oLabel,'fontsize',8);
%         end
%         % % %         label beat number, rate and pressure
%         % % %         get pressure
%         oLabel = text(aXlim(1)+1,aYlim(2)-0.5,sLabels{iCount},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
%         set(oLabel,'fontsize',10);
%         oLabel = text(aXlim(1)-0.4,aYlim(1)+2,sprintf('%4.0f ms',aCouplingIntervals(iBeats(iCount))),'parent',oAxes,'fontunits','points','HorizontalAlignment','left');
%         set(oLabel,'fontsize',8);
%         [MinVal MinIndex] = min(abs(oThisPressure.TimeSeries.Processed - oThisPressure.oRecording.Electrodes.Processed.BeatRateTimes(iBeats(iCount))));
%         oLabel = text(aXlim(1)-0.4,aYlim(1)+0.5,sprintf('%4.0f mmHg',round(oThisPressure.Processed.Data(MinIndex))),'parent',oAxes,'fontunits','points','HorizontalAlignment','left');
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
% oLabel = annotation('textbox','position',[0.55 0.4 0.1 0.1],'string','F','linestyle','none','fontsize',12,'fontweight','bold');
% oLabel = annotation('textbox','position',[0.55 0.2 0.1 0.1],'string','G','linestyle','none','fontsize',12,'fontweight','bold');
% export_fig(strrep(sFileSavePath, '#', '1'),'-png','-r300','-nocrop')

%% create second panel
%get data
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003' ...
    };
aPressureData = cell(1,numel(aFolders));
aCoords = cell(1,numel(aFolders));
aDistance = cell(1,numel(aFolders));
aMagnitude = zeros(numel(aFolders),1);
for i = 1:numel(aFolders)
    sFileName = [aFolders{i},'\Pressure.mat'];
     oPressure = GetPressureFromMATFile(Pressure,sFileName,'Optical');
     aPressureData{i} = oPressure;
    fprintf('Got file %s\n',sFileName);
    aMagnitude(i) = mean(oPressure.Plateau.BeatPressures)-mean(oPressure.Baseline.BeatPressures);
end
%Sort data in terms of pressure magnitude
[B SortIdx] = sort(aMagnitude);
aFiles = aFolders{1};
[pathstr, name, ext, versn] = fileparts(char(aFiles));
load([pathstr,'\BaroLocationData.mat']);

% set up axes
% oSubplotPanel(2).pack('v',{0.8,0.08,0.02});
% oSubplotPanel(2,1).pack('h',{0.5,0.5});
% oSubplotPanel(2,1,1).pack(numel(SortIdx));
% oSubplotPanel(2,1).de.margin = [0 0 0 0];

oSubplotPanel(2).pack('v',{0.8,0.08,0.02});
oSubplotPanel(2,1).pack(numel(SortIdx));
oSubplotPanel(2,1).de.margin = [0 0 0 0];


oColors = jet(5);
iScatterSize = 16;
aYlim = [150 700];
aXlim = [-8.5 19];
aCRange = [0 7];

for p = 1:numel(SortIdx)
    %get index
    j = SortIdx(p);
 
    oPressure = aPressureData{j};
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    %convert rates into coupling intervals 
    aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        
    %get the corresponding pressure
    aPressures = zeros(size(aCouplingIntervals));
    for i = 1:numel(aCouplingIntervals)
        %         find the index that is closest to this time
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Original - aTimes(i)));
        aPressures(i) = aPressureProcessedData(MinIndex);
    end
    
    %find index of first beat to go above threshold from baseline 
    Idx = find(aPressures >= oPressure.Threshold,1,'first');
    aAdjustedTimes = aTimes - aTimes(Idx);
    
    % % %     %get locations
    aLocs =  aDistance{j}(:,1);
    a2ndLocs = aDistance{j}(:,2);
    if size(aLocs,1) ~= numel(aCouplingIntervals);
        x = 1;
    end
    a1stLocIndex = isnan(aDistance{j}(:,2));
    a2ndLocIndex = ~isnan(aDistance{j}(:,2));

    %set up axes
    oSubplotPanel(2,1,1,numel(SortIdx)-p+1).pack('v',{0.75,0.25});
    oAxes = oSubplotPanel(2,1,1,numel(SortIdx)-p+1,1).select();
    axis(oAxes);
    if p == 1
        oBaseAxes = oAxes;
    end
    %     oPressureAxes = aSubplotPanel(1,numel(SortIdx)-p+1,2).select();
    oPhrenicAxes = oSubplotPanel(2,1,1,numel(SortIdx)-p+1,2).select();
    
    [dBaseline iMinIdx] = min(aCouplingIntervals);
    [dTopline iMaxIdx] = max(aCouplingIntervals);
    oLine = plot(oAxes,[aAdjustedTimes(2); aAdjustedTimes(end-1)], [dBaseline-30; dBaseline-30], '--k','LineWidth', 0.5);
    hold(oAxes, 'on');    
%     cmap = colormap(oAxes, jet(aCRange(2)-aCRange(1)));
    %plot 1st locs
    scatter(oAxes, aAdjustedTimes(a1stLocIndex), aCouplingIntervals(a1stLocIndex),iScatterSize,aLocs(a1stLocIndex),'filled');
    %plot 1st locs offset
    scatter(oAxes, aAdjustedTimes(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)+15,iScatterSize,aLocs(a2ndLocIndex),'filled');
    %plot 2nd locs offset
    scatter(oAxes, aAdjustedTimes(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)-15,iScatterSize,a2ndLocs(a2ndLocIndex),'filled');
    cmap = colormap(oAxes, jet(aCRange(2)-aCRange(1)));
    caxis(oAxes, aCRange);
    
    set(oAxes,'ylim',aYlim);
    set(oAxes,'xlim',aXlim);
    %put y axis on and label ends
    oLine = plot(oAxes,[aXlim(1)+0.5; aXlim(1)+0.5], [min(aCouplingIntervals); min(aCouplingIntervals)+200], '-k','LineWidth', 2);
    if p == 1
        olabel = text(aXlim(1)-2,min(aCouplingIntervals)+100, '200 ms', 'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',10);
    end
    olabel = text(aAdjustedTimes(1),min(aCouplingIntervals)+60, sprintf('%4.0f ms',min(aCouplingIntervals)), 'HorizontalAlignment','left','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',8);
    olabel = text(aAdjustedTimes(iMaxIdx),max(aCouplingIntervals)+60, sprintf('%4.0f ms',max(aCouplingIntervals)), 'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',8);
    %put lines on to indicate pressure timing
    %start of increase
    [figx figy] = dsxy2figxy(oAxes, [oPressure.Increase.BeatTimes(1) - aTimes(Idx); oPressure.Increase.BeatTimes(1) - aTimes(Idx)], ...
        [(60000/oPressure.Increase.BeatRates(1))-100 ; (60000/oPressure.Increase.BeatRates(1))-20]);
    annotation('arrow',figx,figy,'headstyle','plain','headwidth',4,'headlength',4);
    %start of plateau
    [figx figy] = dsxy2figxy(oAxes, [oPressure.Plateau.BeatTimes(1) - aTimes(Idx); oPressure.Plateau.BeatTimes(1) - aTimes(Idx)], ...
        [(60000/oPressure.Plateau.BeatRates(1))-100 ; (60000/oPressure.Plateau.BeatRates(1))-20]);
    annotation('arrow',figx,figy,'headstyle','plain','headwidth',4,'headlength',4);
    %end of plateau
    [figx figy] = dsxy2figxy(oAxes, [oPressure.Plateau.BeatTimes(end) - aTimes(Idx); oPressure.Plateau.BeatTimes(end) - aTimes(Idx)], ...
        [(60000/oPressure.Plateau.BeatRates(end))-20 ; (60000/oPressure.Plateau.BeatRates(end))-100]);
    annotation('arrow',figx,figy,'headstyle','plain','headwidth',4,'headlength',4);
    
    %double beat
    if p == 2
        [figx figy] = dsxy2figxy(oAxes, [aAdjustedTimes(a2ndLocIndex)+1; aAdjustedTimes(a2ndLocIndex)+0.2], ...
            [aCouplingIntervals(a2ndLocIndex)+120 ; aCouplingIntervals(a2ndLocIndex)+20]);
        annotation('textarrow',figx,figy,'string','Two pacemaker sites','headstyle','plain','headwidth',4,'headlength',4,'fontsize',8);
    end
    
    hold(oAxes, 'off');
    set(oAxes,'color','none','box','off');
    axis(oAxes,'off');
    %label the pressure
    if p == 1
        olabel = text(aXlim(2)+1,aYlim(1)+250, ['\Delta',sprintf('P=%2.0f mmHg',aMagnitude(j))], 'HorizontalAlignment','right','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
        set(olabel,'fontsize',10);
    else
        olabel = text(aXlim(2)+1,aYlim(1)+250, sprintf('%4.0f mmHg',aMagnitude(j)), 'HorizontalAlignment','right','parent',oAxes,'color','k','fontunits','points','fontweight','bold');
        set(olabel,'fontsize',10);
    end
    
    % %     %plot pressure data
    %     plot(oPressureAxes,oPressure.TimeSeries.Processed- aTimes(Idx),oPressure.Processed.Data,'k-','linewidth',2);
    %     set(oPressureAxes,'xlim',xlim);
    %     set(oPressureAxes,'color','none','box','off');
    %     axis(oPressureAxes,'off');
    % %     %plot phrenic data
    %     aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, ...
    %         oPressure.oPhrenic.Electrodes.Processed.Data./ ...
    %         (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6,3);
    %     oPressure.oPhrenic.ComputeIntegral(50,aBurstData);
    %
    aData = oPressure.oPhrenic.Electrodes.Processed.Data ./ ...
        (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
    aTimeToPlot = oPressure.oPhrenic.TimeSeries - aTimes(Idx);
    aPointsToPlot = aTimeToPlot > aXlim(1)+1;
    
    plot(oPhrenicAxes,aTimeToPlot(aPointsToPlot),aData(aPointsToPlot),'-','linewidth',1,'color','k');
    set(oPhrenicAxes,'xlim',aXlim);
    set(oPhrenicAxes,'ylim',[-70 70]);
    set(oPhrenicAxes,'color','none','box','off');
    axis(oPhrenicAxes,'off');
    hold(oPhrenicAxes,'on');
    %put y axis on and label ends
    oLine = plot(oPhrenicAxes,[aXlim(1)+0.5; aXlim(1)+0.5], [-70; -70+100], 'LineWidth', 2,'color','k');
    if p == 1
        olabel = text(aXlim(1)-2,-70+50, '100 \muV', 'HorizontalAlignment','center',...
            'parent',oPhrenicAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',10);
    end
    hold(oPhrenicAxes,'off');
end
%create time scale
oScaleAxes = axes('parent',oFigure);
plot(oScaleAxes,[aXlim(1)+1; aXlim(1)+6], [aYlim(1); aYlim(1)], '-k','LineWidth', 4)
aPosition = get(oBaseAxes,'position');
set(oScaleAxes,'position',[aPosition(1) aPosition(2)-0.04 aPosition(3) aPosition(4)]);
aXlim = get(oBaseAxes,'xlim');
aYlim = get(oBaseAxes,'ylim');
set(oScaleAxes,'xlim',aXlim);
set(oScaleAxes,'ylim',aYlim);
%label the scale
olabel = text(aXlim(1)+1+5/2,aYlim(1)-75, '5 s', 'HorizontalAlignment','center','parent',oScaleAxes,'color','k','fontunits','points');
set(olabel,'fontsize',10);
axis(oScaleAxes,'off');

%create scalebar
oSubplotPanel(2,3).pack('h',{0.1,0.75});
oBarAxes = oSubplotPanel(2,3,2).select();
aCRange = [aCRange(1) aCRange(2)-1];
aContours = aCRange(1):1:aCRange(2);
cbarf_edit(aCRange, aContours,'horiz','linear',oBarAxes,'Distance');
aCRange = [aCRange(1) aCRange(2)+1];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+abs(aCRange(1)),-2.5,'Dominant pacemaker location (mm)','parent',oBarAxes,'fontunits','points','horizontalalignment','center');
set(oXlabel,'fontsize',8);
dcm_obj = datacursormode(oFigure);
set(dcm_obj,'UpdateFcn',@ScatterCursorCallback);



set(oFigure,'resizefcn',[]);
set(oFigure,'color','none');
% print(oFigure,'-dpsc','-r600',sFileSavePath)
% printgif(oFigure,'-r600',strrep(sFileSavePath, '#', '2'));

% export_fig(strrep(sFileSavePath, '#', '2'),'-png','-r300','-nocrop','-transparent');%
% % % %crop the images
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.png',strrep(sFileSavePath, '#', '1'))}, ...
%     {sprintf(' %s.png',strrep(sFileSavePath, '#', '2'))}, {' -gravity center -composite'},{sprintf(' %s.png', strrep(sFileSavePath, '_#', ''))});
% sStatus = dos(char(sChopString{1}));
% delete(sprintf('%s.png',strrep(sFileSavePath, '#', '1')),sprintf('%s.png',strrep(sFileSavePath, '#', '2')));