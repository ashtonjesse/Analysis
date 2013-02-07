classdef EditControl < SubFigure
% This figure contains a generic edit control

    events
        ValuesEntered;
    end
    
    methods
        %% Constructor
        function oFigure = EditControl(oParent,sInstructions,iNumberOfEdits)
            oFigure = oFigure@SubFigure(oParent,'EditControl',@OpeningFcn);
          
            %Set callbacks
            set(oFigure.oGuiHandle.btnDone, 'callback', @(src, event) btnDone_Callback(oFigure, src, event));
            
            %This figure can be closed by the user
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) oFigure.ParentFigureDeleted(src, event));
            
            % --- Executes just before the figure is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                dPosition = [];
                %Create the edits needed
                for i = 1:iNumberOfEdits
                    if isempty(dPosition)
                        oEdit = uicontrol(handles.oPanel,'Style','edit','tag',sprintf('oEdit_%d',i));
                        dPosition = get(oEdit,'Position');
                        dPosition = [dPosition(1)+dPosition(3)+10, dPosition(2), dPosition(3), dPosition(4)];
                    else
                        oEdit = uicontrol(handles.oPanel,'Style','edit','position',dPosition,'tag',sprintf('oEdit_%d',i));
                        dPosition = [dPosition(1)+dPosition(3)+10, dPosition(2), dPosition(3), dPosition(4)];
                    end
                end
                %Set the instructions
                set(handles.txtInstructions,'string',sInstructions);
                %Set the output attribute
                handles.output = hObject;
                %Update the gui handles
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = public)
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private functions
        function btnDone_Callback(oFigure, src, event)
            %Get the edit handles
            oChildren = get(oFigure.oGuiHandle.oPanel,'children');
            %initialise array
            aValues = zeros(length(oChildren),1);
            %get the edit values
            for i = length(oChildren):-1:1
                sValue = get(oChildren(length(oChildren)-i+1),'string');
                aValues(i) = str2double(sValue);
            end
            %Notify listeners and pass the selected value
            notify(oFigure,'ValuesEntered',EditValuesEnteredEvent(aValues));
        end
        
        function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
         end
    end
end
