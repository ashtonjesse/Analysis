%this script opens a bunch of pressure files and calculates the mean
%pressure and rate during the plateau phase and plots all these data points
%on a scatter plot

close all;
clear all;
% %specify the files
aControlFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat' ...
    };

aIVBFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat', ... 
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat' ...
    };

% aControlFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro002\Pressure.mat', ...
%         'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'...
%     };

% aControlFiles = {{'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro002\Pressure.mat', ...
%         'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro007\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro009\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro009\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'}...
%     };

% aControlFiles = {{'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro002\Pressure.mat', ...
%         'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140612\20140612baro007\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140630\20140630baro009\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro009\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'},...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'}, ...
%     {'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat', ... %'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat'} ...
%     };

% % % % %get the data from these files
aControlPressureData = cell(numel(aControlFiles),1);
for i = 1:numel(aControlPressureData)
    aControlPressureData{i} = GetPressureFromMATFile(Pressure,char(aControlFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aControlFiles{i}));
end
% aControlPressureData = cell(numel(aControlFiles),1);
% for i = 1:numel(aControlPressureData)
%     aFiles = aControlFiles{i};
%     aCellArray = cell(numel(aFiles),1);
%     for j = 1:numel(aFiles)
%         aCellArray{j} = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
%         fprintf('Got file %s\n',char(aFiles{j}));
%     end
%     aControlPressureData{i} = aCellArray;
% end

% % %get the data from these files
aIVBPressureData = cell(numel(aIVBFiles),1);
for i = 1:numel(aIVBPressureData)
    aIVBPressureData{i} = GetPressureFromMATFile(Pressure,char(aIVBFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aIVBFiles{i}));
end
% 
% %loop through control files and calculate means
% %intialise arrays
aControlPressureDuration = zeros(numel(aControlFiles),1);
aControlHRDuration = zeros(numel(aControlFiles),1);
aControlNormalisedDuration = zeros(numel(aControlFiles),1);
aControlMeanBaselineRate = zeros(numel(aControlFiles),1);
aControlMeanPlateauPressure = zeros(numel(aControlFiles),1);
aControlMeanPlateauRate = zeros(numel(aControlFiles),1);
for i = 1:numel(aControlFiles)
    oPressure = aControlPressureData{i};
    aControlPressureDuration(i) = oPressure.Plateau.BeatTimes(end) -  oPressure.Plateau.BeatTimes(1);
    aControlHRDuration(i) = oPressure.HeartRate.Plateau.BeatTimes(end) -  oPressure.HeartRate.Plateau.BeatTimes(1);
    aControlNormalisedDuration(i) = (aControlHRDuration(i)/aControlPressureDuration(i))*100;
    aControlMeanPlateauRate(i) = mean(oPressure.HeartRate.Plateau.BeatRates);
    aControlMeanBaselineRate(i) = mean(oPressure.Baseline.BeatRates);
    aControlMeanPlateauPressure(i) = mean(oPressure.Plateau.BeatPressures);
end

% aControlPressureDuration = cell(size(aControlPressureData));
% aControlHRDuration = cell(size(aControlPressureData));
% aControlNormalisedDuration = cell(size(aControlPressureData));
% aControlMeanBaselineRate = cell(size(aControlPressureData));
% aControlMeanPlateauPressure = cell(size(aControlPressureData));
% aControlMeanPlateauRate = cell(size(aControlPressureData));
% for i = 1:numel(aControlPressureData)
%     aCellArray = aControlPressureData{i};
%     aControlPressureDuration{i} = zeros(numel(aCellArray),1);
%     aControlHRDuration{i} = zeros(numel(aCellArray),1);
%     aControlNormalisedDuration{i} = zeros(numel(aCellArray),1);
%     aControlMeanBaselineRate{i} = zeros(numel(aCellArray),1);
%     aControlMeanPlateauPressure{i} = zeros(numel(aCellArray),1);
%     aControlMeanPlateauRate{i} = zeros(numel(aCellArray),1);
%     for j = 1:numel(aCellArray)
%         oPressure = aCellArray{j};
%         aControlPressureDuration{i}(j) = oPressure.Plateau.BeatTimes(end) -  oPressure.Plateau.BeatTimes(1);
%         if isempty(oPressure.HeartRate.Plateau.BeatRates)
%             aControlHRDuration{i}(j) = NaN;
%             aControlNormalisedDuration{i}(j) = NaN;
%             aControlMeanPlateauRate{i}(j) = NaN;
%         else
%             aControlHRDuration{i}(j) = oPressure.HeartRate.Plateau.BeatTimes(end) -  oPressure.HeartRate.Plateau.BeatTimes(1);
%             aControlNormalisedDuration{i}(j) = (aControlHRDuration{i}(j)/aControlPressureDuration{i}(j))*100;
%             aControlMeanPlateauRate{i}(j) = mean(oPressure.HeartRate.Plateau.BeatRates);
%         end
%         aControlMeanBaselineRate{i}(j) = mean(oPressure.Baseline.BeatRates);
%         aControlMeanPlateauPressure{i}(j) = mean(oPressure.Plateau.BeatPressures);
%     end
% end


% % %repeat for IVB files
aIVBPressureDuration = zeros(numel(aIVBFiles),1);
aIVBHRDuration = zeros(numel(aIVBFiles),1);
aIVBNormalisedDuration = zeros(numel(aIVBFiles),1);
aIVBMeanBaselineRate = zeros(numel(aControlFiles),1);
aIVBMeanPlateauPressure = zeros(numel(aControlFiles),1);
aIVBMeanPlateauRate = zeros(numel(aControlFiles),1);
for j = 1:numel(aIVBFiles)
    oPressure = aIVBPressureData{j};
    aIVBPressureDuration(j) = oPressure.Plateau.BeatTimes(end) -  oPressure.Plateau.BeatTimes(1);
    aIVBHRDuration(j) = oPressure.HeartRate.Plateau.BeatTimes(end) -  oPressure.HeartRate.Plateau.BeatTimes(1);
    aIVBNormalisedDuration(j) = (aIVBHRDuration(j)/aIVBPressureDuration(j))*100;
    aIVBMeanPlateauRate(j) = mean(oPressure.HeartRate.Plateau.BeatRates);
    aIVBMeanBaselineRate(j) = mean(oPressure.Baseline.BeatRates);
    aIVBMeanPlateauPressure(j) = mean(oPressure.Plateau.BeatPressures);
end

% % %plot results on scatter


% oColors = distinguishable_colors(numel(aControlPressureData));
% for m = 1:numel(aControlPressureData)
%     oScatter = scatter(oMeanRatesAxes,aMeanControlPressure{m},aMeanControlRate{m},'o','sizedata',50,'markeredgecolor',oColors(m,:),'markerfacecolor',oColors(m,:));
%     %     if m == numel(aControlPressureData) - 1
%     %         set(oScatter,'displayname','Pre-IVB');
%     %     elseif m == numel(aControlPressureData)
%     %         set(oScatter,'displayname','Post-IVB');
%     %     else
%     %         [~, ~, ~, ~, ~, ~, splitStr] = regexp(aControlFiles{m}{1}, '\');
%     %         set(oScatter,'displayname',char(splitStr(end-2)));
%     %     end
%     [~, ~, ~, ~, ~, ~, splitStr] = regexp(aControlFiles{m}{1}, '\');
%     set(oScatter,'displayname',char(splitStr(end-2)));
%     hold(oMeanRatesAxes,'on');
% end
% hold(oMeanRatesAxes,'off');
% legend(oMeanRatesAxes,'show');
figure();
bplot(aControlPressureDuration,1);
hold on;
bplot(aIVBPressureDuration,2,'nolegend');
hold off;
oAxes = gca;
set(oAxes,'xlim',[0.5 2.5]);
set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
set(get(oAxes,'ylabel'),'string','Pressure challenge duration (s)');
figure();
bplot(aControlHRDuration,1);
hold on;
bplot(aIVBHRDuration,2,'nolegend');
hold off;
oAxes = gca;
set(oAxes,'xlim',[0.5 2.5]);
set(oAxes,'xticklabel',{'','Pre-IVB','','Post-IVB',''});
set(get(oAxes,'ylabel'),'string','Maximum atrial rate response duration (s)');