oFigure = figure();
oAxes = axes();
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aVals(:,1),aErrors(:,1),'k-');
hold(oAxes,'on');
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aVals(:,2),aErrors(:,2),'b-');
errorbar(oAxes,[225,275,325,375,425,475,525,575,625,675,725,775,825,875], aVals(:,3),aErrors(:,3),'r-');
set(oAxes,'xlim',[200 900]);
set(oAxes,'ylim',[0 7]);
set(get(oAxes,'xlabel'),'string','Cycle Length (ms)');
set(get(oAxes,'ylabel'),'string','Location along SVC-IVC axis (mm)');
set(oAxes,'box','off');
oLegend = legend(oAxes,{'Baroreflex','Chemoreflex','Carbachol'});
set(oLegend,'location','northeast');

