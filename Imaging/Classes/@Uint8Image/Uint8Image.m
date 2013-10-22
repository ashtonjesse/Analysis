classdef Uint8Image < BaseImage
    %   The Uint8Image Class.
    %   The  handle class for an uint8 image
        
    properties 
        BinaryImage;
    end
        
    methods
        function oImage = Uint8Image(varargin)
            %% Constructor
            oImage = oImage@BaseImage(varargin);
        end
    end
    
    methods (Access = public)
        function oImage = GetBinaryImageFromFile(oImage, sFile, sFormat)
            %Call the original method first
            %   Get the path
            [sPath, sName] = fileparts(sFile);
            
            % Get the image data
            oImage.BinaryImage = oImage.oDAL.ReadImageFromFile(sFile,sFormat);
            oImage.BinaryImage = im2bw(oImage.BinaryImage,0);
            
        end
    end
end