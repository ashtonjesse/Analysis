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
oOnsetAxes = aSubplotPanel(2,3).select();

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
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','bold','fontsize',10);
% %add panel label
text(axlim(1)-100,aylim(2)+1,'C','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');

