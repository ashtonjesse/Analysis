% % clear all;
% sFilePath = 'G:\PhD\Experiments\Bordeaux\Data\20131201\RA1201-117_refd_spatial3x3_cubic3x3_ROI1-wave.csv';
% 
% %open the file
% fid = fopen(sFilePath,'r');
% %scan the header information in
% for i = 1:10;
%     tline = fgets(fid);
%      [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%     switch (splitstring{1})
%         case 'frm num'
%             iNumFrames = str2double(splitstring{2});
%     end
% end
% aData = zeros(iNumFrames,2);
% %Get activation times
% for i = 1:iNumFrames;
%     tline = fgets(fid);
%     [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%     aData(i,1) = str2double(splitstring{1});
%     aData(i,2) = str2double(splitstring{2});
% end
% fclose(fid);

% aRateData = NaN(1,size(aData,1));
% %Loop through the peaks and insert into aRateTrace
% for i = 1:size(aPeaks,1)
%     aRateData(aLocs(i,1):aLocs(i,2)-2) = aRates(i);
% end

figure();
oMainAxes = axes();
plotyy(oMainAxes,aData(:,1),aData(:,2),aData(:,1),aRateData);
