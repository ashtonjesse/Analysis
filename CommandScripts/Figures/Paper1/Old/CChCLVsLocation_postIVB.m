%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
% close all;
% clear all;

sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\ChemoCChCLVsLocation_postIVB.png';
sThesisSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ChemoCChCLVsLocation_postIVB.eps';
% %set up figure
% dWidth = 9;
% dHeight = 10;
% oFigure = figure();
% 
% set(oFigure,'color','white')
% set(oFigure,'inverthardcopy','off')
% set(oFigure,'PaperUnits','centimeters');
% set(oFigure,'PaperPositionMode','auto');
% set(oFigure,'Units','centimeters');
% set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
% set(oFigure,'Resize','off');

% aSubplotPanel = panel(oFigure);
% aSubplotPanel.pack(2,2);
% aSubplotPanel.margin = [15 10 2 8];
% aSubplotPanel.de.margin = [15 20 0 0];
% aSubplotPanel.fontsize = 8;
% iScatterSize = 4;
% aylim = [0 10];
% axlim = [200 900];

%% set up panels A and B
%get data
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh004\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh003\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh005\Pressure.mat' ...
    }};

%initialise arrays to hold arrays of data
aBaselinePressures = cell(numel(aControlFiles),1);
aBaselineCouplingIntervals = cell(numel(aControlFiles),1);
aAllInitialLocs = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the dynamic data
oOnsetAxes = aSubplotPanel(1,2).select();

%define the colour range for plots
aScatterColor = {...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','k','r','r','r'} ...
    {'k','k','r','r'} ...
    {'k','k','r'} ...
    {'k','k','k','r','r'}};
aScatterMarker = {...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','filled','o','o','o'} ...
    {'filled','filled','o','o'} ...
    {'filled','filled','o'} ...
    {'filled','filled','filled','o','o'}};
aCRange = [0 7];
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    %initialise array for this set of files
    aBaselinePressures{i} = zeros(numel(aFiles),1);
    aBaselineCouplingIntervals{i} = zeros(numel(aFiles),1);
    aInitialStackedLocs = cell(numel(aFiles),1);
    aMaxLocs{i} = zeros(numel(aFiles),1);
    aAllLocs = cell(numel(aFiles),1);
    %get the location data
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-15),'\CChLocationData.mat']);
    iCount = 0;
    for j = 1:numel(aFiles)
        %get the cycle lengths and times for all beats for this file
        if i == 2 && j == 3
            oOptical = GetOpticalFromMATFile(Optical,...
                'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh003\CCh003a_g10_LP100Hz-wave.mat');
            aCouplingIntervals  = oOptical.Electrodes.Processed.BeatRates;
            aTimePoints = oOptical.Electrodes.Processed.Decrease.Beats;
            oOptical = GetOpticalFromMATFile(Optical,...
                'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh003\CCh003b_g10_LP100Hz-wave.mat');
            aCouplingIntervals  = vertcat(aCouplingIntervals, oOptical.Electrodes.Processed.BeatRates);
            aTimePoints = vertcat(aTimePoints,oOptical.Electrodes.Processed.Decrease.Beats);
            aCouplingIntervals = 60000 ./ aCouplingIntervals;
        else
            oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
            fprintf('Got file %s\n',char(aFiles{j}));
            %build CL and time arrays
            switch (i)
                case 4
                    aCouplingIntervals  = vertcat(oPressure.oRecording(1).Electrodes.Processed.BeatRates,...
                        oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                    aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                    aTimes = horzcat(oPressure.oRecording(1).TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes),...
                        oPressure.oRecording(2).TimeSeries(oPressure.oRecording(2).Electrodes.Processed.BeatRateIndexes));
                case 2
                    if j > 1
                        aCouplingIntervals  = horzcat(NaN,oPressure.oRecording(1).Electrodes.Processed.BeatRates,NaN,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                        aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                        aTimes = horzcat(oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRateTimes);
                    else
                        aCouplingIntervals  = vertcat(oPressure.oRecording(1).Electrodes.Processed.BeatRates,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                        aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                        aTimes = horzcat(oPressure.oRecording(1).TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes),...
                            oPressure.oRecording(2).TimeSeries(oPressure.oRecording(2).Electrodes.Processed.BeatRateIndexes));
                    end
                otherwise
                    aCouplingIntervals  = horzcat(NaN,oPressure.oRecording(1).Electrodes.Processed.BeatRates,NaN,...
                        oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                    aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                    aTimes = horzcat(oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes,...
                        oPressure.oRecording(2).Electrodes.Processed.BeatRateTimes);
            end
            aTimePoints = aTimes >= oPressure.HeartRate.Decrease.BeatTimes(1) & ...
                aTimes <= oPressure.HeartRate.Decrease.BeatTimes(end);
        end
        
        %get the locs for this file
        try
            aThisDistance =  aDistance{j};
            aLocs = vertcat(aThisDistance{1}(:,1),aThisDistance{2}(:,1));
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if numel(aLocs) ~= numel(aCouplingIntervals)
            fprintf('Warning: Locs dont match CouplingIntervals for %s\n',char(aFiles{j}));
        end
        %get pressure baseline means for this file
        %         aBaselinePressures{i}(j) = mean(oPressure.Baseline.BeatPressures);
        
        %get CL baseline means for this file
        %         aBaselineCouplingIntervals{i}(j)  = 60000 / mean(oPressure.Baseline.BeatRates);
        
        aAllLocs{j} = aLocs(aTimePoints);
        aMaxLocs{i}(j) = max(aLocs(aTimePoints));
        
        %get data for dynamic relationship between CL and loc (panel 2,1)
        %get initial data
        aInitialCouplingIntervals = aCouplingIntervals(aTimePoints);
        aInitialLocs = aLocs(aTimePoints);
        aInitialStackedLocs{j} = aInitialLocs;
        InitialdelT = aInitialCouplingIntervals(~isnan(aInitialLocs));
        InitialdelX = aInitialLocs(~isnan(aInitialLocs));
        %plot the dynamic data
        scatter(oOnsetAxes, InitialdelT, InitialdelX,iScatterSize,aScatterColor{i}{j},aScatterMarker{i}{j});
        hold(oOnsetAxes, 'on');
    end
    %get the data for the histogram
    StackedLocs = vertcat(aAllLocs{:});
    aCombinedLocs{i} = StackedLocs;
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
end
hold(oOnsetAxes, 'off');

%make the dynamic axes look right
set(oOnsetAxes,'xlim',axlim);
set(oOnsetAxes,'ylim',aylim);
set(oOnsetAxes,'ytick',[2 4 6 8]);
set(get(oOnsetAxes,'xlabel'),'string','CL (ms)','fontsize',8);
set(get(oOnsetAxes,'ylabel'),'string','DPS (mm)','fontsize',8);
set(get(oOnsetAxes,'title'),'string','CCh','fontweight','bold','fontsize',8);
% %add panel label
text(axlim(1)-200,aylim(2)+1.5,'C','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');
oLegend = legend(oOnsetAxes,'Pre-IVB','Post-IVB','location','northeast');
set(oLegend,'position', [0.6021    0.8395    0.2933    0.1005]);
oChildren = get(oLegend,'children');
oChildren = get(oChildren(1),'children');
set(oChildren,'markerfacecolor','none','markeredgecolor','r');
legend(oOnsetAxes,'boxoff');

%create boxplots panel
oAxes = aSubplotPanel(2,2).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');
text(axlim(1)-200,aylim(2)+1.5,'D','parent',oOverlay,'fontsize',12,'fontweight','bold');
%get data
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\CChCLandLocationData.csv');
aInitialDelCL = aData(:,strcmp(aHeader,'CL2')) - aData(:,strcmp(aHeader,'CL1'));
aPreInitialDelCL = aInitialDelCL(~logical(aData(:,strcmp(aHeader,'IVB'))));
aPostInitialDelCL = aInitialDelCL(logical(aData(:,strcmp(aHeader,'IVB'))));
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\CChCLandLocationDataReturn.csv');
aReturnDelCL = aData(:,strcmp(aHeader,'CL4')) - aData(:,strcmp(aHeader,'CL3'));
aPreReturnDelCL = aReturnDelCL(~logical(aData(:,strcmp(aHeader,'IVB'))));
aPostReturnDelCL = aReturnDelCL(logical(aData(:,strcmp(aHeader,'IVB'))));

%plot boxplots
bplot(aPreInitialDelCL,oAxes,1,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean');
hold(oAxes,'on');
bplot(aPostInitialDelCL,oAxes,3,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean','color','r');
hold(oAxes,'on');
bplot(aPreReturnDelCL,oAxes,5,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean','color','k');
hold(oAxes,'on');
bplot(aPostReturnDelCL,oAxes,7,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean','color','r');
aylim2 = get(oAxes,'ylim');
aylim2 = [-400 600];
set(oAxes,'ylim',aylim2);
aytick = get(oAxes,'ytick');
set(oAxes,'xlim',[0 8]);
set(oAxes,'xtick',[1 2 3 4 5 6 7 8]);
plot(oAxes,[4 4],[aylim2(1) aylim2(2)]-[0 50],'k--');
hold(oAxes,'off');
axtick = get(oAxes,'xtick');
xticklabels = cell(1,numel(axtick));
[xticklabels{:}] = deal('');
xticklabels{axtick==1} = ['Pre-',10,'IVB'];
xticklabels{axtick==3} = ['Post-',10,'IVB'];
xticklabels{axtick==5} = ['Pre-',10,'IVB'];
xticklabels{axtick==7} = ['Post-',10,'IVB'];
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/1.2),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
xticklabels{axtick==1} = sprintf('n=%1.0f',numel(aPreInitialDelCL));
xticklabels{axtick==3} = sprintf('n=%1.0f',numel(aPostInitialDelCL));
xticklabels{axtick==5} = sprintf('n=%1.0f',numel(aPreReturnDelCL));
xticklabels{axtick==7} = sprintf('n=%1.0f',numel(aPostReturnDelCL));
text(axtick,ones(numel(axtick),1).*(aylim2(1)-2*abs(aytick(1)-aytick(2))/1.2),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3 5 7]);
set(get(oAxes,'ylabel'),'string','\DeltaCL (ms)');
%put titles on 
text(2,aylim2(2)+50,['First',10,'shift'],'fontsize',8,'fontweight','bold','horizontalalignment','center','parent',oAxes);
text(6,aylim2(2)+50,['Last',10,'shift'],'fontsize',8,'fontweight','bold','horizontalalignment','center','parent',oAxes);
%print
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
export_fig(sPaperSavePath,'-png','-r300','-nocrop','-painters');
print(sThesisSavePath,'-dpsc','-r300');
