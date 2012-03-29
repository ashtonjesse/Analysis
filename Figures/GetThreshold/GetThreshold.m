classdef GetThreshold < SubFigure
    %   GetThreshold
    %   This is the GetThreshold class that wraps the
    %   GetThresholdFig. It needs to be called from a BeatDectection
    %   parent figure and the class wrapper
    %   for this parent passed as a input into the constructor. 
    %   Currently this class is designed to plot curvature data but could
    %   be extended to find a threshold for a user specified set of data
    
    %   This class assumes that the parent figure remains open while the
    %   GetThresholdFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is
    %   done. 
    
    properties
        
    end
    
    events
        ThresholdCalculated
    end
    methods
        function oFigure = GetThreshold(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'GetThreshold',@GetThreshold_OpeningFcn);
            
            set(oFigure.oGuiHandle.oButton, 'callback', @(src, event) oButton_Callback(oFigure, src, event));
            
            %Plot the computed curvature
            cla(oFigure.oGuiHandle.oAxes);
            plot(oFigure.oGuiHandle.oAxes,oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature,'k');
            title(oFigure.oGuiHandle.oAxes,'Curvature');
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
            
            function GetThreshold_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                set(handles.oInstructionText, 'string', 'Select a range of data during electrical quiescence');
                set(handles.oBottomText, 'string', 'How many standard deviations to apply?');
                set(handles.oBottomPopUp, 'string', {'1','2','3','4','5'});
                set(handles.oButton, 'string', 'Done');
                
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
        function oButton_Callback(oFigure, src, event)
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            brushedIdx = ~isnan(brushedData{1});
            % Calculate the standard deviation of the selected data 
            dStandardDeviation = std(brushedData{2}(brushedIdx));
            % Get the selected multiplier
            dSelection = oFigure.GetPopUpSelectionDouble('oBottomPopUp');
            oFigure.oParentFigure.Threshold = mean(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature) + ...
                (dSelection*dStandardDeviation);
                
            notify(oFigure,'ThresholdCalculated');
        end
    end
end
