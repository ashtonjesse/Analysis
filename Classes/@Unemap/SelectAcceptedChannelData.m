function aChannelData = SelectAcceptedChannelData(oUnemap,varargin)
switch size(varargin,2);
    case 2
        %Get the inputs
        aStruct = cell2mat(varargin(1,1));
        sFirstField = char(varargin(1,2));
        %Find the nonzero columns in the array of Accepted
        %values within the struct - will throw an error if
        %there is no Accepted field
        [rowIndexes, colIndexes, vector] = find(cell2mat({aStruct(:).Accepted}));
        %Select the data associated with these indexes
        aChannelData = cell2mat({aStruct(colIndexes).(sFirstField)});
    case 3
        %get the inputs
        aStruct = cell2mat(varargin(1,1));
        sFirstField = char(varargin(1,2));
        sSecondField = char(varargin(1,3));
        %Find the nonzero columns in the array of Accepted
        %values within the struct - will throw an error if
        %there is no Accepted field
        [rowIndexes, colIndexes, vector] = find(cell2mat({aStruct(:).Accepted}));
        %Select the data
        aData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aStruct,sFirstField,sSecondField);
        %restrict the data to just these indexes
        aChannelData = aData(:,colIndexes);
        
end
end
