% close all;
%Open unemap file
oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130822\0822baro003\pabaroreflex003_unemap.mat');
oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20130822\0822baro003\pbaroreflex003_pressure.mat','Extracellular');
for i = 1:numel(oUnemap.Electrodes)
    [x b] = oUnemap.CalculateSinusRate(i);
    oUnemap.Electrodes(i).Processed.BeatRateData = oUnemap.Electrodes(i).Processed.BeatRateData';
    oUnemap.Electrodes(i).Processed.BeatRates = oUnemap.Electrodes(i).Processed.BeatRates';
    oUnemap.Electrodes(i).Processed.BeatRateTimes = oUnemap.Electrodes(i).Processed.BeatRateTimes';
end
% % oUnemap.RotateArray();
oActivation = oUnemap.PrepareEventMap(100, 1,35);

%set variables
dWidth = 16;
dHeight = 23.2;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ExtracellularCV_20130822.eps';
% sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Test.bmp';
%Create plot panel that has 3 rows at top to contain pressure, electrogram and heart rate 

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
xrange = 5;
yrange = 5;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack({0.25 0.73 0.02});
oSubplotPanel(1).pack('h',{0.065,0.935});
oSubplotPanel(2).pack(xrange,yrange);
oSubplotPanel(3).pack('h',{0.95});
movegui(oFigure,'center');

oSubplotPanel.margin = [5 12 5 5];
oSubplotPanel(1).margin = [0 8 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 0 0 5];

oSubplotPanel(1).fontsize = 6;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(3).fontsize = 12;
oSubplotPanel(3).fontweight = 'bold';

aCVRange = [0.2 1];
%% plot top panel
iStartBeat = 16;
iBoxXLocation = 1;
% %plot HR
oAxes = oSubplotPanel(1,2).select();
aXTickLabels = cell(1,xrange*yrange);
for k = iStartBeat:1:iStartBeat+(xrange*yrange)-1
    iMapBeat = k + 1;
    idxCV = find(~isnan(oActivation.Beats(iMapBeat).CVApprox));
    aCVdata = oActivation.Beats(iMapBeat).CVApprox(idxCV);
    bplot(aCVdata,oAxes,iBoxXLocation,'nolegend','nooutliers','nomean','tukey','linewidth',1);
    aXTickLabels{1,iBoxXLocation} = sprintf('%d',k);
    iBoxXLocation = iBoxXLocation + 1;
    hold(oAxes,'on');
end
hold(oAxes,'off');
%set labels
aXticks = 1:1:iBoxXLocation-1;
set(oAxes,'xtick',aXticks)
set(oAxes,'xlim',[0 iBoxXLocation]);
set(oAxes,'ylim',aCVRange);
set(oAxes,'xticklabel',aXTickLabels);
xlabel(oAxes,'Beat #');
oYlabel = ylabel(oAxes,['Apparent', 10,'CV (m/s)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = - 1.8;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 2;
set(oYlabel,'position',oPosition);

%get rate info
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
aRates = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'Processed','BeatRates');
aTimeData = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'Processed','BeatRateTimes');
aMeanRates = mean(aRates,2);
aMeanTimes = mean(aTimeData,2);

% %plot maps
iBeatCount = 0;
aXlim = [-3 6];
aYlim = [-2 7];
aCVContours = aCVRange(1):0.1:aCVRange(2);
for i = 1:5
    for j = 1:5
        iBeat = iStartBeat + iBeatCount;
        iMapBeat = iBeat + 1;
        if (i == 1) && (j == 1)
            oAxes = oSubplotPanel(2,1,1).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130822\20130822Schematic.bmp','Parent', oAxes, 'Border', 'tight');
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            idxCV = find(~isnan(oActivation.Beats(iMapBeat).CVApprox));
            aCVdata = oActivation.Beats(iMapBeat).CVApprox(idxCV);
            aCVdata(aCVdata > 1) = 1;
            scatter(oOverlay,oActivation.CVx(idxCV),oActivation.CVy(idxCV),10,aCVdata,'filled');
            hold(oOverlay, 'on');
            quiver(oOverlay,oActivation.CVx(idxCV),oActivation.CVy(idxCV),oActivation.Beats(iMapBeat).CVVectors(idxCV,1), ...
                oActivation.Beats(iMapBeat).CVVectors(idxCV,2),'color','k','linewidth',0.6);
            hold(oOverlay, 'off');
            caxis(aCVRange);
            colormap(oOverlay, colormap(jet));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
            %create labels
            oLabel = text(1.2,6.8,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
            oLabel = text(-1,0.5,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(4.7,0.5,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
         else
            oAxes = oSubplotPanel(2,i,j).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130822\20130822Schematic.bmp','Parent', oAxes);
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            idxCV = find(~isnan(oActivation.Beats(iMapBeat).CVApprox));
            aCVdata = oActivation.Beats(iMapBeat).CVApprox(idxCV);
            aCVdata(aCVdata > 1) = 1;
            scatter(oOverlay,oActivation.CVx(idxCV),oActivation.CVy(idxCV),12,aCVdata,'filled');
            hold(oOverlay, 'on');
            quiver(oOverlay,oActivation.CVx(idxCV),oActivation.CVy(idxCV),oActivation.Beats(iMapBeat).CVVectors(idxCV,1), ...
                oActivation.Beats(iMapBeat).CVVectors(idxCV,2),'color','k','linewidth',0.6);
            hold(oOverlay, 'off');
            caxis(aCVRange);
            colormap(oOverlay, colormap(jet));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
        end
        %label beat number, rate and pressure
        %get pressure
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Processed - aMeanTimes(iBeat)));
        oLabel = text(-2,4,sprintf('%d mmHg',round(oPressure.Processed.Data(MinIndex))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(-2,3,sprintf('%d bpm',round(aMeanRates(iBeat))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(-2,5.5,sprintf('#%d',iBeat),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',12);
        %plot earliest activation
        oFirstElectrodes = oUnemap.Electrodes(~logical(oActivation.Beats(iMapBeat).FullActivationTimes));
        aCoords = cell2mat({oFirstElectrodes(:).Coords});
        aCoords = aCoords';
        dMarksize = 8;
        hold(oOverlay,'on');
        scatter(oOverlay, aCoords(:,1), aCoords(:,2), 'filled', ...
            'SizeData',dMarksize,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
        iBeatCount = iBeatCount + 1;
        hold(oOverlay,'off');
    end
end
oAxes = oSubplotPanel(3,1).select();
cbarf_edit(aCVRange, aCVContours,'horiz','linear',oAxes,'CV');
oXlabel = text(((aCVRange(2)-aCVRange(1))/2)+abs(aCVRange(1)),-2.2,'Apparent CV (m/s)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);

% print(oFigure,'-dbmp','-r600',sSavePath)
print(oFigure,'-dpsc','-r600',sSavePath)
