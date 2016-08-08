%create layout
%load data
%plot data

% 
close all;
clear all;

sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140814\';
sSubDir = [sBaseDir,'20140814CCh002\'];

%% read in the optical entities
sFileName = {...
    'CCh002a_g10_LP100Hz-waveEach.mat' ...
    'CCh002b_g10_LP100Hz-waveEach.mat' ...
    'CCh002c_g10_LP100Hz-waveEach.mat' ...
    'CCh002d_g10_LP100Hz-waveEach.mat' ...
    };
%% read in the optical entities
% % read in the pressure entity
oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 16;
dHeight = 5;
sThesisFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\Working\CLPlot_3.bmp';

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
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',{0.12,0.88});
oSubplotPanel(2).pack('v',{0.5,0.5});
movegui(oFigure,'center');
oSubplotPanel.margin = [2,2,2,2];
oSubplotPanel.de.margin = [0 5 0 0];%[left bottom right top]

%% plot top panel
% dlabeloffset = 2.2;
% dlabeloffset = 8;
dlabeloffset = 10;

oAxes = oSubplotPanel(2,1).select();
aTime = oThisPressure.TimeSeries.Original(10000:end-10000) - oThisPressure.HeartRate.Decrease.BeatTimes(1);
aPressureProcessedData = oThisPressure.FilterData(oThisPressure.Original.Data, 'LowPass', oThisPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
aData = aPressureProcessedData(10000:end-10000);


hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
% oXLim = [5.4 28.5];
% oXLim = [2.6 85];
oYLim = [20 110];
set(oAxes,'ylim',oYLim);
oXLim = get(oAxes,'xlim');
% set(oAxes,'xlim',oXLim);
%set labels
oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 5;
set(oYlabel,'position',oPosition);


%plot time scale
hold(oAxes,'on');
plot([oXLim(2)-5; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
% iInc = 8;
iInc = 12;
oLabel = text(oXLim(2)-2.5,oYLim(1)-iInc, '5 s', 'parent',oAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',10);

% 
% %plot HR -baro
% oAxes = oSubplotPanel(2,2).select();
% %convert rates into coupling intervals
% aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(1).Electrodes.Processed.BeatRates];
% aTimes = oThisPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
% scatter(oAxes,aTimes,aCouplingIntervals,16,'k','filled');
% %set axes colour
% set(oAxes,'xcolor',[1 1 1]);
% set(oAxes,'xtick',[]);
% set(oAxes,'xticklabel',[]);
% set(oAxes,'yminortick','on');


%plot HR -CCH
oAxes = oSubplotPanel(2,2).select();
iBeats = 66;
dIncremements = 200;
dLineIncrements = 30;
dLineAngle = 0;
iCount = 0;

for m = 1:numel(oThisPressure.oRecording)
    %convert rates into coupling intervals
    %     aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(m).Electrodes.Processed.BeatRates];
    %     aTimes = oThisPressure.oRecording(m).Electrodes.Processed.BeatRateTimes;
    
    %     %convert rates into coupling intervals
    %     aCouplingIntervals = 60000 ./ oThisPressure.oRecording(m).Electrodes.Processed.BeatRates';
    %     aTimes = oThisPressure.oRecording(m).TimeSeries(oThisPressure.oRecording(m).Electrodes.Processed.BeatRateIndexes);
    aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(m).Electrodes.Processed.BeatRates];
    aTimes = oThisPressure.oRecording(m).Electrodes.Processed.BeatRateTimes - oThisPressure.HeartRate.Decrease.BeatTimes(1);;

    scatter(oAxes,aTimes,aCouplingIntervals,4,'k','filled');
    hold(oAxes,'on');
    if m > 1
        %add patch between data
        offset = 0.3;
        aXVertex = [aLastTime+offset, aTimes(2)-offset, aTimes(2)-offset, aLastTime+offset];
        aYVertex = [150, 150, 600, 600];
        oPatch = patch(aXVertex, aYVertex,[0 0 0],'parent',oAxes);
        set(oPatch, 'LineStyle', 'none')
        hh1 = hatchfill(oPatch, 'single', -45, 3);
    end
    
    if m == 3
        iIndex = iBeats;%+1; %mapping between beats in pressure and beats in optical
                oBeatLabel = text(aTimes(iIndex)+dLineAngle, ...
            aCouplingIntervals(iIndex)+dIncremements, 'D','parent',oAxes, ...
            'FontWeight','bold','FontUnits','points','horizontalalignment','center');
        set(oBeatLabel,'FontSize',8);
        %save coupling interval
    
        oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle],...
            [aCouplingIntervals(iIndex),...
            aCouplingIntervals(iIndex)+dIncremements-dLineIncrements],'-','linewidth',0.5);
        set(oLine,'color',[0.5 0.5 0.5]);
    end
    %get last time for next iteration
    aLastTime = aTimes(end);
end

set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[150 600]);
% ylim(oAxes,[150 550]);
%set labels
oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 8;
set(oYlabel,'position',oPosition);
% iBeats = [51,71];
% sLabels = {'B','C'};
% dIncremements = [100,100];
% dLineIncrements = [30,30];
% dLineAngle = [0,0,0,0,0,0,0];
% hold(oAxes,'on');
% for k = 1:numel(iBeats)
%     iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
%     oBeatLabel = text(aTimes(iIndex)+dLineAngle(k), ...
%         aCouplingIntervals(iIndex)+dIncremements(k), sLabels{k},'parent',oAxes, ...
%         'FontWeight','bold','FontUnits','points','horizontalalignment','center');
%     set(oBeatLabel,'FontSize',8);
%     oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle(k)],...
%         [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
%     set(oLine,'color',[0.5 0.5 0.5]);
% end

% export_fig(sThesisFileSavePath,'-bmp','-r600','-nocrop')

