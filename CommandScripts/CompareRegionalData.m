%this script calculates an average conduction velocity in a small
%region around the origin and shift sites for each beat leading up to the
%shift

% clear all;
% close all;
%% barodata pre-ivb
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ... %lots of competition on the way down. worth fitting DD
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ... %another good example of uncoupling
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ... %superior shift prior to inferior 
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
%     }};
%    
% aShiftIndexes = {{27},{28},{56},{24},{28},{35},{46},{37}};

%% chemodata pre-ivb
% aControlFiles = {{...
%      'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...
%     }};
% aShiftIndexes = {{39},{33},{25},{29},{26}};

%% cchdata pre-ivb
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ...
    }};
aShiftIndexes = {{45},{94},{68},{74}};
%create figures
try 
    close(oFigure);
catch ex
    
end

% oFigure = figure();
% oAxes = axes('parent',oFigure);
%initiate variables
dRadius = 1;
aCVData = cell(numel(aControlFiles),1);
aDelVmData = cell(numel(aControlFiles),1);
aAPAData = cell(numel(aControlFiles),1);
for p = 1:numel(aControlFiles)
    aFolder = aControlFiles{p};
    aCVData{p} = cell(1,numel(aFolder));
    aDelVmData{p} = cell(1,numel(aFolder));
    aAPAData{p} = cell(1,numel(aFolder));
    
    [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
    sStimulationType = splitStr{end}(1:end-3);
    for j = 1:numel(aFolder)
        %load the optical file
        listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
        aFilesInFolder = {listing(:).name}; %convert to cell array
        aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
        aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
        oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
        fprintf('Loaded %s\n', aOpticalFileName);
        
        aBeats = false(size(oOptical.Beats.Indexes,1),1);
        switch (sStimulationType)
            case {'baro','chemo'}
                aBeats(max(aShiftIndexes{p}{j}-15,1):min(aShiftIndexes{p}{j}+5,numel(aBeats))) = true;
            case 'CCh'
                aBeats(max(aShiftIndexes{p}{j}-20,1):min(aShiftIndexes{p}{j}+10,numel(aBeats))) = true;
        end
        aBeatIndexes = find(aBeats);
        %load activation data
        aAMSPSData = oOptical.PrepareActivationMap(100, 'Contour', 'amsps', 24, aBeatIndexes(1), [], [], true);
        for m = 2:length(aBeatIndexes)
            aAMSPSData = oOptical.PrepareActivationMap(100, 'Contour', 'amsps', 24, aBeatIndexes(m), aAMSPSData, [], true);
        end
        disp('Collected activation data');
        %get accepted electrodes
        if isfield(oOptical.Electrodes(1).amsps,'Map')
            aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'amsps','Map');
            aAcceptedChannels = aAcceptedChannels(aBeatIndexes(1),:);
        else
            aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
        end
        %get axis points
        aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
        oAxesElectrodes = oOptical.Electrodes(aAxisData);
        aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
        %loop through sections of axis and get average CV for each
        aCVData{p}{j} = zeros(6,numel(aBeatIndexes));
        aDelVmData{p}{j} = zeros(6,numel(aBeatIndexes));
        aAPAData{p}{j} = zeros(6,numel(aBeatIndexes));
        %get data for all beats
        aAMSPSCV =  cell2mat({aAMSPSData.Beats(aBeats).CVApprox});
        aAMSPSDelVm = cell2mat({aAMSPSData.Beats(aBeats).DeltaVmData});
        aAMSPSAPA = cell2mat({aAMSPSData.Beats(aBeats).APAData});
        %save data for each region
        for ii = 1:5 %mm along SVCIVC axis
            %convert axis point location to coords of centre point
            aCentrePoint = [((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*ii+aAxesCoords(1,2),...
                ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*ii+aAxesCoords(2,2)];
            %get electrodes in the ROI
            aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, dRadius);
            %convert logical arrays to indexes and select the
            %indexes that appear in both accepted and ROI
            [c ia ib] = intersect(find(aAcceptedChannels),find(aElectrodes));
            %need to now average data for these electrodes
            %and put into an array which is recording, 5 points x #beats
            aCVData{p}{j}(ii,:) = nanmean(aAMSPSCV(ia,:),1);
            aDelVmData{p}{j}(ii,:) = nanmean(aAMSPSDelVm(ia,:),1);
            aAPAData{p}{j}(ii,:) = nanmean(aAMSPSAPA(ia,:),1);
        end
        %and add right atrial appendage
        aRAALoc = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
            oOptical.Electrodes,'arsps','Exit');
        aCentrePoint = cell2mat({oOptical.Electrodes(logical(aRAALoc(1,:))).Coords})';
        %get electrodes in the ROI
        aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, dRadius);
        %convert logical arrays to indexes and select the
        %indexes that appear in both accepted and ROI
        [c ia ib] = intersect(find(aAcceptedChannels),find(aElectrodes));
        %need to now average data for these electrodes
        %and put into an array which is recording, 5 points x #beats
        aCVData{p}{j}(ii+1,:) = nanmean(aAMSPSCV(ia,:),1);
        aDelVmData{p}{j}(ii+1,:) = nanmean(aAMSPSDelVm(ia,:),1);
        aAPAData{p}{j}(ii+1,:) = nanmean(aAMSPSAPA(ia,:),1);
    end
end
aCVDataStacked = vertcat(aCVData{:});
aCVDataCombined = vertcat(aCVDataStacked{:})';
aCVDataToWrite = zeros(size(aCVDataCombined));
aDelVmDataStacked = vertcat(aDelVmData{:});
aDelVmDataCombined = vertcat(aDelVmDataStacked{:})';
aDelVmDataToWrite = zeros(size(aCVDataCombined));
aAPADataStacked = vertcat(aAPAData{:});
aAPADataCombined = vertcat(aAPADataStacked{:})';
aAPADataToWrite = zeros(size(aCVDataCombined));

iColsPerRegion = size(aCVDataStacked,1);
for ii = 1:6
    iStartCol = (ii-1)*iColsPerRegion+1;
    aCVDataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aCVDataCombined(:,ii:6:end);
    aDelVmDataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aDelVmDataCombined(:,ii:6:end);
    aAPADataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aAPADataCombined(:,ii:6:end);
end
csvwrite(['V:\',sStimulationType,'\aCVDataStacked.csv'],aCVDataToWrite);
csvwrite(['V:\',sStimulationType,'\aAPADataStacked.csv'],aAPADataToWrite);
csvwrite(['V:\',sStimulationType,'\aDelVmDataStacked.csv'],aDelVmDataToWrite);

