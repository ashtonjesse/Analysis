
%plot on axes and hold on
close all;
clear all;

sPaperSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure4\Figure4Bottom.eps';
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
% aSubplotPanel.pack('h',{0.25,0.25,0.02,0.1,0.25});
aSubplotPanel.pack('h',4);
aSubplotPanel.margin = [12 10 2 5];
aSubplotPanel.de.margin = [12 0 0 0];
aSubplotPanel.fontsize = 8;
iScatterSize = 4;
aylim = [180 900];
axlim = [0 8];

%% set up panels A and B
%get data
aControlFiles = {...
    {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo002' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo003' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo002' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo003' ...
    }...
    };
aOnsetShiftIndexes = {{39},{33,34},{25,25,47},{29,27},{34,37,41}}; %chemo onset
aRecoveryShiftIndexes = {{52},{60,48},{3,54,61},{37,38},{57,51,52}}; %chemo recovery

%initialise arrays to hold arrays of data
aAllInitialLocs = cell(1,numel(aControlFiles));
aAllReturnLocs = cell(1,numel(aControlFiles));
aAllInitialCL = cell(1,numel(aControlFiles));
aAllReturnCL = cell(1,numel(aControlFiles));
aAllInitialShiftCL = cell(1,numel(aControlFiles));
aAllReturnShiftCL = cell(1,numel(aControlFiles));
%select the axes to plot the steady state data
oOnsetAxes = aSubplotPanel(1).select();
oRecoveryAxes = aSubplotPanel(2).select();
colormap(jet)
oBaseSignal = BaseSignal();
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    %initialise array for this set of files
    aInitialStackedLocs = cell(numel(aFiles),1);
    aReturnStackedLocs = cell(numel(aFiles),1);
    aInitialStackedCL = cell(numel(aFiles),1);
    aReturnStackedCL = cell(numel(aFiles),1);
    aInitialShiftCL = cell(numel(aFiles),1);
    aInitialTau = cell(numel(aFiles),1);
    %get the location data
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr,'\ChemoOnsetData_20180109.mat']);
    load([pathstr,'\ChemoRecoveryData_20180109.mat']);
    for j = 1:numel(aFiles)
        aInitialStackedLocs{j} = OnsetDPSites(j).Y1;
        aInitialStackedCL{j} = OnsetDPSites(j).CL1;
        aReturnStackedLocs{j} = RecoveryDPSites(j).Y1;
        aReturnStackedCL{j} = RecoveryDPSites(j).CL1;
    end
    %save the dynamic data
    aAllInitialLocs{i} = vertcat(aInitialStackedLocs{:});
    aAllReturnLocs{i} = vertcat(aReturnStackedLocs{:});
    aAllInitialCL{i} = vertcat(aInitialStackedCL{:});
    aAllReturnCL{i} = vertcat(aReturnStackedCL{:});
end
aOnset = horzcat(vertcat(aAllInitialLocs{:}),vertcat(aAllInitialCL{:}));
aRecovery = horzcat(vertcat(aAllReturnLocs{:}),vertcat(aAllReturnCL{:}));
cla(oOnsetAxes);
cla(oRecoveryAxes);
% scatplot(aOnset(:,1),aOnset(:,2),'circles',1,100,[],[],1,9,oOnsetAxes);%,method,radius,N,n,po,ms);
% scatplot(aRecovery(:,1),aRecovery(:,2),'circles',1,100,[],[],1,9,oRecoveryAxes);%,method,radius,N,n,po,ms);
% aCRange = [0 65];
% caxis(oOnsetAxes,aCRange)
% caxis(oRecoveryAxes,aCRange)
scatter(oOnsetAxes,aOnset(:,1),aOnset(:,2),36,'k.');
scatter(oRecoveryAxes,aRecovery(:,1),aRecovery(:,2),36,'r.');
%switch the axes limits
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

% oAxes = aSubplotPanel(3).select();
% aContours = aCRange(1):5:aCRange(2);
% cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',8);
% oLabel = text(-3,5,'Number of cycles','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','left','rotation',90);
% set(oLabel,'fontsize',8);

%create boxplots panel
oAxes = aSubplotPanel(4).select();
% aOnsetCLs = 
aylim2 = [-200 300];
set(oAxes,'ylim',aylim2);
aytick = get(oAxes,'ytick');
set(oAxes,'xlim',[0 4]);
set(oAxes,'xtick',[1 2 3 4]);
axtick = get(oAxes,'xtick');
xticklabels = cell(1,numel(axtick));
[xticklabels{:}] = deal('');
xticklabels{axtick==1} = ['n=5'];
xticklabels{axtick==3} = ['n=5'];
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
