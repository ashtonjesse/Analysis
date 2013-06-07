clear all;
sFile = 'D:\Users\jash042\Documents\PhD\Experiments\ElectrodeArray\Array_20130429.cnfg';
oUnemap = Unemap();
oArrayInfo = cell(18,16,3);
iNumberOfElectrodes = 288;
iElectrodeCount = 0;
%Open the file and put into fid handle
fid = fopen(sFile);
%Get and discard the first 2 lines
tline1 = fgets(fid);
tline2 = fgets(fid);
tline = fgets(fid);
%Loop while there are new lines
while ischar(tline)
    %Split the current line on the :
    [~,~,~,~,~,~,splitstring] = regexpi(tline,':');
    %Trim any white space off the split strings
    sField = strtrim(char(splitstring(1,1)));
    oValue  = strtrim(char(splitstring(1,2)));
    switch (sField)
        case 'electrode'
            %Increment the electrode count
            iElectrodeCount = iElectrodeCount + 1;
            
            %Check to see if the electrode count has reached
            %the maximum
            if iElectrodeCount > iNumberOfElectrodes
                break
            end
            %Get the col and row info
            [row, col] = oUnemap.GetRowColIndexesForElectrode(iElectrodeCount);
            %Insert details into cell array
            oArrayInfo(row, col,1) = {tline};
        case 'position'
            %Insert details into cell array
            oArrayInfo(row, col,3) = {tline};
        case 'channel'
            %Insert details into cell array
            oArrayInfo(row, col,2) = {tline};
    end
    tline = fgets(fid);
end
fclose(fid);
%Flip the arrays
oArrayInfo(:,:,1) = flipud(oArrayInfo(:,:,1));
oArrayInfo(:,:,2) = flipud(oArrayInfo(:,:,2));
oArrayInfo(:,:,3) = flipud(oArrayInfo(:,:,3));

%create a new file
sNewFile = 'D:\Users\jash042\Documents\PhD\Experiments\ElectrodeArray\Array_20130429_layout.cnfg';
fSaveId = fopen(sNewFile,'w');
%write out headers
fprintf(fSaveId,'%s',tline1);
fprintf(fSaveId,'%s',tline2);
%loop through all electrodes and print out
for j = 1:size(oArrayInfo,2)
    for i = 1:size(oArrayInfo,1)
        fprintf(fSaveId,'%s',cell2mat(oArrayInfo(i,j,1)));
        fprintf(fSaveId,'%s',cell2mat(oArrayInfo(i,j,2)));
        fprintf(fSaveId,'%s',cell2mat(oArrayInfo(i,j,3)));
    end
end
fclose(fSaveId);