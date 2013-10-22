classdef ImageDAL < BaseDAL
    % ImageDAL is the DAL class for entities that inherit from the
    % BaseImage class
    
    methods
        function oImageDAL = ImageDAL()
            %%  Constructor
            oImageDAL = oImageDAL@BaseDAL();
        end
    end
   
    methods (Access = public)
        function ImageData = ReadImageFromFile(oImageDAL, sFile, sFormat)
            %Reads an image from file
            
            %Load the image data from the file
            ImageData = imread(sFile, sFormat);
        end
        
        function SaveImageToFile(oImageDAL, oImage, sFilePath, sFormat)
            %Save an image to file with the given format
            imwrite(oImage.Data, sFilePath, sFormat);
        end
    end
end