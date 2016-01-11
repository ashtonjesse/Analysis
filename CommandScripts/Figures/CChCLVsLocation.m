%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
% close all;
% clear all;
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

% %set up figure
% dWidth = 10;
% dHeight = 5;
% oFigure = figure();
% 
% set(oFigure,'color','white')
% set(oFigure,'inverthardcopy','off')
% set(oFigure,'PaperUnits','centimeters');
% set(oFigure,'PaperPositionMode','auto');
% set(oFigure,'Units','centimeters');
% set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
% set(oFigure,'Resize','off');
% 
% aSubplotPanel = panel(oFigure);
% aSubplotPanel.pack('h',2);
% aSubplotPanel.margin = [10 10 5 5];
% aSubplotPanel.de.margin = [10 0 0 0];
% aSubplotPanel.fontsize = 6;
oAxes = aSubplotPanel(1,3).select();
% iScatterSize = 16;
% aylim = [0 10];
% axlim = [200 900];

hold(oAxes, 'on'); 
% sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\chemoCIVsShift_return_all_postIVB.eps';
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\CLVsLocation_initial_preIVB.png';
aPreLocGroups = cell(1,14);
aPostLocGroups = cell(1,14);
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-15),'\CChLocationData.mat']);
    
    for j = 1:numel(aFiles)
                
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
        
        try
            aThisDistance =  aDistance{j};
            aLocs = vertcat(aThisDistance{1}(:,1),aThisDistance{2}(:,1));
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            disp('broken');
            break; 
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
            case {1,5}
                switch (j)
                    case {1,2,3}
                        scatter(oAxes,delT,delX,iScatterSize,'k','marker','+');
                        Pre = true;
%                     case {4,5,6}
%                         scatter(oAxes,delT,delX,iScatterSize,'r','filled');
%                         Post = true;
                end
            case 2
                switch (j)
                    case {1,2,3,4}
                        scatter(oAxes, delT, delX,iScatterSize,'k','marker','+');
                        Pre = true;
%                     case {5,6,7}
%                         scatter(oAxes, delT, delX,iScatterSize,'r','filled');
%                         Post = true;
                end
            case {3,4}
                switch (j)
                    case {1,2}
                        scatter(oAxes, delT, delX,iScatterSize,'k','marker','+');
                        Pre = true;
%                     case {3,4}
%                         scatter(oAxes, delT, delX,iScatterSize,'r','filled');
%                         Post = true;
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
set(oAxes,'xticklabel',[]);
set(oAxes,'xcolor','w');
%add panel label
text(axlim(1)-50,aylim(2)+1,'C','parent',oAxes,'fontsize',12,'fontweight','bold');

% set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
% set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
% oLegend = legend(oAxes,'Pre-IVB','Post-IVB','location','northeast');
% oChildren = get(oLegend,'children');
% oChildren = get(oChildren(1),'children');
% set(oChildren,'markerfacecolor','r');
% legend(oAxes,'boxoff');
% % oAxes = aSubplotPanel(3).select();
for m = 1:numel(aPreLocGroups)
    aPreVals(m,3) = mean(aPreLocGroups{m});
    aPreErrors(m,3) = std(aPreLocGroups{m})/sqrt(numel(aPreLocGroups{m}));
    if Post
        aPostVals(m,3) = mean(aPostLocGroups{m});
        aPostErrors(m,3) = std(aPostLocGroups{m})/sqrt(numel(aPostLocGroups{m}));
    end
%     if numel(aPreLocGroups{m}) > 1
%         bplot(aPreLocGroups{m},oAxes,m,'nolegend','nooutliers','tukey','linewidth',1);
%     end
%     hold(oAxes,'on');
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

oAxes = aSubplotPanel(2,3).select();
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aPreVals(:,3),aPreErrors(:,3),'k-');
if Post
    hold(oAxes,'on');
    errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aPostVals(:,3),aPostErrors(:,3),'r-');
end
set(oAxes,'xlim',axlim);
set(oAxes,'ylim',aylim);
set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
% set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
set(oAxes,'box','off');
%add panel label
text(axlim(1)-50,aylim(2)+1,'F','parent',oAxes,'fontsize',12,'fontweight','bold');

% oLegend = legend(oAxes,'Pre-IVB','Post-IVB','location','northeast');
% legend(oAxes,'boxoff');

movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% print(oFigure,'-dpsc','-r300',sSavePath)
% printgif(oFigure,'-r300',sSavePath);
export_fig(sSavePath,'-png','-r300','-nocrop');