close all;
clear all;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\BaroreflexWithLocation_20140722.eps';
%open all the files 
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009' ...
    };
aPressureData = cell(1,numel(aFolders));
aCoords = cell(1,numel(aFolders));
aDistance = cell(1,numel(aFolders));
aMagnitude = zeros(numel(aFolders),1);
for i = 1:numel(aFolders)
    sFileName = [aFolders{i},'\Pressure.mat'];
     oPressure = GetPressureFromMATFile(Pressure,sFileName,'Optical');
     aPressureData{i} = oPressure;
    fprintf('Got file %s\n',sFileName);
    aMagnitude(i) = mean(oPressure.Plateau.BeatPressures);
end
%Sort data in terms of pressure magnitude
[B SortIdx] = sort(aMagnitude);

for p = 1:numel(SortIdx)
    %get index
    j = SortIdx(p);
    sFolder = aFolders{j};
    sRoot = sFolder(end-2:end);
    sType = 'baro';
    sEachFileName = [aFolders{j},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
    oOptical = GetOpticalFromMATFile(Optical, sEachFileName);
    fprintf('Loaded files in %s\n', aFolders{j});
    
    % % %get origin data
    aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
    %loop through beats
    aThisCoords = cell(size(aOrigins,1),1);
    aThisDistance = NaN(size(aOrigins,1),2);
    aPoints = zeros(5,2);
    iCount = 1;
    dDistance = NaN;
    %get the axis points
    aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
    oAxesElectrodes = oOptical.Electrodes(aAxisData);
    aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
    figure();
    plot(aAxesCoords(1,:),aAxesCoords(2,:));
    xlim([0 10]);
    ylim([0 , 10]);
    hold on;
    for n = 1:size(aOrigins,1)
        aElectrodes = oOptical.Electrodes(aOrigins(n,:));
        if ~isempty(aElectrodes)
            if iCount < 6
                aPoints(iCount,:) = cell2mat({aElectrodes(:).Coords});
                iCount = iCount + 1;
                aPrimaryCoords = centroid(aPoints);
            else
                aBeatPoints = cell2mat({aElectrodes(:).Coords});
                aThisCoords{n} = aBeatPoints;
                for m = 1:size(aBeatPoints,2)
                    %transform coords
                    aNewBeatPoints = TransformCoordinates(aAxesCoords(:,2),aAxesCoords(:,1),aBeatPoints(:,m));
                    %                     dDistance = norm(aBeatPoints(:,m)
                    %                     - aPrimaryCoords);
                    plot(aBeatPoints(1,m),aBeatPoints(2,m),'k+');
                    plot(aNewBeatPoints(1,m),aNewBeatPoints(2,m),'r+');
                    aThisDistance(n,m) = aNewBeatPoints(2);
                end
            end
        elseif iCount > 5
            aThisDistance(n,1) = dDistance;
        end
    end
    aDistance{j} = aThisDistance;
end

dWidth = 16;
dHeight = 14;
oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
% set(oFigure, 'WindowStyle', 'Docked');

aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(1,1);
oAxes = cell(numel(aFolders),1);
oAxes{1} = aSubplotPanel(1,1).select();
aPosition = get(oAxes{1},'position');
set(oAxes{1},'position',[aPosition(1) aPosition(2)+0.02  aPosition(3) 1/(numel(aFolders)+3)]);
oColors = jet(5);
iScatterSize = 25;
ylim = [180 600];
xlim = [-5 25];
aLegendEntries = zeros(5,1);
aLegendNames = {'0 - 1 mm','1 - 2 mm','2 - 3 mm','3 - 4 mm','4 - 5 mm'};
for p = 1:numel(SortIdx)
    %get index
    j = SortIdx(p);
  
    oPressure = aPressureData{j};
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    %convert rates into coupling intervals 
    aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        
    %get the corresponding pressure
    aPressures = zeros(size(aCouplingIntervals));
    for i = 1:numel(aCouplingIntervals)
        %         find the index that is closest to this time
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Original - aTimes(i)));
        aPressures(i) = aPressureProcessedData(MinIndex);
    end
    
    %     %find index of first beat to go above threshold from baseline
    %     if isempty(oPressure.Threshold)
    %         Idx = find(aPressures >= oPressure.Increase.BeatPressures(1),1,'first');
    %     else
    %         Idx = find(aPressures >= oPressure.Threshold,1,'first');
    %     end
    Idx = find(aPressures >= oPressure.Increase.BeatPressures(1),1,'first');
    % get pressure time and data
    %     aPressureTime = oPressure.TimeSeries.Original;
    %     aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    %     aPressureTime = aPressureTime(aSeriesPoints);
    %     aPressureProcessedData = aPressureProcessedData(aSeriesPoints);
    %     aPressureTime = aPressureTime -  aTimes(Idx);
    aAdjustedTimes = aTimes - aTimes(Idx);
    
    %get name of this file
    %     aIndices = regexp(aFolders{j},'\');
    %     sFile = aFolders{j};
    %     sName = sFile(aIndices(end)+1:end);
    
    hold(oAxes{p}, 'on');
    % % %     %get locations
    aLocs =  aDistance{j}(:,1);
    if size(aLocs,1) ~= numel(aCouplingIntervals);
        x = 1;
    end

    % %     %     plot
    if ~isempty(find(0 < aLocs & aLocs <=1))
        oLine = scatter(oAxes{p}, aAdjustedTimes(find(0 < aLocs & aLocs <=1)), aCouplingIntervals(find(0 < aLocs & aLocs <=1)),'filled','cdata',oColors(1,:),'sizedata',iScatterSize);
        aLegendEntries(1) = oLine;
    end
    if ~isempty(find(1 < aLocs & aLocs <=2))
        oLine = scatter(oAxes{p}, aAdjustedTimes(find(1 < aLocs & aLocs <=2)),aCouplingIntervals(find(1 < aLocs & aLocs <=2)),'filled','cdata',oColors(2,:),'sizedata',iScatterSize);
        aLegendEntries(2) = oLine;
    end
    if ~isempty(find(2 < aLocs & aLocs <=3))
        oLine = scatter(oAxes{p}, aAdjustedTimes(find(2 < aLocs & aLocs <=3)),aCouplingIntervals(find(2 < aLocs & aLocs <=3)),'filled','cdata',oColors(3,:),'sizedata',iScatterSize);
        aLegendEntries(3) = oLine;
    end
    if ~isempty(find(3 < aLocs & aLocs <=4))
        oLine = scatter(oAxes{p}, aAdjustedTimes(find(3 < aLocs & aLocs <=4)),aCouplingIntervals(find(3 < aLocs & aLocs <=4)),'filled','cdata',oColors(4,:),'sizedata',iScatterSize);
        aLegendEntries(4) = oLine;
    end
    if ~isempty(find(4 < aLocs & aLocs <=5.5))
        oLine = scatter(oAxes{p}, aAdjustedTimes(find(4 < aLocs & aLocs <=5.5)),aCouplingIntervals(find(4 < aLocs & aLocs <=5.5)),'filled','cdata',oColors(5,:),'sizedata',iScatterSize);
        aLegendEntries(5) = oLine;
    end
    set(oAxes{p},'ylim',ylim);
    %     xlim = get(oAxes{1},'xlim');
    set(oAxes{p},'xlim',xlim);
    aPosition = get(oAxes{p},'position');
    set(oAxes{p},'position',aPosition);
    if p < numel(oAxes)
        oAxes{p+1} = axes('parent',oFigure);
        
        set(oAxes{p+1},'Position',[aPosition(1) aPosition(2)+0.09 aPosition(3) aPosition(4)]);
        
    end
    %put y axis on and label ends
    oLine = plot(oAxes{p},[xlim(1)+1; xlim(1)+1], [min(aCouplingIntervals); max(aCouplingIntervals)], '-k','LineWidth', 2);
    set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    olabel = text(xlim(1)-0.4,min(aCouplingIntervals)+20, sprintf('%4.0f ms',min(aCouplingIntervals)), 'HorizontalAlignment','center','parent',oAxes{p},'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',8);
    olabel = text(xlim(1)-0.4,max(aCouplingIntervals)-20, sprintf('%4.0f ms',max(aCouplingIntervals)), 'HorizontalAlignment','center','parent',oAxes{p},'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',8);
    %put lines on to indicate pressure timing
    %start of increase
    oLine = plot(oAxes{p},[oPressure.Increase.BeatTimes(1) - aTimes(Idx); oPressure.Increase.BeatTimes(1) - aTimes(Idx)], ...
        [(60000/oPressure.Increase.BeatRates(1))-10; (60000/oPressure.Increase.BeatRates(1))+75], '-k','LineWidth', 1.5);
    set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %start of plateau
    oLine = plot(oAxes{p},[oPressure.Plateau.BeatTimes(1) - aTimes(Idx); oPressure.Plateau.BeatTimes(1) - aTimes(Idx)], ...
        [(60000/oPressure.Plateau.BeatRates(1))-10; (60000/oPressure.Plateau.BeatRates(1))+75], '-k','LineWidth', 1.5);
    set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %end of plateau
    oLine = plot(oAxes{p},[oPressure.Plateau.BeatTimes(end) - aTimes(Idx); oPressure.Plateau.BeatTimes(end) - aTimes(Idx)], ...
        [(60000/oPressure.Plateau.BeatRates(end))-10; (60000/oPressure.Plateau.BeatRates(end))+75], '-k','LineWidth', 1.5);
    set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    
    hold(oAxes{p}, 'off');
    set(oAxes{p},'color','none','box','off');
    axis(oAxes{p},'off');
    %label the pressure
    olabel = text(xlim(2)-4,ylim(1)+150, sprintf('%4.0f mmHg',aMagnitude(j)), 'HorizontalAlignment','center','parent',oAxes{p},'color','k','fontunits','points','fontweight','bold');
    set(olabel,'fontsize',10);
end

%create time scale
oScaleAxes = axes('parent',oFigure);
plot(oScaleAxes,[xlim(1)+2; xlim(1)+7], [ylim(1); ylim(1)], '-k','LineWidth', 4)
aPosition = get(oAxes{1},'position');
set(oScaleAxes,'position',[aPosition(1) aPosition(2)-0.08 aPosition(3) aPosition(4)]);
xlim = get(oAxes{1},'xlim');
ylim = get(oAxes{1},'ylim');
set(oScaleAxes,'xlim',xlim);
set(oScaleAxes,'ylim',ylim);
%label the scale
olabel = text(xlim(1)+2+5/2,ylim(1)-100, '5 s', 'HorizontalAlignment','center','parent',oScaleAxes,'color','k','fontunits','points','fontweight','bold');
set(olabel,'fontsize',10);
axis(oScaleAxes,'off');

%create legend
oLegend = legend(aLegendEntries,aLegendNames,'orientation','horizontal');
set(oLegend,'box','off','position',[0.1026    0.0545    0.7816    0.0416]);
set(oLegend,'fontunits','points');
set(oLegend,'fontsize',8);
set(oFigure,'resizefcn',[]);
print(oFigure,'-dpsc','-r600',sSavePath)