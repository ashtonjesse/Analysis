%figure for HRS 2017 abstract

%create layout
%load data
%plot data
%save to file as gif

close all;
% clear all;
% % % % %Read in the file containing all the optical data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\';
% sSubDir = [sBaseDir,'20140723baro004\'];
% 
% %% read in the optical entities
% sAvOpticalFileName = [sSubDir,'baro004_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
% oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
% sOpticalFileName = [sSubDir,'baro004_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
% oThisPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

%set variables
dWidth = 8;
dHeight = 8;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Conferences\2017\HRS\OpticalActivation_20140723baro004.gif';

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
xrange = 3;
yrange = 2;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('v',{0.3,0.7});
oSubplotPanel(1).pack('h',{0.1,0.9});
oSubplotPanel(1,2).pack(2);
oSubplotPanel(2).pack('h',{0.03,0.97});
oSubplotPanel(2,2).pack(yrange,xrange);
oSubplotPanel(2,1).pack('v',{0.2,0.65});

movegui(oFigure,'center');
oSubplotPanel.margin = [10,2,2,2];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
oSubplotPanel(1).de.margin = [0 3 0 0];
oSubplotPanel.de.fontsize = 6;
oSubplotPanel(2).margin = [0 0 0 10];
oSubplotPanel(2,2).de.margin = [0 4 0 0];

%% plot top panel
dlabeloffset = 4.5;

%plot HR
oAxes = oSubplotPanel(1,2,2).select();
%convert rates into coupling intervals
aCouplingIntervals = 60000 ./ [NaN oThisPressure.oRecording(1).Electrodes.Processed.BeatRates];
aTimes = oThisPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
scatter(oAxes,aTimes,aCouplingIntervals,9,'k','filled');
%set axes colour
set(oAxes,'yminortick','on');

%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[150 550]);
%set labels
oYlabel = ylabel(oAxes,['Atrial',10,'Cycle',10,'Length', 10, '(ms)']);
set(oYlabel,'fontsize',6);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1)-50;% + (oYLim(2) - oYLim(1)) / 10
set(oYlabel,'position',oPosition);
iBeats = [34,50,51,71,72,90];
sLabels = {'a','b','c','d','e','f'};
dIncremements = [100,-100,100,180,100,100];
dLineIncrements = [30,-30,20,30,30,30];
dLineAngle = [0,0,0,0,0,0,0];
hold(oAxes,'on');
for k = 1:numel(iBeats)
    iIndex = iBeats(k);% + 1; %mapping between beats in pressure and beats in optical
    oBeatLabel = text(aTimes(iIndex)+dLineAngle(k), ...
        aCouplingIntervals(iIndex)+dIncremements(k), sLabels{k},'parent',oAxes, ...
        'FontWeight','bold','FontUnits','points','horizontalalignment','center');
    set(oBeatLabel,'FontSize',6);
    
    oLine = plot(oAxes,[aTimes(iIndex) aTimes(iIndex)+dLineAngle(k)],...
        [aCouplingIntervals(iIndex)+dLineIncrements(k) aCouplingIntervals(iIndex)+dIncremements(k)-dLineIncrements(k)],'-','linewidth',0.5);
    set(oLine,'color',[0.5 0.5 0.5]);
    
end
oXlabel = xlabel(oAxes,'Time (s)');
oPosition = get(oXlabel,'position');
set(oXlabel,'position',oPosition + [0 30 0]);
set(oXlabel,'fontsize',6);
aXticklabels = str2num(get(oAxes,'xticklabel'))-5;
set(oAxes,'xticklabel',num2str(aXticklabels));
set(oAxes,'tickdir','out');

%plot pressure data
oAxes = oSubplotPanel(1,2,1).select();
aData = oThisPressure.Processed.Data;
aTime = oThisPressure.TimeSeries.Processed;
hline = plot(oAxes,aTime,aData,'k');
set(hline,'linewidth',0.5);
%set axes colour
set(oAxes,'xticklabel',[]);
%set limits
xlim(oAxes,oXLim);
ylim(oAxes,[70 120]);
%set labels
oYlabel = ylabel(oAxes,['Mean',10,'Perfusion',10,'Pressure', 10, '(mmHg)']);
set(oYlabel,'fontsize',6);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = oXLim(1) - dlabeloffset;
oYLim = get(oAxes,'ylim');
oPosition(2) = oYLim(1);% + (oYLim(2) - oYLim(1)) / 3;
set(oYlabel,'position',oPosition);
set(oAxes,'tickdir','out');
% %plot maps
%plot the schematic
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
%get the interpolation points
dTextXAlign = 0;
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
iCount = 0;
for i = 1:yrange
    for j = 1:xrange
        iCount = iCount + 1;
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'arsps', 24, iBeats(iCount), []);
        oAxes = oSubplotPanel(2,2,i,j).select();
             %plot the schematic
        oOverlay = axes('position',get(oAxes,'position'));
        
        set(oOverlay,'box','off','color','none');
        if iCount == 1
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_noholes.bmp','Parent', oOverlay, 'Border', 'tight');
        else
            oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_noholes_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
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
        aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats(iCount),:)).Coords});
        if ~isempty(aOriginCoords)
            scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
                'sizedata',64,'Marker','p','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for poster
        end
        if i==1 && j==2
            hold(oOriginAxes,'on');
            scatter(oOriginAxes, aXlim(1)+0.8, aYlim(1)-0.5, ...
                'sizedata',64,'Marker','p','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for poster
            oLabel = text(aXlim(1)+1.2,aYlim(1)-0.5,'= dominant pacemaker site','parent',oOriginAxes,'fontunits','points','HorizontalAlignment','left');
            set(oLabel,'fontsize',6);
        end
        [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats(iCount)).z,aContours);
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        axis(oOriginAxes,'equal');
        set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oOriginAxes,'off');
        cmap = colormap(oAxes, flipud(hot(aContourRange(2)-aContourRange(1))));
        caxis(oAxes,aContourRange);
               
   
        
        if (i == 1) && (j == 1)
            %create labels
            oLabel = text(aXlim(1)+0.8,aYlim(2)-3.5,'SVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',6);
            oLabel = text(aXlim(2)-0.5,aYlim(1)+0.5,'IVC','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',6);
            oLabel = text(aXlim(1)+6,aYlim(2)-5.3,'CT','parent',oAxes,'fontunits','points','HorizontalAlignment','right');
            set(oLabel,'fontsize',6,'color','w');
            oLabel = text(aXlim(2)-4.8,aYlim(1)-0.5,'2 mm','parent',oAxes,'fontunits','points','HorizontalAlignment','center');
            set(oLabel,'fontsize',6);
        end
        % % %         label beat number, rate and pressure
        % % %         get pressure
        oLabel = text(aXlim(1)+1,aYlim(2)-0.5,sLabels{iCount},'parent',oAxes,'fontweight','bold','fontunits','points','HorizontalAlignment','left');
        set(oLabel,'fontsize',8);
    end
end

oAxes = oSubplotPanel(2,1,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',6);
aCRange = [0 12];
oLabel = text(-2.8,(aCRange(2)-aCRange(1))/2,'Right atrial activation time (ms)','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',6);


% oSubplotPanel(3).pack('h',{0.1,0.8});
% oAxes = oSubplotPanel(3,2).select();
% aCRange = [0 10.8];
% aContours = 0:1.2:10.8;
% cbarf_edit(aCRange, aContours,'horiz','nonlinear',oAxes,'AT');
% aCRange = [0 12];
% oXlabel = text(((aCRange(2)-aCRange(1))/2)+(aCRange(1)),-2.2,'Activation Time (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center');
% set(oXlabel,'fontsize',6);
% sCaption = [...
%     'Example of increase in cycle length during baroreflex stimulation by perfusion ',10, ...
%     'pressure challenge: Representative maps of atrial activation time are shown for',10, ...
%     'beats before (a), during (b) and after (c) the inferior shift in leading pacemaker site', 10,...
%     '(black star). Phrenic nerve discharge provides an index of inspiratory motor drive.',10,...
%     'SVC: superior vena cava; IVC: inferior vena cava; CT: crista terminalis.'];
% oXlabel = text(((aCRange(2)-aCRange(1))/2)+(aCRange(1))+0.5,-6,sCaption,'parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center');
% set(oXlabel,'fontsize',5);
% print(oFigure,'-dbmp','-r600',sSavePath)
set(oFigure,'resizefcn',[]);
printgif(oFigure,'-r300',sFileSavePath)