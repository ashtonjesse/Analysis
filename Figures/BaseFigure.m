classdef BaseFigure < handle
    %   BaseFigure
    %   This is the base figure class from which all other figures inherit
    
    properties
        oGuiHandle;
        sFigureTag;
    end
    
    methods
        %% Constructor
        function oFigure = BaseFigure(sGuiFileName,OpeningFcn)
            %Class constructor - creates and initialises the gui. 

            gui_Singleton = 1;
            gui_State = struct('gui_Name',sGuiFileName, 'gui_Singleton',  gui_Singleton, 'gui_OpeningFcn', OpeningFcn, 'gui_OutputFcn',  @BaselineCorrection_OutputFcn, 'gui_LayoutFcn',  [] , 'gui_Callback',   []);
            %Make the gui figure, get its handles and store locally
            oOutput = gui_mainfcn(gui_State);
            oFigure.oGuiHandle = guihandles(oOutput);            
            
            %Set the figure tag
            oFigure.sFigureTag = strcat(sGuiFileName,'Fig');
            
            % --- Outputs from this function are returned to the command line.
            % Currently don't need to use this function but need it is here to get
            % gui_mainfcn to work without me having to overload it and
            % rewrite it
            function varargout = BaselineCorrection_OutputFcn(hObject, eventdata, handles)
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
        function delete(oFigure)
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
    end
end

