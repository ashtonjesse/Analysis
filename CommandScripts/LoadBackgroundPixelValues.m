%this script loops through a set of oOptical entities and loads background
%pixel values into the electrode array

aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003' ... %example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003' ... %lots of competition on the way down. worth fitting DD
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001' ... %another good example of uncoupling
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001' ... %superior shift prior to inferior 
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001' ...
    }};

for p = 1:1
    aFolder = aControlFiles{p};
    
    [pathstr, name, ext, versn] = fileparts(char(aFolder{1}));
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), '\');
    [startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(char(aFolder{1}), splitStr{end-1});
    sStimulationType = splitStr{end}(1:end-3);
    switch (sStimulationType)
        case {'baro','chemo'}
            for j = 1:numel(aFolder)
                %load the optical file
                listing = dir(aFolder{j}); %names of files vary so just get all the files in dir
                aFilesInFolder = {listing(:).name}; %convert to cell array
                aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
                aOpticalFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
                oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
                fprintf('Loaded %s\n', aOpticalFileName);
                aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.csv']); %find index of CSV file
                aCSVFileName = [aFolder{j},'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
                %load background values
                oOptical.oDAL.GetBackgroundValuesFromCSV(oOptical, aCSVFileName);
                %compute dff0
                
                oOptical.Save(aOpticalFileName);
                fprintf('Saved %s\n', aOpticalFileName);
            end
    end
end
