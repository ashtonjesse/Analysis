%This scipt obtains the x and y coordinates of all pacemaker locations
%across all recordings and all experiments for baroreflex, chemoreflex and
%CCh and saves the result to new location data files

close all;
% % set files of interest
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003' ...%4-9 rejected due to change in baseline rate aDistance includes baro008
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003'...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo002' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo002' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo002' ...
% %     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh003' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002' ...%a&c
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004' ...%b&d
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh001' ...%a&d
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821CCh002' ...%?not sure whether I should use this one
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826CCh002' ...
%     },{...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh001' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh002' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828CCh003' ...
     }};


%update origins
for p = 10
    aFolder = aControlFiles{p};
    %get the location data
    [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
    sStimulationType = splitStr{end}(1:end-3);
    oFigure = figure();
    set(oFigure,'position',[131 9 1779 988]);
    oSubPlot = panel(oFigure);
    oSubPlot.pack(2,5);
    iRow = 1;
    iCol = 1;
    switch (sStimulationType)
        case {'baro','chemo'}
            for j = 1:numel(aFolder)

                oMapAxes = oSubPlot(iRow,iCol).select();
                oSchematicAxes = axes('parent',oFigure,'position',get(oMapAxes,'position'));
                %load the optical file
                listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
                aFilesInFolder = {listing(:).name}; %convert to cell array
                if strcmpi(sStimulationType,'chemo') && p == 3 && j == 1
                    sSearchString = '\d*b?_\w*g10_LP100Hz-waveEach.mat';
                else
                    sSearchString = '\d*a?_\w*g10_LP100Hz-waveEach.mat';
                end
                aFileIndex = regexp(aFilesInFolder, [sStimulationType,sSearchString]); %find index of right file
                aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
                oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
                fprintf('Loaded %s\n', aOpticalFileName);
                sFilePath = oOptical.oExperiment.Optical.SchematicFilePath;
                sGuideFile = strrep(sFilePath, '.bmp', '_guide.bmp');
                oImage = imshow(sGuideFile,'Parent', oSchematicAxes, 'Border', 'tight');
                %make it transparent in the right places
                aCData = get(oImage,'cdata');
                aBlueData = aCData(:,:,3);
                aAlphaData = aCData(:,:,3);
                aAlphaData(aBlueData < 100) = 1;
                aAlphaData(aBlueData > 100) = 1;
                aAlphaData(aBlueData == 100) = 0;
                aAlphaData = double(aAlphaData);
                set(oImage,'alphadata',aAlphaData);
                set(oSchematicAxes,'box','off','color','none');
                axis(oSchematicAxes,'tight');
                axis(oSchematicAxes,'off');
                axis(oSchematicAxes, 'equal');
                
                %Get the electrodes
                oElectrodes = oOptical.Electrodes;
                aCoords = cell2mat({oElectrodes(:).Coords});
                aAccepted = MultiLevelSubsRef(oOptical.oDAL.oHelper,...
                    oOptical.Electrodes,'Accepted');
                aAcceptedCoords = aCoords(:,logical(aAccepted));
                %Get the number of channels
                [i NumChannels] = size(oElectrodes);
                %Loop through the electrodes plotting their locations
                
                %Plot the electrode point
                hold(oMapAxes,'on');
                %Just plotting the electrodes so add a text label
                scatter(oMapAxes, aAcceptedCoords(1,:), aAcceptedCoords(2,:),'k.', ...
                    'sizedata', 64);%1.5 for posters
                
                aAxisData = cell2mat({oElectrodes(:).AxisPoint});
                oAxesElectrodes = oElectrodes(aAxisData);
                aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
                scatter(oMapAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
                    'sizedata',100,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
                aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linewidth',2,'color','k','parent',oMapAxes);
                axis(oMapAxes, 'equal');
                set(oMapAxes,'xlim',oOptical.oExperiment.Optical.AxisOffsets(1,:),'ylim',oOptical.oExperiment.Optical.AxisOffsets(2,:));
                if ~mod(j,5)
                    iRow = iRow + 1;
                    iCol = 1;
                else
                    iCol = iCol + 1;
                end
            end
%         case 'CCh'
%             aDistance = cell(1,numel(aFolder));
%             for j = 1:numel(aFolder)
%                 %get optical entities
%                 listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
%                 aFilesInFolder = {listing(:).name}; %convert to cell array
%                 aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*[a-z_]\w*g10_LP100Hz-waveEach.mat']); %find index of right file
%                 aOpticalFileName = {aFilesInFolder{find(~cellfun('isempty', aFileIndex),5)}}; %build file name 
%                 %loop through entities
%                 aDistance{j} = cell(1,size(aOpticalFileName,2));
%                 for q = 1:size(aOpticalFileName,2)
%                     oOptical = GetOpticalFromMATFile(Optical,[aFolder{j},'\',char(aOpticalFileName{q})]); %get optical file
%                     fprintf('Loaded %s\n', [aFolder{j},'\',aOpticalFileName{q}]);
%                     %get origin data
%                     aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
%                     % %     loop through beats
%                     aThisCoords = cell(size(aOrigins,1),1);
%                     aThisDistance = NaN(size(aOrigins,1),2);
%                     aPoints = zeros(5,2);
%                     iCount = 1;
%                     dDistance = NaN;
%                     % %     get the axis points
%                     aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
%                     oAxesElectrodes = oOptical.Electrodes(aAxisData);
%                     aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
%                     bFirstPoint = false;
%                     for n = 1:size(aOrigins,1)
%                         aElectrodes = oOptical.Electrodes(aOrigins(n,:));
%                         if ~isempty(aElectrodes)
%                             bFirstPoint = true;
%                             aBeatPoints = cell2mat({aElectrodes(:).Coords});
%                             aThisCoords{n} = aBeatPoints;
%                             for m = 1:size(aBeatPoints,2)
%                                 % % %                 transform coords
%                                 aNewBeatPoints = TransformCoordinates(aAxesCoords(:,2),aAxesCoords(:,1),aBeatPoints(:,m));
%                                 dDistance = aNewBeatPoints(2);
%                                 aThisDistance(n,m) = dDistance;
%                             end
%                         elseif bFirstPoint
%                             aThisDistance(n,1) = dDistance;
%                         end
%                     end
%                     if p == 17 && j == 1 && q == 1 
%                         aDistance{j}{q} = vertcat(aThisDistance(1:35,:),[NaN,NaN],[NaN,NaN],[NaN,NaN],aThisDistance(36:end,:));
%                     else
%                         aDistance{j}{q} = aThisDistance;
%                     end
%                     
%                 end
%             end
    end
end



