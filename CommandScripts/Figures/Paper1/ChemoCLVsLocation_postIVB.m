%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
% close all;
% clear all;

% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\ChemoCLVsLocation_postIVB.png';
% %set up figure
% dWidth = 9;
% dHeight = 10;
% oFigure = figure();

% set(oFigure,'color','white')
% set(oFigure,'inverthardcopy','off')
% set(oFigure,'PaperUnits','centimeters');
% set(oFigure,'PaperPositionMode','auto');
% set(oFigure,'Units','centimeters');
% set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
% set(oFigure,'Resize','off');

% aSubplotPanel = panel(oFigure);
% aSubplotPanel.pack(2,2);
% aSubplotPanel.margin = [15 15 2 8];
% aSubplotPanel.de.margin = [8 10 0 0];
% aSubplotPanel.de.margin = [15 20 0 0];
% aSubplotPanel.fontsize = 8;
% iScatterSize = 4;
% aylim = [0 10];
% axlim = [200 900];

%% set up panels A and B
%get data
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo005\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo006\Pressure.mat'...
    }};

%initialise arrays to hold arrays of data
aBaselinePressures = cell(numel(aControlFiles),1);
aBaselineCouplingIntervals = cell(numel(aControlFiles),1);
aAllInitialLocs = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the dynamic data
oOnsetAxes = aSubplotPanel(2,2,1,1).select();

%define the colour range for plots
aScatterColor = {...
    {'k','r'} ...
    {'k','k','r','r','r'} ...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','r','r','r'}};
aScatterMarker = {...
    {'filled','o'} ...
    {'filled','filled','o','o','o'} ...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','o','o','o'}};
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
    load([pathstr(1:end-16),'\ChemoLocationData.mat']);
    iCount = 0;
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        
        %get the cycle lengths and times for all beats for this file
        switch (i)
            case 2
                if j == 5
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 4
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = oPressure.oRecording(1).TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
            case 5
                if j == 2
                    aCouplingIntervals = 60000 ./ [oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
                else
                    aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
                end
            otherwise
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        end
        if i == 3 && j == 1
            %The data used for location detection is a subset missing the
            %first 10 beats
            aCouplingIntervals = aCouplingIntervals(11:end);
            aTimes = aTimes(11:end);
        end
        
        %get the locs for this file
        try
            aThisDistance =  aDistance{j};
            aLocs = aThisDistance{1}(:,1);
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if numel(aLocs) ~= numel(aCouplingIntervals)
            fprintf('Warning: Locs dont match CouplingIntervals for %s\n',char(aFiles{j}));
        end
        aTimePoints = aTimes >= oPressure.HeartRate.Decrease.BeatTimes(1) & ...
            aTimes <= oPressure.HeartRate.Decrease.BeatTimes(end);
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
set(oOnsetAxes,'yticklabel',[]);
set(get(oOnsetAxes,'xlabel'),'string','CL (ms)');
% set(get(oOnsetAxes,'ylabel'),'string','DP site (mm)');
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','bold');
% %add panel label
text(axlim(1)-100,aylim(2)+1.5,'D','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');
% oLegend = legend(oOnsetAxes,'Pre-IVB','Post-IVB','location','northeast');
% set(oLegend,'position', [0.5954    0.8289    0.1650    0.1005]);
% oChildren = get(oLegend,'children');
% oChildren = get(oChildren(1),'children');
% set(oChildren,'markerfacecolor','none','markeredgecolor','r');
% legend(oOnsetAxes,'boxoff');

%create boxplots panel
oAxes = aSubplotPanel(2,2,2,1).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');
text(axlim(1)-100,aylim(2)+1.5,'E','parent',oOverlay,'fontsize',12,'fontweight','bold');
%get data
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\ChemoCLandLocationData.csv');
aInitialDelCL = aData(:,strcmp(aHeader,'CL2')) - aData(:,strcmp(aHeader,'CL1'));
aPreInitialDelCL = aInitialDelCL(~logical(aData(:,strcmp(aHeader,'IVB'))));
aPostInitialDelCL = aInitialDelCL(logical(aData(:,strcmp(aHeader,'IVB'))));
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\ChemoCLandLocationDataReturn.csv');
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
% aylim2 = get(oAxes,'ylim');
aylim2 = [-400 600];
set(oAxes,'ylim',aylim2);
aytick = get(oAxes,'ytick');
set(oAxes,'yticklabel',[]);
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
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/1.5),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
xticklabels{axtick==1} = sprintf('n=%1.0f',numel(aPreInitialDelCL));
xticklabels{axtick==3} = sprintf('n=%1.0f',numel(aPostInitialDelCL));
xticklabels{axtick==5} = sprintf('n=%1.0f',numel(aPreReturnDelCL));
xticklabels{axtick==7} = sprintf('n=%1.0f',numel(aPostReturnDelCL));
text(axtick,ones(numel(axtick),1).*(aylim2(1)-2.2*abs(aytick(1)-aytick(2))/1.5),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3 5 7]);
% set(get(oAxes,'ylabel'),'string','\DeltaCL (ms)');
%put titles on 
text(2,aylim2(2)+50,['First',10,'shift'],'fontsize',8,'fontweight','bold','horizontalalignment','center','parent',oAxes);
text(6,aylim2(2)+50,['Last',10,'shift'],'fontsize',8,'fontweight','bold','horizontalalignment','center','parent',oAxes);
% % %print
% movegui(oFigure,'center');
% set(oFigure,'resizefcn',[]);
% export_fig(sSavePath,'-png','-r300','-nocrop','-painters');
