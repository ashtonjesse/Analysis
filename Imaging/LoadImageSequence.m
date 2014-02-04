function sOutputPath = LoadImageSequence(sDirectory,sExtension,iNumberOfFiles)
    %This function loads all the images in the user specified directory into a
    %struct and saves it into a user specified directory

    %Get the image files present
    sSearchPath = strcat(sDirectory,'/*.',sExtension);
    
    aFiles = dir(sSearchPath);
    oFirstImage = imread(strcat(sDirectory,'/',aFiles(1).name),sExtension);
    if size(oFirstImage,3) > 1
       oFirstImage = rgb2gray(oFirstImage);
    end
    
    %Get length
    iLoopLength = 1;
    if isempty(iNumberOfFiles)
        iLoopLength = length(aFiles);
    else
        iLoopLength = iNumberOfFiles;
    end
    %Intialise an array to store the images
    aImageData = zeros(size(oFirstImage,1), size(oFirstImage,2), iLoopLength,'uint8');
    oNewImage = oFirstImage;
    [~,~,~,~,~,~,splitstring] = regexpi(aFiles(1).name,'0');
    %                 Trim any white space off the split strings
    sBaseName = strtrim(char(splitstring(1,1)));
    sBaseName = strrep(sBaseName,'(','_');
    sBaseName = strrep(sBaseName,')','');
    sBaseName = strrep(sBaseName,'rec','000_000_');
    for i = 1:iLoopLength;
        oNewImage = imread(strcat(sDirectory,'/',aFiles(i).name),sExtension);
        aImageData(:,:,i) = imcomplement(rgb2gray(oNewImage));
        soutfilepath = fullfile(sDirectory,strcat(sBaseName,sprintf('%04d',i),'.png'));
        imwrite(squeeze(aImageData(:,:,i)),soutfilepath,'png');
        disp(soutfilepath);
    end

    %Save the image array
    sOutputPath = strcat(sDirectory,'/SegImage.mat');
%     save(sOutputPath,'aImageData');
    
end