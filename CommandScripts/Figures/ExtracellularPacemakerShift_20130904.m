close all;
%Open unemap file
% oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\pabaro001_unemap.mat');
% for i = 1:numel(oUnemap.Electrodes)
%     oUnemap.Electrodes(i).SignalEvent(1).Range = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Range, [0 0]);
%     oUnemap.Electrodes(i).SignalEvent(1).Index = vertcat(oUnemap.Electrodes(i).SignalEvent(1).Index, 0);
% end
% oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\baro001_pressure.mat','Extracellular');
%set variables
dWidth = 16;
dHeight = 23.2;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ExtracellularPacemakerShift_20130904.eps';
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
oSubplotPanel(1).pack('h',{0.058,0.942});
oSubplotPanel(1,2).pack(3);
oSubplotPanel(2).pack(xrange,yrange);
oSubplotPanel(3).pack();
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
%set limits
% xlim(oAxes,oXLim);
axis(oAxes,'tight');
ylim(oAxes,[-10 10]);
oXLim = get(oAxes,'xlim');
%set labels
oYlabel = ylabel(oAxes,['PND', 10,'(\muV)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.05;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

%plot HR
oAxes = oSubplotPanel(1,2,3).select();
aData = oUnemap.RMS.HeartRate.Data;
aTime = oUnemap.TimeSeries;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',1);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);
set(oAxes,'yminortick','on');
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[100 510]);
%set labels
oYlabel = ylabel(oAxes,['HR', 10, '(bpm)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);
iStartBeat = 30;
for k = iStartBeat:2:iStartBeat+(xrange*yrange)-1
    if k == iStartBeat
        oBeatLabel = text(oUnemap.TimeSeries(oUnemap.RMS.HeartRate.Peaks(2,k)), ...
        oUnemap.RMS.HeartRate.Rates(k)+40, sprintf('#%d',k),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    else
    oBeatLabel = text(oUnemap.TimeSeries(oUnemap.RMS.HeartRate.Peaks(2,k)), ...
        oUnemap.RMS.HeartRate.Rates(k)+40, num2str(k),'parent',oAxes, ...
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
ylim(oAxes,[60 140]);
%set labels
oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - 1.05;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
set(oYlabel,'position',oPosition);

% %plot maps
% oUnemap.RotateArray();
% oActivation = oUnemap.PrepareActivationMap(50, 'Contour', 1 ,[],[]);
%plot the schematic

iBeatCount = 0;
aXlim = [-2 6.4];
aYlim = [-2 6.4];
aContourRange = [0 11];
aContours = aContourRange(1):1:aContourRange(2);
for i = 1:5
    for j = 1:5
        iBeat = iStartBeat + iBeatCount;
        if (i == 1) && (j == 1)
            oAxes = oSubplotPanel(2,1,1).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130904\20130904Schematic.bmp','Parent', oAxes, 'Border', 'tight');
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            [C, oContour] = contourf(oOverlay,oActivation.x,oActivation.y,oActivation.Beats(iBeat).z,aContours);
            caxis(aContourRange);
            colormap(oOverlay, colormap(flipud(colormap(jet))));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
            %create labels
            oLabel = text(3,6.4,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
            oLabel = text(-2,-1,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(5,1.8,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
         else
            oAxes = oSubplotPanel(2,i,j).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130904\20130904Schematic.bmp','Parent', oAxes);
            set(oAxes,'box','off','color','none');
            axis(oAxes,'tight');
            axis(oAxes,'off');
            [C, oContour] = contourf(oOverlay,oActivation.x,oActivation.y,oActivation.Beats(iBeat).z,aContours);
            caxis(aContourRange);
            colormap(oOverlay, colormap(flipud(colormap(jet))));
            axis(oOverlay,'equal');
            set(oOverlay,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
            axis(oOverlay,'off');
        end
        %label beat number, rate and pressure
        %get pressure
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Processed - oUnemap.TimeSeries(oUnemap.RMS.HeartRate.Peaks(2,iBeat))));
        oLabel = text(-2,4,sprintf('%d mmHg',round(oPressure.Processed.Data(MinIndex))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(-2,3,sprintf('%d bpm',round(oUnemap.RMS.HeartRate.Rates(iBeat))),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',6);
        oLabel = text(-2,5.5,sprintf('#%d',iBeat),'parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',12);
        %plot earliest activation
        oFirstElectrodes = oUnemap.Electrodes(~logical(oActivation.Beats(iBeat).FullActivationTimes));
        aCoords = cell2mat({oFirstElectrodes(:).Coords});
        aCoords = aCoords';
        dMarksize = 6;
        hold(oOverlay,'on');
        scatter(oOverlay, aCoords(:,1), aCoords(:,2), 'filled', ...
            'SizeData',dMarksize,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
        iBeatCount = iBeatCount + 1;
        hold(oOverlay,'off');
    end
end
oAxes = oSubplotPanel(3,1).select();
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes);
oXlabel = text(((aContourRange(2)-aContourRange(1))/2)-abs(aContourRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);
movegui(oFigure,'center');
% print(oFigure,'-dbmp','-r600',sSavePath)
print(oFigure,'-dps','-r600',sSavePath)
