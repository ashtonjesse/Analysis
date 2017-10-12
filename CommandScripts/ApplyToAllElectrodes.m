%load other file
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\CCh002c_g10_LP100Hz-waveEach');
aMap = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,'arsps','Map');
ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper, ans.oGuiHandle.oOptical.Electrodes,'aghsm','Map',aMap);

% for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
%     ans.oGuiHandle.oOptical.Electrodes(i).arsps.Map = true(86,1);
% end