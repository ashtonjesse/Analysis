classdef BeatDetection < SubFigure
    %   BeatDetection 
    %   This gui allows the user to complete processing the signals by
    %   calculating a VRMS signal, which is then smoothed and fitted
    %   with a spline approximation. The curvature of this signal is
    %   calculated and used to mark a time window of activation for
    %   each beat. The isoelectric point is found preceeding each beat and
    %   a 2nd order polynomial approximation is fitted to this to normalise
    %   each beat.
    
    properties
        Threshold
    end
    
    methods
        function oFigure = BeatDetection(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BeatDetection',@BeatDetection_OpeningFcn);
            
            %Set the callback functions to the menu items
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothMenu, 'callback', @(src, event) oSmoothMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCurvatureMenu, 'callback', @(src, event) oCurvatureMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectMenu, 'callback', @(src, event) oDetectMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            set(oFigure.oGuiHandle.oMiddleAxes,'Visible','off');
            set(oFigure.oGuiHandle.oBottomAxes,'Visible','off');
            zoom on;
            
            %Calculate Vrms
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Values = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data);
                            
            %Plot the computed Vrms
            oFigure.PlotVRMS('Values');
            
            function BeatDetection_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                set(handles.pmPolynomialOrder, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                set(handles.pmWindowSize, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                set(handles.pmSmoothingType, 'string', {'SavitzkyGolay','MovingAverage'});
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
    
    methods
        %% Ui control callbacks    
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
        
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
       
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oDetectMenu_Callback(oFigure, src, event)
            %Find the beat intervals
            
            %Get the number of peak locations n
            [m,n] = size(oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks);
            %Save the first peak location
            iFirstPeak = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks(2,1);
            %Initialise the loop variables
            iCurrentPeak = iFirstPeak;
            iLastPeak = 0;
            aBeats = zeros(2,1);
            %Loop through the columns of the peak locations array (2nd row of Curvature.Peaks)
            for i = 2:n;
                %If the next peak is greater than 100 more than the current
                %peak then the next group of peaks must be reached so save
                %the first and last peaks of the last group in aBeats.
                if oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks(2,i) < (iCurrentPeak + 100)
                    iLastPeak = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks(2,i);
                else
                    aBeats = [aBeats [iFirstPeak ; iLastPeak]];
                    iFirstPeak = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks(2,i);
                end
                iCurrentPeak = oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks(2,i);
            end
            %Remove the zeros from the first column
            aBeats = aBeats(:,2:size(aBeats,2));
            %Save the beat locations
            oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Beats = aBeats;
        end
        
        % --------------------------------------------------------------------
        function oSmoothMenu_Callback(oFigure, src, event)
            
            %Get the polynomial order from the selection made in the popup
            iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
            %Get the polynomial order from the selection made in the popup
            iWindowSize = oFigure.GetPopUpSelectionDouble('pmWindowSize');
            %Get the Smoothing type from the selection made in the popup
            sSmoothingType = oFigure.GetPopUpSelectionString('pmSmoothingType');
            
            %Calculate Vrms and smooth
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data, ...
                iPolynomialOrder, iWindowSize, sSmoothingType);
            
            %Save the characteristics of the smoothing
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothing = sSmoothingType;
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.PolyOrder = iPolynomialOrder;
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.WindowSize = iWindowSize;
                        
            %Plot the computed Vrms
            oFigure.PlotVRMS('Smoothed');
            
        end
        
        function oCurvatureMenu_Callback(oFigure, src, event)
            
            %Calculate the curvature 
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateCurvature(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed, ...
                20,5);
            
            %Open the GetThreshold figure to apply a threshold
            oGetThresholdFigure = GetThreshold(oFigure);
            %Add a listener so that the figure knows when a user has
            %calculated the threshold            
            addlistener(oGetThresholdFigure,'ThresholdCalculated',@(src,event) oFigure.ThresholdCurvature(src, event));
            
            %Plot the computed curvature
            oFigure.PlotCurvature();
            
        end
        
        function ThresholdCurvature(oFigure, src, event)
            %Get the peaks of the Curvature above threshold
            [aPeaks,aLocations] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPeaks(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values,oFigure.Threshold);
            %Plot the peaks
            hold(oFigure.oGuiHandle.oMiddleAxes,'on');
            plot(oFigure.oGuiHandle.oMiddleAxes,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aLocations),aPeaks,'*g');
            %Save the peak values and locations
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks = [aPeaks ; aLocations];
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Threshold = oFigure.Threshold;
            
        end
        
    end
    
    methods (Access = private)
      
        function PlotVRMS(oFigure,sSelection)
            % Plot VRMS. sSelection should be a field of the RMS struct,
            % either 'Values' or 'Smoothed'
            cla(oFigure.oGuiHandle.oTopAxes);
            plot(oFigure.oGuiHandle.oTopAxes, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.(sSelection),'k');
            switch sSelection
                case 'Smoothed'
                    title(oFigure.oGuiHandle.oTopAxes,'Smoothed V_R_M_S');
                otherwise
                    title(oFigure.oGuiHandle.oTopAxes,'V_R_M_S');
            end
        end
        
        function PlotCurvature(oFigure)
            % Plot Curvature Data
            cla(oFigure.oGuiHandle.oMiddleAxes);
            set(oFigure.oGuiHandle.oMiddleAxes,'Visible','On');
            plot(oFigure.oGuiHandle.oMiddleAxes, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values,'k');
            title(oFigure.oGuiHandle.oMiddleAxes,'Curvature');
        end
    end
end

