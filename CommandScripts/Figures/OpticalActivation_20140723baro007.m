%figure for HRS 2016 abstract

%create layout
%load data
%plot data
%save to file as gif

close all;
% clear all;
% % % % % %Read in the file containing all the optical data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\';
% sSubDir = [sBaseDir,'20140723baro007\'];
% 
% % % %% read in the optical entities
% sAvOpticalFileName = [sSubDir,'baro007_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
% oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
% sOpticalFileName = [sSubDir,'baro007_3x3_1ms_7x_g10_LP100Hz-waveEach-forfigure.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % % read in the pressure entity
% oPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 8;
dHeight = 7;
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\OpticalActivation_20140723baro007.gif';

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
xrange = 3;
yrange = 1;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack({0.5 0.4 0.03});
oSubplotPanel(1).pack('h',{0.18,0.82});
oSubplotPanel(1,2).pack(3);
oSubplotPanel(2).pack(yrange,xrange);
movegui(oFigure,'center');

oSubplotPanel.margin = [2 2 2 2];%[left bottom right top]
oSubplotPanel(1).margin = [0 3 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 2 0 2];

oSubplotPanel(1).fontsize = 6;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(3).fontsize = 12;
oSubplotPanel(3).fontweight = 'bold';

%% plot top panel
dlabeloffset = 6;

%plot phrenic
oAxes = oSubplotPanel(1,2,2).select();
aData = oPressure.oPhrenic.Electrodes.Processed.Data ./ ...
    (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aTime = oPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
axis(oAxes,'tight');
ylim(oAxes,[-55 55]);
oXLim = get(oAxes,'xlim');

%set labels
oYlabel = ylabel(oAxes,['Phrenic', 10,'(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot HR
oAxes = oSubplotPanel(1,2,3).select();
%convert rates into coupling intervals
aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
scatter(oAxes,aTimes,aCouplingIntervals,4,'k','filled');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[150 500]);
%set labels
oYlabel = ylabel(oAxes,['Cycle',10,'Length', 10, '(ms)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 5;
set(oYlabel,'position',oPosition);
iBeats = [45,50,74];
sLabels = {'a','b','c'};

for k = 1:numel(iBeats)
    iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
    oBeatLabel = text(aTimes(iIndex), ...
        aCouplingIntervals(iIndex)+55, sLabels{k},'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    set(oBeatLabel,'FontSize',6);
end
%plot time scale
hold(oAxes,'on');
plot([oXLim(2)-5; oXLim(2)], [oYLim(1)+100; oYLim(1)+100], '-k','LineWidth', 2)
hold(oAxes,'off');
oLabel = text(oXLim(2)-2.5,oYLim(1), '5 s', 'parent',oAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',8);

%plot pressure data
oAxes = oSubplotPanel(1,2,1).select();
aData = oPressure.Processed.Data;
aTime = oPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[70 140]);
%set labels
oYlabel = ylabel(oAxes,['Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 3;
set(oYlabel,'position',oPosition);

% %plot maps
%plot the schematic
aContourRange = [0 10.8];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
dTextXAlign = 0;
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
for i = 1:yrange
    for j = 1:xrange
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'abhsm', 24, iBeats(j), []);
        oAxes = oSubplotPanel(2,i,j).select();
        oOverlay = axes('position',get(oAxes,'position'));
        oOriginAxes = axes('position',get(oAxes,'position'));
        %plot the schematic
        oImage = imshow(oOptical.oExperiment.Optical.SchematicFilePath,'Parent', oOverlay, 'Border', 'tight');
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
        [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats(j)).z,aContours);
        caxis(aContourRange);
        colormap(oAxes, colormap(flipud(colormap(Gray))));
        
        
        aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats(j),:)).Coords});
        if ~isempty(aOriginCoords)
            scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
                'sizedata',9,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        axis(oOriginAxes,'equal');
        set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oOriginAxes,'off');
        if (i == 1) && (j == 1)
            %create labels
            oLabel = text(aXlim(1)+0.8,aYlim(2)-3.5,'SVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',6);
            oLabel = text(aXlim(2)-0.5,aYlim(1)+0.5,'IVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',6);
            oLabel = text(aXlim(2)-5,aYlim(2)-1,'RA','parent',oAxes,'fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',6);
            oLabel = text(aXlim(2)-4.95,aYlim(1)-0.3,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
            set(oLabel,'fontsize',6);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
        oLabel = text(aXlim(1)+1.5,aYlim(2)-1,sLabels{j},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',12);
    end
end
oSubplotPanel(3).pack('h',{0.1,0.8});
oAxes = oSubplotPanel(3,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'horiz','nonlinear',oAxes,'AT');
aCRange = [0 12];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+(aCRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',6);

% print(oFigure,'-dbmp','-r600',sSavePath)
set(oFigure,'resizefcn',[]);
printgif(oFigure,'-r600',sFileSavePath)