%create layout
%load data
%plot data
%save to file as gif
%this figure needs to have a CI plot added to it called CChPhase

close all;
% clear all;
% % % %Read in the file containing all the optical data
sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140826\';
sSubDir = [sBaseDir,'20140826chemo001\'];

%% read in the optical entities
sAvOpticalFileName = [sSubDir,'chemo001a_3x3_1ms_g10_LP100Hz-wave.mat'];
oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
sOpticalFileName = [sSubDir,'chemo001a_3x3_1ms_g10_LP100Hz-waveEach-forpaper.mat'];
oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % read in the pressure entity
oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 17;
dHeight = 9;
sPaperFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\ChemoData.png';
sThesisFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ChemoData.eps';
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
oSubplotPanel.pack('v',{0.77 0.23});
oSubplotPanel(1).pack('v',{0.6,0.4});
oSubplotPanel(1,1).pack('h',{0.1,0.9});
oSubplotPanel(1,1,2).pack('v',{0.25,0.3,0.4});
oSubplotPanel(1,2).pack('h',{0.02,0.98});
oSubplotPanel(1,2,2).pack(yrange,xrange);
oSubplotPanel(1,2,1).pack('v',{0.2,0.65});

movegui(oFigure,'center');
oSubplotPanel.margin = [12,15,2,2];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
oSubplotPanel(1).margin = [0 2 0 0];
oSubplotPanel(1,1).de.margin = [0 2 0 0];
oSubplotPanel(1,1).de.fontsize = 8;
oSubplotPanel(1,2,1).margin = [0 0 2 0];
oSubplotPanel(1,2,2).margin = [0 0 0 0];

%% plot top panel
dlabeloffset = 3;

%plot phrenic
oAxes = oSubplotPanel(1,1,2,2).select();
aData = oThisPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oThisPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oThisPressure.oPhrenic, ...
    aData,2);
oThisPressure.oPhrenic.ComputeIntegral(200,aBurstData);
% aData = oThisPressure.oPhrenic.Electrodes.Processed.Data ./ ...
%     (oThisPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aData = oThisPressure.oPhrenic.Electrodes.Processed.Integral(200:end-5000)/1000;
aTime = oThisPressure.oPhrenic.TimeSeries(200:end-5000);
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set limits
axis(oAxes,'tight');
oYLim = get(oAxes,'ylim');
oXLim = [0 35];
xlim(oAxes,oXLim);
axis(oAxes,'off');


%set labels
oYlabel = ylabel(oAxes,'\intPND');
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
oNewYLabel = text(oPosition(1),oPosition(2),'\intPND','parent',oAxes,'fontsize',8,'horizontalalignment','center');
axis(oAxes,'off');

%plot HR
oAxes = oSubplotPanel(1,1,2,3).select();
%convert rates into coupling intervals
aCouplingIntervals = 60000 ./ oThisPressure.oRecording(1).Electrodes.Processed.BeatRates;
aTimes = oThisPressure.oRecording(1).TimeSeries(oThisPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
scatter(oAxes,aTimes,aCouplingIntervals,16,'k','filled');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');

%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[200 800]);
%set labels
oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 10;
set(oYlabel,'position',oPosition);
iBeats = [22,28,29,36,37,70];
sLabel = {'1','2','3','4','5','6'};
dIncremements = [100,100,-150,200,100,100];
dLineIncrements = [30,30,-30,30,30,30];
hold(oAxes,'on');
for k = [1,numel(iBeats)]
    iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
%     oBeatLabel = text(aTimes(iIndex), ...
%         aCouplingIntervals(iIndex)+dIncremements(k), sLabel{k},'parent',oAxes, ...
%         'FontWeight','bold','FontUnits','points','horizontalalignment','center');
%     set(oBeatLabel,'FontSize',8);
    
    oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)],...
        [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
    set(oLine,'color',[0.5 0.5 0.5]);
    
end
%plot time scale
oScaleAxes = axes('position',get(oAxes,'position')-[0 0.02 0 0]);
plot(oScaleAxes,[oXLim(2)-5; oXLim(2)], [oYLim(1)+50; oYLim(1)+50], '-k','LineWidth', 2)
xlim(oScaleAxes,oXLim);
ylim(oScaleAxes,oYLim);
axis(oScaleAxes,'off');
oLabel = text(oXLim(2)-2.5,oYLim(1)-50, '5 s', 'parent',oScaleAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',10);

%plot pressure data
oAxes = oSubplotPanel(1,1,2,1).select();
aData = oThisPressure.FilterData(oThisPressure.Processed.Data, 'LowPass', oThisPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
aData(1:10000) = NaN;
aTime = oThisPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[50 80]);
%set labels
oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1);
set(oYlabel,'position',oPosition);
%put indication of stimulus timing
hold(oAxes,'on');
plot(oAxes,[4.051 4.923], [65 65], 'k-','linewidth',2);
text(4.051+(4.923-4.051)/2,60,'KCN','fontsize',8,'horizontalalignment','center');
hold(oAxes,'off');

% %plot maps
%plot the schematic
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
dTextXAlign = 0;
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
iCount = 0;
for i = 1:yrange
    for j = 1:xrange
        iCount = iCount + 1;
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'arsps', 24, iBeats(iCount), [],[]);
        oAxes = oSubplotPanel(1,2,2,i,j).select();
             %plot the schematic
        oOverlay = axes('position',get(oAxes,'position'));
        colormap(oOverlay,flipud(jet));
        set(oOverlay,'box','off','color','none');
        if iCount == 1
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140826\20140826Schematic_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
        else
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140826\20140826Schematic_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
        end
        %         %make it transparent in the right places
        aCData = get(oImage,'cdata');
        aBlueData = aCData(:,:,3);
        aAlphaData = aCData(:,:,3);
        aAlphaData(aBlueData < 100) = 1;
        aAlphaData(aBlueData > 100) = 1;
        aAlphaData(aBlueData == 100) = 0;
        aAlphaData = double(aAlphaData);
        set(oImage,'alphadata',aAlphaData);
        axis(oOverlay,'tight');
        axis(oOverlay,'off');
        
        oOriginAxes = axes('position',get(oAxes,'position'));
        aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats(iCount),:)).Coords});
        if ~isempty(aOriginCoords)
            scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
                'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats(iCount)).z,aContours);
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        axis(oOriginAxes,'equal');
        set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oOriginAxes,'off');
        cmap = colormap(oAxes, flipud(jet(aContourRange(2)-aContourRange(1))));
        caxis(oAxes,aContourRange);
               
   
        
        if (i == 1) && (j == 1)
            %create labels
            %             oLabel = text(aXlim(1)+0.8,aYlim(2)-3.5,'SVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6);
            %             oLabel = text(aXlim(2)-0.5,aYlim(1)+0.5,'IVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6);
            %             oLabel = text(aXlim(1)+6,aYlim(2)-5.3,'CT','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6,'color','w');
%             oLabel = text(aXlim(2)-2.2,aYlim(1)+1,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
%             set(oLabel,'fontsize',8);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
%         oLabel = text(aXlim(1)+3,aYlim(2)-1,sLabel{iCount},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
%         set(oLabel,'fontsize',10);
%         oLabel = text(aXlim(1)+0.5,aYlim(1)+0.4,sprintf('%4.0f ms',aCouplingIntervals(iBeats(iCount))),...
%             'parent',oOriginAxes,'fontunits','points','HorizontalAlignment','left','backgroundcolor','w','margin',0.001);
%         set(oLabel,'fontsize',8);
    end
end

oAxes = oSubplotPanel(1,2,1,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',8);
aCRange = [0 12];
oLabel = text(-2.8,(aCRange(2)-aCRange(1))/2,'Atrial AT (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);

set(oFigure,'resizefcn',[]);
% export_fig(sPaperFileSavePath,'-png','-r300','-nocrop')
% print(sThesisFileSavePath,'-dpsc','-r600')