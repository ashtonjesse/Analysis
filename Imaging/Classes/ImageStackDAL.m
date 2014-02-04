classdef ImageStackDAL < BaseDAL
    % ImageStackDAL is the DAL class for ImageStack entities 
    
    methods
        function oImageStackDAL = ImageStackDAL()
            %%  Constructor
            oImageStackDAL = oImageStackDAL@BaseDAL();
        end
    end
   
    methods (Access = public)
        function oImageStack = ReadDataFromFile(oImageStackDAL,sFile,sStackName)
            %Reads data from a mat file and returns an image entity
            
            %Create the ImageStack entity
            oImageStack = ImageStack();
            %Load the data
            oStruct = load(sFile);
            %Access data
            aData = oStruct(1).(sStackName);
            %Loop through images in stack
            for k = 1:size(aData,3)
                %Create image
                oImage =  BaseImage(aData(:,:,k),strcat(sStackName,sprintf('%d',k)));
                switch (oImage.sClass)
                    case 'single'
                        oImage.ConvertToGrayScale();
                end
                oImageStack.oImages(k) = oImage;
            end
            oImageStack.Name = sStackName;
        end
        
        function oImageStack = CreateStackFromData(oImageStackDAL, oStruct, sStackName, sFormat)
            %Reads data from a mat file that hasn't necessarily been saved as a
            %ImageStack entity
            %Create the ImageStack entity
            oImageStack = ImageStack();
            %Access data
            aData = oStruct(1).(sStackName);
            
            %get some info from one of the images
            oFirstImage = BaseImage(aData(:,:,1),'FirstImage');
            %Initialise the stack images array
            ImageStruct = struct('oImages',zeros(size(oFirstImage.Data),oFirstImage.sClass));
            aImages = repmat(ImageStruct, size(aData,3),1);
            oImageStack.oImages = aImages;
            %Loop through images in stack
            for k = 1:size(aData,3)
                %Create image
                oImage =  BaseImage(aData(:,:,k),strcat(sStackName,sprintf('%d',k)));
                switch (oImage.sClass)
                    case 'single'
                        oImage.ConvertToGrayScale();
                end
                oImageStack.oImages(k) = oImage;
            end
        end
    end
end