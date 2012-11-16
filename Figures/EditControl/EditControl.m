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
        function deletefigure(oFigure)
            %A function that can be called by other figures to delete this
            %one.
             deleteme(oFigure);
        end
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
        %% Private UI control callbacks
        function btnDone_Callback(oFigure, src, event)
            %Notify listeners and pass the selected value
            notify(oFigure,'ValuesEntered');
        end
    end
    
end
