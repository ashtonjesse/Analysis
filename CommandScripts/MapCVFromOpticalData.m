clear all;
close all;
sFilesPath = 'G:\PhD\Experiments\Bordeaux\Data\20131129\Baro003\0204_03_ApdMap50.csv';
rowdim = 100;
coldim = 101;
[aHeaderInfo aActivationTimes aRepolarisationTimes aAPDs] = ReadOpticalDataCSVFile(sFilesPath,rowdim,coldim);
aActivationTimes = rot90(aActivationTimes(:,1:end-1),-1);
[rowIndices colIndices] = find(aActivationTimes > 0);
AT = aActivationTimes(aActivationTimes > 0);
dRes = 0.25;
dInterpDim = dRes/4;
x = dRes .* rowIndices;
y = dRes .* colIndices;

%plot the activation field
F=TriScatteredInterp(x,y,AT);
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
rxx = reshape(xx,[prod(size(QAT)),1]);
ryy = reshape(yy,[prod(size(QAT)),1]);
cbarmin = min(min(QAT));
cbarmax = max(max(QAT));
figure(1); oAxes = axes(); 
contourf(oAxes, xx,yy,QAT,floor(cbarmin):1:ceil(cbarmax));
% hold on; scatter(x,y,50,AT,'filled'); hold off;
cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax)); 
axis(oAxes, 'equal'); axis(oAxes, 'tight'); 

%plot the CV with neighbourhood 8
[CV,Vect]=ReComputeCV([x,y],AT,8,0.1);
idx = find(~isnan(CV));
F=TriScatteredInterp(x(idx),y(idx),CV(idx));
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
rxx = reshape(xx,[prod(size(QAT)),1]);
ryy = reshape(yy,[prod(size(QAT)),1]);
figure(2); oAxes = axes(); 
scatter(x(idx),y(idx),60,CV(idx),'filled'); 
axis(oAxes, 'equal'); axis(oAxes, 'tight'); %hold on; scatter(x,y,10,'k','filled'); hold off; 
caxis([0 2]);
cbarf([0 2], 0:0.1:2); 
axis(oAxes, 'equal'); axis(oAxes, 'tight'); 
%get the histogram of the CVs
figure(3); hist(CV(idx),0:0.1:2);

%plot the CV with neighbourhood 24
[CV,Vect]=ReComputeCV([x,y],AT,24,0.1);
idxCV = find(~isnan(CV));
figure(4); oAxes = axes(); 
scatter(x(idxCV),y(idxCV),60,CV(idxCV),'filled'); 
caxis([0 2]);
cbarf([0 2], 0:0.1:2); 
axis(oAxes, 'equal'); axis(oAxes, 'tight'); 
%hold on; scatter(x,y,10,'k','filled'); hold off; 
figure(5); hist(CV(idxCV),0:0.1:max(CV(idxCV)));