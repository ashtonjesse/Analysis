close all;
% % %Open unemap file
oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20140505\20140505baro002\pabaro002_unemap.mat');
oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20140505\20140505baro002\baro002_pressure.mat','Extracellular');
oUnemap.CalculateSinusRate();
% % % % % oUnemap.RotateArray();
oActivation = oUnemap.PrepareEventMap(100, 1, 35);
%set variables
dWidth = 16;
dHeight = 23.2;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ExtracellularActivation_20140505.eps';
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
xrange = 6;
yrange = 6;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack({0.25 0.73 0.02});
oSubplotPanel(1).pack('h',{0.06,0.94});
oSubplotPanel(1,2).pack(3);
oSubplotPanel(2).pack(xrange,yrange);
oSubplotPanel(3).pack('h',{0.02 0.95});
movegui(oFigure,'center');

oSubplotPanel.margin = [5 12 5 5];
oSubplotPanel(1).margin = [0 5 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 0 0 5];

oSubplotPanel(1).fontsize = 6;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(3).fontsize = 12;
oSubplotPanel(3).fontweight = 'bold';

%% plot top panel


%plot HR
oAxes = oSubplotPanel(1,2,3).select();
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
aRates = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'Processed','BeatRates');
aIndexes = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'Processed','BeatRateIndexes');
aTimeData = oUnemap.TimeSeries(aIndexes);
aMeanRates = 60000./mean(aRates,2);
aMeanTimes = mean(aTimeData,2);
for i = 2:numel(aMeanRates)
    plot(oAxes,[aMeanTimes(i-1) aMeanTimes(i)],[aMeanRates(i) aMeanRates(i)],'k');
    hold(oAxes,'on');
end
hold(oAxes,'off');
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
axis(oAxes,'tight');
oXLim = get(oAxes,'xlim');
oXLim(1) = oXLim(1) - 6;
oXLim(2) = oXLim(2) + 2;
xlim(oAxes,oXLim);
ylim(oAxes,[200 800]);
%set labels
oYlabel = ylabel(oAxes,['Mean', 10,'Atrial CL',10, '(ms)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.9;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
iStartBeat = 6;
for k = iStartBeat:2:iStartBeat+(xrange*yrange)-1
    if k == iStartBeat
        oBeatLabel = text(aMeanTimes(k), ...
        aMeanRates(k)+40, sprintf('%d',k),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    else
    oBeatLabel = text(aMeanTimes(k), ...
        aMeanRates(k)+40, num2str(k),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    end
    set(oBeatLabel,'FontSize',6);
end
%plot time scale
hold(oAxes,'on');
plot([oXLim(2)-2; oXLim(2)], [oYLim(1); oYLim(1)], '-k','LineWidth', 2)
hold(oAxes,'off');
oLabel = text(oXLim(2)-1,oYLim(1)-80, '2 s', 'parent',oAxes, ...
        'FontUnits','points','horizontalalignment','center');
set(oLabel,'FontSize',8);


%plot phrenic
oAxes = oSubplotPanel(1,2,2).select();
aData = oPressure.RefSignal.Processed ./ ...
    (oPressure.oExperiment.Phrenic.Amp.OutGain*1000)*10^6;
aTime = oPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
% xlim(oAxes,oXLim);
axis(oAxes,'tight');
ylim(oAxes,[-20 20]);
xlim(oAxes,oXLim);
%set labels
oYlabel = ylabel(oAxes,['PND &', 10,'ECG',10,'(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.8;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot pressure data
oAxes = oSubplotPanel(1,2,1).select();
aData = oPressure.Processed.Data;
aTime = oPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[60 210]);
%set labels
oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.8;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

% %plot maps
%plot the schematic

iBeatCount = 0;
aXlim = [-1.5 6];
aYlim = [-1.5 6];
aContourRange = [0 18];
aContours = aContourRange(1):1:aContourRange(2);
for i = 1:yrange
    for j = 1:xrange
        iBeat = iStartBeat + iBeatCount;
        iMapBeat = iBeat;
        if (i == 1) && (j == 1)
            oAxes = oSubplotPanel(2,1,1).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140501\Schematic.bmp','Parent', oAxes, 'Border', 'tight');
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            [C, oContour] = contourf(oOverlay,oActivation.x,oActivation.y,oActivation.Beats(iMapBeat).z,aContours);
            caxis(aContourRange);
            colormap(oOverlay, colormap(flipud(colormap(jet))));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
            %create labels
            oLabel = text(3,6,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
            oLabel = text(0,0.3,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(4.2,0.5,'RAA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
         else
            oAxes = oSubplotPanel(2,i,j).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140501\Schematic.bmp','Parent', oAxes);
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            [C, oContour] = contourf(oOverlay,oActivation.x,oActivation.y,oActivation.Beats(iMapBeat).z,aContours);
            caxis(aContourRange);
            colormap(oOverlay, colormap(flipud(colormap(jet))));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
        end
        %label beat number, rate and pressure
        %get pressure
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Processed - aMeanTimes(iBeat)));
        oLabel = text(aXlim(1),4,sprintf('%d mmHg',round(oPressure.Processed.Data(MinIndex))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(aXlim(1),3,sprintf('%d ms',round(aMeanRates(iBeat))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(aXlim(1),5.5,sprintf('%d',iBeat),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',12);
        %plot earliest activation
        oFirstElectrodes = oUnemap.Electrodes(~logical(oActivation.Beats(iMapBeat).FullActivationTimes));
        aCoords = cell2mat({oFirstElectrodes(:).Coords});
        aCoords = aCoords';
        dMarksize = 10;
        hold(oOverlay,'on');
        scatter(oOverlay, aCoords(:,1), aCoords(:,2), 'filled', ...
            'SizeData',dMarksize,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
        iBeatCount = iBeatCount + 1;
        hold(oOverlay,'off');
    end
end
oAxes = oSubplotPanel(3,2).select();
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes,'AT',10);
oXlabel = text(((aContourRange(2)-aContourRange(1)+1)/2)-abs(aContourRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
% print(oFigure,'-dbmp','-r600',sSavePath)
% print(oFigure,'-dpsc','-r600',sSavePath)
