%this script loads a bunch of pressure files and compares heart rates,
%phrenic burst rates and durations
close all;
% clear all;
% aFiles = {...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134350\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134621\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134852\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135123\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135354\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135625\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135856\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140522\140127\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\162847\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163118\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163349\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163620\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163911\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171221\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171452\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171723\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171954\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172224\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172455\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172726\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172957\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140526\173324\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163208\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163439\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163710\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163941\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164212\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164605\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164836\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\165107\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140527\165338\Pressure.mat' ...
%     };
% aTimes = [...
%     0
% 151
% 302
% 453
% 604
% 755
% 906
% 1057
% 0
% 151
% 302
% 453
% 604
% 2614
% 2765
% 2916
% 3067
% 3218
% 3369
% 3520
% 3671
% 3822
% 0
% 151
% 302
% 453
% 604
% 755
% 906
% 1057
% 1208
% ];
% 
% aTimes = aTimes ./ 60;
% %loop through files and get data
% %initialise variables
% aHeartBeatRates = cell(numel(aFiles),1);
% aBurstRates = cell(numel(aFiles),1);
% aBurstDurations = cell(numel(aFiles),1);
% aMeanHeartRates = zeros(numel(aFiles),1);
% aMeanBurstRates = zeros(numel(aFiles),1);
% aMeanBurstDurations = zeros(numel(aFiles),1);
% aSEMHeartRates = zeros(numel(aFiles),1);
% aSEMBurstRates = zeros(numel(aFiles),1);
% aSEMBurstDurations = zeros(numel(aFiles),1);
% aMeanPressure = zeros(numel(aFiles),1);
% aSEMPressure = zeros(numel(aFiles),1);
% for i =1:numel(aFiles)
%     oPressure = GetPressureFromMATFile(Pressure, aFiles{i}, 'Optical');
%     aHeartBeatRates{i} = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
%     aBurstRates{i} = oPressure.oPhrenic.Electrodes.Processed.BurstRates;
%     aBurstDurations{i} = oPressure.oPhrenic.Electrodes.Processed.BurstDurations;
%     fprintf('Got data from %s\n',aFiles{i});
%     aMeanHeartRates(i) = mean(aHeartBeatRates{i});
%     aMeanBurstRates(i) = mean(aBurstRates{i});
%     aMeanBurstDurations(i) = mean(aBurstDurations{i});
%     aSEMHeartRates(i) = stderror(aHeartBeatRates{i});
%     aSEMBurstRates(i) = stderror(aBurstRates{i});
%     aSEMBurstDurations(i) = stderror(aBurstDurations{i});
%     aMeanPressure(i) = mean(oPressure.Processed.Data);
%     aSEMPressure(i) = stderror(oPressure.Processed.Data);
% end
dWidth = 16;
dHeight = 16;
oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
% set(oFigure, 'WindowStyle', 'Docked');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',2);
aSubplotPanel(1).pack('v',4);
aSubplotPanel.margin = [15 10 2 10];%left bottom right top
aSubplotPanel.de.fontsize = 8;
aSubplotPanel(1).margin = [0 10 10 10];
movegui(oFigure,'center');

aXLim = [-5 65];
oAxes = aSubplotPanel(1,1).select();
errorbar(aTimes(9:13),aMeanBurstRates(9:13),aSEMBurstRates(9:13),'k','parent',oAxes);
hold(oAxes,'on');
h = plot(oAxes,[aTimes(13) aTimes(14)],[aMeanBurstRates(13) aMeanBurstRates(14)],'k--');
set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
errorbar(aTimes(14:22),aMeanBurstRates(14:22),aSEMBurstRates(14:22),'k','parent',oAxes,'linewidth',1.5);
errorbar(aTimes(23:end),aMeanBurstRates(23:end),aSEMBurstRates(23:end),'b','parent',oAxes);
errorbar(aTimes(1:8),aMeanBurstRates(1:8),aSEMBurstRates(1:8),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim);
set(oAxes,'xcolor','w','xtick',[],'xticklabel',[]);
set(get(oAxes,'ylabel'),'string','PND Rate (bursts/min)');
oLegend = legend(oAxes,'2.5 \muM','+1.25 \muM','5 \muM','10 \muM');
set(oLegend,'position',[0.3232    0.7127    0.1683    0.1179]);

oAxes = aSubplotPanel(1,2).select();
errorbar(aTimes(9:13),aMeanBurstDurations(9:13),aSEMBurstDurations(9:13),'k','parent',oAxes);
hold(oAxes,'on');
plot(oAxes,[aTimes(13) aTimes(14)],[aMeanBurstDurations(13) aMeanBurstDurations(14)],'k--');
errorbar(aTimes(14:22),aMeanBurstDurations(14:22),aSEMBurstDurations(14:22),'k','parent',oAxes,'linewidth',1.5);
errorbar(aTimes(23:end),aMeanBurstDurations(23:end),aSEMBurstDurations(23:end),'b','parent',oAxes);
errorbar(aTimes(1:8),aMeanBurstDurations(1:8),aSEMBurstDurations(1:8),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim);
set(oAxes,'xcolor','w','xtick',[],'xticklabel',[]);
set(get(oAxes,'ylabel'),'string','PND Duration (s)');

oAxes = aSubplotPanel(1,4).select();
errorbar(aTimes(9:13),aMeanPressure(9:13),aSEMPressure(9:13),'k','parent',oAxes);
hold(oAxes,'on');
plot(oAxes,[aTimes(13) aTimes(14)],[aMeanPressure(13) aMeanPressure(14)],'k--');
errorbar(aTimes(14:22),aMeanPressure(14:22),aSEMPressure(14:22),'k','parent',oAxes,'linewidth',1.5);
errorbar(aTimes(23:end),aMeanPressure(23:end),aSEMPressure(23:end),'b','parent',oAxes);
errorbar(aTimes(1:8),aMeanPressure(1:8),aSEMPressure(1:8),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim);
set(get(oAxes,'xlabel'),'string','Time Elapsed (min)');
set(get(oAxes,'ylabel'),'string','Pressure (mmHg)');

%create overlay axes for heart rate
oOverlay = aSubplotPanel(1,3).select();
errorbar(aTimes(9:13),aMeanHeartRates(9:13),aSEMHeartRates(9:13),'k','parent',oOverlay);
hold(oOverlay,'on');
plot(oOverlay,[aTimes(13) aTimes(14)],[aMeanHeartRates(13) aMeanHeartRates(14)],'k--');
errorbar(aTimes(14:22),aMeanHeartRates(14:22),aSEMHeartRates(14:22),'k','parent',oOverlay,'linewidth',1.5);
errorbar(aTimes(23:end),aMeanHeartRates(23:end),aSEMHeartRates(23:end),'b','parent',oOverlay);
errorbar(aTimes(1:8),aMeanHeartRates(1:8),aSEMHeartRates(1:8),'r','parent',oOverlay);
hold(oOverlay,'off');
set(oOverlay,'box','off');
set(oOverlay,'xlim',aXLim,'xtick',[],'xticklabel',[],'xcolor','w');
set(get(oOverlay,'ylabel'),'string','Heart rate (bpm)');

%plot phrenic bursts
aPhrenicFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\162847\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163911\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171221\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163208\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164212\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\165107\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134350\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135354\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\140127\Pressure.mat' ...
    };

aSubplotPanel(2).pack('v',3);
aSubplotPanel(2).de.margin = [0 10 0 0];
aSubplotPanel(2,1).pack(2,3);
aSubplotPanel(2,1).de.margin = [2 2 2 2];
aSubplotPanel(2,2).pack(2,3);
aSubplotPanel(2,2).de.margin = [2 2 2 2];
aSubplotPanel(2,3).pack(2,3);
aSubplotPanel(2,3).de.margin = [2 2 2 2];

aIndices = [
    14800
    14600
    41999
    11000
    6200
    36200
    8199
    19800
    83800];
iGroup = 1;
iPeriod = 30000;
iCount = 0;
sColor = {'k','b','r'};
for i = 1:numel(aPhrenicFiles)
    iCount = iCount + 1;
    oPressure = GetPressureFromMATFile(Pressure, aPhrenicFiles{i}, 'Optical');
    oAxes = aSubplotPanel(2,iGroup,1,iCount).select();
    
    %raw
    aData = oPressure.oPhrenic.Electrodes.Processed.Data(aIndices(i):aIndices(i)+iPeriod)./ ...
        (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
    aYLim = [-75 50];
    plot(oAxes,oPressure.oPhrenic.TimeSeries(aIndices(i):aIndices(i)+iPeriod),aData,sColor{iGroup});
    set(oAxes,'ylim',aYLim);
    set(oAxes,'xlim',[oPressure.oPhrenic.TimeSeries(aIndices(i)) oPressure.oPhrenic.TimeSeries(aIndices(i))+iPeriod/10000]);
    axis(oAxes,'off');
    
    if iCount == 1
        oAxes = axes('parent',oFigure,'position',get(oAxes,'position')-[0.08 0 0 0]);
        plot(oAxes,[0 0], [-25 25],'k','linewidth',2);
        text(-0.1,0,'50 \muV','parent',oAxes,'horizontalalignment','right','fontsize',8);
        set(oAxes,'ylim',aYLim);
        axis(oAxes,'off');
        aXLim = get(oAxes,'xlim');
    end
    
    
    oAxes = aSubplotPanel(2,iGroup,2,iCount).select();
    %integral
    aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, ...
        oPressure.oPhrenic.Electrodes.Processed.Data,2);
    %calc bin integral of this
    aBurstData = oPressure.oPhrenic.ComputeRectifiedBinIntegral(aBurstData, 200);
    aData = aBurstData(aIndices(i):aIndices(i)+iPeriod);
    switch iGroup
        case 1
            aYLim = [0 10];
        case 2
            aYLim = [0 5];
        case 3
            aYLim = [0 5];
    end
    plot(oAxes,oPressure.oPhrenic.TimeSeries(aIndices(i):aIndices(i)+iPeriod),aData,sColor{iGroup});
    set(oAxes,'ylim',aYLim);
    set(oAxes,'xlim',[oPressure.oPhrenic.TimeSeries(aIndices(i)) oPressure.oPhrenic.TimeSeries(aIndices(i))+iPeriod/10000]);
    axis(oAxes,'off');
    
    if iCount == 1
        oAxes = axes('parent',oFigure,'position',get(oAxes,'position')-[0.08 0 0 0]);
        set(oAxes,'ylim',aYLim,'xlim',aXLim);
        text(-0.1,(aYLim(2)-aYLim(1))/2,'\intPND','parent',oAxes,'horizontalalignment','right','fontsize',8);
        axis(oAxes,'off');
    end

    
    
    if ~mod(i,3)
        iCount = 0;
        iGroup = iGroup + 1;
    end
end

export_fig('D:\Users\jash042\Documents\PhD\Thesis\Figures\EffectsOfBlebbistatin.png','-png','-r300','-nocrop','-painters');