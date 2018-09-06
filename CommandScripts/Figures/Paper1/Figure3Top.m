%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;

%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure3\Figure3Top.eps';
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
aSubplotPanel.pack('h',4);
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
aOnsetShiftIndexes = { ...
{41,50,36,39,33,37,35,51}, ...
{27,30,28,34,30,30,28}, ...
{27,38,37}, ...
{28,36,42,46,50,68,57,79,87}, ...
{56,50,56,51,78,49,50,60,55}, ...
{24,34}, ...
{28,31,42}, ...
{35,40,49}, ...
{46,35,39}, ...
{37,39,38} ...
}; %baro onset
aRecoveryShiftIndexes = { ...
  {66,66,62,63,52,52,51,72}, ...  
  {50,48,45,60,46,44,38}, ...
  {44,51,50}, ...
  {65,56,62,67,70,77,75,88,92}, ...
  {60,60,75,71,84,58,74,82,76}, ...
  {50,67}, ...
  {58,61,66}, ...
  {54,57,64}, ...
  {49,40,67}, ...
  {56,72,64}...
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
oOnsetAxes = aSubplotPanel(2).select();
oRecoveryAxes = aSubplotPanel(3).select();

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
    
    %get the location data
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\BaroLocationData.mat']);
    load([pathstr(1:end-16),'\BaroOnsetData_20180220.mat']);
    load([pathstr(1:end-16),'\BaroRecoveryData_20180220.mat']);
    iCount = 0;
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        
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
        end
        
        aInitialStackedLocs{j} = OnsetDPSites(j).Y1;
        aInitialStackedCL{j} = OnsetDPSites(j).CL1;
        aReturnStackedLocs{j} = RecoveryDPSites(j).Y1;
        aReturnStackedCL{j} = RecoveryDPSites(j).CL1;
    end
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
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
    aAllInitialCL{i} = vertcat(aInitialStackedCL{:});
    aAllReturnCL{i} = vertcat(aReturnStackedCL{:});
    scatter(oOnsetAxes,aAllInitialLocs{i},aAllInitialCL{i},36,'k.');
    scatter(oRecoveryAxes,aAllReturnLocs{i},aAllReturnCL{i},36,'r.');
    aylim = [180 900];
    axlim = [0 8];
    set(oOnsetAxes,'ylim',aylim);
    set(oOnsetAxes,'xlim',axlim);
    set(oOnsetAxes,'xtick',[0 2 4 6]);
    set(get(oOnsetAxes,'ylabel'),'string','CL (ms)');
    set(get(oOnsetAxes,'xlabel'),'string','LP site (mm)');
    set(get(oOnsetAxes,'title'),'string','Onset','fontweight','normal');
    set(oRecoveryAxes,'ylim',aylim);
    set(oRecoveryAxes,'xlim',axlim);
    set(oRecoveryAxes,'xtick',[0 2 4 6]);
    set(get(oRecoveryAxes,'ylabel'),'string','CL (ms)');
    set(get(oRecoveryAxes,'xlabel'),'string','LP site (mm)');
    set(get(oRecoveryAxes,'title'),'string','Recovery','fontweight','normal');
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

aOnset = horzcat(vertcat(aAllInitialLocs{:}),vertcat(aAllInitialCL{:}));
aRecovery = horzcat(vertcat(aAllReturnLocs{:}),vertcat(aAllReturnCL{:}));
cla(oOnsetAxes);
cla(oRecoveryAxes);
scatter(oOnsetAxes,aOnset(:,1),aOnset(:,2),36,'k.');
scatter(oRecoveryAxes,aRecovery(:,1),aRecovery(:,2),36,'r.');

%switch the axes limits
aylim = [180 900];
axlim = [0 8];
set(oOnsetAxes,'ylim',aylim);
set(oOnsetAxes,'xlim',axlim);
set(oOnsetAxes,'xtick',[0 2 4 6]);
set(get(oOnsetAxes,'ylabel'),'string','CL (ms)');
set(get(oOnsetAxes,'xlabel'),'string','LP site (mm)');
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','normal');
set(oRecoveryAxes,'ylim',aylim);
set(oRecoveryAxes,'xlim',axlim);
set(oRecoveryAxes,'xtick',[0 2 4 6]);
set(get(oRecoveryAxes,'ylabel'),'string','CL (ms)');
set(get(oRecoveryAxes,'xlabel'),'string','LP site (mm)');
set(get(oRecoveryAxes,'title'),'string','Recovery','fontweight','normal');

%create boxplots panel
oAxes = aSubplotPanel(4).select();
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
print(sPaperSavePath,'-dpsc2','-r600','-painters');
% export_fig(sThesisSavePath,'-dbmp','-r300','-nocrop');
