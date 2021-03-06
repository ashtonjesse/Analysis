%This command script opens a set of unemap files and rejects the electrodes
%specified by a different unemap file
% fprintf('Running... \n');
% %Load the specified file
% oUnemapTemplate = GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20111124\B_dx_1408_unemap.mat');
% oUnemapToChange = GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20111124\B_dy_1408_unemap.mat');
% 
% %Loop through the electrodes
% for i = 1:length(oUnemapTemplate.Electrodes)
%     if oUnemapTemplate.Electrodes(i).Accepted
%         oUnemapToChange.Electrodes(i).Accepted = 1;
%     else
%         oUnemapToChange.Electrodes(i).Accepted = 0;
%     end
% end
% fprintf('Saving... \n');
% %save the changed unemap
% oUnemapToChange.Save('D:\Users\jash042\Documents\PhD\Analysis\Database\20111124\B_dy_1408_unemap.mat');
% fprintf('Done\n');

%This command script opens a set of unemap files and rejects the electrodes
%specified by a different unemap file
fprintf('Running... \n');
%Load the specified file
sTemplateFile = 'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Optical_g10.mat';
sFiletoChange = 'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Optical_g10_LP100Hz.mat';
oOpticalTemplate = GetOpticalFromMATFile(Optical,sTemplateFile);
oOpticalToChange = GetOpticalFromMATFile(Optical,sFiletoChange);

%Loop through the electrodes
for i = 1:length(oOpticalTemplate.Electrodes)
    if oOpticalTemplate.Electrodes(i).Accepted
        oOpticalToChange.Electrodes(i).Accepted = 1;
    else
        oOpticalToChange.Electrodes(i).Accepted = 0;
    end
end
fprintf('Saving... \n');
%save the changed unemap
oOpticalToChange.Save(sFiletoChange);
fprintf('Done\n');