%this script calculates an average conduction velocity in a small
%region around the origin and shift sites for each beat leading up to the
%shift

clear all;
close all;
%% barodata pre-ivb
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ... %lots of competition on the way down. worth fitting DD
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ... %another good example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ... %superior shift prior to inferior 
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
    }};
   
aShiftIndexes = {{27},{28},{56},{24},{28},{35},{46},{37}};
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
%     }};
% aShiftIndexes = {{56}};
%% barodata post-ivb
% aControlFiles = {{...
%      'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005'...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004'...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004'...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro004'...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004'...
%     }};
% aShiftIndexes = {{38},{40},{49},{29},{25}}; 

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
%% chemodata post-ivb
% aControlFiles = {{...
%      'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo004' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo004' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004' ...
%     }};

%% cchdata pre-ivb
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ...
%     }};

%% cchdata post-ivb
% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh005' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh004' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh003' ...
%      },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh005' ...
%     }};
% 
%create figures
try 
    close(oFigure);
catch ex
    
end

% oFigure = figure();
% oAxes = axes('parent',oFigure);
%initiate variables
aOriginAMSPSData = cell(numel(aControlFiles),1);
aOriginAGHSMData = cell(numel(aControlFiles),1);
aShiftAMSPSData = cell(numel(aControlFiles),1);
aShiftAGHSMData =cell(numel(aControlFiles),1);
aCTAMSPSData = cell(numel(aControlFiles),1);
aDPAGHSMData = cell(numel(aControlFiles),1);

aDistance = zeros(numel(aControlFiles),3);
dRadius = 1;

% 
aColours = distinguishable_colors(numel(aControlFiles));
for p = 1:numel(aControlFiles)
    aFolder = aControlFiles{p};
    aOriginAMSPSData{p} = cell(1,numel(aFolder));
    aOriginAGHSMData{p} = cell(1,numel(aFolder));
    aShiftAMSPSData{p} = cell(1,numel(aFolder));
    aShiftAGHSMData{p} = cell(1,numel(aFolder));
    aCTAMSPSData{p} = cell(1,numel(aFolder));
    aDPAGHSMData{p} = cell(1,numel(aFolder));
    
    [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
    sStimulationType = splitStr{end}(1:end-3);
    switch (sStimulationType)
        case {'baro','chemo'}
            for j = 1:numel(aFolder)
                %load the optical file
                listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
                aFilesInFolder = {listing(:).name}; %convert to cell array
                aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
                aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
                oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
                fprintf('Loaded %s\n', aOpticalFileName);

                aBeats = false(size(oOptical.Beats.Indexes,1),1);
                aBeats(aShiftIndexes{p}{j}-15:aShiftIndexes{p}{j}+5) = true;
                aBeatIndexes = find(aBeats);
                %load activation data
                aAMSPSData = oOptical.PrepareActivationMap(100, 'Contour', 'amsps', 24, aBeatIndexes(1), [], [], false);
                aAGHSMData = oOptical.PrepareActivationMap(100, 'Contour', 'aghsm', 24, aBeatIndexes(1), [], [], false);
                for m = 2:length(aBeatIndexes)
                    aAMSPSData = oOptical.PrepareActivationMap(100, 'Contour', 'amsps', 24, aBeatIndexes(m), aAMSPSData, [], false);
                    aAGHSMData = oOptical.PrepareActivationMap(100, 'Contour', 'aghsm', 24, aBeatIndexes(m), aAGHSMData, [], false);
                end
                disp('Collected activation data');
                %get the origin electrode
                aOriginData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
                    oOptical.Electrodes,'aghsm','Origin');
                aAvCoords = mean(cell2mat({oOptical.Electrodes(logical(sum(aOriginData(1:5,:),1))).Coords}),2);
                
                %get electrodes within neighbourhood
                aElectrodes = oOptical.GetElectrodesWithinRadius(aAvCoords', dRadius);
                if isfield(oOptical.Electrodes(1).amsps,'Map')
                    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'amsps','Map');
                    aAcceptedChannels = aAcceptedChannels(aBeatIndexes(1),:);
                else
                    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
                end
                aOriginElectrodes = aElectrodes & aAcceptedChannels;
                %get shift electrode 
                aShiftCoords = cell2mat({oOptical.Electrodes(logical(aOriginData(aShiftIndexes{p}{j},:))).Coords});
                if size(aShiftCoords,2)>1
                    [C I] = min(aShiftCoords(2,:));
                    aShiftCoords=aShiftCoords(:,I);
                end
                aDistance(p,1) = norm(aAvCoords - aShiftCoords);
                %get electrodes within neighbourhood
                aElectrodes = oOptical.GetElectrodesWithinRadius(aShiftCoords', dRadius);
                aShiftElectrodes = aElectrodes & aAcceptedChannels;
                %get CT electrode 
                aCTData = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
                    oOptical.Electrodes,'arsps','Exit');
                aCoords = cell2mat({oOptical.Electrodes(logical(aCTData(1,:))).Coords});
                aDistance(p,2) = norm(aAvCoords - aCoords);
                aDistance(p,3) = norm(aShiftCoords - aCoords);
                %get electrodes within neighbourhood
                aElectrodes = oOptical.GetElectrodesWithinRadius(aCoords', dRadius);
                aCTElectrodes = aElectrodes & aAcceptedChannels;
                %select average CV for these electrodes
                aAMSPSCV =  cell2mat({aAMSPSData.Beats(aBeats).CVApprox});
                aOriginAMSPSData{p}{j} = nanmean(aAMSPSCV(aOriginElectrodes,:),1);
                aShiftAMSPSData{p}{j} = nanmean(aAMSPSCV(aShiftElectrodes,:),1);
%                 aDPAGHSMData{p}{j} = aAGHSMTimes(aOriginData(aBeats,:)');
%                 if p == 3
%                     aDPAGHSMData{p}{j} = aDPAGHSMData{p}{j}([1:14,16:end]);
%                 end
            end
    end
end
aOriginAMSPS = vertcat(aOriginAMSPSData{:});
aOriginAMSPS = vertcat(aOriginAMSPS{:});
aOriginAMSPS = aOriginAMSPS';
errorbar(mean(aOriginAMSPS,2),std(aOriginAMSPS,0,2)/sqrt(size(aOriginAMSPS,2)));
% aOriginAGHSM = vertcat(aOriginAGHSMData{:});
% aOriginAGHSM = vertcat(aOriginAGHSM{:});
% aOriginAGHSM = aOriginAGHSM';

aShiftAMSPS = vertcat(aShiftAMSPSData{:});
aShiftAMSPS = vertcat(aShiftAMSPS{:});
aShiftAMSPS = aShiftAMSPS';
hold on;
errorbar(mean(aShiftAMSPS,2),std(aShiftAMSPS,0,2)/sqrt(size(aShiftAMSPS,2)),'r-');
% aShiftAGHSM = vertcat(aShiftAGHSMData{:});
% aShiftAGHSM = vertcat(aShiftAGHSM{:});
% aShiftAGHSM = aShiftAGHSM';
% 
% aCTAMSPS = vertcat(aCTAMSPSData{:});
% aCTAMSPS = vertcat(aCTAMSPS{:});
% aCTAMSPS = aCTAMSPS';
% 
% aDPAGHSM = vertcat(aDPAGHSMData{:});
% aDPAGHSM = vertcat(aDPAGHSM{:});
% aDPAGHSM = aDPAGHSM';
% 
% aDPVsShift = 1000*(aShiftAMSPS - aDPAGHSM) ./ repmat(aDistance(:,1)', [size(aDPAGHSM,1), 1]);
% aDPVsShift(16:end,:) = 1000*(aOriginAMSPS(16:end,:) - aDPAGHSM(16:end,:)) ./ repmat(aDistance(:,1)', [size(aDPAGHSM(16:end,:),1), 1]);
% aDPVsCT = 1000*(aCTAMSPS - aDPAGHSM) ./ repmat(aDistance(:,2)', [size(aDPAGHSM,1), 1]);
csvwrite('V:\aOriginAMSPS.csv',aOriginAMSPS);
csvwrite('V:\aShiftAMSPS.csv',aShiftAMSPS);
% fprintf('%4.0f,%3.0f,%5.3f,%5.3f\n',iElectrode,iBeat,oActivation.AverageAPA(iElectrode),oActivation.Beats(iBeat).APAData(iElectrode)+oActivation.AverageAPA(iElectrode));