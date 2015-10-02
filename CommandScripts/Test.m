oBasePotential = ans.oGuiHandle.oOptical;
%get all the data\
iBeat = 1;
for j = 1:numel(ans.oGuiHandle.oOptical.Electrodes(1).SignalEvents)
    sSignalEvent = ans.oGuiHandle.oOptical.Electrodes(1).SignalEvents{j};
    RangeStart = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'RangeStart');
    RangeEnd = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'RangeEnd');
    Index = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'Index');
    
    NewRangeStart =  vertcat(RangeStart(1:iBeat-1,:), RangeStart(iBeat+1:end,:));
    NewRangeEnd =  vertcat(RangeEnd(1:iBeat-1,:), RangeEnd(iBeat+1:end,:));
    NewIndex =  vertcat(Index(1:iBeat-1,:), Index(iBeat+1:end,:));
    
    ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'RangeStart',NewRangeStart);
    ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'RangeEnd',NewRangeEnd);
    ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,sSignalEvent,'Index',NewIndex);
    
end
