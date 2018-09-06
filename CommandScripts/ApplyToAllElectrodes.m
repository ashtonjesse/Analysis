%load other file
% oOptical = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\CCh002c_g10_LP100Hz-waveEach');
% aMap = MultiLevelSubsRef(ans.oGuiHandle.oOptical.oDAL.oHelper,ans.oGuiHandle.oOptical.Electrodes,'amsps','Map');
% ans.oGuiHandle.oOptical.Electrodes = MultiLevelSubsAsgn(ans.oGuiHandle.oOptical.oDAL.oHelper, ans.oGuiHandle.oOptical.Electrodes,'ryhsm','Map',aMap);

% for i = 1:numel(ans.oGuiHandle.oOptical.Electrodes)
%     if ans.oGuiHandle.oOptical.Electrodes(i).Background < 0
%         ans.oGuiHandle.oOptical.Electrodes(i).Processed.Data = -ans.oGuiHandle.oOptical.Electrodes(i).Processed.Data;
%         ans.oGuiHandle.oOptical.Electrodes(i).Background = -ans.oGuiHandle.oOptical.Electrodes(i).Background;
%         ans.oGuiHandle.oOptical.FinishProcessing(i);
%         disp(i);
%     end
% end
% ans.oGuiHandle.oOptical.MarkEvent('amsps');
sFile = 'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\CCh002a_g10_LP100Hz-waveEach.mat';
sFile2 = 'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\CCh002b_g10_LP100Hz-waveEach.mat';
% oOptical = GetOpticalFromMATFile(Optical, sFile);
% oOptical2 = GetOpticalFromMATFile(Optical, sFile2);
% aAMSPSData2 = PrepareEventData(oOptical2, 100, 'Contour', 'amsps', 1,
% []);
aMap = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'arsps','Map');
aMap2 = MultiLevelSubsRef(oOptical2.oDAL.oHelper,oOptical2.Electrodes,'arsps','Map');
aMap3 = repmat(aMap(1,:),size(oOptical2.Beats.Indexes,1),1);
oOptical2.Electrodes = MultiLevelSubsAsgn(oOptical2.oDAL.oHelper, oOptical2.Electrodes,'arsps','Map',aMap3);
oOptical2.Save(sFile2);
fprintf('Saved %s\n', sFile2);

% aControlFiles = {{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ...
%     }};
% 
% for p = 1:numel(aControlFiles)
%     aFolder = aControlFiles{p};
%     [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
%     [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
%     [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
%     sStimulationType = splitStr{end}(1:end-3);
%     for j = 1:numel(aFolder)
%         %load the optical file
%         listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
%         aFilesInFolder = {listing(:).name}; %convert to cell array
%         aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%         aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
%         oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
%         fprintf('Loaded %s\n', aOpticalFileName);
%         %get exit
%         %         aExit = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'arsps','Exit');
%         aAccess = [oOptical.Electrodes(:).AxisPoint];
%         ind = find(aAccess);
%         clear oOptical;
%         clear aOpticalFileName;
% 
%         switch (p)
%             case {1,3} %CCh
%                 aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*c?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%             case {2} %CCh
%                 aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*d?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%         end
%         aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
%         oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
%         fprintf('Loaded %s\n', aOpticalFileName);
%         [oOptical.Electrodes(:).AxisPoint] = deal(false);
%         [oOptical.Electrodes(ind).AxisPoint] = deal(true);
%         oOptical.Save(aOpticalFileName);
%         fprintf('Saved %s\n', aOpticalFileName);
%     end
% end
