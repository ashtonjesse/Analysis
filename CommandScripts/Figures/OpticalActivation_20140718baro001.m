%have not finished this file - need to change the format so that the grid
%of maps covers the whole space - 06/08/2015

close all;
clear all;
% % % %Read in the file containing all the optical data
sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\';
sSubDir = [sBaseDir,'20140718baro003\'];
sCSVFileName = [sSubDir,'baro003_3x3_1ms_7x_g10_LP100Hz-waveEach.csv'];
[path name ext ver] = fileparts(sCSVFileName);
if strcmpi(ext,'.csv')
    aThisOAP = ReadOpticalTimeDataCSVFile(sCSVFileName,6);
    save(fullfile(path,strcat(name,'.mat')),'aThisOAP');
elseif strcmpi(ext,'.mat')
    load(sCSVFileName);
end
%%% read in the experiment file
sExperimentFileName = [sBaseDir,'20140718_experiment.txt'];
oExperiment = GetExperimentFromTxtFile(Experiment, sExperimentFileName);
% % %% read in the optical entity
sOpticalFileName = [sSubDir,'Optical.mat'];
oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
oPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');
% % % get needle points
oNeedlePoints = GetNeedlePointLocationsFromCSV([sSubDir,'NeedlePoints.csv'],0,0);

%set variables
dWidth = 16;
dHeight = 21.7;
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\OpticalActivation_20140718baro001_xx-zz.eps';
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
xrange = 5;
yrange = 5;
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
aData = oPressure.oPhrenic.Electrodes.Processed.Data ./ ...
    (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
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
ylim(oAxes,[-50 50]);
oXLim = get(oAxes,'xlim');

%set labels
oYlabel = ylabel(oAxes,['PND', 10,'(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot HR
oAxes = oSubplotPanel(1,2,3).select();
aTime = oPressure.oRecording.TimeSeries;
aData = oPressure.oRecording.Electrodes.Processed.BeatRateData;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[80 300]);
%set labels
oYlabel = ylabel(oAxes,['HR', 10, '(bpm)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
iStartBeat = 44;
for k = iStartBeat:2:iStartBeat+(xrange*yrange)-1
    iIndex = k + 1; %mapping between beats in pressure and beats in optical
    if k == iStartBeat
        oBeatLabel = text(oPressure.oRecording.Electrodes.Processed.BeatRateTimes(iIndex), ...
        oPressure.oRecording.Electrodes.Processed.BeatRates(iIndex-1)+15, sprintf('#%d',iIndex),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    elseif k == iStartBeat+2
        %do nothing
    else
        oBeatLabel = text(oPressure.oRecording.Electrodes.Processed.BeatRateTimes(iIndex), ...
        oPressure.oRecording.Electrodes.Processed.BeatRates(iIndex-1)+15, num2str(iIndex),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    end
    set(oBeatLabel,'FontSize',6);
end
%plot time scale
hold(oAxes,'on');
plot([oXLim(2)-2; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
oLabel = text(oXLim(2)-1,oYLim(1)-40, '2 s', 'parent',oAxes, ...
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
ylim(oAxes,[60 120]);
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
iBeatCount = 0;
iStartBeat = iStartBeat+1; %redefine startbeat to be in the index format of optical
aXlim = [-2.2 9.6];
aYlim = [-1.7 8.8];
aContourRange = [0 12];
aContours = aContourRange(1):1:aContourRange(2);
%get the interpolation points
dRes = 0.2;
aCoords = aThisOAP.Locations'.*dRes;
rowlocs = aCoords(:,1);
collocs = aCoords(:,2);
dInterpDim = 100;
dTextXAlign = 0;
%Get the interpolated points array
[xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
    min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
for i = 1:yrange
    for j = 1:xrange
        iBeat = iStartBeat + iBeatCount;
         oAxes = oSubplotPanel(2,i,j).select();
        oOverlay = axes('position',get(oAxes,'position'));
        oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140718\20140718Schematic.bmp','Parent', oOverlay, 'Border', 'tight');
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
        [C, oContour] = contourf(oAxes, aThisOAP.InterpPoints.X, aThisOAP.InterpPoints.Y, aThisOAP.InterpArray(:,:,iBeat), aContours);
        caxis(aContourRange);
        colormap(oAxes, colormap(flipud(colormap(jet))));
        %         hold(oAxes,'on');
        %         for n = 1:numel(oNeedlePoints)
        %             plot(oAxes,oNeedlePoints(n).Line1(1:2)*dRes, oNeedlePoints(n).Line1(3:4)*dRes, '-k','LineWidth', 2)
        %             plot(oAxes,oNeedlePoints(n).Line2(1:2)*dRes, oNeedlePoints(n).Line2(3:4)*dRes, '-k','LineWidth', 2)
        %         end
        %         hold(oAxes,'off');
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        if (i == 1) && (j == 1)
            %create labels
            oLabel = text(aXlim(1)+1.2,aYlim(2)-1.5,'SVC','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(aXlim(1)+1,aYlim(1)+1,'IVC','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(aXlim(2)-3.5,aYlim(2)-1.2,'RA','parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Processed - oPressure.oRecording.Electrodes.Processed.BeatRateTimes(iBeat)));
        oLabel = text(aXlim(2)-dTextXAlign,aYlim(1)+2,sprintf('%d mmHg',round(oPressure.Processed.Data(MinIndex))),'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',6);
        oLabel = text(aXlim(2)-dTextXAlign,aYlim(1)+1,sprintf('%d bpm',round(oPressure.oRecording.Electrodes.Processed.BeatRates(iBeat-1))),'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',6);
        oLabel = text(aXlim(2)-dTextXAlign,aYlim(1)+3.5,sprintf('#%d',iBeat),'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',12);
        % % %label the frame number
        oLabel = text(aXlim(2)-dTextXAlign-4,aYlim(1)+1,sprintf('%d',round(mean(aThisOAP.ActivationIndex(:,iBeat)))),'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
        set(oLabel,'fontsize',6);
        iBeatCount = iBeatCount + 1;
    end
end
oAxes = oSubplotPanel(3,1).select();
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes,'AT');
oXlabel = text(((aContourRange(2)-aContourRange(1))/2)-abs(aContourRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);

% print(oFigure,'-dbmp','-r600',sSavePath)
sFileSavePath = strrep(sFileSavePath,'xx',num2str(iStartBeat));
sFileSavePath = strrep(sFileSavePath,'zz',num2str(iBeat));
print(oFigure,'-dpsc','-r600',sFileSavePath)
