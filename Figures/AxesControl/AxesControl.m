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
            sPathName = uigetdir('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if ~ischar(sPathName)
                return
            end
            sLongFileName=strcat(sPathName,'\',oFigure.PlotName);
            oFigure.PrintFigureToFile(sLongFileName);
        end
        
    end
    
    methods (Access = private)
        function DisplayPlot(oFigure)
            %Plot the data on the specified plot
            switch (oFigure.PlotType)
                case '2DContour'
                    xlin = linspace(min(oFigure.PlotData.x),max(oFigure.PlotData.x),length(oFigure.PlotData.x));
                    ylin = linspace(min(oFigure.PlotData.y),max(oFigure.PlotData.y),length(oFigure.PlotData.y));
                    [X, Y] = meshgrid(xlin, ylin);
                    Z = griddata(oFigure.PlotData.x, oFigure.PlotData.y,oFigure.PlotData.z,X,Y,'cubic');
                    iSplit = abs(oFigure.PlotData.MaxCLim - oFigure.PlotData.MinCLim)/20;
                    iSplit = str2num(sprintf('%3.1f',iSplit));
                    contourf(oFigure.oGuiHandle.oAxes,X,Y,Z,floor(oFigure.PlotData.MinCLim):iSplit:ceil(oFigure.PlotData.MaxCLim));
%                     colormap(oFigure.oGuiHandle.oAxes, colormap(flipud(colormap(jet))));
                    oColorBar = cbarf(Z,floor(oFigure.PlotData.MinCLim):iSplit:ceil(oFigure.PlotData.MaxCLim));
                    oTitle = get(oColorBar, 'title');
                    set(oTitle,'string','Time (ms)');
                    set(oFigure.oGuiHandle.oAxes,'XTick',[],'YTick',[]);
%                     title(oFigure.oGuiHandle.oAxes,oFigure.PlotName);
                case '2DScatter'
                    scatter(oFigure.oGuiHandle.oAxes, oFigure.PlotData.x, oFigure.PlotData.y, 100, oFigure.PlotData.z, 'filled');
                    colormap(oFigure.oGuiHandle.oAxes, colormap(flipud(colormap(jet))));
                    colorbar('peer',oFigure.oGuiHandle.oAxes);
                    colorbar('location','EastOutside');
                    set(oFigure.oGuiHandle.oAxes,'CLim',[oFigure.PlotData.MinCLim oFigure.PlotData.MaxCLim]);
                    set(oFigure.oGuiHandle.oAxes,'XTick',[],'YTick',[]);
                    title(oFigure.oGuiHandle.oAxes,oFigure.PlotName);
                case '3DTriSurf'
                    for i = 1:size(oFigure.PlotData,2);
                        aTriangulatedMesh = delaunay(oFigure.PlotData(i).x, oFigure.PlotData(i).y);
                        trisurf(aTriangulatedMesh,oFigure.PlotData(i).x, oFigure.PlotData(i).y, oFigure.PlotData(i).z);
                        hold(oFigure.oGuiHandle.oAxes,'on');
                    end
                    hold(oFigure.oGuiHandle.oAxes,'off');
                    zlim(oFigure.oGuiHandle.oAxes,[oFigure.PlotData(1).MinZLim oFigure.PlotData(1).MaxZLim]);
                    set(oFigure.oGuiHandle.oAxes,'CLim',[oFigure.PlotData(1).MinCLim oFigure.PlotData(1).MaxCLim]);
                    view(oFigure.oGuiHandle.oAxes,8,9);
                    camlight;
                    lighting gouraud;
                    alpha(0.8);
                    colormap(oFigure.oGuiHandle.oAxes, colormap(colormap(jet)));
                    colorbar('peer',oFigure.oGuiHandle.oAxes);
                    colorbar('location','EastOutside');
                    title(oFigure.oGuiHandle.oAxes,oFigure.PlotName);
                case 'LineGraph'
                    
            end
            
        end
    end
end


