%this script calculates an average conduction velocity in a small
%region around the origin and shift sites for each beat leading up to the
%shift

% clear all;
% close all;
%% barodata pre-ivb
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro004' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ... %outright competition on recovery
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ... %lots of competition on the way down. worth fitting DD
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ... %another good example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ... %superior shift prior to inferior? 
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ... %don't use for recovery
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
    }};
   

% aShiftIndexes = {{41},{50},{27},{27},{28},{56},{24},{28},{35},{46},{37}}; % Onset
aShiftIndexes = {{65},{66},{50},{44},{64},{75},{53},{58},{54},{49},{56}}; % Recovery

% barodata post-atropine
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro014' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro015' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro011' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro010' ... 
%     }};
% aShiftIndexes = {{21},{38},{40},{48}};

%% chemodata pre-ivb
% aControlFiles = {{...
%      'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002' ... %ok for +15 on recovery
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ... %ok for +15 on recovery
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001' ... %for recovery need last cycle of chemo001a, 2 missed then shift is on cycle 3 of b
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001' ... %ok for +15 on recovery
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...%ok for +15 on recovery
%     }};
% aShiftIndexes = {{39},{33},{25},{29},{26}}; %onset
% aShiftIndexes = {{52},{60},{3},{37},{57}}; %recovery
%% cchdata pre-ivb
% aControlFiles = {{... %20140813CCh003c recovery shift is 51
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...
%     },{...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001' ...%not used in recovery
% %     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ... %outright shift 79, further shift on b 17, c 55 partial recovery
%     }};
% % aShiftIndexes = {{16},{45},{94},{74}}; %onset 
% aShiftIndexes = {{51},{47},{51},{55}}; %recovery
% % aShiftIndexes = {{28},{57},{1},{17}}; %after outright shift
% %create figures
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
aPhaseData = cell(numel(aControlFiles),1);
for p = 1:numel(aControlFiles)
    aFolder = aControlFiles{p};
    aCVData{p} = cell(1,numel(aFolder));
    aDelVmData{p} = cell(1,numel(aFolder));
    aAPAData{p} = cell(1,numel(aFolder));
    aPhaseData{p} = cell(1,numel(aFolder));
    
    [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
    dExperiment = str2double(splitStr{end-1});
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
    
    sStimulationType = splitStr{end}(1:end-3);
    for j = 1:numel(aFolder)
        %load the optical file
        listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
        aFilesInFolder = {listing(:).name}; %convert to cell array
%                 switch (p)
            %                                     case {1,2} %CCh after LP shift
            %                                         aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']);
            %                                     case {3,4} %CCh after LP shift
            %                                         aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*b?_\w*g10_LP100Hz-waveEach.mat']);
%                         case {1,2,4} %CCh recovery
%                             aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*c?_\w*g10_LP100Hz-waveEach.mat']); %recovery
%                         case 3 %chemo recovery
%                             aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*b?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%                         case {3} %CCh recovery
%                             aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*d?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%                         otherwise %baro onset&recovery, chemo onset&recovery, CCh onset
                                aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%                 end
        aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
        oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
        fprintf('Loaded %s\n', aOpticalFileName);
        
        aBeats = false(size(oOptical.Beats.Indexes,1),1);
        switch (sStimulationType)
            case 'baro'
                %                 aBeats(max(aShiftIndexes{p}{j}-15,1):...
                %                     min(aShiftIndexes{p}{j}+5,numel(aBeats))) = true; %onset
                %                aCycles = -15:1:5;
                aBeats(max(aShiftIndexes{p}{j}-5,1):...
                    min(aShiftIndexes{p}{j}+10,numel(aBeats))) = true;%recovery
                aCycles = -5:1:10;
            case 'chemo'
                %                                 aBeats(max(aShiftIndexes{p}{j}-15,1):...
                %                                     min(aShiftIndexes{p}{j}+5,numel(aBeats))) = true; %onset
                aBeats(max(aShiftIndexes{p}{j}-5,1):...
                    min(aShiftIndexes{p}{j}+15,numel(aBeats))) = true; %recovery
            case 'CCh'
                %                                                 aBeats(max(aShiftIndexes{p}{j}-20,1):...
                %                                                     min(aShiftIndexes{p}{j}+10,numel(aBeats))) = true; %onset
                aBeats(max(aShiftIndexes{p}{j}-5,1):...
                    min(aShiftIndexes{p}{j}+15,numel(aBeats))) = true; %recovery
                %                 aBeats(aShiftIndexes{p}{j}:aShiftIndexes{p}{j}+10) = true; %post LP shift
        end
        aBeatIndexes = find(aBeats);
        %load activation data
        aAMSPSData = PrepareEventData(oOptical, 100, 'Contour', 'amsps', aBeatIndexes(1), []);
        
        aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
        aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
        oOpticalA = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
        aAMSPSDataA = PrepareEventData(oOpticalA, 100, 'Contour', 'amsps', aBeatIndexes(1), []);
        aAMSPSData.AverageDeltaVm = aAMSPSDataA.AverageDeltaVm;
        aAMSPSData.AverageAmplitude = aAMSPSDataA.AverageAmplitude;
        clear aAMSPSDataA;
        clear oOpticalA;
        
        aAMSPSData = GetEventMap(oOptical, aAMSPSData, aBeatIndexes(1));
        aAMSPSData = GetDeltaVmMap(oOptical,aAMSPSData, aBeatIndexes(1));
        aAMSPSData = GetAmplitudeMap(oOptical,aAMSPSData,aBeatIndexes(1));
        aAMSPSData = GetCVMap(oOptical,aAMSPSData,24,aBeatIndexes(1));
        for m = 2:length(aBeatIndexes)
            aAMSPSData = GetEventMap(oOptical, aAMSPSData, aBeatIndexes(m));
            aAMSPSData = GetDeltaVmMap(oOptical,aAMSPSData, aBeatIndexes(m));
            aAMSPSData = GetAmplitudeMap(oOptical,aAMSPSData,aBeatIndexes(m));
            aAMSPSData = GetCVMap(oOptical,aAMSPSData,24,aBeatIndexes(m));
        end
        disp('Collected activation data');
        %get axis points
        aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
        oAxesElectrodes = oOptical.Electrodes(aAxisData);
        aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
        %         %loop through sections of axis and get average CV for each
        %         aCVData{p}{j} = zeros(6,numel(aBeatIndexes));
        %         aDelVmData{p}{j} = zeros(6,numel(aBeatIndexes));
        %         aAPAData{p}{j} = zeros(6,numel(aBeatIndexes));
        %         aPhaseData{p}{j} = zeros(6,numel(aBeatIndexes));
        aCVData{p}{j} = cell(3,1);
        aDelVmData{p}{j} = cell(3,1);
        aAPAData{p}{j} = cell(3,1);
        aPhaseData{p}{j} = cell(3,1);
        
        %get data for all beats
        aAMSPSCV =  cell2mat({aAMSPSData.Beats(aBeats).CVApprox});
        aAMSPSDelVm = cell2mat({aAMSPSData.Beats(aBeats).DeltaVmData});
        aAMSPSAPA = cell2mat({aAMSPSData.Beats(aBeats).AmplitudeData});
        aAMSPSEvent = cell2mat({aAMSPSData.Beats(aBeats).EventTimes});
        %save data for each region
        aLocations = [1,4];%mm along SVCIVC axis
        for ii = 1:2 
            mm = aLocations(ii);
            %convert axis point location to coords of centre point
            aCentrePoint = [((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*mm+aAxesCoords(1,2),...
                ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*mm+aAxesCoords(2,2)];
            %get electrodes in the ROI
            aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, dRadius, [oOptical.Electrodes(:).Coords]');
            %convert logical arrays to indexes and select the
            %indexes that appear in both accepted and ROI
            [c ia ib] = intersect(find(aAMSPSData.AcceptedChannels),find(aElectrodes));
            %             %need to now average data for these electrodes
            %             %and put into an array which is recording, 5 points x #beats
            %             aCVData{p}{j}(ii,:) = nanmean(aAMSPSCV(ia,:),1);
            %             aDelVmData{p}{j}(ii,:) = nanmean(aAMSPSDelVm(ia,:),1);
            %             aAPAData{p}{j}(ii,:) = nanmean(aAMSPSAPA(ia,:),1);
            aCV = aAMSPSCV(ia,:);
            aCycleLabels = repmat(aCycles,size(aCV,1),1);
            aExperiment = repmat(dExperiment,size(aCV));
            aLocation = repmat(mm,size(aCV));
            aPoint = repmat([1:size(aCV,1)]',1,size(aCV,2));
            aCVData{p}{j}{ii} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aCV(:));
            aDelVm = aAMSPSDelVm(ia,:);
            aDelVmData{p}{j}{ii} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aDelVm(:));
            aAPA = aAMSPSAPA(ia,:);
            aAPAData{p}{j}{ii} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aAPA(:));
            %decrease ROI radius for the event time measurement
            %get electrodes in the ROI
            aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, 0.5, [oOptical.Electrodes(:).Coords]');
            %convert logical arrays to indexes and select the
            %indexes that appear in both accepted and ROI
            [c ia ib] = intersect(find(aAMSPSData.AcceptedChannels),find(aElectrodes));
            aPhase = aAMSPSEvent(ia,:);
            aCycleLabels = repmat(aCycles,size(aPhase,1),1);
            aExperiment = repmat(dExperiment,size(aPhase));
            aLocation = repmat(mm,size(aPhase));
            aPoint = repmat([1:size(aPhase,1)]',1,size(aPhase,2));
            aPhaseData{p}{j}{ii} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aPhase(:));
            %deleted a statement here for aPhaseData{p}{j}(ii,:)
        end
        %and add right atrial appendage
        aRAALoc = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
            oOptical.Electrodes,'arsps','Exit');
        aCentrePoint = cell2mat({oOptical.Electrodes(logical(aRAALoc(1,:))).Coords})';
        %get electrodes in the ROI
        aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, dRadius, [oOptical.Electrodes(:).Coords]');
        %convert logical arrays to indexes and select the
        %indexes that appear in both accepted and ROI
        [c ia ib] = intersect(find(aAMSPSData.AcceptedChannels),find(aElectrodes));
        %         %need to now average data for these electrodes
        %         %and put into an array which is recording, 5 points x #beats
        %         aCVData{p}{j}(ii+1,:) = nanmean(aAMSPSCV(ia,:),1);
        %         aDelVmData{p}{j}(ii+1,:) = nanmean(aAMSPSDelVm(ia,:),1);
        %         aAPAData{p}{j}(ii+1,:) = nanmean(aAMSPSAPA(ia,:),1);
        aCV = aAMSPSCV(ia,:);
        aCycleLabels = repmat(aCycles,size(aCV,1),1);
        aExperiment = repmat(dExperiment,size(aCV));
        aLocation = repmat(0,size(aCV)); %label RAA location as 0
        aPoint = repmat([1:size(aCV,1)]',1,size(aCV,2));
        aCVData{p}{j}{ii+1} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aCV(:));
        aDelVm = aAMSPSDelVm(ia,:);
        aDelVmData{p}{j}{ii+1} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aDelVm(:));
        aAPA = aAMSPSAPA(ia,:);
        aAPAData{p}{j}{ii+1} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aAPA(:));
        
        %decrease ROI radius for phase measurement
        %get electrodes in the ROI
        aElectrodes = oOptical.GetElectrodesWithinRadius(aCentrePoint, 0.5, [oOptical.Electrodes(:).Coords]');
        %convert logical arrays to indexes and select the
        %indexes that appear in both accepted and ROI
        [c ia ib] = intersect(find(aAMSPSData.AcceptedChannels),find(aElectrodes));
        %         aPhaseData{p}{j}(ii+1,:) = nanmean(aAMSPSEvent(ia,:),1);
        aPhase = aAMSPSEvent(ia,:);
        aCycleLabels = repmat(aCycles,size(aPhase,1),1);
        aExperiment = repmat(dExperiment,size(aPhase));
        aLocation = repmat(0,size(aPhase));
        aPoint = repmat([1:size(aPhase,1)]',1,size(aPhase,2));
        aPhaseData{p}{j}{ii+1} = horzcat(aExperiment(:),aCycleLabels(:),aLocation(:),aPoint(:),aPhase(:));
    end
end
% %hack for chemo recovery
% aAPAData{3,1}{1} = horzcat(NaN(6,3),aAPAData{3,1}{1});
% aDelVmData{3,1}{1} = horzcat(NaN(6,3),aDelVmData{3,1}{1});
% aPhaseData{3,1}{1} = horzcat(NaN(6,3),aPhaseData{3,1}{1});
% aCVData{3,1}{1} = horzcat(NaN(6,3),aCVData{3,1}{1});

% %%hack for CCh onset
% aAPAData{1,1}{1} = horzcat(aAPAData{1,1}{1},NaN(6,5));
% aDelVmData{1,1}{1} = horzcat(aDelVmData{1,1}{1},NaN(6,5));
% aPhaseData{1,1}{1} = horzcat(aPhaseData{1,1}{1},NaN(6,5));
% aCVData{1,1}{1} = horzcat(aCVData{1,1}{1},NaN(6,5));

%%hack for CCh recovery
% aAPAData{3,1}{1} = horzcat(aAPAData{3,1}{1},NaN(6,6));
% aDelVmData{3,1}{1} = horzcat(aDelVmData{3,1}{1},NaN(6,6));
% aPhaseData{3,1}{1} = horzcat(aPhaseData{3,1}{1},NaN(6,6));
% aCVData{3,1}{1} = horzcat(aCVData{3,1}{1},NaN(6,6));

aCVDataStacked = vertcat(aCVData{:});
aCVDataStacked = vertcat(aCVDataStacked{:});
aCVDataStacked = vertcat(aCVDataStacked{:});
aDelVmDataStacked = vertcat(aDelVmData{:});
aDelVmDataStacked = vertcat(aDelVmDataStacked{:});
aDelVmDataStacked = vertcat(aDelVmDataStacked{:});
aAPADataStacked = vertcat(aAPAData{:});
aAPADataStacked = vertcat(aAPADataStacked{:});
aAPADataStacked = vertcat(aAPADataStacked{:});
aPhaseDataStacked = vertcat(aPhaseData{:});
aPhaseDataStacked = vertcat(aPhaseDataStacked{:});
aPhaseDataStacked = vertcat(aPhaseDataStacked{:});

aCVDataToWrite = aCVDataStacked(~isnan(aCVDataStacked(:,5)),:);
aAPADataToWrite = aAPADataStacked(~isnan(aAPADataStacked(:,5)),:);
aDelVmDataToWrite = aDelVmDataStacked(~isnan(aDelVmDataStacked(:,5)),:);
aPhaseDataToWrite = aPhaseDataStacked(~isnan(aPhaseDataStacked(:,5)),:);
% aCVDataStacked = vertcat(aCVData{:});
% aCVDataCombined = vertcat(aCVDataStacked{:})';
% aCVDataToWrite = zeros(size(aCVDataCombined));
% aDelVmDataStacked = vertcat(aDelVmData{:});
% aDelVmDataCombined = vertcat(aDelVmDataStacked{:})';
% aDelVmDataToWrite = zeros(size(aCVDataCombined));
% aAPADataStacked = vertcat(aAPAData{:});
% aAPADataCombined = vertcat(aAPADataStacked{:})';
% aAPADataToWrite = zeros(size(aCVDataCombined));
% aPhaseDataStacked = vertcat(aPhaseData{:});
% aPhaseDataCombined = vertcat(aPhaseDataStacked{:})';
% aPhaseDataToWrite = zeros(size(aCVDataCombined));

% iColsPerRegion = size(aCVDataStacked,1);
% for ii = 1:6
%     iStartCol = (ii-1)*iColsPerRegion+1;
%     aCVDataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aCVDataCombined(:,ii:6:end);
%     aDelVmDataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aDelVmDataCombined(:,ii:6:end);
%     aAPADataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aAPADataCombined(:,ii:6:end);
%     aPhaseDataToWrite(:,iStartCol:(iStartCol+iColsPerRegion-1)) = aPhaseDataCombined(:,ii:6:end);
% end
dlmwrite(['V:\',sStimulationType,'\recovery\aCVDataStacked.csv'],aCVDataToWrite,'precision','%10.5f');
dlmwrite(['V:\',sStimulationType,'\recovery\aAPADataStacked.csv'],aAPADataToWrite,'precision','%10.5f');
dlmwrite(['V:\',sStimulationType,'\recovery\aDelVmDataStacked.csv'],aDelVmDataToWrite,'precision','%10.5f');
dlmwrite(['V:\',sStimulationType,'\recovery\aPhaseDataStacked.csv'],aPhaseDataToWrite,'precision','%10.5f');
