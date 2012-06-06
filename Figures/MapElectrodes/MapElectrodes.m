classdef MapElectrodes < SubFigure
    %   AnalyseSignals
    
    
    properties
        
    end
    
    methods
        function oFigure = MapElectrodes(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'MapElectrodes',@MapElectrodes_OpeningFcn);
            
            %Callbacks
            set(oFigure.oGuiHandle.oDataCursorTool, 'oncallback', @(src, event) oDataCursorOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'offcallback', @(src, event) oDataCursorOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.PlotElectrodes();
            % --- Executes just before BaselineCorrection is made visible.
            function MapElectrodes_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)
                
                %Set ui control creation attributes 
                
                
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
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            nValue = GetPopUpSelectionDouble@BaseFigure(oFigure,sPopUpMenuTag);
        end
        
     end
    
     methods (Access = public)
        %% Ui control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
        
        function oDataCursorOnTool_Callback(oFigure, src, event)
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
        end
        
        function oDataCursorOffTool_Callback(oFigure, src, event)
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
        end
     end
     
     methods (Access = private)
         function PlotElectrodes(oFigure)
             %Set up the axes
             set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[], 'NextPlot','replacechildren');
             %Get the electrodes
             oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
             %Get the number of channels
             [i NumChannels] = size(oElectrodes);
             %Loop through the electrodes plotting their locations
             for i = 1:NumChannels;
                 %Plot the electrode point
                 plot(oFigure.oGuiHandle.oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.');
                 hold(oFigure.oGuiHandle.oMapAxes,'on');
                 %Label the point with the channel name
                 oLabel = text(oElectrodes(i).Coords(1) - 0.1, oElectrodes(i).Coords(2) + 0.07, ...
                     oElectrodes(i).Name);
                 set(oLabel,'FontWeight','bold','FontUnits','normalized');
                 set(oLabel,'FontSize',0.015);
                 set(oLabel,'parent',oFigure.oGuiHandle.oMapAxes);
             end
             hold(oFigure.oGuiHandle.oMapAxes,'off');
         end
     end
end
