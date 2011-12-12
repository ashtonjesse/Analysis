% This script allows user to rewrite the fileDirect.mat file easily
global fileDirect; 

motherS = which('MainMother.m');
[pathMotherS nameMotherS typeMotherS] = fileparts(motherS);
fileDfullpath = fullfile(pathMotherS,['fileDirect' '.mat']);
fileDExist = exist(fileDfullpath,'file');
% if(fileDExist)
%     disp('Using Last DIR');
%     load(fileDfullpath);
% else
fileDirect.GEO = 'D:\Users\jash042\Documents\PhD\Analysis\ETC01\';
fileDirect.DATA = 'D:\Users\jash042\Documents\PhD\Analysis\envelopesubtraction';
fileDirect.pathMotherShip = pathMotherS;
fileDirect.fileDfullpath = fileDfullpath;
fileDirect.currentfile = '';
save(fileDfullpath,'fileDirect')
% end