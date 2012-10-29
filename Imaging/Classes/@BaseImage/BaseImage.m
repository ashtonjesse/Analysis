classdef BaseImage < BaseEntity
    %   The BaseImage Class.
    %   The base handle class for an image
        
    properties 
        Data;
        Name;
        sClass;
    end
        
    methods
        function oImage = BaseImage(varargin)
            %% Constructor
            oImage = oImage@BaseEntity();
            oImage.oDAL = ImageDAL();
            if nargin > 0
                oImage.Data = varargin{1};
                oImage.Name = varargin{2};
                oImage.sClass = class(oImage.Data);
            end
        end
    end
    
    methods (Access = public)
        %% Public methods
        function oImage = GetImageEntityFromMATFile(oImage, sFile)
            %   Create an ImageEntity from a mat file

            %   Load the mat file into the workspace
            oData = oImage.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 

        end
        
        function oImage = GetImageEntityFromFile(oImage, sFile, sFormat)
            %   Get an entity by loading an image from an image file - only done the
            %   first time you are creating an ImageEntity
            
            %   Get the path
            [sPath, sName] = fileparts(sFile);
            
            % Get the image data
            oImage = oImage.oDAL.ReadImageFromFile(sFile, sFormat);
            oImage.Name = sName;
            oImage.sClass = class(oImage.Data);
        end
        
        function ConvertToGrayScale(oImage)
            %Convert image data to double 
            oImage.Data = double(im2uint8(oImage.Data));
        end
    end
    
    
end