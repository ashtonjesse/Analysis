close all;
%Open unemap file
oUnemap = GetUnemapFromMATFile(Unemap,'G:\PhD\Experiments\Auckland\InSituPrep\20130221\0221baro001\pabaro001_unemap.mat');
oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20130221\0221baro001\baro001_pressure.mat','Extracellular');
%set variables
dWidth = 16;
dHeight = 21.7;
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ExtracellularPacemakerShift_20130221.eps';
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
oSubplotPanel.pack({0.27 0.71 0.02});
oSubplotPanel(1).pack(3);
oSubplotPanel(2).pack(xrange,yrange);
oSubplotPanel(3).pack();

oSubplotPanel.margin = [15 11 2 5];
oSubplotPanel(1).margin = [0 5 0 0];
oSubplotPanel(2).margin = [0 0 0 0];
oSubplotPanel(3).margin = [0 0 0 5];

oSubplotPanel(1).fontsize = 6;
oSubplotPanel(1).fontweight = 'normal';
oSubplotPanel(3).fontsize = 12;
oSubplotPanel(3).fontweight = 'bold';

%% plot top panel
%plot phrenic
oAxes = oSubplotPanel(1,2).select();
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
oAxes = oSubplotPanel(1,3).select();
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
iStartBeat = 33;
for k = iStartBeat:2:iStartBeat+(xrange*yrange)-1
    if k == iStartBeat
        oBeatLabel = text(oUnemap.TimeSeries(oUnemap.RMS.HeartRate.Peaks(2,k)), ...
        oUnemap.RMS.HeartRate.Rates(k)+40, sprintf('#%d',k),'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    elseif k == 35
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
oAxes = oSubplotPanel(1,1).select();
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

%plot maps
oActivation = oUnemap.PrepareActivationMap(50, 'Contour', 1 ,[],[]);
%plot the schematic

iBeatCount = 0;
aXlim = [-1.8 6.2];
aYlim = [-2 6];
aContourRange = [-1 11];
aContours = aContourRange(1):1:aContourRange(2);
for i = 1:5
    for j = 1:5
        iBeat = iStartBeat + iBeatCount;
        if (i == 1) && (j == 1)
            oAxes = oSubplotPanel(2,1,1).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130221\20130221Schematic.bmp','Parent', oAxes, 'Border', 'tight');
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
            oLabel = text(2.4,6.2,'SVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
            oLabel = text(-1.8,2.2,'IVC','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',8);
            oLabel = text(5,0.6,'RA','parent',oOverlay,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',8);
        else
            oAxes = oSubplotPanel(2,i,j).select();
            oOverlay = axes('position',get(oAxes,'position'));
            imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20130221\20130221Schematic.bmp','Parent', oAxes);
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
        [C iFirstActivationChannel] = min(oActivation.Beats(iBeat).FullActivationTimes);
        hold(oOverlay,'on');
        plot(oOverlay, oUnemap.Electrodes(iFirstActivationChannel).Coords(1), oUnemap.Electrodes(iFirstActivationChannel).Coords(2), ...
            'MarkerSize',5,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
        iBeatCount = iBeatCount + 1;
    end
end
oAxes = oSubplotPanel(3,1).select();
cbarf_edit(aContourRange, aContours,'horiz','linear',oAxes);
oXlabel = text(((aContourRange(2)-aContourRange(1))/2)-abs(aContourRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
set(oXlabel,'fontsize',12);
movegui(oFigure,'center');
% print(oFigure,'-dbmp','-r600',sSavePath)
print(oFigure,'-dps','-r600',sSavePath)
