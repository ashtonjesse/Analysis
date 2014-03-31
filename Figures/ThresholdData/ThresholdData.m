classdef ThresholdData < SelectData
    %   ThresholdData
    %   This is the ThresholdData class that wraps the
    %   ThresholdDataFig. It needs to be called from a 
    %   parent figure and the class wrapper
    %   for this parent passed as a input into the constructor. 
    %   Currently this class is designed to plot data and allow a user 
    %   to specify a set of data from which a threshold is calculated
    
    %   This class assumes that the parent figure remains open while the
    %   ThresholdDataFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is
    %   done. 
    
    properties
        Peaks;
        Threshold;
        YDataInput;
        XDataInput;
    end
    
    events
        ThresholdCalculated;
    end

    methods
        function oFigure = ThresholdData(oParent,XData,YData,sOptions)
            %% Constructor
            oFigure = oFigure@SelectData(oParent,'ThresholdData',XData,YData,sOptions);
            %Override the ReturnButton callback
            set(oFigure.oGuiHandle.oReturnButton, 'callback', @(src, event) oReturnButton_Callback(oFigure, src, event));
            %set other callbacks
            set(oFigure.oGuiHandle.bCalcThreshold, 'callback', @(src, event) bCalcThreshold_Callback(oFigure, src, event));
            %set properties
            oFigure.YDataInput = YData;
            oFigure.XDataInput = XData;
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
        
        function oReturnButton_Callback(oFigure, src, event)
            %Notify listeners and pass the selected data
            notify(oFigure,'ThresholdCalculated',DataPassingEvent(oFigure.Peaks,oFigure.Threshold));
            oFigure.Close_fcn;
        end

        function bCalcThreshold_Callback(oFigure, src, event)
            %Calculate the threshold based on the selected data
            
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            brushedIdx = ~isnan(brushedData{1});
            XData = brushedData{1}(brushedIdx);
            YData = brushedData{2}(brushedIdx);
            %Get the popup selection
            dSelection = double(oFigure.GetPopUpSelectionDouble('oBottomPopUp'));
            
            % Calculate the standard deviation of the selected data
            dStandardDeviation = std(YData);
            oFigure.Threshold = mean(oFigure.YDataInput) + ...
                (dSelection*dStandardDeviation);
            
            %Get the peaks of the Curvature above threshold
            %need a BaseSignal class for this... bit cludgy
            oSignal = BaseSignal();
            [aPeaks,aLocations] = oSignal.GetPeaks(oFigure.YDataInput, oFigure.Threshold);
            clear oSignal;
            %save the peaks
            oFigure.Peaks = [aPeaks ; aLocations];
            %Plot the peaks
            cla(oFigure.oGuiHandle.oAxes);
            plot(oFigure.oGuiHandle.oAxes,oFigure.XDataInput,oFigure.YDataInput,'k');
            hold(oFigure.oGuiHandle.oAxes,'on');
            plot(oFigure.oGuiHandle.oAxes, oFigure.XDataInput(aLocations),aPeaks,'*g');
            hold(oFigure.oGuiHandle.oAxes,'off');
        end
    end
end