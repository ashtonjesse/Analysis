% % % %create and process files 
% clear all;

% % % %name the folders files we want
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012' ...
    };
aCoords = cell(1,numel(aFolders));
aDistance = cell(1,numel(aFolders));

% % %loop through the folders
for i = 1:numel(aFolders)
% % %     %create files
    
    sFolder = aFolders{i};
    sRoot = sFolder(end-2:end);
    sType = 'baro';
    sAvFileName = [aFolders{i},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
    sEachFileName = [aFolders{i},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
    oAvOptical = GetOpticalFromMATFile(Optical, sAvFileName);
    oOptical = GetOpticalFromMATFile(Optical, sEachFileName);
    fprintf('Loaded files in %s\n', aFolders{i});
    
% % %get origin data
aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
%loop through beats
aThisCoords = cell(size(aOrigins,1),1);
aThisDistance = NaN(size(aOrigins,1),2);
aPoints = zeros(5,2);
iCount = 1;
for j = 1:size(aOrigins,1)
    aElectrodes = oOptical.Electrodes(aOrigins(j,:));
    if ~isempty(aElectrodes)
        if iCount < 6
            aPoints(iCount,:) = cell2mat({aElectrodes(:).Coords});
            iCount = iCount + 1;
            aPrimaryCoords = centroid(aPoints);
        else
            aBeatPoints = cell2mat({aElectrodes(:).Coords});
            aThisCoords{j} = aBeatPoints;
            for m = 1:size(aBeatPoints,2)
                aThisDistance(j,m) = norm(aBeatPoints(:,m) - aPrimaryCoords);
            end
        end
    end
end
oFigure = figure();
oAxes = axes();
scatter(oAxes, aThisDistance(:,1), oAvOptical.Electrodes.Processed.BeatRates, 'filled');
hold(oAxes,'on')
scatter(oAxes, aThisDistance(:,2), oAvOptical.Electrodes.Processed.BeatRates, 'filled');
hold(oAxes,'off')
oTitle = get(oAxes,'title');
set(oTitle,'string',sAvFileName);
aDistance{i} = aThisDistance;
aCoords{i} = aThisCoords;
end 

oFigure = figure();
oAxes = axes();
for i = 1:numel(aFolders)
    sFolder = aFolders{i};
    sRoot = sFolder(end-2:end);
    sType = 'baro';
    sAvFileName = [aFolders{i},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
    oAvOptical = GetOpticalFromMATFile(Optical, sAvFileName);
    scatter(oAxes, aDistance{i}(:,1), oAvOptical.Electrodes.Processed.BeatRates, 'filled');
    hold(oAxes,'on');
end
hold(oAxes,'off');
set(get(oAxes,'xlabel'),'string','Distance from primary pacemaker (mm)');
set(get(oAxes,'ylabel'),'string','Activation rate (bpm)');
set(get(oAxes,'title'),'string','Location vs Activation Rate for 20140703 ');
