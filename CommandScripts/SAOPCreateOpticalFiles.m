% % % %create and process files 
% clear all;
% % %read in average waveform file
oAvOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\baro012_3x3_1ms_7x_g10_LP100Hz-wave.mat');

% % % %read in all waveforms 
oEachOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\baro012_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');

% % % % %name the folders files we want
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011' ...
   };
% 
aInOptions = struct('Procedure','','Inputs',cell(1,1));
aInOptions.Procedure = 'FilterData';
aInOptions.Inputs = {'SovitzkyGolay',3,25};

% % % %loop through the folders
for i = 1:numel(aFolders)

    tic;
    % % % %     %create files
    sFolder = aFolders{i};
    sRoot = sFolder(end-2:end);
    sType = 'baro';
    sAvFileName = [aFolders{i},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-wave.csv'];
    sEachFileName = [aFolders{i},'\',sType,sRoot,'_3x3_1ms_7x_g10_LP100Hz-waveEach.csv'];
    oThisAvOptical = GetOpticalRecordingFromCSVFile(Optical, sAvFileName, oAvOptical.oExperiment);
    oThisEachOptical = GetOpticalRecordingFromCSVFile(Optical, sEachFileName, oAvOptical.oExperiment);
    fprintf('Loaded files in %s\n', aFolders{i});
    % % %     %smooth average data
    oThisAvOptical.ProcessElectrodeData(1, aInOptions);
    
    % % %     set beats for the average file
    [aPeaks,aLocations] = oThisAvOptical.GetPeaks(abs(oThisAvOptical.Electrodes.Processed.Curvature), oAvOptical.Beats.Threshold);
    Peaks = [aPeaks ; aLocations];
    oThisAvOptical.GetArrayBeats(Peaks,oAvOptical.Beats.Threshold);
    oThisEachOptical.GetArrayBeats(Peaks,oAvOptical.Beats.Threshold);
    fprintf('Got Beats for %s\n', aFolders{i});
    
    %create the events
    oThisEachOptical.CreateNewEvent(1:1:length(oThisEachOptical.Electrodes), 1:1:size(oThisEachOptical.Beats.Indexes,1), ...
        'r', 'Activation', 'SteepestPositiveSlope');
    oThisEachOptical.CreateNewEvent(1:1:length(oThisEachOptical.Electrodes), 1:1:size(oThisEachOptical.Beats.Indexes,1), ...
        'g', 'Activation', 'HalfSignalMagnitude');
    oThisEachOptical.CreateNewEvent(1:1:length(oThisEachOptical.Electrodes), 1:1:size(oThisEachOptical.Beats.Indexes,1), ...
        'b', 'Activation', 'HalfSignalMagnitude');
    % % %     %save files
    [pathstr, name, ext, versn] = fileparts(sAvFileName);
    oThisAvOptical.Save([pathstr,'\',name,'.mat']);
    fprintf('Saved %s\n', [pathstr,'\',name,'.mat']);
    [pathstr, name, ext, versn] = fileparts(sEachFileName);
    oThisEachOptical.Save([pathstr,'\',name,'.mat']);
    fprintf('Saved %s\n', [pathstr,'\',name,'.mat']);
    toc;
end

