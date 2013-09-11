classdef AxesControl < SubFigure
    %   AxesControl
    %   This class wraps the AxesControl figure, a figure that holds just a
    %   set of axes for viewing and functionality to print to file.
    
    properties
        PlotName;
        PlotData;
        PlotType;
    end

    methods
        function oFigure = AxesControl(oParent,sPlotType,sPlotName,oPlotData)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'AxesControl',@AxesControl_OpeningFcn);
            %Save inputs to properties
            oFigure.PlotName = sPlotName;
            oFigure.PlotData = oPlotData;
            oFigure.PlotType = sPlotType;
            %Set callbacks
            set(oFigure.oGuiHandle.oFileMenu,  'callback', @(src,event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPrintMenu,  'callback', @(src,event) oPrintMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.DisplayPlot();
            function AxesControl_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
               
                %Set the output attribute
                handles.output = hObject;
                %Update the gui handles 
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = protected)
         %% Protected methods inherited from superclass
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
        
   end
    
    methods (Access = public)
        %% Public methods and callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        % --------------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)
            
        end
        
        % --------------------------------------------------------------------
        function oPrintMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if (~ischar(sFilename) && ~ischar(sPathName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sPathName,sFilename);
            oFigure.PrintFigureToFile(sLongDataFileName);
        end
        
    end
    
    methods (Access = private)
        function DisplayPlot(oFigure)
            
        end
    end
end


