classdef SelectData < SubFigure
    %   SelectData
    %   This is the SelectData class that wraps the
    %   SelectDataFig. It needs to be called from a 
    %   parent figure and the class wrapper
    %   for this parent passed as a input into the constructor. 
    %   Currently this class is designed to plot data and allow a user 
    %   to specify a set of data
    
    %   This class assumes that the parent figure remains open while the
    %   SelectDataFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is
    %   done. 
    
    properties
        
    end
    
    events
        DataSelected;
    end
    methods
        function oFigure = SelectData(oParent,XData,YData,sOptions)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'SelectData',@SelectData_OpeningFcn);
            
            set(oFigure.oGuiHandle.oButton, 'callback', @(src, event) oButton_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'oncallback', @(src, event) oZoomOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'offcallback', @(src, event) oZoomOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'oncallback', @(src, event) oDataCursorOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'offcallback', @(src, event) oDataCursorOffTool_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Plot the data
            cla(oFigure.oGuiHandle.oAxes);
            plot(oFigure.oGuiHandle.oAxes,XData,YData,'k');
            
            function SelectData_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                for i = 1:size(sOptions,1)
                    sObject = char(sOptions{i}(1));
                    sProperty = char(sOptions{i}(2));
                    if strcmpi(sObject,'oBottomPopUp') && strcmpi(sProperty,'string');
                        sValue = sOptions{i,1}(3);
                        sValue = sValue{1};
                    else
                        sValue = char(sOptions{i}(3));
                    end
                    if strcmpi(sObject,'oAxes') && strcmpi(sProperty,'title')
                        set(handles.(sObject),sProperty,text('String',sValue));
                    else
                        set(handles.(sObject),sProperty,sValue);
                    end
                end
                
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
        
        function sValue = GetPopUpSelectionString(oFigure,sPopUpMenuTag)
            sValue = GetPopUpSelectionString@BaseFigure(oFigure,sPopUpMenuTag);
        end
   end
    
    methods (Access = public)
        %% Public methods and callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        function oButton_Callback(oFigure, src, event)
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            brushedIdx = ~isnan(brushedData{1});
            %Get the popup selection
            sSelection = oFigure.GetPopUpSelectionDouble('oBottomPopUp');
            %Notify listeners and pass the selected data
            notify(oFigure,'DataSelected',DataSelectedEvent(brushedData{1}(brushedIdx),brushedData{2}(brushedIdx),brushedIdx,sSelection));
            oFigure.Close_fcn;
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
        
        function oZoomOnTool_Callback(oFigure, src, event)
            zoom(oFigure.oGuiHandle.(oFigure.sFigureTag), 'on');
        end
        
        function oZoomOffTool_Callback(oFigure, src, event)
            zoom(oFigure.oGuiHandle.(oFigure.sFigureTag), 'off');
        end
    end
end
