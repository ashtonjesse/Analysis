% clear all
% %This script is used for running simple tests
% disp('loading unemap...');
% oUnemap = GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130221\p_baropacetest001_unemap3.mat');
% disp('done loading');

%Get the electrode processed data
iBeat = 2;
aProcessedData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
aBeatData = aProcessedData(oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,1):...
    oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,2),:);
aMinValues = min(aBeatData(40:end,:), [], 1);

aNewData = zeros(size(aBeatData));
for i = 1:size(aBeatData,2)
    aNewData(:,i) = -sign(aMinValues(i))*abs(aMinValues(i)) + aBeatData(:,i);
    aNewData(:,i) = aNewData(:,i) / max(aNewData(40:end,i));
end

plot(aNewData(:,2),'r');
hold on;
plot(aNewData(:,3),'r');
plot(aNewData(:,4),'r');
plot(aNewData(:,5),'r');
plot(aNewData(:,6),'r');
plot(aNewData(:,7),'r');
plot(aNewData(:,145),'b');
plot(aNewData(:,146),'b');
plot(aNewData(:,147),'b');
plot(aNewData(:,148),'b');
plot(aNewData(:,149),'b');
plot(aNewData(:,150),'g');
hold off;
figure();
plot(aBeatData(:,2),'r');
hold on;
plot(aBeatData(:,3),'r');
plot(aBeatData(:,4),'r');
plot(aBeatData(:,5),'r');
plot(aBeatData(:,6),'r');
plot(aBeatData(:,7),'r');
plot(aBeatData(:,145),'b');
plot(aBeatData(:,146),'b');
plot(aBeatData(:,147),'b');
plot(aBeatData(:,148),'b');
plot(aBeatData(:,149),'b');
plot(aBeatData(:,150),'g');
hold off;