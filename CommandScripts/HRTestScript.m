close all;
% clear all;
% % % open all the files 
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat' ...
%     };
% aPressureData = cell(1,numel(aFiles));
% for i = 1:numel(aFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aFiles{i}));
% end
aIndices = ones(numel(aFiles),1);
aIndices(1) = 2;
HRBaroFunction_GetPressureThreshold(aFiles,aPressureData,aIndices);



