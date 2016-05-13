%figure for HRS 2016 abstract

%create layout
%load data
%plot data
%save to file as gif
%this figure needs to have a CI plot added to it called CChPhase

close all;
clear all;
% % % %Read in the file containing all the optical data
sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140828\';
sSubDir = [sBaseDir,'20140828CCh001\'];

%% read in the optical entities
sOpticalFileName = {...
    'CCh001a_g10_LP100Hz-waveEach.mat' ...
    'CCh001b_g10_LP100Hz-waveEach.mat' ...
    'CCh001c_g10_LP100Hz-waveEach.mat' ...
    'CCh001d_g10_LP100Hz-waveEach.mat' ...
    };

% % read in the pressure entity
oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 16;
dHeight = 14;
sPaperFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\CChData.bmp';
sThesisFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\CChData.eps';
%Create plot panel that has 3 rows at top to contain pressure, phrenic and
%heart rate 

oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
xrange = 7;
yrange = 1;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('v',{0.77 0.23});
oSubplotPanel(1).pack('v',{0.6,0.4});
oSubplotPanel(1,1).pack('h',{0.1,0.9});
oSubplotPanel(1,1,2).pack(3);
oSubplotPanel(1,2).pack('h',{0.02,0.98});
oSubplotPanel(1,2,2).pack(yrange,xrange);
oSubplotPanel(1,2,1).pack('v',{0.2,0.65});

movegui(oFigure,'center');
oSubplotPanel.margin = [12,15,2,2];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
oSubplotPanel(1).margin = [0 5 0 0];
oSubplotPanel(1,1).de.margin = [0 5 0 0];
oSubplotPanel(1,1).de.fontsize = 8;
oSubplotPanel(1,2,1).margin = [0 0 2 0];
oSubplotPanel(1,2,2).margin = [0 0 0 0];


%% plot top panel
dlabeloffset = 10;
oXLim = [0 110];

%plot phrenic
oAxes = oSubplotPanel(1,1,2,3).select();
aData = oThisPressure.oPhrenic.Electrodes.Processed.Data./ ...
    (oThisPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aBurstData = ComputeDWTFilteredSignalsKeepingScales(oThisPressure.oPhrenic, ...
    aData,2);
oThisPressure.oPhrenic.ComputeIntegral(200,aBurstData);
oThisPressure.oPhrenic.Electrodes.Processed.Integral(1:30000) = NaN;
aTime = oThisPressure.oPhrenic.TimeSeries;
hline = plot(oAxes,aTime,oThisPressure.oPhrenic.Electrodes.Processed.Integral/1000,'k');
set(hline,'linewidth',0.5);

%set limits
% axis(oAxes,'tight');
ylim(oAxes,[0 1]);
oYLim = get(oAxes,'ylim');
xlim(oAxes,oXLim);

oYlabel = ylabel(oAxes,'\intPND');
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 2;
set(oYlabel,'position',oPosition);
oNewYLabel = text(oPosition(1),oPosition(2),'\intPND','parent',oAxes,'fontsize',8,'horizontalalignment','center');
axis(oAxes,'off');

%plot time scale
oScaleAxes = axes('position',get(oAxes,'position')-[0 0.02 0 0]);
plot(oScaleAxes,[oXLim(2)-5; oXLim(2)], [oYLim(1)+0.1; oYLim(1)+0.1], '-k','LineWidth', 2)
xlim(oScaleAxes,oXLim);
ylim(oScaleAxes,oYLim);
axis(oScaleAxes,'off');
oLabel = text(oXLim(2)-2.5,oYLim(1)-0.05, '5 s', 'parent',oScaleAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',10);


%plot HR
oAxes = oSubplotPanel(1,1,2,2).select();
iBeats = {[50,74,79],17,[54,55],65};
dIncremements = {[100,70,120],80,[70,120],100};
dLineIncrements = {[30,30,30],30,[30,30],30};
dLineAngle = {[0,-0.5,0.5],0,[-0.5,0.5],0};
iCount = 0;
aCILabels = cell(numel(iBeats),1);
for m = 1:numel(oThisPressure.oRecording)
    %convert rates into coupling intervals
    aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(m).Electrodes.Processed.BeatRates];
    aTimes = oThisPressure.oRecording(m).Electrodes.Processed.BeatRateTimes;
    scatter(oAxes,aTimes,aCouplingIntervals,4,'k','filled');
    hold(oAxes,'on');
    if m > 1
        %add patch between data
        offset = 0.3;
        aXVertex = [aLastTime+offset, aTimes(2)-offset, aTimes(2)-offset, aLastTime+offset];
        aYVertex = [aCouplingIntervals(2)-50, aCouplingIntervals(2)-50, aCouplingIntervals(2)+50, aCouplingIntervals(2)+50];
        oPatch = patch(aXVertex, aYVertex,[0 0 0],'parent',oAxes);
        set(oPatch, 'LineStyle', 'none')
        hh1 = hatchfill(oPatch, 'single', -45, 3);
    end
    aCILabels{m} = zeros(numel(iBeats{m}));
    for k = 1:numel(iBeats{m})
        iCount = iCount + 1;
        iIndex = iBeats{m}(k);%+1; %mapping between beats in pressure and beats in optical
        sLabel = num2str(iCount);
        oBeatLabel = text(aTimes(iIndex)+dLineAngle{m}(k), ...
            aCouplingIntervals(iIndex)+dIncremements{m}(k), sLabel,'parent',oAxes, ...
            'FontWeight','bold','FontUnits','points','horizontalalignment','center');
        set(oBeatLabel,'FontSize',8);
        %save coupling interval
        aCILabels{m}(k) = aCouplingIntervals(iIndex);
        oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle{m}(k)],...
            [aCouplingIntervals(iIndex),...
            aCouplingIntervals(iIndex)+dIncremements{m}(k)-dLineIncrements{m}(k)],'-','linewidth',0.5);
        set(oLine,'color',[0.5 0.5 0.5]);
    end
    %get last time for next iteration
    aLastTime = aTimes(end);
end

%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[200 500]);
%set labels
oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1);% + (oYLim(2) - oYLim(1)) / 10
set(oYlabel,'position',oPosition);

%plot pressure data
oAxes = oSubplotPanel(1,1,2,1).select();
aData = oThisPressure.Processed.Data;
aData(1:10000) = NaN;
aTime = oThisPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[0 100]);
%set labels
oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1);
set(oYlabel,'position',oPosition);
%put line on to indicate stimulus timing
hold(oAxes,'on');
plot(oAxes,[3.641 20.02],[5 5],'k','linewidth',1);
plot(oAxes,[3.641 3.641],[5 0],'k','linewidth',1);
plot(oAxes,[6.194 6.194],[5 0],'k','linewidth',1);
plot(oAxes,[16.56 16.56],[5 0],'k','linewidth',1);
plot(oAxes,[20.02 20.02],[5 0],'k','linewidth',1);
text(((16.56-6.194)/2)+6.194,-10,'CCh','parent',oAxes,'fontsize',10,'horizontalalignment','center');
text(((6.194-3.641)/2)+3.641,-10,'*','parent',oAxes,'fontsize',10,'horizontalalignment','center');
text(((20.02-16.56)/2)+16.56,-10,'*','parent',oAxes,'fontsize',10,'horizontalalignment','center');
hold(oAxes,'off');

% %plot maps
%plot the schematic
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
dTextXAlign = 0;
iFileCount = 1;
iCount = 1;
oOptical = GetOpticalFromMATFile(Optical,[sSubDir,sOpticalFileName{iFileCount}]);
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
for i = 1:yrange
    for j = 1:xrange
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'arsps', 24, iBeats{iFileCount}(iCount), []);
        oAxes = oSubplotPanel(1,2,2,i,j).select();
             %plot the schematic
        oOverlay = axes('position',get(oAxes,'position'));
        colormap(oOverlay,flipud(jet));
        set(oOverlay,'box','off','color','none');
        if (i == 1) && (j == 1)
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140828\20140828Schematic_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
        else
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140828\20140828Schematic_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
        end
        %         %make it transparent in the right places
        aCData = get(oImage,'cdata');
        aBlueData = aCData(:,:,3);
        aAlphaData = aCData(:,:,3);
        aAlphaData(aBlueData < 100) = 1;
        aAlphaData(aBlueData > 100) = 1;
        aAlphaData(aBlueData == 100) = 0;
        aAlphaData = double(aAlphaData);
        set(oImage,'alphadata',aAlphaData);
        axis(oOverlay,'tight');
        axis(oOverlay,'off');
        
        oOriginAxes = axes('position',get(oAxes,'position'));
        aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats{iFileCount}(iCount),:)).Coords});
        if ~isempty(aOriginCoords)
            scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
                'sizedata',81,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats{iFileCount}(iCount)).z,aContours);
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        axis(oOriginAxes,'equal');
        set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oOriginAxes,'off');
        caxis(oAxes,aContourRange);
        cmap = colormap(oAxes, flipud(jet));
        
        if (i == 1) && (j == 1)
            %create labels
            %             oLabel = text(aXlim(1)+0.8,aYlim(2)-3.5,'SVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6);
            %             oLabel = text(aXlim(2)-0.5,aYlim(1)+0.5,'IVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6);
            %             oLabel = text(aXlim(1)+6,aYlim(2)-5.3,'CT','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            %             set(oLabel,'fontsize',6,'color','w');
            oLabel = text(aXlim(2)-1.5,aYlim(1)-0.5,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
            set(oLabel,'fontsize',8);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
        oLabel = text(aXlim(1)+0.5,aYlim(2)-1,num2str(j),'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',10);
        oLabel = text(aXlim(1)+0.5,aYlim(1)+0.4,sprintf('%4.0f ms',aCILabels{iFileCount}(iCount)),...
            'parent',oOriginAxes,'fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',8);
        %update counters
        iCount = iCount + 1;
        if iCount > numel(iBeats{iFileCount})
            iCount = 1;
            iFileCount = iFileCount + 1;
            if iFileCount <= numel(sOpticalFileName)
                oOptical = GetOpticalFromMATFile(Optical,[sSubDir,sOpticalFileName{iFileCount}]);
            end
        end
    end
end

oAxes = oSubplotPanel(1,2,1,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT');
aCRange = [0 12];
oLabel = text(-2.8,(aCRange(2)-aCRange(1))/2,'Atrial AT (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);

%create text labels
oLabel = annotation('textbox','position',[0 0.9 0.1 0.1],'string','A','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0 0.76 0.1 0.1],'string','B','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0 0.58 0.1 0.1],'string','C','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0 0.48 0.1 0.1],'string','D','linestyle','none','fontsize',12,'fontweight','bold');

%% create second panel
% set up axes
oSubplotPanel(2).pack('h',{0.2,0.2,0.2,0.2,0.2});
oSubplotPanel(2).de.margin = [0 0 0 0];
oSubplotPanel(2).de.fontsize = 8;
iScatterSize = 4;
aylim = [0 10];
axlim = [200 900];
%% set up panels A and B
%get data
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh002\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh002\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\Pressure.mat' ...
    }};

%initialise arrays to hold arrays of data
aBaselinePressures = cell(numel(aControlFiles),1);
aBaselineCouplingIntervals = cell(numel(aControlFiles),1);
aAllInitialLocs = cell(1,numel(aControlFiles));
%the most inferior location during the plateau
aMaxLocs = cell(numel(aControlFiles),1);
aCombinedLocs = cell(numel(aControlFiles),1);
%select the axes to plot the dynamic data
oOnsetAxes = oSubplotPanel(2,2).select();

%define the colour range for plots
aScatterColor = {...
    {'k','k','k','r','r','r'} ...
    {'k','k','k','k','r','r','r'} ...
    {'k','k','r','r'} ...
    {'k','k','r'} ...
    {'k','k','k','r','r'}};
aScatterMarker = {...
    {'filled','filled','filled','o','o','o'} ...
    {'filled','filled','filled','filled','o','o','o'} ...
    {'filled','filled','o','o'} ...
    {'filled','filled','o'} ...
    {'filled','filled','filled','o','o'}};
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
    load([pathstr(1:end-15),'\CChLocationData.mat']);
    iCount = 0;
    for j = 1:numel(aFiles)
        %get the cycle lengths and times for all beats for this file
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
                case 2
                    if j > 1
                        aCouplingIntervals  = horzcat(NaN,oPressure.oRecording(1).Electrodes.Processed.BeatRates,NaN,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                        aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                        aTimes = horzcat(oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRateTimes);
                    else
                        aCouplingIntervals  = vertcat(oPressure.oRecording(1).Electrodes.Processed.BeatRates,...
                            oPressure.oRecording(2).Electrodes.Processed.BeatRates);
                        aCouplingIntervals  = 60000 ./ aCouplingIntervals;
                        aTimes = horzcat(oPressure.oRecording(1).TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes),...
                            oPressure.oRecording(2).TimeSeries(oPressure.oRecording(2).Electrodes.Processed.BeatRateIndexes));
                    end
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
        
        %get the locs for this file
        try
            aThisDistance =  aDistance{j};
            aLocs = vertcat(aThisDistance{1}(:,1),aThisDistance{2}(:,1));
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if numel(aLocs) ~= numel(aCouplingIntervals)
            fprintf('Warning: Locs dont match CouplingIntervals for %s\n',char(aFiles{j}));
        end
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
set(get(oOnsetAxes,'xlabel'),'string','CL (ms)','fontsize',8);
set(get(oOnsetAxes,'ylabel'),'string','DP site (mm)','fontsize',8);
set(get(oOnsetAxes,'title'),'string','Onset','fontweight','bold','fontsize',8);
% %add panel label
text(axlim(1)-200,aylim(2)+1.5,'E','parent',oOnsetAxes,'fontsize',12,'fontweight','bold');

%create boxplots panel
oAxes = oSubplotPanel(2,4).select();
oOverlay = axes('parent',oFigure,'position',get(oAxes,'position'));
set(oOverlay,'xlim',axlim);
set(oOverlay,'ylim',aylim);
axis(oOverlay,'off');
text(axlim(1)-200,aylim(2)+1.5,'F','parent',oOverlay,'fontsize',12,'fontweight','bold');

%plot boxplots
aylim2 = [-100 150];
set(oAxes,'ylim',aylim2);
aytick = get(oAxes,'ytick');
set(oAxes,'xlim',[0 4]);
set(oAxes,'xtick',[1 2 3 4]);
axtick = get(oAxes,'xtick');
xticklabels = cell(1,numel(axtick));
[xticklabels{:}] = deal('');
xticklabels{axtick==1} = ['n=4'];
xticklabels{axtick==3} = ['n=4'];
text(axtick,ones(numel(axtick),1).*(aylim2(1)-abs(aytick(1)-aytick(2))/1.6),...
    xticklabels,'parent',oAxes,'fontsize',get(oAxes,'fontsize'),...
    'horizontalalignment','center');
set(oAxes,'xticklabel',[]);
set(oAxes,'xtick',[1 3]);
set(get(oAxes,'ylabel'),'string','\DeltaCL (ms)');

set(oFigure,'resizefcn',[]);
export_fig(sPaperFileSavePath,'-png','-r600','-nocrop')
% print(sThesisFileSavePath,'-dpsc','-r600')
