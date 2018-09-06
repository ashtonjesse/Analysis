classdef BaseFigure < handle
    %   BaseFigure
    %   This is the base figure class from which all other figures inherit
    
    properties
        oGuiHandle;
        sFigureTag;
        oDAL;
        oZoom;
    end
    
    methods
        %% Constructor
        function oFigure = BaseFigure(sGuiFileName,OpeningFcn)
            %Class constructor - creates and initialises the gui. 
            
            %Get the DAL for this class
            oFigure.oDAL = BaseFigureDAL();
            gui_Singleton = 0;
            gui_State = struct('gui_Name',sGuiFileName, 'gui_Singleton',  gui_Singleton, 'gui_OpeningFcn', OpeningFcn, 'gui_OutputFcn',  @BaseFigure_OutputFcn, 'gui_LayoutFcn',  [] , 'gui_Callback',   []);
            %Make the gui figure, get its handles and store locally
            oOutput = gui_mainfcn(gui_State);
            oFigure.oGuiHandle = guihandles(oOutput);            
            
            %Set the figure tag
            oFigure.sFigureTag = strcat(sGuiFileName,'Fig');
            %Create a zoom object
            oFigure.oZoom = zoom(oFigure.oGuiHandle.(oFigure.sFigureTag));
            
            % --- Outputs from this function are returned to the command line.
            % Currently don't need to use this function but need it is here to get
            % gui_mainfcn to work without me having to overload it and
            % rewrite it
            function varargout = BaseFigure_OutputFcn(hObject, eventdata, handles)
                % varargout  cell array for returning output args (see VARARGOUT);
                % hObject    handle to figure (not initialised properly)
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see
                % GUIDATA) (not initialised properly)
                % Get default command line output from handles structure
                varargout{1} = handles.output;
            end
            
        end
    end
    
    methods (Access = protected)
        %% Delete and exit methods
        function deleteme(oFigure)
            %Class deconstructor - handles the cleaning up of the class &
            %figure. Either the class or the figure can initiate the closing
            %condition, this function makes sure both are cleaned up
            
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', '');
            
            %delete the figure
            delete(oFigure.oGuiHandle.(oFigure.sFigureTag));
            %clear out the pointer to the figure - prevents memory leaks
            oFigure.oGuiHandle = [];
        
        end
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            %   Get the value of the selection made in the specified
            %   popupmenu
            aString = get(oFigure.oGuiHandle.(sPopUpMenuTag),'String');
            iIndex = get(oFigure.oGuiHandle.(sPopUpMenuTag),'Value');
            nValue = aString(iIndex);
            % Make sure output are of type double
            nValue = str2double(char(nValue));
        end
        
        function sValue = GetPopUpSelectionString(oFigure,sPopUpMenuTag)
            %   Get the value of the selection made in the specified
            %   popupmenu
            aString = get(oFigure.oGuiHandle.(sPopUpMenuTag),'String');
            iIndex = get(oFigure.oGuiHandle.(sPopUpMenuTag),'Value');
            sValue = aString(iIndex);
        end
        
        function PrintFigureToFile(oFigure, sFilePath)
            %print(oFigure.oGuiHandle.(oFigure.sFigureTag),'-dpng','-r500',sFilePath);
            [pathstr, name, ext, versn] = fileparts(sFilePath);
            switch (ext)
                case '.bmp'
                    print(oFigure.oGuiHandle.(oFigure.sFigureTag),'-dbmp','-r300',sFilePath)
                case '.eps'
                    print(oFigure.oGuiHandle.(oFigure.sFigureTag),'-dpsc','-r300',sFilePath)
            end
        end
        
        function nValue = GetSliderIntegerValue(oFigure, sSliderTag)
            dCurrentValue = get(oFigure.oGuiHandle.(sSliderTag),'Value');
            if ~isinteger(dCurrentValue)
                %Round down to nearest integer if a double is supplied
                nValue = round(dCurrentValue);
            end
        end
        
        function nValue = GetEditInputDouble(oFigure,varargin)
            %   Get the value entered by the user into the edit box
            
            %check inputs
            if nargin == 2
                sEditTag = char(varargin{1});
                aString = get(oFigure.oGuiHandle.(sEditTag),'String');
                if iscell(aString)
                    aString = aString{1};
                end
            elseif nargin == 3
                oParent = varargin{1};
                oChildren = get(oParent,'children');
                sEditTag = varargin{2};
                oEdit = oFigure.oDAL.oHelper.GetHandle(oChildren,sEditTag);
                aString = get(oEdit,'String');
            else
                error('BaseFigure:GetEditInputDouble:VerifyInputs.','Wrong number of inputs entered.');
            end
            if ~isempty(aString) && ~isempty(str2num(aString))
                nValue = str2double(aString);
            else
                nValue = 0;
            end
        end
    end
end

