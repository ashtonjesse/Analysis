%load other file
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\CCh002c_g10_LP100Hz-waveEach');
aMap = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,'amsps','Map');
ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper, ans.oGuiHandle.oOptical.Electrodes,'ryhsm','Map',aMap);

% for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
%     if ans.oGuiHandle.oOptical.Electrodes(i).Background < 0
%         ans.oGuiHandle.oOptical.Electrodes(i).Processed.Data = -ans.oGuiHandle.oOptical.Electrodes(i).Processed.Data;
%         ans.oGuiHandle.oOptical.Electrodes(i).Background = -ans.oGuiHandle.oOptical.Electrodes(i).Background;
%         ans.oGuiHandle.oOptical.FinishProcessing(i);
%         disp(i);
%     end
% end
% ans.oGuiHandle.oOptical.MarkEvent('amsps');