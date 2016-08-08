%have not finished this file - need to change the format so that the grid
%of maps covers the whole space - 06/08/2015

close all;
% clear all;
% % % %Read in the file containing all the optical data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\';
% sSubDir = [sBaseDir,'20140718baro001\'];
% 
% %% read in the optical entities
% sOpticalFileName = [sSubDir,'baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
% oPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');


%set variables
dWidth = 16;
dHeight = 21.7;
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\OpticalActivation_20140718baro001.bmp';
% sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Test.bmp';
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
xrange = 4;
yrange = 4;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack({0.25 0.73 0.02});
oSubplotPanel(1).pack('h',{0.06,0.94});
oSubplotPanel(1,2).pack(3);
oSubplotPanel(2).pack(xrange,yrange);
oSubplotPanel(3).pack();
movegui(oFigure,'center');

oSubplotPanel.margin = [5 12 5 5];
oSubplotPanel(1).margin = [0 5 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 0 0 5];

oSubplotPanel(1).fontsize = 6;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(3).fontsize = 12;
oSubplotPanel(3).fontweight = 'bold';

%% plot top panel

dlabeloffset = 2.5;
%plot phrenic
oAxes = oSubplotPanel(1,2,2).select();
aData = oPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, ...
    aData,2);
oPressure.oPhrenic.ComputeIntegral(200,aBurstData);
aData = oPressure.oPhrenic.Electrodes.Processed.Integral;
aTime = oPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
axis(oAxes,'tight');
% ylim(oAxes,[-50 50]);
oXLim = get(oAxes,'xlim');

%set labels
oYlabel = ylabel(oAxes,['\intPND', 10,'(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 2;
set(oYlabel,'position',oPosition);
oNewYLabel = text(oPosition(1),oPosition(2),'\intPND','parent',oAxes,'fontsize',6,'horizontalalignment','center');
axis(oAxes,'off');

%plot HR
oAxes = oSubplotPanel(1,2,3).select();
aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
scatter(oAxes,aTimes,aCouplingIntervals,16,'k','filled');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[250 650]);
%set labels
oYlabel = ylabel(oAxes,['CL', 10, '(ms)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
iBeats = [10,18,20,21,23,25,26,27,29,44,48,55,59,62,64,67];
sLabels = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'};
dIncremements = [100,100,200,100,200,100,-100,100,100,200,100,100,200,100,200,100];
dLineIncrements = [30,30,30,30,30,30,-30,30,30,30,30,30,30,30,30,30];
dLineAngle = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
hold(oAxes,'on');
for k = 1:numel(iBeats)
    iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
    oBeatLabel = text(aTimes(iIndex)+dLineAngle(k), ...
        aCouplingIntervals(iIndex)+dIncremements(k), sLabels{k},'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    set(oBeatLabel,'FontSize',8);
    
    oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle(k)],...
        [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
    set(oLine,'color',[0.5 0.5 0.5]);
    
end
%plot time scale
hold(oAxes,'on');
plot([oXLim(2)-2; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
oLabel = text(oXLim(2)-1,oYLim(1)-80, '2 s', 'parent',oAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',8);
aRateData = aData;

%plot pressure data
oAxes = oSubplotPanel(1,2,1).select();
aData = oPressure.Processed.Data;
aTime = oPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[70 120]);
%set labels
oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

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
        if iCount > numel(iBeats)
            break;
        end
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'arsps', 24, iBeats(iCount), []);
         oAxes = oSubplotPanel(2,i,j).select();
        oOverlay = axes('position',get(oAxes,'position'));
        oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140718\20140718Schematic_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
        %make it transparent in the right places
        aCData = get(oImage,'cdata');
        aBlueData = aCData(:,:,3);
        aAlphaData = aCData(:,:,3);
        aAlphaData(aBlueData < 100) = 1;
        aAlphaData(aBlueData > 100) = 1;
        aAlphaData(aBlueData == 100) = 0;
        aAlphaData = double(aAlphaData);
        set(oImage,'alphadata',aAlphaData);
        set(oOverlay,'box','off','color','none');
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
            oLabel = text(aXlim(1)+1.2,aYlim(2)-1.5,'SVC','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(aXlim(1)+1,aYlim(1)+1,'IVC','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(aXlim(2)-3.5,aYlim(2)-1.2,'RAA','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
        % % %         label beat number, rate and pressure
        % % %         get pressure
        oLabel = text(aXlim(1)+1,aYlim(2)-0.5,sLabels{iCount},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',10);
        oLabel = text(aXlim(2)-2,aYlim(1)+2,sprintf('%3.0f ms',aCouplingIntervals(iBeats(iCount))),'parent',oAxes,'fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',8);
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Processed - oPressure.oRecording.Electrodes.Processed.BeatRateTimes(iBeats(iCount))));
        oLabel = text(aXlim(2)-2,aYlim(1)+1,sprintf('%2.0f mmHg',round(oPressure.Processed.Data(MinIndex))),'parent',oAxes,'fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',8);
    end
end
oAxes = oSubplotPanel(3,1).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes,'AT',8);
oXlabel = text(((aContourRange(2)-aContourRange(1))/2)-abs(aContourRange(1)),-2.2,'Atrial AT (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',10);

% print(oFigure,'-dbmp','-r600',sFileSavePath)
% sFileSavePath = strrep(sFileSavePath,'xx',num2str(iStartBeat));
% sFileSavePath = strrep(sFileSavePath,'zz',num2str(iBeat));
% print(oFigure,'-dpsc','-r600',sFileSavePath)
