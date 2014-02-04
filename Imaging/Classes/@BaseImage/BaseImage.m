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
                %Can have an empty cell array inside a cell array which
                %returns nargin = 1 but contains no information
                if ~isempty(varargin{1})
                    if iscell(varargin{1}) 
                        if isa(varargin{1}{1},'BaseImage')
                            %If a baseimage is being passed then copy the
                            %appropriate fields over
                            oBaseImageStruct = varargin{1}{1};
                            oImage.Data = oBaseImageStruct.Data;
                            oImage.Name = oBaseImageStruct.Name;
                            oImage.sClass = oBaseImageStruct.sClass;
                        end
                    else
                        %Else the fields have been supplied as arguments
                        oImage.Data = varargin{1};
                        oImage.Name = varargin{2};
                        oImage.sClass = class(oImage.Data);
                    end
                end
            end
        end
    end
    
    methods (Access = public)
        %% Public methods
        function oImage = GetImageEntityFromFile(oImage, sFile, sFormat)
            %   Get an entity by loading an image from an image file - only done the
            %   first time you are creating an ImageEntity
            
            %   Get the path
            [sPath, sName] = fileparts(sFile);
            
            % Get the image data
            oImage.Data = oImage.oDAL.ReadImageFromFile(sFile,sFormat);
            oImage.Name = sName;
            oImage.sClass = class(oImage.Data);
        end
        
        function ConvertToGrayScale(oImage)
            %Convert image data to double 
            oImage.Data = double(im2uint8(oImage.Data));
        end
        
    end
    
    
end