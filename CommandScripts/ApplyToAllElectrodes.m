%load other file
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001\CCh001a_g10_LP100Hz-waveEach');
for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
    ans.oGuiHandle.oOptical.Electrodes(i).arsps.Map = oOptical.Electrodes(i).abhsm.Map;
end