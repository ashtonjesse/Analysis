classdef ImageStack < BaseEntity
    %   ImageStack is a class that contains an array of Images of BaseImage
    %   class and inherits from BaseEntity
    
    properties
        oImages = BaseImage();
    end
    
    methods
        function oStack = ImageStack()
            %% Constructor
            oStack = oStack@BaseEntity();
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oStack,sPath)
            SaveEntity@BaseEntity(oStack,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oStack,sPath)
            SaveEntity(oStack,sPath);
        end
        %% Class specific methods
        
        function oStack = GetImageStackFromMATFile(oStack, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oStack.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oStack.oImages = oData.oEntity.oImages;
        end
        
        function SaveStackImages(oStack, sPath, sFormat)
            %Save images in stack to file by format
            for i = 1:length(oStack.oImages)
                sFileName = strcat(sPath,'\',oStack.oImages(i).Name,'.',sFormat);
                oStack.oImages(i).oDAL.SaveImageToFile(oStack.oImages(i), sFileName, sFormat);
            end
        end
    end
end