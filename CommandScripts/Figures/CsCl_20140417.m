%this plots the figure demonstrating RSA, TH waves etc in the results
%section of the methods chapter
% clear all;
close all;
%set variables
dWidth = 16;
dHeight = 8;
sRecordingType = 'Extracellular';
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140417\20140417baro001\baro001_pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140417\20140417baro004\baro004_pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140417\20140417baro007\baro007_pressure.mat' ...
    };
% % %load the data
% oPressureEntities = cell(numel(aFiles),1);
% for i = 1:numel(aFiles)
%     oPressureEntities{i} = GetPressureFromMATFile(Pressure,aFiles{i},sRecordingType);
% end

%create figure
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
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',3);
oSubplotPanel.margin = [15 5 5 10];
oSubplotPanel(1).margin = [5 5 0 0];
oSubplotPanel(2).margin = [5 5 0 0];
oSubplotPanel(3).margin = [5 5 0 0];

oSubplotPanel.de.fontsize = 6;
oSubplotPanel.de.fontweight = 'normal';
movegui(oFigure,'center');
dXOffset = 7;
for i = 1:numel(aFiles)
    oSubplotPanel(i).pack('v',3);
    %plot pressure
    oAxes = oSubplotPanel(i,1).select();
    oPressure = oPressureEntities{i};
    aData = oPressure.(oPressure.Status).Data;
    aTime = oPressure.TimeSeries.(oPressure.TimeSeries.Status);
    hline = plot(oAxes,aTime,aData,'k');
    set(hline,'linewidth',1);
    %set axes colour
    set(oAxes,'xcolor',[1 1 1]);
    set(oAxes,'xtick',[]);
    set(oAxes,'xticklabel',[]);
    set(oAxes,'yminortick','on');
    %set limits
    xlim(oAxes,[0 30]);
    oXLim = get(oAxes,'xlim');
    ylim(oAxes,[65 150]);
    if i == 1
        %set labels
        oYlabel = ylabel(oAxes,['Perfusion', 10, 'Pressure', 10, '(mmHg)']);
        set(oYlabel,'rotation',0);
        oPosition = get(oYlabel,'position');

        oPosition(1) = oXLim(1) - dXOffset;
        oYLim = get(oAxes,'ylim');
        oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
        set(oYlabel,'position',oPosition);
    else
        axis(oAxes,'off');
    end
    
    %plot phrenic integral
    oAxes = oSubplotPanel(i,2).select();
    aData = oPressure.oPhrenic.Electrodes.Processed.Integral;
    aTime = oPressure.TimeSeries.Processed;
    plot(oAxes,aTime, aData, 'k');
    %set axes colour
    set(oAxes,'xcolor',[1 1 1]);
    set(oAxes,'xtick',[]);
    set(oAxes,'xticklabel',[]);
    set(oAxes,'yminortick','on');
    set(hline,'linewidth',0.5);
    %set limits
    ylim(oAxes,[40 165]);
    xlim(oAxes,oXLim);
    if i == 1
        %set labels
        oYlabel = ylabel(oAxes,['PND', 10, '(\muV)']);
        set(oYlabel,'rotation',0);
        oPosition = get(oYlabel,'position');
        oPosition(1) = oXLim(1) - dXOffset;
        oYLim = get(oAxes,'ylim');
        oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
        set(oYlabel,'position',oPosition);
        axis(oAxes,'off');
        text(oPosition(1),oPosition(2)+25,['\intPND &',10,'ECG'],'fontsize',6,'horizontalalignment','center');
    else
        axis(oAxes,'off');
    end
    
    %plot Heart rate
    oAxes = oSubplotPanel(i,3).select();
    aData = oPressure.oPhrenic.Electrodes.Processed.BeatRateData;
    aTime = oPressure.oPhrenic.TimeSeries;
    hline = plot(oAxes,aTime, aData, 'k');
    set(hline,'linewidth',1);
    %set axes colour
    set(oAxes,'xcolor',[1 1 1]);
    set(oAxes,'xtick',[]);
    set(oAxes,'xticklabel',[]);
    set(oAxes,'yminortick','on');
    %set limits
    ylim(oAxes,[50 400]);
    xlim(oAxes,oXLim);
    if i == 1
        %set labels
        oYlabel = ylabel(oAxes,['Heart', 10, 'Rate', 10, '(bpm)']);
        set(oYlabel,'rotation',0);
        oPosition = get(oYlabel,'position');
        oPosition(1) = oXLim(1) - dXOffset;
        oYLim = get(oAxes,'ylim');
        oPosition(2) = oYLim(1) + (oYLim(2) - oYLim(1)) / 4;
        set(oYlabel,'position',oPosition);
        %put on time scale
        oOverlay = axes('parent',oFigure,'position',get(oAxes,'position')-[-0.02 0.05 0 0],'color','none');
        plot(oOverlay,[0 5],[oYLim(1)+50 oYLim(1)+50],'k-','linewidth',1.5);
        text(2.5,oYLim(1)+10,'5 s','fontsize',6,'parent',oOverlay,'horizontalalignment','center');
        axis(oOverlay,'off');
        xlim(oOverlay,oXLim);
        oYLim  = get(oAxes,'ylim');
        ylim(oOverlay,oYLim);
    else
        axis(oAxes,'off');
    end

end
%annotate
annotation('textbox',[0.17,0.9,0.1,0.1],'string','Baseline','fontsize',12,'fontweight','bold','edgecolor','none');
annotation('textbox',[0.48,0.9,0.1,0.1],'string','CsCl','fontsize',12,'fontweight','bold','edgecolor','none');
annotation('textbox',[0.78,0.9,0.1,0.1],'string','Washout','fontsize',12,'fontweight','bold','edgecolor','none');



%% print figure
export_fig('D:\Users\jash042\Documents\PhD\Thesis\Figures\CsCl_20140417.png','-png','-r600','-nocrop','-painters');