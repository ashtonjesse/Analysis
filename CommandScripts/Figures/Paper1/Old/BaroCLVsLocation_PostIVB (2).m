%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;

% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\BaroCLVsLocation_postIVB.png';
sThesisSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\BaroCLVsLocation_postIVB.eps';
%set up figure
dWidth = 16;
dHeight = 7;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('v',{0.01 0.99});
aSubplotPanel(2).pack('h',4);
aSubplotPanel.margin = [15 12 2 8];
aSubplotPanel.de.margin = [8 10 0 0];
aSubplotPanel.fontsize = 8;
iScatterSize = 4;
aylim = [0 10];
axlim = [180 900];

%% set up panels A and B
%get data
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat'...
    }};
%initialise arrays to hold arrays of data
aBaselinePressures = cell(numel(aControlFiles),1);
aPlateauPressures = cell(numel(aControlFiles),1);
aBaselineCouplingIntervals = cell(numel(aControlFiles),1);
aPlateauCouplingIntervals = cell(numel(aControlFiles),1);
aAllInitialLocs = cell(1,numel(aControlFiles));
aAllReturnLocs = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the steady state data
oOnsetAxes = aSubplotPanel(2,1).select();
oRecoveryAxes = aSubplotPanel(2,2).select();
%define the colour range for plots
aScatterColor = {...
    {'k','k','r','r','r'} ...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','r'} ...
    {'k','k','k','r','r','r'}};
aScatterMarker = {...
    {'filled','filled','o','o','o'} ...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','o'} ...
    {'filled','filled','filled','o','o','o'}};
aCRange = [0 7];
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    %initialise array for this set of files
    aBaselinePressures{i} = zeros(numel(aFiles),1);
    aPlateauPressures{i} = zeros(numel(aFiles),1);
    aBaselineCouplingIntervals{i} = zeros(numel(aFiles),1);
    aPlateauCouplingIntervals{i} = zeros(numel(aFiles),1);
    aInitialStackedLocs = cell(numel(aFiles),1);
    aReturnStackedLocs = cell(numel(aFiles),1);
    aMaxLocs{i} = zeros(numel(aFiles),1);
    aAllLocs = cell(numel(aFiles),1);
    %get the location data
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\BaroLocationData.mat']);
    iCount = 0;
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        
        %get the cycle lengths and times for all beats for this file
        switch (i)
            case {2,5}
                if j == 1
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 3
                if j == 1 || j == 2
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 4
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = [oPressure.oRecording(1).TimeSeries(...
                    oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes(1:end-1)) NaN];
            otherwise
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        end
        
        %get the locs for this file
        aLocs =  aDistance{j}(:,1);
        if numel(aLocs) ~= numel(aCouplingIntervals)
            fprintf('Warning: Locs dont match CouplingIntervals for %s\n',char(aFiles{j}));
        end
        
        %get pressure baseline and plateau means for this file
        aBaselinePressures{i}(j) = mean(oPressure.Baseline.BeatPressures);
        aPlateauPressures{i}(j) = mean(oPressure.Plateau.BeatPressures);
        %get CL baseline and plateua means for this file
        aBaselineCouplingIntervals{i}(j)  = 60000 / mean(oPressure.Baseline.BeatRates);
        aPlateauCouplingIntervals{i}(j) = 60000 / mean(oPressure.HeartRate.Plateau.BeatRates);
        aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(1)) & ...
            aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
        aAllLocs{j} = aLocs(aTimePoints);
        aMaxLocs{i}(j) = max(aLocs(aTimePoints));
        

        %get data for dynamic relationship between CL and loc (panel 2,1)
        %get initial data
        if oPressure.HeartRate.Plateau.Range > 0
            %             aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(1));
        else
            %             aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Plateau.Range(2));
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.Plateau.Range(1));
        end
        aInitialCouplingIntervals = aCouplingIntervals(aTimePoints);
        aInitialLocs = aLocs(aTimePoints);
        aInitialStackedLocs{j} = aInitialLocs;
        InitialdelT = aInitialCouplingIntervals(~isnan(aInitialLocs));
        InitialdelX = aInitialLocs(~isnan(aInitialLocs));
        %get return data
        if oPressure.HeartRate.Increase.Range > 0
             aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Increase.Range(2));
        else
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
        end
        aReturnCouplingIntervals = aCouplingIntervals(aTimePoints);
        aReturnLocs = aLocs(aTimePoints);
        aReturnStackedLocs{j} = aReturnLocs;
        ReturndelT = aReturnCouplingIntervals(~isnan(aReturnLocs));
        ReturndelX = aReturnLocs(~isnan(aReturnLocs));
        %plot the dynamic data
        scatter(oOnsetAxes, InitialdelT, InitialdelX,iScatterSize,aScatterColor{i}{j},aScatterMarker{i}{j});
        hold(oOnsetAxes, 'on');
        scatter(oRecoveryAxes, ReturndelT, ReturndelX,iScatterSize,aScatterColor{i}{j},aScatterMarker{i}{j});
        hold(oRecoveryAxes, 'on');
    end
    %get the data for the histogram
    StackedLocs = vertcat(aAllLocs{:});
    aCombinedLocs{i} = StackedLocs;
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
end
hold(oOnsetAxes, 'off');
hold(oRecoveryAxes, 'off');

%make the dynamic axes look right
set(oOnsetAxes,'xlim',axlim);
set(oOnsetAxes,'ylim',aylim);
set(oOnsetAxes,'ytick',[2 4 6 8]);
set(get(oOnsetAxes,'xlabel'),'string','CL (ms)');
set(get(oOnsetAxes,'ylabel'),'string','DP site (mm)');
set(oRecoveryAxes,'xlim',axlim);
set(oRecoveryAxes,'ylim',aylim);
set(oRecoveryAxes,'ytick',[2 4 6 8]);
set(oRecoveryAxes,'yticklabel',[]);
set(get(oRecoveryAxes,'xlabel'),'string','CL (ms)');
% set(get(oRecoveryAxes,'ylabel'),'string','DP site (mm)');
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','bold','fontsize',10);
set(get(oRecoveryAxes,'title'),'string','Recovery','fontweight','bold','fontsize',10);
% %add panel label
text(axlim(1)-100,aylim(2)+1,'A','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');
text(axlim(1)-100,aylim(2)+1,'B','parent',oRecoveryAxes,'fontsize',12,'fontweight','bold');
oLegend = legend(oOnsetAxes,'Pre-IVB','Post-IVB','location','northeast');
set(oLegend,'position', [0.1201    0.5865    0.1650    0.1434]);
oChildren = get(oLegend,'children');
oChildren = get(oChildren(1),'children');
set(oChildren,'markerfacecolor','none','markeredgecolor','r');
legend(oOnsetAxes,'boxoff');

% oLegend = legend(oRecoveryAxes,'Pre-IVB','Post-IVB','location','northeast');
% set(oLegend,'position', [0.3454    0.8289    0.1650    0.1005]);
% legend(oRecoveryAxes,'boxoff');
% oChildren = get(oLegend,'children');
% oChildren = get(oChildren(1),'children');
% set(oChildren,'markerfacecolor','none','markeredgecolor','r');




%print
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
%put overtitles on
annotation('textbox',[0.18 0.88 0.1 0.1],'string','Baroreflex','fontsize',12,'fontweight','bold','edgecolor','w');
annotation('textbox',[0.56 0.88 0.1 0.1],'string','Chemoreflex','fontsize',12,'fontweight','bold','edgecolor','w');
annotation('textbox',[0.85 0.88 0.1 0.1],'string','CCh','fontsize',12,'fontweight','bold','edgecolor','w');
% export_fig(sPaperSavePath,'-png','-r300','-nocrop','-painters');
% print(sThesisSavePath,'-dpsc','-r300');
