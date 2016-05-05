%this script loads a bunch of pressure files and compares heart rates,
%phrenic burst rates and durations
close all;
clear all;
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\164850\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\165121\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\165352\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\165623\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\165854\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\170124\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\151225\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\151456\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\151727\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\151958\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\152317\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\164956\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\165227\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\165458\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\165729\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\170000\Pressure.mat' ...
    };
aTimes = [...
    0
151
302
453
604
755
0
151
302
453
652
0
151
302
453
604
];
% 
aTimes = aTimes ./ 60;
%loop through files and get data
%initialise variables
aHeartBeatRates = cell(numel(aFiles),1);
aBurstRates = cell(numel(aFiles),1);
aBurstDurations = cell(numel(aFiles),1);
aMeanHeartRates = zeros(numel(aFiles),1);
aMeanBurstRates = zeros(numel(aFiles),1);
aMeanBurstDurations = zeros(numel(aFiles),1);
aSEMHeartRates = zeros(numel(aFiles),1);
aSEMBurstRates = zeros(numel(aFiles),1);
aSEMBurstDurations = zeros(numel(aFiles),1);
aMeanPressure = zeros(numel(aFiles),1);
aSEMPressure = zeros(numel(aFiles),1);
for i =1:numel(aFiles)
    oPressure = GetPressureFromMATFile(Pressure, aFiles{i}, 'Optical');
    aHeartBeatRates{i} = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
    aBurstRates{i} = oPressure.oPhrenic.Electrodes.Processed.BurstRates;
    aBurstDurations{i} = oPressure.oPhrenic.Electrodes.Processed.BurstDurations;
    fprintf('Got data from %s\n',aFiles{i});
    aMeanHeartRates(i) = mean(aHeartBeatRates{i});
    aMeanBurstRates(i) = mean(aBurstRates{i});
    aMeanBurstDurations(i) = mean(aBurstDurations{i});
    aSEMHeartRates(i) = stderror(aHeartBeatRates{i});
    aSEMBurstRates(i) = stderror(aBurstRates{i});
    aSEMBurstDurations(i) = stderror(aBurstDurations{i});
    aMeanPressure(i) = mean(oPressure.Processed.Data);
    aSEMPressure(i) = stderror(oPressure.Processed.Data);
end
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

aXLim = [-5 15];
oAxes = aSubplotPanel(1,1).select();
errorbar(aTimes(1:6),aMeanBurstRates(1:6),aSEMBurstRates(1:6),'k','parent',oAxes);
hold(oAxes,'on');
errorbar(aTimes(7:11),aMeanBurstRates(7:11),aSEMBurstRates(7:11),'b','parent',oAxes);
errorbar(aTimes(12:end),aMeanBurstRates(12:end),aSEMBurstRates(12:end),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim);
set(oAxes,'xcolor','w','xtick',[],'xticklabel',[]);
set(get(oAxes,'ylabel'),'string','PND Rate (bursts/min)');
oLegend = legend(oAxes,'20140715','20140718','20140723');
set(oLegend,'position',[0.3232    0.7127    0.1683    0.1179]);

oAxes = aSubplotPanel(1,2).select();
errorbar(aTimes(1:6),aMeanBurstDurations(1:6),aSEMBurstDurations(1:6),'k','parent',oAxes);
hold(oAxes,'on');
errorbar(aTimes(7:11),aMeanBurstDurations(7:11),aSEMBurstDurations(7:11),'b','parent',oAxes);
errorbar(aTimes(12:end),aMeanBurstDurations(12:end),aSEMBurstDurations(12:end),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim);
set(oAxes,'xcolor','w','xtick',[],'xticklabel',[]);
set(get(oAxes,'ylabel'),'string','PND Duration (s)');

oAxes = aSubplotPanel(1,3).select();
errorbar(aTimes(1:6),aMeanHeartRates(1:6),aSEMHeartRates(1:6),'k','parent',oAxes);
hold(oAxes,'on');
errorbar(aTimes(7:11),aMeanHeartRates(7:11),aSEMHeartRates(7:11),'b','parent',oAxes);
errorbar(aTimes(12:end),aMeanHeartRates(12:end),aSEMHeartRates(12:end),'r','parent',oAxes);
set(oAxes,'box','off');
set(oAxes,'xlim',aXLim,'xtick',[],'xticklabel',[],'xcolor','w');
set(get(oAxes,'ylabel'),'string','Heart rate (bpm)');


%create overlay axes for heart rate
oOverlay = aSubplotPanel(1,4).select();
errorbar(aTimes(1:6),aMeanPressure(1:6),aSEMPressure(1:6),'k','parent',oOverlay);
hold(oOverlay,'on');
errorbar(aTimes(7:11),aMeanPressure(7:11),aSEMPressure(7:11),'b','parent',oOverlay);
errorbar(aTimes(12:end),aMeanPressure(12:end),aSEMPressure(12:end),'r','parent',oOverlay);
hold(oOverlay,'off');
set(oOverlay,'box','off');
set(oOverlay,'xlim',aXLim);
set(get(oOverlay,'xlabel'),'string','Time Elapsed (min)');
set(get(oOverlay,'ylabel'),'string','Pressure (mmHg)');

% %plot phrenic bursts
% aPhrenicFiles = {...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\162847\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\163911\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\171221\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\163208\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\164212\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\165107\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\134350\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\135354\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\140127\Pressure.mat' ...
%     };
% 
% aSubplotPanel(2).pack('v',3);
% aSubplotPanel(2).de.margin = [0 10 0 0];
% aSubplotPanel(2,1).pack(2,3);
% aSubplotPanel(2,1).de.margin = [2 2 2 2];
% aSubplotPanel(2,2).pack(2,3);
% aSubplotPanel(2,2).de.margin = [2 2 2 2];
% aSubplotPanel(2,3).pack(2,3);
% aSubplotPanel(2,3).de.margin = [2 2 2 2];
% 
% aIndices = [
%     14800
%     14600
%     41999
%     11000
%     6200
%     36200
%     8199
%     19800
%     83800];
% iGroup = 1;
% iPeriod = 30000;
% iCount = 0;
% sColor = {'k','b','r'};
% for i = 1:numel(aPhrenicFiles)
%     iCount = iCount + 1;
%     oPressure = GetPressureFromMATFile(Pressure, aPhrenicFiles{i}, 'Optical');
%     oAxes = aSubplotPanel(2,iGroup,1,iCount).select();
%     
%     %raw
%     aData = oPressure.oPhrenic.Electrodes.Processed.Data(aIndices(i):aIndices(i)+iPeriod)./ ...
%         (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
%     aYLim = [-75 50];
%     plot(oAxes,oPressure.oPhrenic.TimeSeries(aIndices(i):aIndices(i)+iPeriod),aData,sColor{iGroup});
%     set(oAxes,'ylim',aYLim);
%     set(oAxes,'xlim',[oPressure.oPhrenic.TimeSeries(aIndices(i)) oPressure.oPhrenic.TimeSeries(aIndices(i))+iPeriod/10000]);
%     axis(oAxes,'off');
%     
%     if iCount == 1
%         oAxes = axes('parent',oFigure,'position',get(oAxes,'position')-[0.08 0 0 0]);
%         plot(oAxes,[0 0], [-25 25],'k','linewidth',2);
%         text(-0.1,0,'50 \muV','parent',oAxes,'horizontalalignment','right','fontsize',8);
%         set(oAxes,'ylim',aYLim);
%         axis(oAxes,'off');
%         aXLim = get(oAxes,'xlim');
%     end
%     
%     
%     oAxes = aSubplotPanel(2,iGroup,2,iCount).select();
%     %integral
%     aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, ...
%         oPressure.oPhrenic.Electrodes.Processed.Data,2);
%     %calc bin integral of this
%     aBurstData = oPressure.oPhrenic.ComputeRectifiedBinIntegral(aBurstData, 200);
%     aData = aBurstData(aIndices(i):aIndices(i)+iPeriod);
%     switch iGroup
%         case 1
%             aYLim = [0 10];
%         case 2
%             aYLim = [0 5];
%         case 3
%             aYLim = [0 5];
%     end
%     plot(oAxes,oPressure.oPhrenic.TimeSeries(aIndices(i):aIndices(i)+iPeriod),aData,sColor{iGroup});
%     set(oAxes,'ylim',aYLim);
%     set(oAxes,'xlim',[oPressure.oPhrenic.TimeSeries(aIndices(i)) oPressure.oPhrenic.TimeSeries(aIndices(i))+iPeriod/10000]);
%     axis(oAxes,'off');
%     
%     if iCount == 1
%         oAxes = axes('parent',oFigure,'position',get(oAxes,'position')-[0.08 0 0 0]);
%         set(oAxes,'ylim',aYLim,'xlim',aXLim);
%         text(-0.1,(aYLim(2)-aYLim(1))/2,'\intPND','parent',oAxes,'horizontalalignment','right','fontsize',8);
%         axis(oAxes,'off');
%     end
% 
%     
%     
%     if ~mod(i,3)
%         iCount = 0;
%         iGroup = iGroup + 1;
%     end
% end
% 
% export_fig('D:\Users\jash042\Documents\PhD\Thesis\Figures\EffectsOfDi4.png','-png','-r300','-nocrop','-painters');