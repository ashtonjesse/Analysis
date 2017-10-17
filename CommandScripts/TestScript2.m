close all;
% clear all;
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'); %get optical file
aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'amsps','Map');
aAcceptedChannels = aAcceptedChannels(1,:);
aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));

%get processed data
aProcessedData = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'Processed','Data');
aDeltaVm = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'Processed','Slope');
aRangeStart = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'amsps','RangeStart');
aRangeEnd = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'amsps','RangeEnd');
aSteepestIndex = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'amsps','Index');

%loop through first five beats
aF0 = mean(aProcessedData(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,1)+10,545),1);
%get APA
aBeatData = aProcessedData(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,2),545);
aBaselineData = aProcessedData(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,1)+10,545);
aBeatSlope = aDeltaVm(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,2),545);
aBaselineSlope = aDeltaVm(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,1)+10,545);
aSlope0 = mean(aDeltaVm(oOptical.Beats.Indexes(1,1):oOptical.Beats.Indexes(1,1)+10,545),1);
%calc dF
adF = (aBeatData - mean(aBaselineData,1)) ./ aF0; 
%get slope
adFdt = fCalculateMovingSlope(adF,5,3);
%get slope from data
aSlope = (aBeatSlope - mean(aBaselineSlope,1)) ./ aSlope0;

% %get deltavm peak
% aSteepestIndexForBeat = aSteepestIndex(nn,:) - 1 + oOptical.Beats.Indexes(nn,1);
% aIndex = sub2ind(size(aDeltaVm),aSteepestIndexForBeat,1:1:numel(aSteepestIndexForBeat));
% aMaxDeltaVm = aDeltaVm(aIndex);
% aDeltaVmToAverage(nn,:) = aMaxDeltaVm(1,:);

