classdef ImageStackDAL < BaseDAL
    % ImageStackDAL is the DAL class for ImageStack entities 
    
    methods
        function oImageStackDAL = ImageStackDAL()
            %%  Constructor
            oImageStackDAL = oImageStackDAL@BaseDAL();
        end
    end
   
    methods (Access = public)
        function oImageStack = ReadDataFromFile(oImageDAL,sFile,sStackName)
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
    end
end