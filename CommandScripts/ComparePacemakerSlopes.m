%compare slopes of diastolic depolarisation for two beats from same point
oNewFigure = figure();
oNewAxes = axes();
aBeatsToPlot = [4,21,70];
sColors = {'k','r','b'};
oFig = ans;
oOptical = oFig.oGuiHandle.oOptical;
for mm = 1:numel(aBeatsToPlot)
% aData = oOptical.Electrodes(oFig.SelectedChannel).Processed.Data(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
aData = ans.FilteredSignals(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2),9); 
aSlope = oOptical.Electrodes(oFig.SelectedChannel).Processed.Slope(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
[val cc] = max(aSlope);
aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
plot(oNewAxes,aTime-aTime(cc),...
    aData-mean(aData(1:10)),'color',sColors{mm});
hold(oNewAxes,'on');
end

% %compare action potential amplitude for a few beats 
% oNewFigure = figure();
% oNewAxes = axes();
% aBeatsToPlot = [13,14,34,35,36];
% sColors = {'k','k','r','r','r'};
% for mm = 1:numel(aBeatsToPlot)
% aData = oOptical.Electrodes(oFig.SelectedChannel).Processed.Data(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
% aSlope = oOptical.Electrodes(oFig.SelectedChannel).Processed.Slope(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
% [val cc] = max(aSlope);
% aTime = oOptical.TimeSeries(oOptical.Beats.Indexes(aBeatsToPlot(mm),1):oOptical.Beats.Indexes(aBeatsToPlot(mm),2));
% plot(oNewAxes,aTime-aTime(cc),...
%     aData-mean(aData(1:10)),'color',sColors{mm});
% hold(oNewAxes,'on');
% end