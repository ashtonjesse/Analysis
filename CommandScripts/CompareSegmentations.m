%This script loads data sets from manual and vasex
%segmentation and compares the results. It assumes that the images
%correlate 1 to 1
% clear all;
% close all;
% 
% oManualData = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\ManSeg\iso010_seg.mat');
% oVasExData = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\VasExSeg\1to8_05\1to8_05.mat');
% sSavePath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\';
% 
% %Initialise arrays
% aAndResult = logical(zeros(size(oManualData.aImageData)));
% aExManResult = logical(zeros(size(oManualData.aImageData)));
% aExVasExResult = logical(zeros(size(oManualData.aImageData)));
% %loop through the images
% for i = 1:size(oManualData.aImageData,3);
%     aAndResult(:,:,i) = oManualData.aImageData(:,:,i) & oVasExData.imvolffBW(:,:,i);
%     aExManResult(:,:,i) = oManualData.aImageData(:,:,i) & ~oVasExData.imvolffBW(:,:,i);
%     aExVasExResult(:,:,i) = oVasExData.imvolffBW(:,:,i) & ~oManualData.aImageData(:,:,i);
% end
% 
% %Append .mat to the end of the filename
% sFileSaveName = strcat(sSavePath,'aAndResult','.mat');
% save(sFileSaveName,'aAndResult');
% %Append .mat to the end of the filename
% sFileSaveName = strcat(sSavePath,'aExManResult','.mat');
% save(sFileSaveName,'aExManResult');
% %Append .mat to the end of the filename
% sFileSaveName = strcat(sSavePath,'aExVasExResult','.mat');
% save(sFileSaveName,'aExVasExResult');
% 
% oAndResult = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\aAndResult.mat');
% oExManResult = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\aExManResult.mat');
% oExVasExResult = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\aExVasExResult.mat');
% oManualData = load('D:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\20120704\Series010\ManSeg\iso010_seg.mat');
%initialise arrays
aAndTotal = zeros(size(oAndResult.aAndResult,3),1);
aExManTotal = zeros(size(oAndResult.aAndResult,3),1);
aExVasExTotal = zeros(size(oAndResult.aAndResult,3),1);
aManTotal = zeros(size(oAndResult.aAndResult,3),1);
aXArray = 1:size(oAndResult.aAndResult,3);
for i = 1:size(oAndResult.aAndResult,3)
    aManTotal(i,1) = sum(sum(oManualData.aImageData(:,:,i)));
    aAndTotal(i,1) = sum(sum(oAndResult.aAndResult(:,:,i)));
    aExManTotal(i,1) = sum(sum(oExManResult.aExManResult(:,:,i)));
    aExVasExTotal(i,1) = sum(sum(oExVasExResult.aExVasExResult(:,:,i)));
end

plot(aXArray,aAndTotal,'k-');
hold on;
plot(aXArray,aExManTotal,'r-');
plot(aXArray,aExVasExTotal,'g-');
plot(aXArray,aManTotal,'b-');
hold off;