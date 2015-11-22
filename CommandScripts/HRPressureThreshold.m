close all;
% clear all;
% % open all the files 
% aFiles = {...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat' ...
%     };
% aPressureData = cell(1,numel(aFiles));
% for i = 1:numel(aFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aFiles{i}));
% end
% aIndices = ones(numel(aFiles),1);
% aIndices(1) = 2;
% warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
% HRBaroFunction_GetPressureThreshold_constrained(aFiles,aPressureData,aIndices);
% 
for i = 1:numel(aFiles)
    aPressureData{i}.Threshold = aRange(i,1);
    aPressureData{i}.Save(char(aFiles{i}));
    fprintf('Saved file %s\n',char(aFiles{i}));
end