%load csv
close all;
% clear all;
% aGangliaData = ReadCSV('V:\DataAnalysis\Ganglia.csv','%u,%f,%u,%u,%9s,%f,%f,%f,%f,%f,%f,%f,%f,%u,%u');

% get the x and y coordinates of each ganglion
aXM = aGangliaData.aData{strcmp(aGangliaData.aHeader,'XM')};
aYM = -aGangliaData.aData{strcmp(aGangliaData.aHeader,'YM')};

%select only those ganglia that belong to this sample
aSampleX = aXM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160113 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);
aSampleY = aYM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160113 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);

%define new origin and point on the y axis
O = [9868.421 ; -1328.947];
Y = [8631.579 ; -7092.105];
%transform the coordinates
aNewPoints = zeros(2,numel(aSampleX));
for i = 1:numel(aSampleX)
    aNewPoints(:,i) = TransformCoordinates(O,Y,[aSampleX(i) ; aSampleY(i)]);
end
plot(-aNewPoints(1,:),-aNewPoints(2,:),'b+');
hold on;
csvwrite('V:\DataAnalysis\20160103_transformed.csv',aNewPoints');

aSampleX = aXM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160307 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);
aSampleY = aYM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160307 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);

O = [9552.632 ; -315.789];
Y = [9065.789 ; -5289.474];
aNewPoints = zeros(2,numel(aSampleX));
for i = 1:numel(aSampleX)
    aNewPoints(:,i) = TransformCoordinates(O,Y,[aSampleX(i) ; aSampleY(i)]);
end
csvwrite('V:\DataAnalysis\20160307_transformed.csv',aNewPoints');
plot(-aNewPoints(1,:),-aNewPoints(2,:),'y+');

aSampleX = aXM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160517 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);
aSampleY = aYM(aGangliaData.aData{strcmp(aGangliaData.aHeader,'SampleID')}==20160517 & ...
    aGangliaData.aData{strcmp(aGangliaData.aHeader,'SectionNum')}==1);

O = [12736.842 ; -3666.667];
Y = [12210.526 ; -9701.754];
aNewPoints = zeros(2,numel(aSampleX));
for i = 1:numel(aSampleX)
    aNewPoints(:,i) = TransformCoordinates(O,Y,[aSampleX(i) ; aSampleY(i)]);
end
csvwrite('V:\DataAnalysis\20160517_transformed.csv',aNewPoints');
plot(-aNewPoints(1,:),-aNewPoints(2,:),'g+');
hold off;