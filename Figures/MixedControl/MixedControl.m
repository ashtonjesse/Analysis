classdef MixedControl < SubFigure
% This figure contains a generic panel containing a mixture of controls

    events
        ValuesEntered;
    end
    
    methods
        %% Constructor
        function oFigure = MixedControl(oParent, sInstructions, oPopUpData)
            oFigure = oFigure@SubFigure(oParent,'MixedControl',@OpeningFcn);
          
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
                
                %Set the popup menu items
                set(handles.ppLeft, 'string', oPopUpData{1});
                set(handles.ppMidLeft, 'string', oPopUpData{2});
                set(handles.ppMidRight, 'string', oPopUpData{3});
                set(handles.ppRight, 'string', oPopUpData{4});
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
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        function btnDone_Callback(oFigure, src, event)
            %Get the edit handles
            aValues = cell(4,1);
            aValues{1} = oFigure.GetPopUpSelectionString('ppLeft');
            aValues{2} = oFigure.GetPopUpSelectionString('ppMidLeft');
            aValues{3} = oFigure.GetPopUpSelectionString('ppMidRight');
            aValues{4} = oFigure.GetPopUpSelectionString('ppRight');
            aValues{5} = get(oFigure.oGuiHandle.edt1,'string');
            %Notify listeners and pass the selected value
            notify(oFigure,'ValuesEntered',EditValuesEnteredEvent(aValues));
        end
    end
    
end
