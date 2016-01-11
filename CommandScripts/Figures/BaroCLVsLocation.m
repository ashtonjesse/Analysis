%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat'...
    }};
% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
% sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\';
%set up figure
dWidth = 16;
dHeight = 10;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack(2,3);
aSubplotPanel.margin = [10 10 5 8];
aSubplotPanel.de.margin = [8 10 0 0];
aSubplotPanel.fontsize = 6;
oAxes = aSubplotPanel(1,1).select();
iScatterSize = 4;
aylim = [0 8];
axlim = [200 900];

hold(oAxes, 'on');
aBaselinePressures = cell(numel(aControlFiles),1);
aPlateauPressures = cell(numel(aControlFiles),1);
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\BaroCLVsLocation_initial_postIVB.gif';
aInitialPreLocGroups = cell(1,14);
aInitialPostLocGroups = cell(1,14);
aReturnPreLocGroups = cell(1,14);
aReturnPostLocGroups = cell(1,14);
aAllInitialLocs = cell(1,numel(aControlFiles));
aAllReturnLocs = cell(1,numel(aControlFiles));
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\BaroLocationData.mat']);
    
    aBaselinePressures{i} = zeros(1,numel(aFiles));
    aPlateauPressures{i} = zeros(1,numel(aFiles));
    aInitialStackedLocs = cell(numel(aFiles),1);
    aReturnStackedLocs = cell(numel(aFiles),1);
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        aBaselinePressures{i}(j) = mean(oPressure.Baseline.BeatPressures);
        aPlateauPressures{i}(j) = mean(oPressure.Plateau.BeatPressures);
        switch (i)
            case {7,10}
                if j == 1
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 8
                if j == 1 || j == 2
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 9
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = [oPressure.oRecording(1).TimeSeries(...
                    oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes(1:end-1)) NaN];
            case 11                
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = oPressure.oRecording.TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
            otherwise
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        end
        aLocs =  aDistance{j}(:,1);
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            if i == 4
                switch (j)
                    case 9
                        aLocs = vertcat(aLocs(1:49),aLocs(49),aLocs(50:end));
                    case 8
                        aLocs = vertcat(aLocs(1:20),aLocs(20),aLocs(21:end));
                    case 6
                        aLocs = vertcat(aLocs(1:22),aLocs(22),aLocs(23:end));
                    case 7
                        aLocs = vertcat(aLocs(1:18),aLocs(18),aLocs(19:end));
                end
            else
                disp('broken');
                break;
            end
        end
        if i == 9
            dBaseline = mean(oPressure.Baseline.BeatRates(2:end));
        else
            dBaseline = mean(oPressure.Baseline.BeatRates);
        end
        
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
        if oPressure.HeartRate.Plateau.Range > 0
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
        else
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Plateau.Range(2));
        end
        aReturnCouplingIntervals = aCouplingIntervals(aTimePoints);
        aReturnLocs = aLocs(aTimePoints);
        aReturnStackedLocs{j} = aReturnLocs;
        ReturndelT = aReturnCouplingIntervals(~isnan(aReturnLocs));
        ReturndelX = aReturnLocs(~isnan(aReturnLocs));
        
        Pre = false;
        Post = false;
        switch (i)
            case 6
                switch (j)
                    case {1,2}
                        scatter(oAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
                        scatter(oAxes, ReturndelT, ReturndelX,iScatterSize,'r','marker','o');
                        Pre = true;
%                     case {3,4,5}
%                         scatter(oAxes, delT, delX,iScatterSize,'r','filled');
%                         Post = true;
                end
            case {7,8,10}
                switch (j)
                    case {1,2,3}
                        scatter(oAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
                        scatter(oAxes, ReturndelT, ReturndelX,iScatterSize,'r','marker','o');
                        Pre = true;
%                     case {4,5,6}
%                         scatter(oAxes, delT, delX,iScatterSize,'r','filled');
%                         Post = true;
                end
            case 9
                switch (j)
                    case {1,2,3}
                        scatter(oAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
                        scatter(oAxes, ReturndelT, ReturndelX,iScatterSize,'r','marker','o');
                        Pre = true;
%                     case 4
%                         scatter(oAxes, delT, delX,iScatterSize,'r','filled');
%                         Post = true;
                end
            otherwise
                scatter(oAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
                scatter(oAxes, ReturndelT, ReturndelX,iScatterSize,'r','marker','o');
                Pre = true;
        end
        if Pre
            iStart = 200;
            for m = 1:numel(aInitialPreLocGroups)
                aPoints = InitialdelT >= iStart & ...
                    InitialdelT < (iStart+50);
                aInitialPreLocGroups{m} = vertcat(aInitialPreLocGroups{m},InitialdelX(aPoints));
                aPoints = ReturndelT >= iStart & ...
                    ReturndelT < (iStart+50);
                aReturnPreLocGroups{m} = vertcat(aReturnPreLocGroups{m},ReturndelX(aPoints));
                iStart = iStart + 50;
            end
        elseif Post
            iStart = 200;
            for m = 1:numel(aPostLocGroups)
                aPoints = InitialdelT >= iStart & ...
                    InitialdelT < (iStart+50);
                aPostLocGroups{m} = vertcat(aPostLocGroups{m},InitialdelX(aPoints));
                iStart = iStart + 50;
            end
        end
    end
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
end
hold(oAxes, 'off'); 
set(oAxes,'xlim',axlim);
set(oAxes,'ylim',aylim);
% set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
set(get(oAxes,'ylabel'),'string','Pacemaker location (mm)');
set(oAxes,'xticklabel',[]);
set(oAxes,'xcolor','w');
%add panel label
text(axlim(1)-50,aylim(2)+1,'A','parent',oAxes,'fontsize',12,'fontweight','bold');

oLegend = legend(oAxes,'Increasing Phase','Decreasing Phase','location','northeast');
set(oLegend,'position',[0.1235    0.8726    0.1997    0.0794]);
legend(oAxes,'boxoff');


% oAxes = aSubplotPanel(3).select();
aInitialPreVals = zeros(numel(aInitialPreLocGroups),3);
aInitialPreErrors = zeros(numel(aInitialPreLocGroups),3);
aReturnPreVals = zeros(numel(aReturnPreLocGroups),3);
aReturnPreErrors = zeros(numel(aReturnPreLocGroups),3);
if Post
    aPostVals = zeros(numel(aPostLocGroups),3);
    aPostErrors = zeros(numel(aPostLocGroups),3);
end
for m = 1:numel(aInitialPreLocGroups)
    aInitialPreVals(m,1) = mean(aInitialPreLocGroups{m});
    aInitialPreErrors(m,1) = std(aInitialPreLocGroups{m})/sqrt(numel(aInitialPreLocGroups{m}));
    aReturnPreVals(m,1) = mean(aReturnPreLocGroups{m});
    aReturnPreErrors(m,1) = std(aReturnPreLocGroups{m})/sqrt(numel(aReturnPreLocGroups{m}));
    if Post
        aPostVals(m,1) = mean(aPostLocGroups{m});
        aPostErrors(m,1) = std(aPostLocGroups{m})/sqrt(numel(aPostLocGroups{m}));
    end
    %     if numel(aPreLocGroups{m}) > 1
%         bplot(aPreLocGroups{m},oAxes,m,'nolegend','nooutliers','tukey','linewidth',1);
%     end
%     hold(oAxes,'on');
%     if numel(aPostLocGroups{m}) > 1
%         bplot(aPostLocGroups{m},oAxes,m,'nolegend','nooutliers','tukey','linewidth',1);
%     end
end
% set(oAxes,'xlim',[0.5 14.5]);
% set(oAxes,'xtick',[1 2 3 4 5 6 7 8 9 10 11 12 13 14]);
% set(oAxes,'xticklabel',[]);
% set(oAxes,'ylim',aylim);
% set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
% xtl = {'200-250','250-300','300-350','350-400','400-450','450-500','500-550',...
%     '550-600','600-650','650-700','700-750','750-800','800-850','850-900'};
% text([1 2 3 4 5 6 7 8 9 10 11 12 13 14],ones(1,14)*-2,xtl,'parent',oAxes,'rotation',90,'fontsize',6); 
% hold(oAxes,'off');

oAxes = aSubplotPanel(2,1).select();
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aInitialPreVals(:,1),aInitialPreErrors(:,1),'k-');
hold(oAxes,'on');
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aReturnPreVals(:,1),aReturnPreErrors(:,1),'r-');
if Post
    errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aPostVals(:,1),aPostErrors(:,1),'r-');
end
set(oAxes,'xlim',axlim);
set(oAxes,'ylim',aylim);
set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
set(get(oAxes,'ylabel'),'string','Pacemaker location (mm)');
set(oAxes,'box','off');

% set(oReturnAxes,'xlim',axlim);
% set(oReturnAxes,'ylim',aylim);
% set(oReturnAxes,'xdir','reverse');
% axis(oReturnAxes,'off');
% set(oReturnAxes,'box','off');

%label panel
text(axlim(1)-50,aylim(2)+1,'D','parent',oAxes,'fontsize',12,'fontweight','bold');

oLegend = legend(oAxes,'Increasing Phase','Decreasing Phase','location','northeast');
legend(oAxes,'boxoff');

movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% print(oFigure,'-dpsc','-r300',sSavePath)
% printgif(oFigure,'-r300',sSavePath);
oNewFig = figure();
oNewAxes = axes('parent',oNewFig);
aInitialStacked = vertcat(aAllInitialLocs{:});
aReturnStacked = vertcat(aAllReturnLocs{:});
if numel(aInitialStacked) > numel(aReturnStacked)
    aReturnStacked = vertcat(aReturnStacked,NaN(numel(aInitialStacked)-numel(aReturnStacked),1));
elseif numel(aInitialStacked) < numel(aReturnStacked)
    aInitialStacked = vertcat(aInitialStacked,NaN(numel(aReturnStacked)-numel(aInitialStacked),1));
end
hist(oNewAxes,horzcat(aInitialStacked,aReturnStacked),0:0.5:7);
h = findobj(oNewAxes,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
