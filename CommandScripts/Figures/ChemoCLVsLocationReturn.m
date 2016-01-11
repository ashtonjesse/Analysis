%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
% clear all;
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

%set up figure
dWidth = 16;
dHeight = 5;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',3);
aSubplotPanel.margin = [10 10 5 5];
aSubplotPanel.de.margin = [10 0 0 0];
aSubplotPanel.fontsize = 6;
oAxes = aSubplotPanel(1).select();
iScatterSize = 16;
aylim = [0 8];
axlim = [200 900];

hold(oAxes, 'on'); 
% sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\chemoCIVsShift_return_all_postIVB.eps';
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\ChemoCLVsLocation_return_postIVB.gif';
aPreLocGroups = cell(1,14);
aPostLocGroups = cell(1,14);
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\ChemoLocationData.mat']);

    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
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
        aTimePoints = aTimes >= oPressure.HeartRate.Decrease.BeatTimes(1) & ...
            aTimes <= oPressure.HeartRate.Decrease.BeatTimes(end);
        try
            aThisDistance =  aDistance{j};
            aLocs = aThisDistance{1}(:,1);
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            break; disp('broken');
        end
        %         delT = [NaN diff(aCouplingIntervals)];
        %         delX = vertcat(NaN, -diff(aLocs));
        aCouplingIntervals = aCouplingIntervals(aTimePoints);
        aLocs = aLocs(aTimePoints);
        aCouplingIntervals = aCouplingIntervals(~isnan(aLocs));
        aLocs = aLocs(~isnan(aLocs));
        delT = aCouplingIntervals;
        delX = aLocs;
        Pre = false;
        Post = false;
        switch (i)
            case 1
                switch (j)
                    case 1
                        scatter(oAxes,delT,delX,iScatterSize,'k','filled');
                        Pre = true;
                    case 2
                        scatter(oAxes,delT,delX,iScatterSize,'r','filled');
                        Post = true;
                end
            case 2
                switch (j)
                    case {1,2}
                        scatter(oAxes, delT, delX,iScatterSize,'k','filled');
                        Pre = true;
                    case {3,4,5}
                        scatter(oAxes, delT, delX,iScatterSize,'r','filled');
                        Post = true;
                end
            otherwise
                switch (j)
                    case {1,2,3}
                        scatter(oAxes, delT, delX,iScatterSize,'k','filled');
                        Pre = true;
                    case {4,5,6}
                        scatter(oAxes, delT, delX,iScatterSize,'r','filled');
                        Post = true;
                end
        end
        if Pre
            iStart = 200;
            for m = 1:numel(aPreLocGroups)
                aPoints = delT >= iStart & ...
                    delT < (iStart+50);
                aPreLocGroups{m} = vertcat(aPreLocGroups{m},delX(aPoints));
                iStart = iStart + 50;
            end
        elseif Post
            iStart = 200;
            for m = 1:numel(aPostLocGroups)
                aPoints = delT >= iStart & ...
                    delT < (iStart+50);
                aPostLocGroups{m} = vertcat(aPostLocGroups{m},delX(aPoints));
                iStart = iStart + 50;
            end
        end
    end
    
end
hold(oAxes, 'off'); 
set(oAxes,'xlim',axlim);
set(oAxes,'ylim',aylim);
set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');

oAxes = aSubplotPanel(3).select();
for m = 1:numel(aPreLocGroups)
    aPreVals(m,2) = mean(aPreLocGroups{m});
    aPostVals(m,2) = mean(aPostLocGroups{m});
    aPreErrors(m,2) = std(aPreLocGroups{m})/sqrt(numel(aPreLocGroups{m}));
    aPostErrors(m,2) = std(aPostLocGroups{m})/sqrt(numel(aPostLocGroups{m}));
    if numel(aPreLocGroups{m}) > 1
        bplot(aPreLocGroups{m},oAxes,m,'nolegend','nooutliers','tukey','linewidth',1);
    end
    hold(oAxes,'on');
    if numel(aPostLocGroups{m}) > 1
        bplot(aPostLocGroups{m},oAxes,m,'nolegend','nooutliers','tukey','linewidth',1);
    end
end
set(oAxes,'xlim',[0.5 14.5]);
set(oAxes,'xtick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14]);
set(oAxes,'xticklabel',[]);
set(oAxes,'ylim',aylim);
set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
xtl = {'200-250','250-300','300-350','350-400','400-450','450-500','500-550',...
    '550-600','600-650','650-700','700-750','750-800','800-850','850-900'};
text([1 2 3 4 5 6 7 8 9 10 11 12 13 14],ones(1,14)*-2,xtl,'parent',oAxes,'rotation',90,'fontsize',6); 
hold(oAxes,'off');

oAxes = aSubplotPanel(2).select();
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aPreVals(:,2),aPreErrors(:,2),'k-');
hold(oAxes,'on');
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aPostVals(:,2),aPostErrors(:,2),'r-');
set(oAxes,'xlim',axlim);
set(oAxes,'ylim',aylim);
set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
set(oAxes,'box','off');


movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% print(oFigure,'-dpsc','-r300',sSavePath)
printgif(oFigure,'-r300',sSavePath);