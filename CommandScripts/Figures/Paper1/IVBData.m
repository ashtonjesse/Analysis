%figure for HRS 2016 abstract

%create layout
%load data
%plot data
%save to file as gif
% 
close all;
% clear all;

%% read in the optical entities
sFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\baro002a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\baro005a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002\chemo002a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004\chemo004a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004\chemo004b_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\CCh003a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\CCh003b_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003\CCh003c_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\CCh004a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\CCh004b_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh004\CCh004c_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    }};

%set variables
dWidth = 16;
dHeight = 10;
sPaperFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2015\Paper1\Figures\IVBData.png';
sThesisFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\IVBData.eps';

%set up figure
oFigure = figure();
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
xrange = 3;
yrange = 2;
oSubplotPanel = panel(oFigure,'no-manage-font');
oSubplotPanel.pack('v',{0.95,0.02});
oSubplotPanel(1).pack(yrange,xrange);

%set up margins
movegui(oFigure,'center');
oSubplotPanel.margin = [12,5,1,2];
oSubplotPanel.de.margin = [6 0 0 0];%[left bottom right top]

% %create text labels
oLabel = annotation('textbox','position',[0 0.9 0.1 0.1],'string','A','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0 0.5 0.1 0.1],'string','B','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0.36 0.9 0.1 0.1],'string','C','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0.36 0.5 0.1 0.1],'string','D','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0.68 0.9 0.1 0.1],'string','E','linestyle','none','fontsize',12,'fontweight','bold');
oLabel = annotation('textbox','position',[0.68 0.5 0.1 0.1],'string','F','linestyle','none','fontsize',12,'fontweight','bold');


%% create panel
% % % get data
% iNumFiles = numel(sFiles);
% aPressureData = cell(1,iNumFiles);
% aDistance = cell(1,iNumFiles);
% aMagnitude = zeros(2,1);
% aBaseline = zeros(2,1);
% aPlateau = zeros(2,1);
% 
% for i = 1:iNumFiles
%         if iscell(sFiles{i})
%             sThisFile = sFiles{i}{1};
%         else
%             sThisFile = sFiles{i};
%         end
%         [pathstr, name, ext, versn] = fileparts(sThisFile);
%         sFileName = [pathstr,'\Pressure.mat'];
%         oPressure = GetPressureFromMATFile(Pressure,sFileName,'Optical');
%         aPressureData{i} = oPressure;
%         fprintf('Got file %s\n',sFileName);
%         if i < 3
%             aPlateau(i) = mean(oPressure.Plateau.BeatPressures);
%             aBaseline(i) = mean(oPressure.Baseline.BeatPressures);
%             aMagnitude(i) = round(aPlateau(i))-round(aBaseline(i));
%         end
% end

iScatterSize = 4;
aYlim = [150 600];
aPressureYlim = [10 130];
aXlim = [-10 30 ; -8 40 ; -30 65];
aChemoLabelLimits = [-2.821 -1.767; -3.926 -2.452];
aCChLabelLimits = [-18.76 -6.132;-16.97 -4.845];
aCRange = [0 7];
iRow = 1;
iCol = 1;
aIndices = [2,5,2,4,3,4];
for j = 1:iNumFiles
    %get distance data
    if iscell(sFiles{j})
        sThisFile = sFiles{j}{1};
    else
        sThisFile = sFiles{j};
    end
    [pathstr, name, ext, versn] = fileparts(sThisFile);
    switch j
        case 1
            load([pathstr(1:end-15),'\BaroLocationData.mat']);
        case 3
            load([pathstr(1:end-17),'\ChemoLocationData.mat']);
        case 5
            load([pathstr(1:end-15),'\CChLocationData.mat']);
    end
    oPressure = aPressureData{j};
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    aAdjustedTimes = cell(1,numel(aDistance{aIndices(j)}));
    %set up axes
    oSubplotPanel(1,iRow,iCol).pack('v',{0.2,0.01,0.45,0.01,0.2,0.13});
    oAxes = oSubplotPanel(1,iRow,iCol,3).select();
    oPressureAxes = oSubplotPanel(1,iRow,iCol,1).select();

    oDummyAxes = oSubplotPanel(1,iRow,iCol,5).select();
    oPhrenicAxes = axes('position',get(oDummyAxes,'position')+[0 0.02 0 0]);
    axis(oDummyAxes,'off');

    %convert rates into coupling intervals 
    dMax = 0;
    iRecordingWithMax = 1;
    if iscell(aDistance{aIndices(j)})
        looplimit = numel(aDistance{aIndices(j)});
    else
        looplimit = 1;
    end
    %% plot cycle length
    for p = 1:looplimit;
        iRecordingIndex = p;
        aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
        aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
        switch j
            case {1,2}
                aTimePoint = oPressure.Increase.BeatTimes(1);
            case {3,4,5,6}
                aTimePoint = oPressure.HeartRate.Decrease.BeatTimes(1);
        end
        aAdjustedTimes{p} = aTimes - aTimePoint;
        
        hold(oAxes, 'on');
        %plot baseline
        if p == 1
            [dBaseline iMinIdx] = min(aCouplingIntervals);
        end
        [dTopline iMaxIdx] = max(aCouplingIntervals);
        if dTopline > dMax
            dMax = dTopline;
            iOverallMaxIdx = iMaxIdx;
            iRecordingWithMax = p;
        end
        oLine = plot(oAxes,[aAdjustedTimes{p}(2); aAdjustedTimes{p}(end-1)], [dBaseline-10; dBaseline-10], '--k','LineWidth', 0.5);

        % % %     %get locations
        try
            aLocs =  aDistance{aIndices(j)}{p}(:,1);
            a2ndLocs = aDistance{aIndices(j)}{p}(:,2);
            a1stLocIndex = isnan(aDistance{aIndices(j)}{p}(:,2));
            a2ndLocIndex = ~isnan(aDistance{aIndices(j)}{p}(:,2));
        catch ex
            aLocs =  aDistance{aIndices(j)}(:,1);
            a2ndLocs = aDistance{aIndices(j)}(:,2);
            a1stLocIndex = isnan(aDistance{aIndices(j)}(:,2));
            a2ndLocIndex = ~isnan(aDistance{aIndices(j)}(:,2));
        end
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            x = 1;
        end
        
        %plot 1st locs
        scatter(oAxes, aAdjustedTimes{p}(a1stLocIndex), aCouplingIntervals(a1stLocIndex),iScatterSize,aLocs(a1stLocIndex),'filled');
        %plot 1st locs offset
        scatter(oAxes, aAdjustedTimes{p}(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)+25,iScatterSize,aLocs(a2ndLocIndex),'filled');
        %plot 2nd locs offset
        scatter(oAxes, aAdjustedTimes{p}(a2ndLocIndex), aCouplingIntervals(a2ndLocIndex)-25,iScatterSize,a2ndLocs(a2ndLocIndex),'filled');
        cmap = colormap(oAxes, jet(aCRange(2)-aCRange(1)));
        caxis(oAxes, aCRange);
        if p > 1
            %add patch between data
            offset = 0.3;
            aXVertex = [aLastTime+offset, aAdjustedTimes{p}(2)-offset, aAdjustedTimes{p}(2)-offset, aLastTime+offset];
            aYVertex = [aCouplingIntervals(2)-75, aCouplingIntervals(2)-75, aCouplingIntervals(2)+75, aCouplingIntervals(2)+75];
            oPatch = patch(aXVertex, aYVertex,[0 0 0],'parent',oAxes);
            set(oPatch, 'LineStyle', 'none')
            hh1 = hatchfill(oPatch, 'single', -45, 3);
        end
        aLastTime = aAdjustedTimes{p}(end);
    end
    %set limits
    set(oAxes,'ylim',aYlim);
    set(oAxes,'xlim',aXlim(iCol,:));
    
    %put y axis on and label ends
    if iCol == 1
        oLine = plot(oAxes,[aXlim(iCol,1)+1; aXlim(iCol,1)+1], [dBaseline; dBaseline+200], '-k','LineWidth', 2);
        olabel = text(aXlim(iCol,1)-3.5,dBaseline+100, ['200',10,'(ms)'], 'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',8);
    end
    
    offset = [-2 0;-5 -5;-10 -10];
    Index = 1;
    %need to label the shortest and longest coupling intervals but also
    %some need labels during the main part of the response
    olabel = text(aAdjustedTimes{1}(Index)+offset(iCol,iRow),dBaseline+50, sprintf('%4.0f ms',dBaseline),...
        'HorizontalAlignment','left','parent',oAxes,'color','k','fontunits','points');
    set(olabel,'fontsize',6);
    olabel = text(aAdjustedTimes{iRecordingWithMax}(iOverallMaxIdx),dMax+50, sprintf('%4.0f ms',dMax), ...
        'HorizontalAlignment','center','parent',oAxes,'color','k','fontunits','points');
    set(olabel,'fontsize',6);
    
    hold(oAxes, 'off');
    set(oAxes,'color','none','box','off');
    axis(oAxes,'off');
    
    %% plot pressure data
    offset = 15;
    aTimeToPlot = oPressure.TimeSeries.Original(10000:end-10000) - aTimePoint;
    aDataToPlot = aPressureProcessedData(10000:end-10000);
    aPointsToPlot = aTimeToPlot > aXlim(iCol,1)+4;
    hold(oPressureAxes,'on');
    plot(oPressureAxes, aTimeToPlot(aPointsToPlot), aDataToPlot(aPointsToPlot), 'linewidth',0.5,'color','k');
    olabel = text(min(aTimeToPlot(aPointsToPlot)),aDataToPlot(find(aPointsToPlot,1,'first')), sprintf('%4.0f',aDataToPlot(find(aPointsToPlot,1,'first'))), ...
        'HorizontalAlignment','right','parent',oPressureAxes,'color','k','fontunits','points');
    set(olabel,'fontsize',6);
    %label change in pressure for baroreflex only
    if iCol == 1
        olabel = text(aXlim(iCol,2),aDataToPlot(find(aPointsToPlot,1,'last'))+20, ['\Delta',sprintf('P=%2.0f mmHg',aMagnitude(iRow))], ...
            'HorizontalAlignment','right','parent',oPressureAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',6);
    end

    set(oPressureAxes,'ylim',aPressureYlim);
    set(oPressureAxes,'xlim',aXlim(iCol,:));

    %put y axis on and label ends
    if iCol == 1
        oLine = plot(oPressureAxes,[aXlim(iCol,1)+1; aXlim(iCol,1)+1], [aPressureYlim(1); aPressureYlim(1)+100], 'LineWidth', 2,'color','k');
        olabel = text(aXlim(iCol,1)-3.5,aPressureYlim(1)+50, ['100',10,'(mmHg)'], 'HorizontalAlignment','center',...
            'parent',oPressureAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',8);
    end
    
    switch (iCol)
        case 2
            %put line on to indicate stimulus timing
            plot(oPressureAxes,aChemoLabelLimits(iRow,:),[95 95],'k','linewidth',1.5);
            text(((aChemoLabelLimits(iRow,1)-aChemoLabelLimits(iRow,2))/2)+aChemoLabelLimits(iRow,2),120,...
                'KCN','parent',oPressureAxes,'fontsize',6,'horizontalalignment','center');
        case 3
            %put line on to indicate stimulus timing
            plot(oPressureAxes,aCChLabelLimits(iRow,:),[95 95],'k','linewidth',1.5);
                        text(((aCChLabelLimits(iRow,1)-aCChLabelLimits(iRow,2))/2)+aCChLabelLimits(iRow,2),120,...
                'CCh','parent',oPressureAxes,'fontsize',6,'horizontalalignment','center');
    end
    set(oPressureAxes,'color','none','box','off');
    axis(oPressureAxes,'off');
    
    %% plot phrenic data
    aData = oPressure.oPhrenic.Electrodes.Processed.Data./ ...
        (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
    aBurstData = ComputeDWTFilteredSignalsKeepingScales(oPressure.oPhrenic, aData,2);
    oPressure.oPhrenic.ComputeIntegral(200,aBurstData);
    aTimeToPlot = oPressure.oPhrenic.TimeSeries - aTimePoint;
    aPointsToPlot = aTimeToPlot > aXlim(iCol,1)+2;
    aPointsToPlot(1:2000) = 0;
    plot(oPhrenicAxes,aTimeToPlot(aPointsToPlot),oPressure.oPhrenic.Electrodes.Processed.Integral(aPointsToPlot)./1000,...
        '-','linewidth',0.5,'color','k');
    %put y axis on and label ends
    hold(oPhrenicAxes,'on');
    axis(oPhrenicAxes,'tight');
    set(oPhrenicAxes,'xlim',aXlim(iCol,:));
    oYLim = get(oPhrenicAxes,'ylim');
    if iCol == 1
        olabel = text(aXlim(iCol,1)-3.5,oYLim(1)+(oYLim(2)-oYLim(1))/2, '\intPND', 'HorizontalAlignment','center',...
            'parent',oPhrenicAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',8);
    end
    set(oPhrenicAxes,'color','none','box','off');
    axis(oPhrenicAxes,'off');
    hold(oPhrenicAxes,'off');
    
    % %create time scale
    if iRow == 2
        oScaleAxes = oSubplotPanel(1,iRow,iCol,6).select();
        plot(oScaleAxes,[aXlim(iCol,1); aXlim(iCol,1)+10], [1.8; 1.8], '-k','LineWidth', 2)
        set(oScaleAxes,'xlim',aXlim(iCol,:));
        set(oScaleAxes,'ylim',[0 2]);
        %label the scale
        olabel = text(aXlim(iCol,1)+10/2,0.8, '10 s', 'HorizontalAlignment','center','parent',oScaleAxes,'color','k','fontunits','points');
        set(olabel,'fontsize',8);
        axis(oScaleAxes,'off');
    end
    
    %increment count for axes
    iRow = iRow + 1;
    if iRow > 2
        iCol = iCol + 1;
        iRow = 1;
    end
end
% 
%create scalebar
oSubplotPanel(2).pack('h',{0.1,0.75});
oBarAxes = oSubplotPanel(2,2).select();
aCRange = [aCRange(1) aCRange(2)-1];
aContours = aCRange(1):1:aCRange(2);
cbarf_edit(aCRange, aContours,'horiz','linear',oBarAxes,'Distance',8);
aCRange = [aCRange(1) aCRange(2)+1];
oXlabel = text(((aCRange(2)-aCRange(1))/2)+abs(aCRange(1)),-2.5,'DPS (mm)','parent',oBarAxes,'fontunits','points','horizontalalignment','center');
set(oXlabel,'fontsize',8);
dcm_obj = datacursormode(oFigure);
set(dcm_obj,'UpdateFcn',@ScatterCursorCallback);

set(oFigure,'resizefcn',[]);
% set(oFigure,'color','none');


export_fig(sPaperFileSavePath,'-png','-r300','-nocrop','-painters');
print(sThesisFileSavePath,'-dpsc','-r300');
% export_fig(strrep(sFileSavePath, '#', '2'),'-png','-r300','-nocrop','-transparent','-painters')
%crop the images
% sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.png',strrep(sFileSavePath, '#', '1'))}, ...
%     {sprintf(' %s.png',strrep(sFileSavePath, '#', '2'))}, {' -gravity center -composite'},{sprintf(' %s.png', strrep(sFileSavePath, '_#', ''))});
% sStatus = dos(char(sChopString{1}));
