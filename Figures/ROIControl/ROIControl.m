classdef ROIControl < SubFigure
% This figure contains a generic ROI selection control

    events
        SelectROINow;
        DoneSelecting;
        ClearROI;
    end
    
    methods
        %% Constructor
        function oFigure = ROIControl(oParent,sTitle)
            oFigure = oFigure@SubFigure(oParent,'ROIControl',@ROIControl_OpeningFcn);
            
            %Set callbacks
            set(oFigure.oGuiHandle.oSelectROI, 'callback', @(src, event) oSelectROI_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oClearROI, 'callback', @(src, event) oClearROI_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDone, 'callback', @(src, event) oDone_Callback(oFigure, src, event));
            
            % --- Executes just before figure is made visible.
            function ROIControl_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set the output attribute
                set(handles.oAxesSelect,'string',{'x','y','z'});
                set(handles.oROIPanel,'title',sTitle);
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
        function oDone_Callback(oFigure, src, event)
            %Notify listeners
            notify(oFigure,'DoneSelecting');
        end
        
        function oSelectROI_Callback(oFigure, src, event)
            %Notify listeners 
            notify(oFigure,'SelectROINow');
        end
        
        function oClearROI_Callback(oFigure, src, event)
            %clear the data on the roi table
            oData = cell(2,5);
            set(oFigure.oGuiHandle.oROITable,'data',oData);
            notify(oFigure,'ClearROI');
        end
    end
    
end
