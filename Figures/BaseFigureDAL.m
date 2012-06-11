classdef BaseFigureDAL < handle
    %   BaseFigureDAL is the data access layer super class for figures
    %   This class should contain all methods associated with loading or
    %   saving figures, but not data that is used on figures. 
    
    properties
        oHelper = DataHelper;
    end
    
    methods

        function oBaseFigureDAL = BaseFigureDAL()
            %%  Constructor

        end
    end
    
    methods (Access = public)
        %% Public Methods
       function oFig = LoadFromFile(oBaseFigureDAL)
            %   Loads figure from file
            
            
        end
                
        function sLongDataFileName = SaveFigure(oBaseFigureDAL,oHandle,varargin)
            %Save the figure component specified by the oHandle handle. You
            %can either specify a path to save to or not, in which case a
            %ui dialog will open asking the user to specify a file path
            
            %Check the input args
            if ~isempty(varargin) && size(varargin,2) == 1
                sLongDataFileName = varargin{1,1};
            else
                %Call built-in file dialog to select filename
                [sDataFileName,sDataPathName] = uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';'*.*','All Files' },'Save Image',sDefaultPath);
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                    return
                end
                %Get the full file name and save it to string attribute
                sLongDataFileName = strcat(sDataPathName,sDataFileName);
            end
            
            %Get an image of the figure
            oFrame = getframe(oHandle);
            %Convert frame to image
            [oImage,map] = frame2im(oFrame);
            %Write out image to file
            imwrite(oImage,sLongDataFileName);
        end
        
        
    end
    
end

