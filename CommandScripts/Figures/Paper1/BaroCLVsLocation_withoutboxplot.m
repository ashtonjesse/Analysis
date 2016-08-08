%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;
%this figure needs to have a CI plot added to it called BaroPhase

% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\BaroCLVsLocation.png';
sThesisSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\Working\BaroCLVsLocation.bmp';
%set up figure
dWidth = 9;
dHeight = 15;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('v',3);
aSubplotPanel(1).pack('h',2);
aSubplotPanel(2).pack('h',2);
aSubplotPanel(3).pack('h',{0.08 0.5});
aSubplotPanel(1,1).pack('v',{0.1 0.9});
aSubplotPanel.margin = [15 13 2 8];
% aSubplotPanel.de.margin = [8 10 0 0];
aSubplotPanel.de.margin = [15 20 0 0];
aSubplotPanel(1,1).de.margin = [15 8 0 0];
aSubplotPanel.fontsize = 8;
iScatterSize = 4;
aylim = [180 900];
axlim = [0 8];

%% set up panels A and B
%get data
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
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    }};
%define indices of files that will be used for the heart rate plateau data
aIndices = {...
    [1,1,0,1,1,1,1,0] ...
    [1,1,1,1,1,1,1] ...
    [1,1,1] ...
    [1,1,1,1,1,1,1,1,0] ...
    [0,1,1,1,1,1,1,1,1] ...
    [1,1] ...
    [1,0,1] ...
    [1,1,1] ...
    [1,1,1] ...
    [1,1,1] ...
    };
%initialise arrays to hold arrays of data
aBaselinePressures = cell(numel(aControlFiles),1);
aPlateauPressures = cell(numel(aControlFiles),1);
aBaselineCouplingIntervals = cell(numel(aControlFiles),1);
aPlateauCouplingIntervals = cell(numel(aControlFiles),1);
aAllInitialLocs = cell(1,numel(aControlFiles));
aAllReturnLocs = cell(1,numel(aControlFiles));
aInitialPreLocGroups = cell(1,3);
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the steady state data
oSSAxes = aSubplotPanel(1,1,2).select();
oOnsetAxes = aSubplotPanel(2,1).select();
oRecoveryAxes = aSubplotPanel(2,2).select();
aRsq = cell(1,numel(aControlFiles));
%define the colour range for plots
aCRange = [0 7];
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    %initialise array for this set of files
    aBaselinePressures{i} = zeros(sum(aIndices{i}),1);
    aPlateauPressures{i} = zeros(sum(aIndices{i}),1);
    aBaselineCouplingIntervals{i} = zeros(sum(aIndices{i}),1);
    aPlateauCouplingIntervals{i} = zeros(sum(aIndices{i}),1);
    aInitialStackedLocs = cell(numel(aFiles),1);
    aReturnStackedLocs = cell(numel(aFiles),1);
    aMaxLocs{i} = zeros(sum(aIndices{i}),1);
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
        
        %get the locs for this file
        aLocs =  aDistance{j}(:,1);
        %adjust locs due to difference in no. locs and no. CLs
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
        end
        if numel(aLocs) ~= numel(aCouplingIntervals)
            fprintf('Warning: Locs dont match CouplingIntervals for %s\n',char(aFiles{j}));
        end
        if aIndices{i}(j)
            %this data should be included in the steady state data panel 1,1
            %increment the counter
            iCount = iCount + 1;
            %get pressure baseline and plateau means for this file
            aBaselinePressures{i}(iCount) = mean(oPressure.Baseline.BeatPressures);
            aPlateauPressures{i}(iCount) = mean(oPressure.Plateau.BeatPressures);
            %get CL baseline and plateua means for this file
            aBaselineCouplingIntervals{i}(iCount)  = 60000 / mean(oPressure.Baseline.BeatRates);
            aPlateauCouplingIntervals{i}(iCount) = 60000 / mean(oPressure.HeartRate.Plateau.BeatRates);
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
            aAllLocs{iCount} = aLocs(aTimePoints);
            aMaxLocs{i}(iCount) = max(aLocs(aTimePoints));
        end

        %get data for dynamic relationship between CL and loc (panel 2,1)
        %get initial data
        if oPressure.HeartRate.Plateau.Range > 0
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Decrease.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(1));
        else
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Decrease.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Decrease.Range(2));
        end
        aInitialCouplingIntervals = aCouplingIntervals(aTimePoints);
        aInitialLocs = aLocs(aTimePoints);
        aInitialStackedLocs{j} = aInitialLocs;
        InitialdelT = aInitialCouplingIntervals(~isnan(aInitialLocs));
        InitialdelX = aInitialLocs(~isnan(aInitialLocs));
        
        %         aPoints = InitialdelX > 0 & InitialdelX <= 2.7;
        %         aInitialPreLocGroups{1} = horzcat(aInitialPreLocGroups{1},InitialdelT(aPoints));
        %         aPoints = InitialdelX > 2.7 & InitialdelX <= 4;
        %         aInitialPreLocGroups{2} = horzcat(aInitialPreLocGroups{2},InitialdelT(aPoints));
        %         aPoints = InitialdelX > 4 & InitialdelX <= 6;
        %         aInitialPreLocGroups{3} = horzcat(aInitialPreLocGroups{3},InitialdelT(aPoints));
        
        %get return data
        if oPressure.HeartRate.Plateau.Range > 0
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Increase.Range(2));
        else
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Increase.Range(2));
        end
        aReturnCouplingIntervals = aCouplingIntervals(aTimePoints);
        aReturnLocs = aLocs(aTimePoints);
        aReturnStackedLocs{j} = aReturnLocs;
        ReturndelT = aReturnCouplingIntervals(~isnan(aReturnLocs));
        ReturndelX = aReturnLocs(~isnan(aReturnLocs));
        %plot the dynamic data
        scatter(oOnsetAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
        hold(oOnsetAxes, 'on');
        scatter(oRecoveryAxes, ReturndelT, ReturndelX,iScatterSize,'r','filled');
        hold(oRecoveryAxes, 'on');
    end
    %get the data for the histogram
    StackedLocs = vertcat(aAllLocs{:});
    aCombinedLocs{i} = StackedLocs;
    %plot the steady state data
    ThisPressure = aPlateauPressures{i};%-aBaselinePressures{i}
    ThisCL = aPlateauCouplingIntervals{i};%-aBaselineCouplingIntervals{i}
    switch i
        case {1,2,3,4,5}
            scatter(oSSAxes,ThisPressure,ThisCL,9,aMaxLocs{i},'filled');%
            cmap = colormap(oSSAxes, jet(aCRange(2)-aCRange(1)));
            caxis(oSSAxes, aCRange);
    end
    hold(oSSAxes,'on');
    
    %             X = [ones(length(ThisPressure),1) ThisPressure];
    %             b = X\ThisCL;
    %             yCalc = X*b;
    %             aRsq{i} = 1 - sum((ThisCL - yCalc).^2)/sum((ThisCL - mean(ThisCL)).^2);
    %             oLine = plot(oSSAxes,ThisPressure,yCalc,'-','color','k');
    %             text(max(ThisPressure),max(yCalc),sprintf('%4.3f',aRsq{i}),'color','k','parent',oSSAxes);
    
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
end
%plot trendline on steady state data
StackedPressures = vertcat(aPlateauPressures{1:5});%-vertcat(aBaselinePressures{1:5})
StackedCI = vertcat(aPlateauCouplingIntervals{1:5});%-vertcat(aBaselineCouplingIntervals{:})
 X = [ones(length(StackedPressures),1) StackedPressures];
%  b = X\StackedCI;
b = [-112.06 ; 4.8921];
% b = [239.75 ; 5.1355];
 yCalc = X*b;
 Rsq = 1 - sum((StackedCI - yCalc).^2)/sum((StackedCI - mean(StackedCI)).^2);
oLine = plot(oSSAxes,StackedPressures,yCalc,'-','color','k');
% set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
% text(130,800,sprintf('R^2=%4.2f',0.83),'color','k',... mean(horzcat(aRsq{1:5}))
%      'parent',oSSAxes,'horizontalalignment','left','fontsize',8);
set(oSSAxes,'ylim',[0 800]);
set(oSSAxes,'xlim',[80 150]);
set(oSSAxes,'ytick',[0 400 800]);
set(oSSAxes,'yticklabel',[0 400 800]);
hold(oSSAxes,'off');
hold(oOnsetAxes, 'off'); 
hold(oRecoveryAxes, 'off'); 

%make SS axes look right
set(get(oSSAxes,'ylabel'),'string',['Mean CL (ms)'],'fontsize',8);%\Delta 
set(get(oSSAxes,'xlabel'),'string','Mean PP (mmHg)','fontsize',8);%\Delta 
set(oSSAxes,'fontsize',8);
oLabelAxes = axes('parent',oFigure,'position',get(oSSAxes,'position'));
set(oLabelAxes,'xlim',axlim);
set(oLabelAxes,'ylim',aylim);
axis(oLabelAxes,'off');

%create scalebar
oBarAxes = aSubplotPanel(1,1,1).select();
aCRange = [aCRange(1) aCRange(2)-1];
aContours = aCRange(1):1:aCRange(2);
cbarf_edit(aCRange, aContours,'horiz','linear',oBarAxes,'Distance',8);
aCRange = [aCRange(1) aCRange(2)+1];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+abs(aCRange(1)),2,'DP site (mm)','parent',oBarAxes,'fontunits','points','horizontalalignment','center');
set(oXlabel,'fontsize',8);

%plot histogram of locations
StackedLocs = vertcat(aCombinedLocs{:});
oAxes = aSubplotPanel(1,2).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'),'color','none');
hist(oAxes,StackedLocs,0:0.5:6);
h = findobj(oAxes,'Type','patch');
set(h,'FaceColor','k','EdgeColor','w')
axis(oAxes,'tight');
%overlay an axes because the bars cover the axes
set(oOverlay,'xlim',get(oAxes,'xlim'),'ylim',get(oAxes,'ylim'))
axis(oAxes,'off');
set(get(oOverlay,'xlabel'),'string','DP site (mm)','fontsize',8);
set(get(oOverlay,'ylabel'),'string','# of cycles','fontsize',8);
set(oOverlay,'fontsize',8,'box','off');
%save the data to file
csvwrite('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\BaroSSLocations.csv',StackedLocs);

%label panels
holder = axlim;
axlim=aylim;
aylim = holder;
oLabelAxes = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oLabelAxes,'xlim',axlim);
set(oLabelAxes,'ylim',aylim);
axis(oLabelAxes,'off');
text(axlim(1)-1250,aylim(2)+1.5,'A','parent',oLabelAxes,'fontsize',12,'fontweight','bold');
text(axlim(1)-200,aylim(2)+1.5,'B','parent',oLabelAxes,'fontsize',12,'fontweight','bold');

%make the dynamic axes look right
% for i = 1:numel(aInitialPreLocGroups)
%     bplot(aInitialPreLocGroups{i},oOnsetAxes,i,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean');
%     hold(oOnsetAxes,'on');
% end
%switch the axes limits
set(oOnsetAxes,'xlim',axlim);
set(oOnsetAxes,'ylim',aylim);
set(get(oOnsetAxes,'xlabel'),'string','CL (ms)');
set(get(oOnsetAxes,'ylabel'),'string','DP site (mm)');
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','bold');
set(oRecoveryAxes,'xlim',axlim);
set(oRecoveryAxes,'ylim',aylim);
set(get(oRecoveryAxes,'xlabel'),'string','CL (ms)');
set(get(oRecoveryAxes,'ylabel'),'string','DP site (mm)');
set(get(oRecoveryAxes,'title'),'string','Recovery','fontweight','bold');
%add panel label
text(axlim(1)-200,aylim(2)+1.5,'C','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');
text(axlim(1)-200,aylim(2)+1.5,'D','parent',oRecoveryAxes,'fontsize',12,'fontweight','bold');


%create boxplots panel
oAxes = aSubplotPanel(3,2).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');
text(axlim(1)-200,aylim(2)+1.5,'E','parent',oOverlay,'fontsize',12,'fontweight','bold');

%plot boxplots
% bplot(aPreInitialDelCL,oAxes,1,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean');
% hold(oAxes,'on');
% bplot(aPreReturnDelCL,oAxes,3,'nolegend','outliers','tukey','linewidth',0.5,'width',0.5,'nomean','color','r');
% hold(oAxes,'off');
aylim2 = [-200 300];
set(oAxes,'ylim',aylim2);
aytick = get(oAxes,'ytick');
set(oAxes,'xlim',[0 4]);
set(oAxes,'xtick',[1 2 3 4]);
axtick = get(oAxes,'xtick');
xticklabels = cell(1,numel(axtick));
[xticklabels{:}] = deal('');
xticklabels{axtick==1} = ['n=10'];
xticklabels{axtick==3} = ['n=10'];
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/1.6),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3]);
set(get(oAxes,'ylabel'),'string','\DeltaCL (ms)');

%print
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% export_fig(sPaperSavePath,'-png','-r600','-nocrop');
export_fig(sThesisSavePath,'-dbmp','-r600','-nocrop');
