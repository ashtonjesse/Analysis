% % % %load data
%%initialise variables
% oFig = ans;
% oOptical = oFig.oGuiHandle.oOptical;
% oPotential = [];

%close other figures if they exist
try 
    close(oFigure);
catch ex
    
end
try 
    close(oDiffFigure);
catch ex
    
end
try 
    close(oAPAFigure);
catch ex
    
end
try 
    close(oDHFigure);
catch ex
    
end
%Create plot panel
oFigure = figure();
dWidth = 16;
dHeight = 16;
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
oSubplotPanel.pack('v',{0.16 0.84});
oSubplotPanel(1).pack('h',xrange);
oSubplotPanel(2).pack(xrange,yrange);
movegui(oFigure,'center');
oSubplotPanel.margin = [5 10 5 5];
oSubplotPanel(1).margin = [10 0 0 0];
oSubplotPanel(2).margin = [10 0 0 0];
oSubplotPanel(2).fontsize = 8;
oSubplotPanel(2).fontweight = 'normal';

%create diff panel
oDiffFigure = figure();
set(oDiffFigure,'color','white')
set(oDiffFigure,'inverthardcopy','off')
set(oDiffFigure,'PaperUnits','centimeters');
set(oDiffFigure,'PaperPositionMode','manual');
set(oDiffFigure,'Units','centimeters');
set(oDiffFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oDiffFigure,'Resize','off');
%set up panel
oDiffPanel = panel(oDiffFigure);
oDiffPanel.pack();
oDiffPanel(1).pack(xrange,yrange);
movegui(oDiffFigure,'center');
oDiffPanel.margin = [5 10 5 5];
oDiffPanel(1).margin = [10 0 0 0];
oDiffPanel(1).fontsize = 8;
oDiffPanel(1).fontweight = 'normal';

%create apa panel
oAPAFigure = figure();
set(oAPAFigure,'color','white')
set(oAPAFigure,'inverthardcopy','off')
set(oAPAFigure,'PaperUnits','centimeters');
set(oAPAFigure,'PaperPositionMode','manual');
set(oAPAFigure,'Units','centimeters');
set(oAPAFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oAPAFigure,'Resize','off');
%set up panel
oAPAPanel = panel(oAPAFigure);
oAPAPanel.pack();
oAPAPanel(1).pack(xrange,yrange);
movegui(oAPAFigure,'center');
oAPAPanel.margin = [5 10 5 5];
oAPAPanel(1).margin = [10 0 0 0];
oAPAPanel(1).fontsize = 8;
oAPAPanel(1).fontweight = 'normal';

%create diastolic hyperpolarisation panel
oDHFigure = figure();
set(oDHFigure,'color','white')
set(oDHFigure,'inverthardcopy','off')
set(oDHFigure,'PaperUnits','centimeters');
set(oDHFigure,'PaperPositionMode','manual');
set(oDHFigure,'Units','centimeters');
set(oDHFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oDHFigure,'Resize','off');
%set up panel
oDHPanel = panel(oDHFigure);
oDHPanel.pack();
oDHPanel(1).pack(xrange,yrange);
movegui(oDHFigure,'center');
oDHPanel.margin = [5 10 5 5];
oDHPanel(1).margin = [10 0 0 0];
oDHPanel(1).fontsize = 8;
oDHPanel(1).fontweight = 'normal';

aBeatsToAverage = 5:1:9;
aBeats = [27:1:51];

aContourRange = [-140 550];
Difference = (aContourRange(2) - aContourRange(1))/60;
aContourLevels = aContourRange(1):Difference:aContourRange(2);


%% get the average dp sites for the baseline cycles
aDPCoords = zeros(2,numel(aBeatsToAverage));
aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
    oOptical.Electrodes,'aghsm','Origin');
for nn = 1:numel(aBeatsToAverage)
    aDPCoords(:,nn) = cell2mat({oOptical.Electrodes(aOriginData(aBeatsToAverage(nn),:)).Coords});
end
% %get electrodes within neighbourhood 
% aCoords = [oOptical.Electrodes(:).Coords]';
% RelativeDistVectors = aCoords-repmat([mean(aDPCoords(1,:)),mean(aDPCoords(2,:))],[size(aCoords,1),1]);
% [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
% aLocalRegion = SupportPoints(Dist <= 1.5);
% aPointsToPlot = false(1,numel(oOptical.Electrodes));
% aPointsToPlot(aLocalRegion) = true;
aPointsToPlot = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'arsps','Map');
aPointsToPlot = aPointsToPlot(aBeatsToAverage(1),:);

    
%% loop through the beats to obtain average map
%get potential data for first beat
oPotential = oOptical.PreparePotentialMap(100,aBeatsToAverage(1),oFig.SelectedEventID,oPotential,aPointsToPlot);
%get electrode data
aElectrodeData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Data');
%initialise variables
VmFields = zeros(size(oPotential.Beats(aBeatsToAverage(1)).Fields(1).Vm',1),numel(aBeatsToAverage));
aAPAmplitudesToAverage = zeros(size(oPotential.Beats(aBeatsToAverage(1)).Fields(1).Vm',1),numel(aBeatsToAverage));
aDHAmplitudesToAverage = zeros(size(oPotential.Beats(aBeatsToAverage(1)).Fields(1).Vm',1),numel(aBeatsToAverage));
%create first axes for mean field
oAxes = oSubplotPanel(1,1).select();
oPointAxes = axes('parent',oFigure,'position',get(oAxes,'position'),'color','none');
%get contours for first beat
[aContours, h] = contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),oPotential.Beats(aBeatsToAverage(1)).Fields(oFig.SelectedTimePoint).z,aContourLevels);
[Area1,Centroid1,SortedLevels1] = GetPeakContourAttributes(aContours);
%save this field
VmFields(:,1) = oPotential.Beats(aBeatsToAverage(1)).Fields(oFig.SelectedTimePoint).Vm';
%get beat data for first beat
aBeatData = aElectrodeData(oOptical.Beats.Indexes(aBeatsToAverage(1),1):oOptical.Beats.Indexes(aBeatsToAverage(1),2),aPointsToPlot);
aBaselineData = aElectrodeData(oOptical.Beats.Indexes(aBeatsToAverage(1),1):oOptical.Beats.Indexes(aBeatsToAverage(1),1)+10,aPointsToPlot);
aAPAmplitude = max(aBeatData,[],1) - mean(aBaselineData,1);
[C MaxIndices] = max(aBeatData,[],1);
aDataBeforePeak = aBeatData(1:MaxIndices(:),:);
aDHAmplitude = min(aDataBeforePeak,[],1)-mean(aBaselineData,1);
aAPAmplitudesToAverage(:,1) = aAPAmplitude';
aDHAmplitudesToAverage(:,1) = aDHAmplitude';

%loop through remaining beats
for nn = 2:numel(aBeatsToAverage)
    oPotential = oOptical.PreparePotentialMap(100,aBeatsToAverage(nn),oFig.SelectedEventID,oPotential,aPointsToPlot);
    %get the maximum value in the field for each time point
    aFields = {oPotential.Beats(aBeatsToAverage(nn)).Fields(:).z};
    aFieldsArray = cell2mat(aFields);
    aFieldsArray = reshape(aFieldsArray,size(aFields{1},1),size(aFields{1},2),size(aFields,2));
    dMax = max(aFieldsArray,[],1);
    dMax = max(dMax,[],2);
    dMax = squeeze(dMax);
    %get the timepoint that corresponds to our first beat
    Points = dMax > max(max(oPotential.Beats(aBeatsToAverage(1)).Fields(oFig.SelectedTimePoint).z));
    Points = imerode(Points,[1;1;1]);
    iTimePoint = find(Points,1,'first')-2;
    %find equivalent contour for this beat
    [aContours2 VmFields(:,nn)] = FindMatchingContourMap(oOptical,oPotential,oAxes,iTimePoint,aBeatsToAverage(nn),SortedLevels1,Area1,aContourLevels);
    
    %find average action potential amplitude
    %get Vm data for this beat
    aBeatData = aElectrodeData(oOptical.Beats.Indexes(aBeatsToAverage(nn),1):oOptical.Beats.Indexes(aBeatsToAverage(nn),2),aPointsToPlot);
    aBaselineData = aElectrodeData(oOptical.Beats.Indexes(aBeatsToAverage(nn),1):oOptical.Beats.Indexes(aBeatsToAverage(nn),1)+10,aPointsToPlot);
    aAPAmplitude = max(aBeatData,[],1) - mean(aBaselineData,1);
    [C MaxIndices] = max(aBeatData,[],1);
    aDataBeforePeak = aBeatData(1:MaxIndices(:),:);
    aDHAmplitude = min(aDataBeforePeak,[],1)-mean(aBaselineData,1);
    aAPAmplitudesToAverage(:,nn) =  aAPAmplitude';
    aDHAmplitudesToAverage(:,nn) =  aDHAmplitude';
end
%map average of these beats
MeanAPAmplitude = mean(aAPAmplitudesToAverage,2);
MeanDHAmplitude = mean(aDHAmplitudesToAverage,2);
VmMean = mean(VmFields,2);
oInterpolant = TriScatteredInterp(oPotential.DT,VmMean);
oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
%rearrange to be able to apply boundary
aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
%apply boundary
aQZArray(~oPotential.Boundary) = NaN;
%save result back in proper format
aNewFields  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields,aContourLevels);
scatter(oPointAxes, mean(aDPCoords(1,:)), mean(aDPCoords(2,:)), ...
    'sizedata',25,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
%set up the axes properly
axis(oAxes,'equal');
axis(oAxes,'off');
caxis(oAxes,[aContourRange(1) aContourRange(2)]);
colormap(oAxes, colormap(jet));
aXLim = get(oAxes,'xlim');
aYLim = get(oAxes,'ylim');
set(oPointAxes,'xlim',aXLim,'ylim',aYLim);
axis(oPointAxes,'off');
text(aXLim(1),aYLim(2),'Mean','fontsize',8,'parent',oAxes);

%% plot beats of interest
%initialise variables
iCount = 0;
VmFields = zeros(size(oPotential.Beats(aBeatsToAverage(1)).Fields(1).Vm',1),numel(aBeats));
VmDiff = zeros(size(oPotential.Beats(aBeatsToAverage(1)).Fields(1).Vm',1),numel(aBeats));
% oAllHistAxes = oHistPanel(1,1).select();

%loop through axes plotting time frame for each beat
for ii = 1:xrange
    for jj = 1:yrange
        %record count of beat
        iCount = iCount + 1;
        if iCount > numel(aBeats)
            break;
        end
        %get potential field for this beat 
        oPotential = oOptical.PreparePotentialMap(100,aBeats(iCount),oFig.SelectedEventID,oPotential,aPointsToPlot);
        oAxes = oSubplotPanel(2,ii,jj).select();
        oDiffAxes = oDiffPanel(1,ii,jj).select();
        oAPAAxes = oAPAPanel(1,ii,jj).select();
        oDHAxes = oDHPanel(1,ii,jj).select();
        %get the maximum value in the field for each time point
        aFields = {oPotential.Beats(aBeats(iCount)).Fields(:).z};
        aFieldsArray = cell2mat(aFields);
        aFieldsArray = reshape(aFieldsArray,size(aFields{1},1),size(aFields{1},2),size(aFields,2));
        dMax = max(aFieldsArray,[],1);
        dMax = max(dMax,[],2);
        dMax = squeeze(dMax);
        %get the timepoint that corresponds to our first beat
        Points = dMax > max(max(oPotential.Beats(aBeatsToAverage(1)).Fields(oFig.SelectedTimePoint).z));
        Points = imerode(Points,[1;1;1]);
        iTimePoint = find(Points,1,'first')-2;
        
        % %          %find equivalent contour for this beat
        %         [aContours2 VmFields(:,iCount)] = FindMatchingContourMap(oOptical,oPotential,oAxes,iTimePoint,aBeats(iCount),SortedLevels1,Area1,aContourLevels);
        
        % %         %compute difference map
        %         VmDiff(:,iCount) = VmMean - VmFields(:,iCount);
        %         oInterpolant = TriScatteredInterp(oPotential.DT,VmDiff(:,iCount));
        %         oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
        %         %rearrange to be able to apply boundary
        %         aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
        %         %apply boundary
        %         aQZArray(~oPotential.Boundary) = NaN;
        %         %save result back in proper format
        %         aNewFields  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
        %         %plot difference map
        %         contourf(oDiffAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields,[-100:5:100]);
        %         %         cdfplot(oHistAxes,VmDiff(:,iCount));
        %         %         h = cdfplot(oAllHistAxes,VmDiff(:,iCount));
        %         %         if iCount > numel(aBeats)-2
        %         %             set(h,'color','r');
        %         %         end
        %         %         hold(oAllHistAxes,'on');
        
        %plot apa map
        %get Vm data for this beat
        aBeatData = aElectrodeData(oOptical.Beats.Indexes(aBeats(iCount),1):oOptical.Beats.Indexes(aBeats(iCount),2),aPointsToPlot);
        aBaselineData = aElectrodeData(oOptical.Beats.Indexes(aBeats(iCount),1):oOptical.Beats.Indexes(aBeats(iCount),1)+10,aPointsToPlot);
        [C MaxIndices] = max(aBeatData,[],1);
        aDataBeforePeak = aBeatData(1:MaxIndices(:),:);
        aDHAmplitude = min(aDataBeforePeak,[],1) - mean(aBaselineData,1) - MeanDHAmplitude';
        aAPAmplitude = max(aBeatData,[],1) - mean(aBaselineData,1) - MeanAPAmplitude';
        oInterpolant = TriScatteredInterp(oPotential.DT,aAPAmplitude');
        oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
        %rearrange to be able to apply boundary
        aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
        %apply boundary
        aQZArray(~oPotential.Boundary) = NaN;
        %save result back in proper format
        aNewFields  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
        %plot APA map
        contourf(oAPAAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields,[-120:10:100]);
        
        oInterpolant = TriScatteredInterp(oPotential.DT,aDHAmplitude');
        oInterpolatedField = oInterpolant(oPotential.x,oPotential.y);
        %rearrange to be able to apply boundary
        aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
        %apply boundary
        aQZArray(~oPotential.Boundary) = NaN;
        %save result back in proper format
        aNewFields  = reshape(aQZArray,size(oPotential.x,1),size(oPotential.x,2));
        %plot DH map
        contourf(oDHAxes,oPotential.x(1,:),oPotential.y(:,1),aNewFields,[-80:5:20]);
        
        %plot origin data
        oMapAxes = axes('parent',oAPAFigure,'position',get(oAPAAxes,'position'),'color','none');
        aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
            oOptical.Electrodes,'aghsm','Origin');
        aCoords = cell2mat({oOptical.Electrodes(aOriginData(aBeats(iCount),:)).Coords});
        if ~isempty(aCoords)
            scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                'sizedata',25,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        %plot origin data on diff map
        oMapDiffAxes = axes('parent',oDiffFigure,'position',get(oDiffAxes,'position'),'color','none');
        if ~isempty(aCoords)
            scatter(oMapDiffAxes, aCoords(1,:), aCoords(2,:), ...
                'sizedata',25,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
        end
        %set up the axes properly
        axis(oAxes,'equal');
        axis(oAxes,'off');
        axis(oDiffAxes,'equal');
        axis(oDiffAxes,'off');
        axis(oAPAAxes,'equal');
        axis(oAPAAxes,'off');
        axis(oDHAxes,'equal');
        axis(oDHAxes,'off');
        set(oMapAxes,'xlim',get(oAPAAxes,'xlim'),'ylim',get(oAPAAxes,'ylim'));
        axis(oMapAxes,'off');
        set(oMapDiffAxes,'xlim',get(oDiffAxes,'xlim'),'ylim',get(oDiffAxes,'ylim'));
        axis(oMapDiffAxes,'off');
        caxis(oAxes,[aContourRange(1) aContourRange(2)]);
        colormap(oAxes, colormap(jet));
        caxis(oDiffAxes,[-100 100]);
        caxis(oAPAAxes,[-120 100]);
        caxis(oDHAxes,[-80 20]);
        aXLim = get(oAxes,'xlim');
        aYLim = get(oAxes,'ylim');
        text(aXLim(1),aYLim(2),sprintf('%2.0f',aBeats(iCount)),'fontsize',10,'parent',oAxes);
        text(aXLim(1),aYLim(2),sprintf('%2.0f',aBeats(iCount)),'fontsize',10,'parent',oDiffAxes);
        text(aXLim(1),aYLim(2),sprintf('%2.0f',aBeats(iCount)),'fontsize',10,'parent',oAPAAxes);
        text(aXLim(1),aYLim(2),sprintf('%2.0f',aBeats(iCount)),'fontsize',10,'parent',oDHAxes);
        %         set(oHistAxes,'xlim',[-100 100]);
        %         set(oAllHistAxes,'xlim',[-100 100]);
        %         aXLim = get(oHistAxes,'xlim');
        %         aYLim = get(oHistAxes,'ylim');
        %         text(aXLim(1)+10,aYLim(2),sprintf('%2.0f',aBeats(iCount)),'fontsize',10,'parent',oHistAxes);
    end
end
% %define axes
% oAxes2 = oSubplotPanel(1,1,2).select();
% Overlay(oAxes2,oOptical.oExperiment.Optical.SchematicFilePath);
% [aContours2, h] = contourf(oAxes2,oPotential2.x(1,:),oPotential2.y(:,1),oPotential2.Beats(iBeat2).Fields(iTime2).z,aContourRange(1):0.05:aContourRange(2));
% axis(oAxes2,'equal');
% set(oAxes2,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
% axis(oAxes2,'off');
% caxis(oAxes2,[aContourRange(1) aContourRange(2)]);
% colormap(oAxes2, colormap(jet));
% % %get the peak contour
% [aLevels2 aPoints2] = SplitContours(aContours2);
% [SortedLevels2 IX2] = sort(aLevels2);
% % %  get area of peak contour
% if ~isnan(aPoints2{IX2(end)}(1,1))
%     Area2 = polyarea(aPoints2{IX2(end)}(1,:),aPoints2{IX2(end)}(2,:));
%     Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end)}'));
%     %     Inc2 = 3;
% else
%     Area2 = polyarea(aPoints2{IX2(end-1)}(1,:),aPoints2{IX2(end-1)}(2,:));
%     Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end-1)}'));
%     %     Inc2 = 3;
% end
% 
% if abs(SortedLevels1(end)-SortedLevels2(end)) < 0.001
%     %the peak levels are the same so should check areas
% else
%     %subsample data from 1
%     delVm = oPotential2.Beats(iBeat2).Fields(iTime2+1).Vm' - oPotential2.Beats(iBeat2).Fields(iTime2).Vm';
%     delT = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat2,1)+iTime2)-oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat2,1)+iTime2-1);
%     NSubSamples = 10;
%     aNewFields = cell(NSubSamples,1);
%     for ii = 1:NSubSamples
%         newVm = delVm.*((ii*delT/NSubSamples)/delT) + oPotential2.Beats(iBeat2).Fields(iTime2).Vm';
%         oInterpolant = TriScatteredInterp(oPotential2.DT,newVm);
%         oInterpolatedField = oInterpolant(oPotential2.x,oPotential2.y);
%         %rearrange to be able to apply boundary
%         aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
%         %apply boundary
%         aQZArray(~oPotential2.Boundary) = NaN;
%         %save result back in proper format
%         aNewFields{ii}  = reshape(aQZArray,size(oPotential2.x,1),size(oPotential2.x,2));
%         [aContours2, h] = contourf(oAxes2,oPotential2.x(1,:),oPotential2.y(:,1),aNewFields{ii},aContourRange(1):0.05:aContourRange(2));
%         % %get the peak contour
%         [aLevels2 aPoints2] = SplitContours(aContours2);
%         [SortedLevels2 IX2] = sort(aLevels2);
%         % %  get area of peak contour
%         if ~isnan(aPoints2{IX2(end)}(1,1))
%             %then use this one
%             if abs(SortedLevels1(end)-SortedLevels2(end)) < 0.001
%                 %if the levels are the same then check if the areas are the
%                 %same
%                 Area2 = polyarea(aPoints2{IX2(end)}(1,:),aPoints2{IX2(end)}(2,:));
%                 Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end)}'));
%                 if Area2 > Area1
%                     break;
%                 end
%             end
%         else
%             %do as above but for the second to last points as some of the
%             %entries are NaNs
%             if abs(SortedLevels1(end)-SortedLevels2(end-1)) < 0.001
%                 Area2 = polyarea(aPoints2{IX2(end-1)}(1,:),aPoints2{IX2(end-1)}(2,:));
%                 Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end-1)}'));
%                 if Area2 > Area1
%                     break;
%                 end
%             end
%         end
%     end
% end
% aProfile11 = zeros(2,12); 
% aProfile12 = zeros(2,12); 
% aProfile21 = zeros(2,12); 
% aProfile22 = zeros(2,12); 
% %first point of the profile is the centre of mass of the peak contour
% aProfile11(:,1) = Centroid1;
% aProfile12(:,1) = Centroid2;
% aProfile21(:,1) = Centroid1;
% aProfile22(:,1) = Centroid2;
% %initialise the variables that define the increment along each profile
% multiplier = 0;
% increment = 0.1;
% EndPoint1 =  [2.8; 6.2];
% EndPoint2 =[ 3.2;3.0];
% Length11 = norm(EndPoint1-Centroid1);
% Length12 = norm(EndPoint1-Centroid2);
% Length21 = norm(EndPoint2-Centroid1);
% Length22 = norm(EndPoint2-Centroid2);
% theta11 = -(pi - asin((EndPoint1(1) - Centroid1(1)) / Length11));
% theta12 = -(pi - asin((EndPoint1(1) - Centroid2(1)) / Length12));
% theta21 = (pi - asin((EndPoint2(1) - Centroid1(1)) / Length21));
% theta22 = (pi - asin((EndPoint2(1) - Centroid2(1)) / Length22));
% for ii = 2:size(aProfile11,2);
%     multiplier = multiplier + increment;
%     aProfile11(:,ii) = Centroid1 - multiplier*Length11*[sin(theta11); cos(theta11)];
%     aProfile12(:,ii) = Centroid2 - multiplier*Length12*[sin(theta12); cos(theta12)];
%     aProfile21(:,ii) = Centroid1 + multiplier*Length21*[sin(theta21); cos(theta21)];
%     aProfile22(:,ii) = Centroid2 + multiplier*Length22*[sin(theta22); cos(theta22)];
% end
% 
% %plot these profiles
% hold(oAxes1,'on');
% plot(oAxes1,aProfile11(1,:),aProfile11(2,:),'ko','MarkerSize',2);
% plot(oAxes1,aProfile21(1,:),aProfile21(2,:),'ro','MarkerSize',2);
% % plotellipse(oAxes1,z, a, b, alpha,'r--');
% set(get(oAxes1,'title'),'string',sprintf('Beat %d, frame %d',[iBeat1,iTime1]));
% %evaluate the field at these points
% aInterpLine1 = oPotential1.Beats(iBeat1).Fields(iTime1).Interpolant(aProfile11(1,:),aProfile11(2,:));
% aInterpLine2 = oPotential1.Beats(iBeat1).Fields(iTime1).Interpolant(aProfile21(1,:),aProfile21(2,:));
% 
% oAxes3 = oSubplotPanel(1,1,3).select();
% plot(oAxes3,[1:size(aProfile11,2)]*norm(aProfile11(:,1)-aProfile11(:,2)),aInterpLine1,'k-');
% hold(oAxes3,'on');
% plot(oAxes3,[1:size(aProfile21,2)]*norm(aProfile21(:,1)-aProfile21(:,2)),aInterpLine2,'r-');
% % set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
% set(oAxes3,'ylim',[0 0.7]);
% 
% %% 
% 
% %plot these profiles
% hold(oAxes2,'on');
% plot(oAxes2,aProfile12(1,:),aProfile12(2,:),'ko','MarkerSize',2);
% plot(oAxes2,aProfile22(1,:),aProfile22(2,:),'ro','MarkerSize',2);
% % plotellipse(oAxes2,z, a, b, alpha,'r--');
% set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d + %6.6f s',[iBeat2,iTime2,ii*delT/NSubSamples]));
% %evaluate the field at these points
% aInterpLine1 = oInterpolant(aProfile12(1,:),aProfile12(2,:));
% aInterpLine2 = oInterpolant(aProfile22(1,:),aProfile22(2,:));
% 
% plot(oAxes3,[1:size(aProfile12,2)]*norm(aProfile12(:,1)-aProfile12(:,2)),aInterpLine1,'k--');
% hold(oAxes3,'on');
% plot(oAxes3,[1:size(aProfile22,2)]*norm(aProfile22(:,1)-aProfile22(:,2)),aInterpLine2,'r--');
% % set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
% set(oAxes3,'ylim',[0 1]);
% set(get(oAxes3,'ylabel'),'string','Normalised F.I.');
% set(get(oAxes3,'xlabel'),'string','Distance (mm)');


[~,~,~,~,~,~,splitstring] = regexpi(oFig.DefaultDirectory,'\');
% sFileSavePath = ['D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareVm_',splitstring{end},...
%     sprintf('_%2.0f',oFig.SelectedTimePoint),'_VmField.bmp'];
% print(oFigure,'-dbmp','-r150',sFileSavePath);
% [~,~,~,~,~,~,splitstring] = regexpi(oFig.DefaultDirectory,'\');
% sFileSavePath = ['D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareVm_',splitstring{end},...
%     sprintf('_%2.0f',oFig.SelectedTimePoint),'_Diffmap.bmp'];
% print(oDiffFigure,'-dbmp','-r150',sFileSavePath);
sFileSavePath = ['D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareVm_',splitstring{end},...
    sprintf('_%2.0f',oFig.SelectedTimePoint),'_APA.bmp'];
print(oAPAFigure,'-dbmp','-r150',sFileSavePath);
% sFileSavePath = ['D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareVm_',splitstring{end},...
%     sprintf('_%2.0f',oFig.SelectedTimePoint),'_DHA.bmp'];
% print(oDHFigure,'-dbmp','-r150',sFileSavePath);

% 
% %% fit ellipse to contour1
% % [z, a, b, alpha] = fitellipse(aPoints1{IX1(end-Inc1)});
% % %plot major and minor axes for profiles
% % aProfile1 = zeros(2,15); %the major axis
% % aProfile2 = zeros(2,15); %the minor axis
% % %first point of the profile is the centre of mass of the ellipse
% % aProfile1(:,1) = z;
% % aProfile2(:,1) = z;
% % %initialise the variables that define the increment along each profile
% % multiplier = 0;
% % increment = 0.1;
% % for ii = 2:size(aProfile1,2);
% %     multiplier = multiplier + increment;
% %     if sign(alpha) > 0
% %         aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(-pi/2);multiplier*sin(-pi/2)];
% %         aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
% %     else
% %         aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
% %         aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi/2);multiplier*sin(pi/2)];
% %     end
% % end