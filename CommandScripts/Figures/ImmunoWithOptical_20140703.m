% this panel has three plots stacked vertically. In the top one there is an
% image of VAChT labelling in a whole mount preparation of RA, in the lower
% two there are corresponding optical maps for beats emanating from two
% locations.

close all;
% clear all;
% % % % % %Read in the file containing all the optical data
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\baro006_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');
% [oElectrode1, iIndex1] = GetElectrodeByName(oOptical,'26-9');
% [oElectrode2, iIndex2] = GetElectrodeByName(oOptical,'11-12');

%set variables
dWidth = 16;
dHeight = 20;
sThesisFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\Working\ImmunoWithOptical_20140703.png';

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
oSubplotPanel.pack('h',{0.02,0.6,0.35});
oSubplotPanel(1).pack('v',{0.45,0.4,0.1});
oSubplotPanel(2).pack('v',3);
oSubplotPanel(3).pack('v',3);
movegui(oFigure,'center');
oSubplotPanel.margin = [12,5,2,2];
oSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
oSubplotPanel(1).margin = [0 5 0 0];

%set parameters
iBeats = [4,50];
aContourRange = [0 12];
aContours = aContourRange(1):1.2:aContourRange(2);
dTextXAlign = 0;
iFileCount = 1;
iCount = 1;
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
aColorStrings = {'b','r'};
%loop through beats
for i = 1:2
        oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'arsps', 24, iBeats(i), []);
        oAxes = oSubplotPanel(2,i+1).select();
        %plot the schematic
        oOverlay = axes('position',get(oAxes,'position'));
        colormap(oOverlay,flipud(jet));
        set(oOverlay,'box','off','color','none');
        oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140703\20140703Schematic_v2.bmp','Parent', oOverlay, 'Border', 'tight');
        
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
                'sizedata',324,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        %plot the recording points
        hold(oOriginAxes,'on');
        scatter(oOriginAxes, [oElectrode1.Coords(1),oElectrode2.Coords(1)], [oElectrode1.Coords(2),oElectrode2.Coords(2)], ...
            'sizedata',164,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
        text([oElectrode1.Coords(1)], [oElectrode1.Coords(2)],'1',...
            'color',aColorStrings{1},'parent',oOriginAxes,'fontsize',10,'horizontalalignment','center','fontweight','bold');
        text([oElectrode2.Coords(1)], [oElectrode2.Coords(2)],'2',...
            'color',aColorStrings{2},'parent',oOriginAxes,'fontsize',10,'horizontalalignment','center','fontweight','bold');
        
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
        %plot the alignment points if needed
        %         dRes = oOptical.oExperiment.Optical.SpatialResolution;
        %         oPlot = oAxes;
        %         for n = 1:numel(oOptical.ReferencePoints)
        %             hold(oPlot,'on');
        %             plot(oPlot,oOptical.ReferencePoints(n).Line1(1:2)*dRes, ...
        %                 oOptical.ReferencePoints(n).Line1(3:4)*dRes, '-k','LineWidth', 2)
        %             plot(oPlot,oOptical.ReferencePoints(n).Line2(1:2)*dRes, ...
        %                 oOptical.ReferencePoints(n).Line2(3:4)*dRes, '-k','LineWidth', 2)
        %             hold(oPlot,'off');
        %         end
        
        %plot the electrode traces for the selected beats
        oElectrodeAxes = oSubplotPanel(3,i+1).select();
        %get data
        aDataToPlot = oOptical.NormaliseDataToPeak(oElectrode1.Processed.Data(oOptical.Beats.Indexes(iBeats(i),1):oOptical.Beats.Indexes(iBeats(i),2)));
        aTimeToPlot = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeats(i),1):oOptical.Beats.Indexes(iBeats(i),2));
        %plot data
        plot(oElectrodeAxes,aTimeToPlot,aDataToPlot,aColorStrings{1},'linewidth',1);
        %plot activation time
        hold(oElectrodeAxes,'on');
        oLine = scatter(oElectrodeAxes,aTimeToPlot(oElectrode1.arsps.Index(iBeats(i))), aDataToPlot(oElectrode1.arsps.Index(iBeats(i))),64,aColorStrings{1},'filled');
        hold(oElectrodeAxes,'off');
        %set axes limits
        currentxlim = get(oElectrodeAxes,'xlim');
        set(oElectrodeAxes,'ylim',[-1.3 1],'xlim',currentxlim-[0 0.1]+[0.01 0]);
        axis(oElectrodeAxes,'off');
        %create 2nd axes for next electrode
        oFloatingAxes = axes('position',get(oElectrodeAxes,'position')-[0 0.1 0 0],'color','none');
        %get data
        aDataToPlot = oOptical.NormaliseDataToPeak(oElectrode2.Processed.Data(oOptical.Beats.Indexes(iBeats(i),1):oOptical.Beats.Indexes(iBeats(i),2)));
        %plot data
        plot(oFloatingAxes,aTimeToPlot,aDataToPlot,aColorStrings{2},'linewidth',1);
        %plot activation time
        hold(oFloatingAxes,'on');
        oLine = scatter(oFloatingAxes,aTimeToPlot(oElectrode2.arsps.Index(iBeats(i))), aDataToPlot(oElectrode2.arsps.Index(iBeats(i))),64,aColorStrings{2},'filled');
        hold(oFloatingAxes,'off');
        %set axes limits
        set(oFloatingAxes,'ylim',[-1.3 1],'xlim',get(oElectrodeAxes,'xlim'));
        currentxlim = get(oFloatingAxes,'xlim');
        %plot timescale
        hold(oFloatingAxes,'on');
        plot(oFloatingAxes,[currentxlim(1) currentxlim(1)+0.02],[-0.54 -0.54],'k','linewidth',4);
        hold(oFloatingAxes,'off');
        axis(oFloatingAxes,'off');
        if i == 1
            %store the axes limits
            xlimits = get(oElectrodeAxes,'xlim');
        end
end
currentxlim = get(oElectrodeAxes,'xlim');
set(oElectrodeAxes,'xlim',[currentxlim(1) currentxlim(1)+xlimits(2)-xlimits(1)]);
oAxes = oSubplotPanel(1,2).select();
aCRange = [0 10.8];
aContours = 0:1.2:10.8;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',10);
aCRange = [0 12];
oLabel = text(-2.8,(aCRange(2)-aCRange(1))/2,'Atrial AT (ms)','parent',oAxes,'fontunits','points','fontweight','bold','horizontalalignment','center','rotation',90);
set(oLabel,'fontsize',10);
export_fig(sThesisFileSavePath,'-png','-r600','-nocrop')