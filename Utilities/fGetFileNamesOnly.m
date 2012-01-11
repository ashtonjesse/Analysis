%Returns a cell array of all the full path names of files with a specified
%extension (sSearchTag) in the specified directory (sDir).

function aFileFull = fGetFileNamesOnly(sDir,sSearchTag)
    cd(sDir);
    %Get an array of files with the extension sSearchTag
    aFiles = dir(sSearchTag);
    %Get the number of files
    iNumFiles = length(aFiles);
    %Initialise a cell array to contain the full file names
    aFileFull = cell(iNumFiles,1);

    for x = 1:iNumFiles 
        %Loop through the files saving there full paths to function output
        aFileFull{x} = fullfile(sDir,aFiles(x,1).name); 
    end
end
