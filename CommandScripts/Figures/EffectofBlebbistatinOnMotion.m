close all;
% clear all;

dWidth = 16;
dHeight = 6;
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

aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',2);
aSubplotPanel.margin = [15 10 2 10];%left bottom right top
aSubplotPanel.de.fontsize = 8;
movegui(oFigure,'center');

oFirstAxes = aSubplotPanel(1).select();
oOverlay = axes('position',get(oFirstAxes,'position'),'parent',oFigure);
oAxes = [oFirstAxes,oOverlay];
%get data
sFiles = {...
'G:\PhD\Experiments\Auckland\InSituPrep\20140526\test001-wave.csv' ...    
'G:\PhD\Experiments\Auckland\InSituPrep\20140526\test002-wave.csv' ...
};

% aData = cell(numel(sFiles),1);
aRange = [0.7391 0.9406; 1.548 1.7495];
oColors = {'r','k'};
for i = 1:numel(sFiles)
%     %open the file
%     fid = fopen(sFiles{i},'r');
%     %scan the header information in
%     for j = 1:10;
%         tline = fgets(fid);
%         [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%         switch (splitstring{1})
%             case 'frm num'
%                 iNumFrames = str2double(splitstring{2});
%         end
%     end
%     aData{i} = zeros(iNumFrames,2);
%     %Get activation times
%     for j = 1:iNumFrames;
%         tline = fgets(fid);
%         [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%         aData{i}(j,1) = str2double(splitstring{1});
%         aData{i}(j,2) = str2double(splitstring{2});
%     end
%     fclose(fid);
    
    aTime = aData{i}(:,1)/466.37;
    aPoints = aTime > aRange(i,1) & aTime < aRange(i,2);
    plot(oAxes(i),aTime(aPoints)-aTime(find(aPoints,1,'first')),aData{i}(aPoints,2)-min(aData{i}(aPoints,2)),oColors{i},'linewidth',1.5);
    hold(oAxes(i),'on');
    plot(oAxes(i),aTime(aPoints)-aTime(find(aPoints,1,'first')),aData{i}(aPoints,2)-min(aData{i}(aPoints,2)),oColors{i},'linewidth',1.5);
    axis(oAxes(i),'tight');
    if i == 1
        oYLim = get(oAxes(i),'ylim');
    end
    set(oAxes(i),'ylim',[oYLim(1) - 1, oYLim(2) + 1])
end
set(oAxes(2),'color','none');
axis(oAxes(1),'off');
axis(oAxes(2),'off');
oLegend = legend(oAxes(1),'Pre-BLB','Post-BLB','location','northwest');
legend(oLegend,'boxoff');
set(oLegend,'position',[0.0465    0.6217    0.1700    0.1674]);
oChildren = get(oLegend,'children');
set(oChildren(2),'color','k');
oScaleAxes = axes('position',get(oAxes(1),'position')-[0 0.02 0 0],'parent',oFigure);
plot(oScaleAxes,[0 0.05],[0 0],'k-','linewidth',2);
text(0.025,-30,'50 ms','fontsize',10,'horizontalalignment','center');
set(oScaleAxes,'xlim',get(oAxes(1),'xlim'),'ylim',get(oAxes(1),'ylim'));
axis(oScaleAxes,'off');
set(oScaleAxes,'color','none');
axlim = get(oAxes(1),'xlim');

text(axlim(1),oYLim(2)+35,'A','fontsize',14,'fontweight','bold');
%load files for time comparison
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\baro004_3x3_1ms_7x_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\baro008_3x3_1ms_7x_g10_LP100Hz-waveEach.mat' ...
};
oFirstAxes = aSubplotPanel(2).select();
% aElectrodes = cell(1,numel(aFiles));
% aBeatIndexes = zeros(numel(aFiles),2);
% aTimeSeries = cell(1,numel(aFiles));
% %loop through files
% for i = 1:numel(aFiles)
%     %get file
%     oOptical = GetOpticalFromMATFile(Optical,aFiles{i});
%     %get electrode
%     [aElectrodes{i} iIndex] = GetElectrodeByName(oOptical,'16-7');
%     aBeatIndexes(i,:) = oOptical.Beats.Indexes(2,:);
%     aTimeSeries{i} = oOptical.TimeSeries;
% end
sColors = {'k','b','r'};
for i = 1:numel(aFiles)
    oThisElectrode = aElectrodes{i};
    aDataToPlot = oThisElectrode.Processed.Data(aBeatIndexes(i,1):aBeatIndexes(i,2));
    %normalise
    dBaseLine = min(aDataToPlot);
    aDataToPlot = (aDataToPlot+sign(dBaseLine)*(-1)*abs(dBaseLine));
%     dPeak = max(aDataToPlot);
%     aDataToPlot = aDataToPlot./dPeak;
    %align
    aTimeToPlot = aTimeSeries{i}(aBeatIndexes(i,1):aBeatIndexes(i,2));
    aSlope = oThisElectrode.Processed.Slope(aBeatIndexes(i,1):aBeatIndexes(i,2));
    [val ind] = max(aSlope);
    aTimeToPlot = aTimeToPlot - aTimeToPlot(ind);
    plot(oFirstAxes,aTimeToPlot,aDataToPlot,'linewidth',1.5,'color',sColors{i});
    hold(oFirstAxes,'on');
end
axis(oFirstAxes,'off');
oLegend = legend(oFirstAxes,'40 min','60 min','80 min','location','northeast');
legend(oLegend,'boxoff');
oScaleAxes = axes('position',get(oFirstAxes,'position')-[0 0.02 0 0],'parent',oFigure);
axlim = get(oFirstAxes,'xlim');
plot(oScaleAxes,[0 0.05],[0 0],'k-','linewidth',2);
text(0.025,-30,'50 ms','fontsize',10,'horizontalalignment','center');
set(oScaleAxes,'xlim',get(oFirstAxes,'xlim'),'ylim',get(oAxes(1),'ylim'));
axis(oScaleAxes,'off');
set(oScaleAxes,'color','none');
%put panel label
aylim = get(oAxes(1),'ylim');
text(axlim(1),aylim(2)+30,'B','fontsize',14,'fontweight','bold');
print(oFigure,'-dpsc','-r300','D:\Users\jash042\Documents\PhD\Thesis\Figures\EffectsOfBlebbistatinOnMotion.eps')