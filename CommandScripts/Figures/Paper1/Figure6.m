%this script plots three activation maps in a column with the scale bar
%down the side

close all;
% clear all;
% % % % % % % %Read in the file containing all the optical data
% oOpticalEntities{1} = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\baro006_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');
% oOpticalEntities{2} = oOpticalEntities{1};
% oOpticalEntities{3} = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\baro007_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');

%set variables
dWidth = 4.2;
dHeight = 7.2;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure6\20140703ActivationMapExamples.eps';

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
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',{0.08,0.92});
oSubplotPanel(1).pack('v',{0.1,0.8,0.1});
oSubplotPanel(2).pack('v',3);
movegui(oFigure,'center');
oSubplotPanel.margin = [5,0,0,0];
oSubplotPanel.de.margin = [5 0 0 0];%[left bottom right top]

%set parameters
iBeats = [4,58,61];
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
dTextXAlign = 0;
iFileCount = 1;
iCount = 1;

aColorStrings = {'b','r'};
%loop through beats
oActivation = oOptical.PrepareEventData(100, 'Contour', 'arsps', iBeats(1), []);
for i = 1:numel(iBeats)
    oOptical = oOpticalEntities{i};
    aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
    aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
    oActivation = GetEventMap(oOptical, oActivation, iBeats(i));
    oAxes = oSubplotPanel(2,i).select();
    %plot the schematic
    oOverlay = axes('position',get(oAxes,'position'));
    colormap(oOverlay,flipud(jet));
    set(oOverlay,'box','off','color','none');
    if i == 3
        oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140703\20140703Schematic_noholes_highres.bmp','Parent', oOverlay, 'Border', 'tight');
    else
        oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140703\20140703Schematic_noholes_highres_noscale.bmp','Parent', oOverlay, 'Border', 'tight');
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
    
    %plot the origin star
    oOriginAxes = axes('position',get(oAxes,'position'));
    aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
    aOriginCoords = cell2mat({oOptical.Electrodes(aOriginData(iBeats(i),:)).Coords});
    if ~isempty(aOriginCoords)
        scatter(oOriginAxes, aOriginCoords(1,:), aOriginCoords(2,:), ...
            'sizedata',144,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
    end
    %plot the activation time data
    [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeats(i)).z,aContours);
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oAxes,'off');
    axis(oOriginAxes,'equal');
    set(oOriginAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oOriginAxes,'off');
    caxis(oAxes,aContourRange);
    cmap = colormap(oAxes, flipud(jet));
end
oAxes = oSubplotPanel(1,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',8);
aCRange = [0 12];
oLabel = text(-3.5,(aCRange(2)-aCRange(1))/2,'Atrial activation time (ms)','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',8);
print(sFileSavePath,'-dpsc2','-r600','-painters')