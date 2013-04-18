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
            %Delete the figure if the parent is deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) oFigure.ParentFigureDeleted(src, event));
            
            % --- Executes just before the figure is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set the popup menu items
                set(handles.pp1, 'string', oPopUpData{1});
                set(handles.pp2, 'string', oPopUpData{2});
                set(handles.pp3, 'string', oPopUpData{3});
                set(handles.pp4, 'string', oPopUpData{4});
                set(handles.pp5, 'string', oPopUpData{5});
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
        
        function ParentFigureDeleted(oFigure,src, event)
            deleteme(oFigure);
        end
        
        function btnDone_Callback(oFigure, src, event)
            %Get the edit handles
            aValues = cell(4,1);
            aValues{1} = oFigure.GetPopUpSelectionString('pp1');
            aValues{2} = oFigure.GetPopUpSelectionString('pp2');
            aValues{3} = oFigure.GetPopUpSelectionString('pp3');
            aValues{4} = oFigure.GetPopUpSelectionString('pp4');
            aValues{5} = oFigure.GetPopUpSelectionString('pp5');
            %Notify listeners and pass the selected value
            notify(oFigure,'ValuesEntered',EditValuesEnteredEvent(aValues));
        end
    end
    
end
