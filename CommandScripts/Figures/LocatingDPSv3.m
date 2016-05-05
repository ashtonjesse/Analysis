%this script draws a figure with two rows of axes that demonstrate the
%process of determining the site of dominant pacemaker
% version 2 does not have any activation maps
close all;
% clear all;
% % % %open data
% sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\';
% sRecording = 'baro001';
% sSubDir = [sBaseDir,sBaseDir(end-8:end-1),sRecording,'\'];
% 
% % % %% read in the optical entities
% sOpticalFileName = [sSubDir,sRecording,'a_3x3_1ms_g10_LP100Hz-waveEach_forfigure.mat'];
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% sElectrodes = {...
% '12-18' ...
% '15-16' ...
% '17-14' ...
% '19-12' ...
% '22-10' ...
% }; 
% oElectrodes = cell(numel(sElectrodes),1);
% for i = 1:numel(oElectrodes)
%     [oElectrodes{i}, iIndex] = GetElectrodeByName(oOptical,sElectrodes{i});
% end

% % % read in the pressure entity
dWidth = 10;
dHeight = 14;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('v',{0.45,0.55});
aSubplotPanel(1).pack('h',{0.33 0.33 0.33});
aSubplotPanel(2).pack('h',{0.05 0.02 0.93});
aSubplotPanel(2,3).pack(3,3);
aSubplotPanel.margin = [1 1 1 1]; %left bottom right top
aSubplotPanel(1).margin = [5 5 0 0];
aSubplotPanel(2).margin = [0 0 0 0];
aSubplotPanel.fontsize = 6;

%plot beat 37
iBeat = 37;
iFrames = [30,31,32,33,34,35,36,37,38];
iPrefix = 0; 
iSuffix = 0;
XLim = [8.505 8.6];
YScale = 2800;
iScatterSize = 25;
iAxesOffset = 0.07;
movegui(oFigure,'center');
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\Working\LocatingDPS_#';
sSchematicPath = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\20140821Schematic.bmp';
sSchematicPathNoScale = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\20140821Schematic_noscale_noholes.bmp';
 
iPanel = 2;

if iPanel == 1
    %% plot schematic
    aSubplotPanel(1,1).pack('v',2);
    oImageAxes = aSubplotPanel(1,1,1).select();
    imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140821\ImageForFigure.png','Parent', oImageAxes, 'Border', 'tight');
    set(oImageAxes,'box','off','color','none');
    axis(oImageAxes,'tight');
    axis(oImageAxes,'off');
    
    %% plot electrode
    oAxes = aSubplotPanel(1,2).select();
    oBaseAxes = oAxes;
    for i = 1:numel(oElectrodes)
        aData = oElectrodes{i}.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        plot(oAxes,aTime,aData,'k-','linewidth',1);
        hold(oAxes,'on');
        aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        aBeatData = oElectrodes{i}.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        %plot activation time
        oLine = scatter(oAxes,aBeatTime(oElectrodes{i}.aghsm.Index(iBeat)), aBeatData(oElectrodes{i}.aghsm.Index(iBeat)),iScatterSize,'k','filled');
        set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        %set axes limits
        xlim(oAxes,XLim);
        YLim = [min(aData)-200 min(aData)+YScale-200];
        ylim(oAxes,YLim);
        set(oAxes,'box','off');
        axis(oAxes,'off');
        %label electrode
        if i == 3
            text(XLim(1)-0.01,min(aData)+YScale/12,sprintf('%1.0f-DPS',numel(oElectrodes)-i+1),'color','k','fontsize',6,'horizontalalignment','left','parent',oAxes);
        else
            text(XLim(1)-0.01,min(aData)+YScale/12,num2str(numel(oElectrodes)-i+1),'color','k','fontsize',6,'horizontalalignment','left','parent',oAxes);
        end
        if i ~= numel(oElectrodes)
            oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
        end
    end
    %% create time scale
    hold(oBaseAxes,'on');
    oLine = plot(oBaseAxes,[aBeatTime(oElectrodes{1}.aghsm.Index(iBeat)) aBeatTime(oElectrodes{1}.aghsm.Index(iBeat))+0.02],...
        [YLim(1)-700 YLim(1)-700],'k-','linewidth',2);
    text(aBeatTime(oElectrodes{1}.aghsm.Index(iBeat))+0.01,YLim(1)-800,'20 ms','parent',oBaseAxes,'horizontalalignment','center','fontsize',8);
    hold(oBaseAxes,'off');
    
    %% plot box around upstrokes
    iWidth = 0.026;
    BoxLim = [XLim(1)+0.012 XLim(1)+0.012+iWidth];
    figpos = dsxy2figxy(oBaseAxes, [BoxLim(1) YLim(1)-650 iWidth YScale-200]);
    annotation('rectangle',figpos,'linestyle','--','facecolor','none','edgecolor','k')
    [figx figy] = dsxy2figxy(oBaseAxes, [BoxLim(2) ; 8.605],[YLim(2)-100;YLim(2)-100]);
    annotation('arrow',figx,[0.97 0.97],'headstyle','plain','headwidth',4,'headlength',4);
    
    
    %% set xlim
    XLim = [XLim(1)+0.012 XLim(1)+0.012+iWidth];
    
    %% Plot upstroke1
    oAxes = aSubplotPanel(1,3).select();
    oBaseAxes = oAxes;
    for i = 1:numel(oElectrodes)
        aData = oElectrodes{i}.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        aIndices = XLim(1) <= aTime & XLim(2) >= aTime;
        plot(oAxes,aTime(aIndices),aData(aIndices),'k-','linewidth',1);
        hold(oAxes,'on');
        aBeatTime = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        aBeatData = oElectrodes{i}.Processed.Data(oOptical.Beats.Indexes(iBeat,1):oOptical.Beats.Indexes(iBeat,2));
        %plot activation time
        oLine = scatter(oAxes,aBeatTime(oElectrodes{i}.aghsm.Index(iBeat)), aBeatData(oElectrodes{i}.aghsm.Index(iBeat)),iScatterSize,'k','filled');
        set(get(get(oLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        %plot lines for frame references
        oLine = plot(oAxes,[aBeatTime(iFrames(1)) aBeatTime(iFrames(1))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
        oLine = plot(oAxes,[aBeatTime(iFrames(5)) aBeatTime(iFrames(5))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
        oLine = plot(oAxes,[aBeatTime(iFrames(end)) aBeatTime(iFrames(end))],[min(aBeatData) max(aBeatData)],'linestyle','--','color',[0.5 0.5 0.5]);
        %label lines
        if i == numel(oElectrodes)
            text([aBeatTime(iFrames(1)) aBeatTime(iFrames(5)) aBeatTime(iFrames(end))],...
                [max(aBeatData) max(aBeatData) max(aBeatData)],{'E1','E5',sprintf('E%1.0f',numel(iFrames))},'horizontalalignment','center','fontsize',8);
        end
        hold(oAxes,'off');
        %set axes limits
        xlim(oAxes,XLim);
        YLim = [min(aData)-200 min(aData)+YScale-200];
        ylim(oAxes,YLim);
        set(oAxes,'box','off');
        axis(oAxes,'off');
        %label electrode
        if i == 3
            text(XLim(1)+0.001,min(aData)+YScale/12,sprintf('%1.0f-DPS',numel(oElectrodes)-i+1),'color','k','fontsize',6,'horizontalalignment','left','parent',oAxes);
        else
            text(XLim(1)+0.001,min(aData)+YScale/12,num2str(numel(oElectrodes)-i+1),'color','k','fontsize',6,'horizontalalignment','left','parent',oAxes);
        end
        if i ~= numel(oElectrodes)
            oAxes = axes('parent',oFigure,'color','none','position',get(oAxes,'position')+[0 iAxesOffset 0 0]);
        end
    end
    
    %% put on scale
    hold(oBaseAxes,'on');
    oLine = plot(oBaseAxes,[aBeatTime(oElectrodes{1}.aghsm.Index(iBeat)) aBeatTime(oElectrodes{1}.aghsm.Index(iBeat))+0.01],...
        [YLim(1)-700 YLim(1)-700],'k-','linewidth',2);
    text(aBeatTime(oElectrodes{1}.aghsm.Index(iBeat))+0.005,YLim(1)-800,'10 ms','parent',oBaseAxes,'horizontalalignment','center','fontsize',8);
    hold(oBaseAxes,'off');
    
    % %% create rectangle to surround upstrokes
    figpos = dsxy2figxy(oBaseAxes, [BoxLim(1) YLim(1)-650 iWidth YScale-200]);
    annotation('rectangle',figpos,'linestyle','--','facecolor','none','edgecolor','k')
    
    %% plot activation map
    aContourRange = [0 10.8];
    aContours = aContourRange(1):1.2:aContourRange(2);
    %get the interpolation points
    aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
    aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
    oActivation = oOptical.PrepareActivationMap(100, 'Contour', 'abhsm', 24, iBeat, []);
    aSubplotPanel(1,1,2).pack('v',{0.9 0.1});
    aSubplotPanel(1,1).margin = [2 2 0 0];

    oAxes = aSubplotPanel(1,1,2,1).select();
    oOverlay = axes('position',get(oAxes,'position'));
    oPointAxes = axes('position',get(oAxes,'position'));
    %plot the schematic
    oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
    %make it transparent in the right places
    aCData = get(oImage,'cdata');
    aBlueData = aCData(:,:,3);
    aAlphaData = aCData(:,:,3);
    aAlphaData(aBlueData < 100) = 1;
    aAlphaData(aBlueData > 100) = 1;
    aAlphaData(aBlueData == 100) = 0;
    aAlphaData = double(aAlphaData);
    set(oImage,'alphadata',aAlphaData);
    set(oOverlay,'box','off','color','none');
    axis(oOverlay,'tight');
    axis(oOverlay,'off');
    [C, oContour] = contourf(oAxes,oActivation.x,oActivation.y,oActivation.Beats(iBeat).z,aContours);
    caxis(oAxes,aContourRange);
    colormap(oAxes, colormap(flipud(colormap(jet))));
    % %plot points
    aElectrodes = cell2mat(oElectrodes);
    aCoords = cell2mat({aElectrodes(:).Coords});
    scatter(oPointAxes, aCoords(1,:), aCoords(2,:), 'sizedata',16,'Marker','+','MarkerEdgeColor','k');
    text(aCoords(1,[1,numel(aElectrodes)])+[0.3,-0.3], ...
        aCoords(2,[1,numel(aElectrodes)])+[-0.3,0.3],{num2str(numel(aElectrodes)),'1'},'color','k','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
    axis(oAxes,'equal');
    set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oAxes,'off');
    axis(oPointAxes,'equal');
    set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
    axis(oPointAxes,'off');
    
    %% draw color bar
    aSubplotPanel(1,1,2,2).pack('h',{0.01 0.99});
    oAxes = aSubplotPanel(1,1,2,2,2).select();
    aCRange = [0 10.8];
    aContours = 0:1.2:10.8;
    cbarf_edit(aCRange, aContours,'horizontal','nonlinear',oAxes,'AT',6);
    aCRange = [0 12];
    oLabel = text((aCRange(2)-aCRange(1))/2,-2,'Activation time (ms)','parent',oAxes,'fontsize',8,'fontweight','normal','horizontalalignment','center');
    
    
    %% label panels
    annotation('textbox',[0.01,0.89,0.1,0.1],'string','A','edgecolor','none','fontsize',12,'fontweight','bold');
    annotation('textbox',[0.01,0.69,0.1,0.1],'string','B','edgecolor','none','fontsize',12,'fontweight','bold');
    annotation('textbox',[0.3,0.89,0.1,0.1],'string','C','edgecolor','none','fontsize',12,'fontweight','bold');
    annotation('textbox',[0.68,0.89,0.1,0.1],'string','D','edgecolor','none','fontsize',12,'fontweight','bold');
    
    % % %     print
    sThisFile = [strrep(sSavePath,'#','1'),'.png'];
    export_fig(sThisFile,'-png','-r600','-nocrop');
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sThisFile)});
    sChopString = strcat(sChopString, {' -gravity South -chop 0x1700'}, {sprintf(' %s',sThisFile)});
    sStatus = dos(char(sChopString{1}));
elseif iPanel == 2
    %% plot Vm fields
    oPotential = oOptical.PreparePotentialMap(100, iBeat, 'abhsm', []);
    iRow = 1;
    iCol = 1;
    for i = 1:numel(iFrames)
        oAxes = aSubplotPanel(2,3,iRow,iCol).select();
        aContourRange = [-0.1 1];
        aContours = aContourRange(1):0.1:aContourRange(2);
        %get the interpolation points
        aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
        aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);
        oOverlay = axes('position',get(oAxes,'position'));
        oPointAxes = axes('position',get(oAxes,'position'));
        %plot the schematic
        if i > 1
            oImage = imshow(sSchematicPathNoScale,'Parent', oOverlay, 'Border', 'tight');
        else
            oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
        end
        %make it transparent in the right places
        aCData = get(oImage,'cdata');
        aBlueData = aCData(:,:,3);
        aAlphaData = aCData(:,:,3);
        aAlphaData(aBlueData < 100) = 1;
        aAlphaData(aBlueData > 100) = 1;
        aAlphaData(aBlueData == 100) = 0;
        aAlphaData = double(aAlphaData);
        set(oImage,'alphadata',aAlphaData);
        set(oOverlay,'box','off','color','none');
        axis(oOverlay,'tight');
        axis(oOverlay,'off');
        [C, oContour] = contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),oPotential.Beats(iBeat).Fields(iFrames(i)).z,aContours);
        caxis(oAxes,aContourRange);
        colormap(oAxes, colormap(jet));
        if i == 1
            % %plot points
            scatter(oPointAxes, aCoords(1,:), aCoords(2,:), ...
                'sizedata',16,'Marker','+','MarkerEdgeColor','w');
            text(aCoords(1,[1,numel(aElectrodes)])+[0.3,-0.3], aCoords(2,[1,numel(aElectrodes)])+[-0.3,0.3],{num2str(numel(aElectrodes)),'1'},'color','w','parent',oPointAxes,'fontsize',6,'horizontalalignment','center');
        end
        axis(oAxes,'equal');
        set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oAxes,'off');
        axis(oPointAxes,'equal');
        set(oPointAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
        axis(oPointAxes,'off');
        %label frame
        text(aXlim(1),aYlim(2)-0.5,sprintf('E%1.0f',i),'fontsize',12,'fontweight','bold');
        %label time
        text(aXlim(2)-0.5,aYlim(1)+2,sprintf('%1.1f ms',(aBeatTime(iFrames(i))-aBeatTime(iFrames(1)))*1000),'fontsize',8,'horizontalalignment','right');
        iCol = iCol + 1;
        if ~mod(i,3)
            iRow = iRow + 1;
            iCol = 1;
        end
    end
    %% draw color bar
    aSubplotPanel(2,2).pack('v',{0.3 0.4});
    oAxes = aSubplotPanel(2,2,2).select();
    aCRange = [0 1];
    aContours = 0:0.1:1;
    cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'Vm_n',8);
    aCRange = [0 1];
    oLabel = text(-1.5,(aCRange(2)-aCRange(1))/2,'Normalised F.I.','parent',oAxes,'fontunits','points','fontweight','normal','horizontalalignment','center','rotation',90);
    set(oLabel,'fontsize',8);
    
    % % %% print
    sThisFile = [strrep(sSavePath,'#','2'),'.png'];
    set(oFigure,'resizefcn',[]);
    export_fig(sThisFile,'-png','-r600','-nocrop');%
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sThisFile)});
    sChopString = strcat(sChopString, {' -gravity North -chop 0x1500'}, {sprintf(' %s',sThisFile)});
    sStatus = dos(char(sChopString{1}));
    sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s.png',strrep(sSavePath, '#', '1'))}, ...
        {sprintf(' %s.png',strrep(sSavePath, '#', '2'))}, {' -append'}, {sprintf(' %s.png', strrep(sSavePath, '_#', ''))});
    sStatus = dos(char(sChopString{1}));
end
