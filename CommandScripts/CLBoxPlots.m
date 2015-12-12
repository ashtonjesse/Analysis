close all;
% clear all;
% %load in the data
% [BaroCols BaroData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\BaroCLandLocationData.csv');
% [ChemoCols ChemoData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\ChemoCLandLocationData.csv');
% [CChCols CChData] = ReadCSV('G:\PhD\Experiments\Auckland\InSituPrep\Statistics\CChCLandLocationData.csv');

BaroIVBIndex = BaroData(:,strcmp('IVB',BaroCols));
BaroPreIVBCL1 = BaroData(BaroIVBIndex==1,strcmp('CL1',BaroCols));
BaroPreIVBCL2 = BaroData(BaroIVBIndex==1,strcmp('CL2',BaroCols));
BaroPreIVBDelCL = BaroPreIVBCL2-BaroPreIVBCL1;

BaroPostIVBCL1 = BaroData(BaroIVBIndex==2,strcmp('CL1',BaroCols));
BaroPostIVBCL2 = BaroData(BaroIVBIndex==2,strcmp('CL2',BaroCols));
BaroPostIVBDelCL = BaroPostIVBCL2-BaroPostIVBCL1;

% ChemoIVBIndex = ChemoData(:,strcmp('IVB',ChemoCols));
% ChemoPreIVBCL1 = ChemoData(ChemoIVBIndex==1,strcmp('CL1',ChemoCols));
% ChemoPreIVBCL2 = ChemoData(ChemoIVBIndex==1,strcmp('CL2',ChemoCols));
% ChemoPreIVBDelCL = ChemoPreIVBCL2-ChemoPreIVBCL1;
% 
% ChemoPostIVBCL1 = ChemoData(ChemoIVBIndex==2,strcmp('CL1',ChemoCols));
% ChemoPostIVBCL2 = ChemoData(ChemoIVBIndex==2,strcmp('CL2',ChemoCols));
% ChemoPostIVBDelCL = ChemoPostIVBCL2-ChemoPostIVBCL1;
% 
% CChIVBIndex = CChData(:,strcmp('IVB',CChCols));
% CChPreIVBCL1 = CChData(CChIVBIndex==1,strcmp('CL1',CChCols));
% CChPreIVBCL2 = CChData(CChIVBIndex==1,strcmp('CL2',CChCols));
% CChPreIVBDelCL = CChPreIVBCL2-CChPreIVBCL1;
% 
% CChPostIVBCL1 = CChData(CChIVBIndex==2,strcmp('CL1',CChCols));
% CChPostIVBCL2 = CChData(CChIVBIndex==2,strcmp('CL2',CChCols));
% CChPostIVBDelCL = CChPostIVBCL2-CChPostIVBCL1;

oFigure = figure();
oAxes = axes();
bplot(BaroPreIVBDelCL,oAxes,1,'nolegend','nooutliers','tukey','linewidth',1);
hold(oAxes,'on');
bplot(BaroPostIVBDelCL,oAxes,2,'nolegend','nooutliers','tukey','linewidth',1);
% bplot(ChemoPreIVBDelCL,oAxes,3,'nolegend','nooutliers','tukey','linewidth',1);
% bplot(ChemoPostIVBDelCL,oAxes,4,'nolegend','nooutliers','tukey','linewidth',1);
% bplot(CChPreIVBDelCL,oAxes,5,'nolegend','nooutliers','tukey','linewidth',1);
% bplot(CChPostIVBDelCL,oAxes,6,'nolegend','nooutliers','tukey','linewidth',1);
hold(oAxes,'off');
xlim(oAxes,[0.5 6.5]);
ylim(oAxes,[-100 500]);
% set(oAxes,'xticklabel',{['Baro, n=',sprintf('%2.0f',numel(BaroPreIVBDelCL))],...
%     ['Post-IVB, n=',sprintf('%2.0f',numel(BaroPostIVBDelCL))],...
%     ['Chemo, n=',sprintf('%2.0f',numel(ChemoPreIVBDelCL))],...
%     ['Post-IVB, n=',sprintf('%2.0f',numel(ChemoPostIVBDelCL))],...
%     ['CCh, n=',sprintf('%2.0f',numel(CChPreIVBDelCL))],...
%     ['Post-IVB, n=',sprintf('%2.0f',numel(CChPostIVBDelCL))]});
% set(get(oAxes,'ylabel'),'string','Change in Cycle Length (ms)');

oFigure = figure();
oAxes = axes();
aBins = -200:25:600;
if numel(BaroPreIVBDelCL) > numel(BaroPostIVBDelCL)
    BaroPostIVBDelCL = vertcat(BaroPostIVBDelCL,NaN(numel(BaroPreIVBDelCL)-numel(BaroPostIVBDelCL),1));
elseif numel(BaroPreIVBDelCL) < numel(BaroPostIVBDelCL)
    BaroPreIVBDelCL = vertcat(BaroPreIVBDelCL,NaN(numel(BaroPostIVBDelCL)-numel(BaroPreIVBDelCL),1));
end
hist(oAxes,horzcat(BaroPreIVBDelCL,BaroPostIVBDelCL),aBins);
xlim(oAxes,[aBins(1) aBins(end)]);
set(get(oAxes,'ylabel'),'string','Frequency');
set(get(oAxes,'xlabel'),'string','Change in Cycle Length (ms)');
set(get(oAxes,'title'),'string','Baroreflex');

oFigure = figure();
oAxes = axes();
scatter(oAxes,BaroData(BaroIVBIndex==1,strcmp('Y2',BaroCols)),BaroPreIVBCL2,...
    64,BaroData(BaroIVBIndex==1,strcmp('Pressure',BaroCols)),'filled');
X = [ones(numel(BaroData(BaroIVBIndex==1,strcmp('Y2',BaroCols))),1) BaroData(BaroIVBIndex==1,strcmp('Y2',BaroCols))];
y= BaroPreIVBCL2;
b = X\y;
aTrend = X*b;
hold(oAxes,'on')
plot(oAxes,BaroData(BaroIVBIndex==1,strcmp('Y2',BaroCols)),aTrend,'r-');
Rsq1 = 1 - sum((y - aTrend).^2)/sum((y - mean(y)).^2)
% oFigure = figure();
% oAxes = axes();
% if numel(ChemoPreIVBDelCL) > numel(ChemoPostIVBDelCL)
%     ChemoPostIVBDelCL = vertcat(ChemoPostIVBDelCL,NaN(numel(ChemoPreIVBDelCL)-numel(ChemoPostIVBDelCL),1));
% elseif numel(ChemoPreIVBDelCL) < numel(ChemoPostIVBDelCL)
%     ChemoPreIVBDelCL = vertcat(ChemoPreIVBDelCL,NaN(numel(ChemoPostIVBDelCL)-numel(ChemoPreIVBDelCL),1));
% end
% hist(oAxes,horzcat(ChemoPreIVBDelCL,ChemoPostIVBDelCL),aBins);
% xlim(oAxes,[aBins(1) aBins(end)]);
% set(get(oAxes,'ylabel'),'string','Frequency');
% set(get(oAxes,'xlabel'),'string','Change in Cycle Length (ms)');
% set(get(oAxes,'title'),'string','Chemoreflex');
% 
% oFigure = figure();
% oAxes = axes();
% if numel(CChPreIVBDelCL) > numel(CChPostIVBDelCL)
%     CChPostIVBDelCL = vertcat(CChPostIVBDelCL,NaN(numel(CChPreIVBDelCL)-numel(CChPostIVBDelCL),1));
% elseif numel(CChPreIVBDelCL) < numel(CChPostIVBDelCL)
%     CChPreIVBDelCL = vertcat(CChPreIVBDelCL,NaN(numel(CChPostIVBDelCL)-numel(CChPreIVBDelCL),1));
% end
% hist(oAxes,horzcat(CChPreIVBDelCL,CChPostIVBDelCL),aBins);
% xlim(oAxes,[aBins(1) aBins(end)]);
% set(get(oAxes,'ylabel'),'string','Frequency');
% set(get(oAxes,'xlabel'),'string','Change in Cycle Length (ms)');
% set(get(oAxes,'title'),'string','CCh');
