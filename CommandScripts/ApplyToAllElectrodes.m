%load other file
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\CCh002c_g10_LP100Hz-waveEach');
for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
    ans.oGuiHandle.oOptical.Electrodes(i).aghsm.Map =  ans.oGuiHandle.oOptical.Electrodes(i).arsps.Map;
end

% for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
%     ans.oGuiHandle.oOptical.Electrodes(i).arsps.Map = true(86,1);
% end