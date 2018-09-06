%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;

%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure5\Figure5Bottom.eps';
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

%% Control files
aControlFiles = {
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\',
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\',
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\',
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\'    
};

%% set up panels A and B
%get data

%initialise arrays to hold arrays of data
aAllInitialLocs = cell(1,numel(aControlFiles));
aAllReturnLocs = cell(1,numel(aControlFiles));
aAllInitialCL = cell(1,numel(aControlFiles));
aAllReturnCL = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the steady state data
oOnsetAxes = aSubplotPanel(1).select();
oRecoveryAxes = aSubplotPanel(2).select();

for ii = 1:numel(aControlFiles)
    aFiles = aControlFiles{ii};
    
    %get the location data
    load([aFiles,'\CChData_20180304.mat']);
    %initialise array for this set of files
    aInitialStackedLocs = cell(numel(DPSites{1}),1);
    aReturnStackedLocs = cell(numel(DPSites{2}),1);
    aInitialStackedCL = cell(numel(DPSites{1}),1);
    aReturnStackedCL = cell(numel(DPSites{2}),1);
    %loop through onset data
    for jj = 1:numel(aInitialStackedLocs)
           aInitialStackedLocs{jj} = DPSites{1}(jj).Y1;
           aInitialStackedCL{jj} = DPSites{1}(jj).CL1;
    end
    for nn = 1:numel(aReturnStackedLocs)
        aReturnStackedLocs{jj} = DPSites{2}(jj).Y1;
        aReturnStackedCL{jj} = DPSites{2}(jj).CL1;
    end
    
    %save the dynamic data
    aAllInitialLocs{ii} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{ii} = vertcat(aReturnStackedLocs{:});
    aAllInitialCL{ii} = vertcat(aInitialStackedCL{:});
    aAllReturnCL{ii} = vertcat(aReturnStackedCL{:});
    scatter(oOnsetAxes,aAllInitialLocs{ii},aAllInitialCL{ii},36,'k.');
    scatter(oRecoveryAxes,aAllReturnLocs{ii},aAllReturnCL{ii},36,'r.');
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
