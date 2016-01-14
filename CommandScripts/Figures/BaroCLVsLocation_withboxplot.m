%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;

% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\BaroCLVsLocation.png';
%set up figure
dWidth = 9;
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
aSubplotPanel.pack('v',2);
aSubplotPanel(1).pack('h',2);
aSubplotPanel(2).pack('h',2);
aSubplotPanel(1,1).pack('v',{0.1 0.9});
aSubplotPanel.margin = [15 10 2 8];
% aSubplotPanel.de.margin = [8 10 0 0];
aSubplotPanel.de.margin = [15 20 0 0];
aSubplotPanel(1,1).de.margin = [15 8 0 0];
aSubplotPanel.fontsize = 8;
iScatterSize = 4;
aylim = [0 8];
axlim = [200 900];

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
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the steady state data
oSSAxes = aSubplotPanel(1,1,2).select();
oDynamicAxes = aSubplotPanel(2,1).select();

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
        %plot the dynamic data
        scatter(oDynamicAxes, InitialdelT, InitialdelX,iScatterSize,'k','filled');
        hold(oDynamicAxes, 'on');
        scatter(oDynamicAxes, ReturndelT, ReturndelX,iScatterSize,'r','marker','o');
    end
    %get the data for the histogram
    StackedLocs = vertcat(aAllLocs{:});
    aCombinedLocs{i} = StackedLocs;
    %plot the steady state data
    ThisPressure = aPlateauPressures{i}-aBaselinePressures{i};%
    ThisCL = aPlateauCouplingIntervals{i};%-aBaselineCouplingIntervals{i}
    scatter(oSSAxes,ThisPressure,ThisCL,9,aMaxLocs{i},'filled');%
    cmap = colormap(oSSAxes, jet(aCRange(2)-aCRange(1)));
    caxis(oSSAxes, aCRange);
    hold(oSSAxes,'on');
    
    %         X = [ones(length(ThisPressure),1) ThisPressure];
    %         b = X\ThisCL;
    %         yCalc = X*b;
    %         Rsq = 1 - sum((ThisCL - yCalc).^2)/sum((ThisCL - mean(ThisCL)).^2);
    %         oLine = plot(oAxes,ThisPressure,yCalc,'-','color','k');
    %         text(max(ThisPressure),max(yCalc),sprintf('%4.3f',Rsq),'color','k','parent',oAxes);
    
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
end
%plot trendline on steady state data
StackedPressures = vertcat(aPlateauPressures{:})-vertcat(aBaselinePressures{:});%
StackedCI = vertcat(aPlateauCouplingIntervals{:});%-vertcat(aBaselineCouplingIntervals{:})
X = [ones(length(StackedPressures),1) StackedPressures];
b = X\StackedCI;
yCalc = X*b;
Rsq = 1 - sum((StackedCI - yCalc).^2)/sum((StackedCI - mean(StackedCI)).^2);
oLine = plot(oSSAxes,StackedPressures,yCalc,'-','color','k');
set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
text(max(StackedPressures)-5,max(yCalc)-100,sprintf('r=%4.2f',Rsq),'color','k',...
    'parent',oSSAxes,'horizontalalignment','left','fontsize',8);
hold(oSSAxes,'off');
hold(oDynamicAxes, 'off'); 

%make SS axes look right
set(get(oSSAxes,'ylabel'),'string',['Mean CL (ms)'],'fontsize',8);%\Delta 
set(get(oSSAxes,'xlabel'),'string','\Delta Mean PP (mmHg)','fontsize',8);%\Delta 
set(oSSAxes,'fontsize',8);
oLabelAxes = axes('parent',oFigure,'position',get(oSSAxes,'position'));
set(oLabelAxes,'xlim',axlim);
set(oLabelAxes,'ylim',aylim);
axis(oLabelAxes,'off');

%create scalebar
oBarAxes = aSubplotPanel(1,1,1).select();
aCRange = [aCRange(1) aCRange(2)-1];
aContours = aCRange(1):1:aCRange(2);
cbarf_edit(aCRange, aContours,'horiz','linear',oBarAxes,'Distance');
aCRange = [aCRange(1) aCRange(2)+1];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+abs(aCRange(1)),2,'DPS (mm)','parent',oBarAxes,'fontunits','points','horizontalalignment','center');
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
set(get(oOverlay,'xlabel'),'string','DPS (mm)','fontsize',8);
set(get(oOverlay,'ylabel'),'string','# of beats','fontsize',8);
set(oOverlay,'fontsize',8,'box','off');

%label panels
oLabelAxes = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oLabelAxes,'xlim',axlim);
set(oLabelAxes,'ylim',aylim);
axis(oLabelAxes,'off');
text(axlim(1)-1250,aylim(2)+1.5,'A','parent',oLabelAxes,'fontsize',12,'fontweight','bold');
text(axlim(1)-200,aylim(2)+1.5,'B','parent',oLabelAxes,'fontsize',12,'fontweight','bold');

%make the dynamic axes look right
set(oDynamicAxes,'xlim',axlim);
set(oDynamicAxes,'ylim',aylim);
set(get(oDynamicAxes,'xlabel'),'string','CL (ms)');
set(get(oDynamicAxes,'ylabel'),'string','DPS (mm)');
% set(oAxes,'xticklabel',[]);
% set(oAxes,'xcolor','w');
%add panel label
text(axlim(1)-200,aylim(2)+1.5,'C','parent',oDynamicAxes,'fontsize',12,'fontweight','bold');

oLegend = legend(oDynamicAxes,'Onset','Recovery','location','northeast');
set(oLegend,'position',[0.1491    0.3461    0.3079    0.1005]);
legend(oDynamicAxes,'boxoff');


%create boxplots panel
oAxes = aSubplotPanel(2,2).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');
text(axlim(1)-200,aylim(2)+1.5,'D','parent',oOverlay,'fontsize',12,'fontweight','bold');
%get data
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\BaroCLandLocationData.csv');
aInitialDelCL = aData(:,strcmp(aHeader,'CL2')) - aData(:,strcmp(aHeader,'CL1'));
[aHeader aData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\BaroCLandLocationDataReturn.csv');
aReturnDelCL = aData(:,strcmp(aHeader,'CL4')) - aData(:,strcmp(aHeader,'CL3'));
%plot boxplots
bplot(aInitialDelCL,oAxes,1,'nolegend','outliers','tukey','linewidth',1,'width',0.5,'nomean');
hold(oAxes,'on');
bplot(aReturnDelCL,oAxes,3,'nolegend','outliers','tukey','linewidth',1,'width',0.5,'nomean','color','r');
hold(oAxes,'off');
aytick = get(oAxes,'ytick');
aylim2 = get(oAxes,'ylim');
set(oAxes,'xlim',[0 4]);
set(oAxes,'xtick',[1 2 3 4]);
axtick = get(oAxes,'xtick');
xticklabels = cell(1,numel(axtick));
[xticklabels{:}] = deal('');
xticklabels{axtick==1} = ['First',10,'Shift'];
xticklabels{axtick==3} = ['Last',10,'Shift'];
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/1.8),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3]);
set(get(oAxes,'ylabel'),'string','\DeltaCL (ms)');

%print
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% export_fig(sSavePath,'-png','-r300','-nocrop');
