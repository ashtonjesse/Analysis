classdef ComparePlots < SubFigure
    % ComparePlots
    % This figure compares two plots for a range of data and allows the user to approve or
    % cancel proceeding
    properties
        XData;
        Y1Data;
        Y2Data;
    end
    
    events
        Accepted;
    end
    
    methods
        function oFigure = ComparePlots(oParent,aXData,aY1Data,aY2Data)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'ComparePlots',@ComparePlots_OpeningFcn);
            %Set properties
            oFigure.XData = aXData;
            oFigure.Y1Data = aY1Data;
            oFigure.Y2Data = aY2Data;
            
            set(oFigure.oGuiHandle.oOkButton, 'callback', @(src, event) oOkButton_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCancelButton, 'callback', @(src, event) oCancelButton_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            aSliderTexts = [oFigure.oGuiHandle.oSliderText1,oFigure.oGuiHandle.oSliderText2];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', ...
                size(aY1Data,2), 'Value', 1, 'Callback', @(src, event) oSlider_Callback(oFigure, src, event)},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            %Plot the data
            oFigure.PlotData(1);
            
            function ComparePlots_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                set(handles.oOkButton, 'string', 'Accept');
                set(handles.oCancelButton, 'string', 'Cancel');
                
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
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        function oOkButton_Callback(oFigure, src, event)
            oFigure.oParentFigure.ComparePlotsOutput = oFigure.Y2Data;           
            notify(oFigure,'Accepted');
            oFigure.Close_fcn(src, event);
        end
        
        function oCancelButton_Callback(oFigure,src,event)
            oFigure.Close_fcn(src, event);
        end
        
        function oSlider_Callback(oFigure, src, event)
           % Plot the data associated with this channel
            oFigure.PlotData(get(oFigure.oGuiHandle.oSlider,'Value'));
        end
        
        function PlotData(oFigure,iIndex)
            %Plot the selected index
            if ~isinteger(iIndex)
                %Round down to nearest integer if a double is supplied
                iIndex = round(iIndex(1));
            end
            cla(oFigure.oGuiHandle.oTopAxes);
            plot(oFigure.oGuiHandle.oTopAxes,oFigure.XData,oFigure.Y1Data(:,iIndex),'k');
            
            cla(oFigure.oGuiHandle.oBottomAxes);
            plot(oFigure.oGuiHandle.oBottomAxes,oFigure.XData,oFigure.Y2Data(:,iIndex),'k');
        end
    end
end
