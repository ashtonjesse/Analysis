classdef ImageStack < BaseEntity
    %   ImageStack is a class that contains an array of Images of BaseImage
    %   class and inherits from BaseEntity
    
    properties
        oImages = BaseImage();
        Name;
    end
    
    methods
        function oStack = ImageStack()
            %% Constructor
            oStack = oStack@BaseEntity();
            oStack.oDAL = ImageStackDAL();
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
        
        function oStack = GetImageStackFromDataFile(oStack, sFile, sName)
            %   Get an entity by loading a mat file that has NOT been saved
            %   previously and is just a set of image data
            
            oStack = oStack.oDAL.ReadDataFromFile(sFile,sName);
        end
        
        function SaveStackImages(oStack, sPath, sFormat)
            %Save images in stack to file by format
            for i = 1:length(oStack.oImages)
                sFileName = strcat(sPath,'\',oStack.oImages(i).Name,'.',sFormat);
                oStack.oImages(i).oDAL.SaveImageToFile(oStack.oImages(i), sFileName, sFormat);
            end
        end
        
        function oStackVolume = GetStackVolume(oStack)
            %Loop through stack to combine all image data into one array
            %Initialise volume array
            oStackVolume = uint8(zeros(size(oStack.oImages(1).Data,1),size(oStack.oImages(1).Data,2),length(oStack.oImages)));
            for i = 1:length(oStack.oImages)
                oStackVolume(:,:,i) = oStack.oImages(i).Data;
            end
        end
        
        function oNewStack = ResampleStack(oStack, sDimension)
            %Resample the stack images in the dimension specified
            switch (sDimension)
                case 'x'
                    %Create new array of images
                    oResampledImages = BaseImage(size(oStack.oImages(1).Data,2),1);
                    %Initialise image data
                    oResampledImages(:).Data = zeros(length(oStack.oImages),size(oStack.oImages(1).Data,2));
                    % Loop through the images
                    for i = 1:length(oStack.oImages)
                        % Loop through the columns of the image data
                        for j = 1:size(oStack.oImages(1).Data,2)
                            %Set the ith row of each image to be the jth column in
                            %the original image
                            oResampledImages(j).Data(i,:) = oStack.oImages(i).Data(:,j);
                            oResampledImages(j).Name = sprintf('%d',j);
                            %Reconvert resampled images in to appropriate image
                            %class
                            oResampledImages(j).Data = uint8(oResampledImages(j).Data);
                            oResampledImages(j).sClass = 'uint8';
                        end
                    end
                    oNewStack = ImageStack();
                    oNewStack.oImages = oResampledImages;
                case 'y'
                    %Create new array of images
                    oResampledImages = BaseImage(size(oStack.oImages(1).Data,1),1);
                    %Initialise image data
                    oResampledImages(:).Data = zeros(length(oStack.oImages),size(oStack.oImages(1).Data,2));
                    % Loop through the images
                    for i = 1:length(oStack.oImages)
                        % Loop through the rows of the image data
                        for j = 1:size(oStack.oImages(1).Data,1)
                            %Set the ith row of each image to be the jth row in
                            %the original image
                            oResampledImages(j).Data(i,:) = oStack.oImages(i).Data(j,:);
                            oResampledImages(j).Name = sprintf('%d',j);
                            %Reconvert resampled images in to appropriate image
                            %class
                            oResampledImages(j).Data = uint8(oResampledImages(j).Data);
                            oResampledImages(j).sClass = 'uint8';
                        end
                    end
                    oNewStack = ImageStack();
                    oNewStack.oImages = oResampledImages;
            end
        end
    end
end