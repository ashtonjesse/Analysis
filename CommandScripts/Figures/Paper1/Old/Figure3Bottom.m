%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;
%this figure needs to have a CI plot added to it called BaroPhase

% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2017\PacemakerUncoupling\Figures\BaroCLVsLocation.png';
%set up figure
dWidth = 17;
dHeight = 4.5;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',{0.25,0.5,0.25});
aSubplotPanel.margin = [12 10 2 5];
aSubplotPanel.de.margin = [12 0 0 0];
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
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat' ...%4-9 rejected due to change in baseline rate
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
aAllInitialCL = cell(1,numel(aControlFiles));
aAllReturnCL = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the steady state data
oSSAxes = aSubplotPanel(1).select();
aSubplotPanel(2).pack('h',{0.45,0.45,0.05});
aSubplotPanel(2).de.margin = [10 0 0 0];
oOnsetAxes = aSubplotPanel(2,1).select();
oRecoveryAxes = aSubplotPanel(2,2).select();

for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    %initialise array for this set of files
    aBaselinePressures{i} = zeros(sum(aIndices{i}),1);
    aPlateauPressures{i} = zeros(sum(aIndices{i}),1);
    aBaselineCouplingIntervals{i} = zeros(sum(aIndices{i}),1);
    aPlateauCouplingIntervals{i} = zeros(sum(aIndices{i}),1);
    aInitialStackedLocs = cell(numel(aFiles),1);
    aReturnStackedLocs = cell(numel(aFiles),1);
    aInitialStackedCL = cell(numel(aFiles),1);
    aReturnStackedCL = cell(numel(aFiles),1);
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
        InitialdelT = aInitialCouplingIntervals(~isnan(aInitialLocs));
        InitialdelX = aInitialLocs(~isnan(aInitialLocs));
        aInitialStackedLocs{j} = aInitialLocs;
        aInitialStackedCL{j} = aInitialCouplingIntervals';
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
        ReturndelT = aReturnCouplingIntervals(~isnan(aReturnLocs));
        ReturndelX = aReturnLocs(~isnan(aReturnLocs));
        aReturnStackedCL{j} = aReturnCouplingIntervals';
        aReturnStackedLocs{j} = aReturnLocs;
        %plot the dynamic data
%         scatter(oOnsetAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
%         hold(oOnsetAxes, 'on');
%         scatter(oRecoveryAxes, ReturndelT, ReturndelX,iScatterSize,'r','filled');
%         hold(oRecoveryAxes, 'on');
    end
    %get the data for the histogram
    StackedLocs = vertcat(aAllLocs{:});
    aCombinedLocs{i} = StackedLocs;
    %plot the steady state data
    ThisPressure = aPlateauPressures{i};%-aBaselinePressures{i}
    ThisCL = aPlateauCouplingIntervals{i};%-aBaselineCouplingIntervals{i}
    switch i
        case 1 %only in cases where pressure was varied systematically
            scatter(oSSAxes,ThisPressure,ThisCL,9,'k','filled','Marker','s');%aMaxLocs{i} for colour
        case 2
            scatter(oSSAxes,ThisPressure,ThisCL,9,'k','filled','Marker','o');%aMaxLocs{i} for colour
        case 3
            scatter(oSSAxes,ThisPressure,ThisCL,9,'k','Marker','d');%aMaxLocs{i} for colour
        case 4
            scatter(oSSAxes,ThisPressure,ThisCL,9,'k','filled','Marker','d');%aMaxLocs{i} for colour
        case 5
            scatter(oSSAxes,ThisPressure,ThisCL,9,'k','Marker','o');%aMaxLocs{i} for colour
            %             cmap = colormap(oSSAxes, jet(aCRange(2)-aCRange(1)));
            %             caxis(oSSAxes, aCRange);
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
    aAllInitialCL{i} = vertcat(aInitialStackedCL{:});
    aAllReturnCL{i} = vertcat(aReturnStackedCL{:});
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
% text(130,800,sprintf('R^2=%4.2f',0.83),'color','k',... mean(horzcat(aRsq{1:5}))
%      'parent',oSSAxes,'horizontalalignment','left','fontsize',8);
set(oSSAxes,'ylim',[0 800]);
set(oSSAxes,'xlim',[80 150]);
set(oSSAxes,'ytick',[0 200 400 600 800]);
set(oSSAxes,'yticklabel',[0 200 400 600 800]);

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

%label panels
holder = axlim;
axlim=aylim;
aylim = holder;
oLabelAxes = axes('parent',oFigure,'position',get(oSSAxes,'position'));
set(oLabelAxes,'xlim',axlim);
set(oLabelAxes,'ylim',aylim);
axis(oLabelAxes,'off');

% % plot scatter plots
aOnset = horzcat(vertcat(aAllInitialLocs{:}),vertcat(aAllInitialCL{:}));
aRecovery = horzcat(vertcat(aAllReturnLocs{:}),vertcat(aAllReturnCL{:}));
colormap(jet)
cla(oOnsetAxes);
cla(oRecoveryAxes);
scatplot(aOnset(:,1),aOnset(:,2),'circles',1,100,[],[],1,9,oOnsetAxes);%,method,radius,N,n,po,ms);
scatplot(aRecovery(:,1),aRecovery(:,2),'circles',1,100,[],[],1,9,oRecoveryAxes);%,method,radius,N,n,po,ms);
aCRange = [0 65];
caxis(oOnsetAxes,aCRange)
caxis(oRecoveryAxes,aCRange)
%switch the axes limits
set(oOnsetAxes,'xlim',aylim);
set(oOnsetAxes,'ylim',axlim);
set(oOnsetAxes,'xtick',[0 2 4 6]);
set(get(oOnsetAxes,'ylabel'),'string','CL (ms)');
set(get(oOnsetAxes,'xlabel'),'string','LP site (mm)');
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','normal');
set(oRecoveryAxes,'xlim',aylim);
set(oRecoveryAxes,'ylim',axlim);
set(oRecoveryAxes,'xtick',[0 2 4 6]);
set(get(oRecoveryAxes,'ylabel'),'string','CL (ms)');
set(get(oRecoveryAxes,'xlabel'),'string','LP site (mm)');
set(get(oRecoveryAxes,'title'),'string','Recovery','fontweight','normal');

oAxes = aSubplotPanel(2,3).select();

aContours = aCRange(1):5:aCRange(2);
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',8);
oLabel = text(-3,5,'Number of cycles','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','left','rotation',90);
set(oLabel,'fontsize',8);

%create boxplots panel
oAxes = aSubplotPanel(3).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');

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
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/2),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3]);
oYLabel = get(oAxes,'ylabel');
set(oYLabel,'string','\DeltaCL (ms)');
set(oYLabel,'position',get(oYLabel,'position') + [0.2 0 0]);

%print
% movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
export_fig(sPaperSavePath,'-png','-r600','-nocrop');
% export_fig(sThesisSavePath,'-dbmp','-r300','-nocrop');
