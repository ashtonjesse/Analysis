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
        SelectedBeat = [];
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
            set(oFigure.oGuiHandle.oInterbeatMenu, 'callback', @(src, event) oInterbeatMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oBeatSelectionMenu, 'callback', @(src, event) oBeatSelectionMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectPacedBeatsMenu, 'callback', @(src, event) oDetectPacedBeatsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDeleteSelectedBeatMenu, 'callback', @(src, event) oDeleteSelectedBeatMenu_Callback(oFigure, src, event));
             
            set(oFigure.oGuiHandle.oMiddleAxes,'Visible','off');
            set(oFigure.oGuiHandle.oBottomAxes,'Visible','off');
            
            
            %Calculate Vrms
            oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms();
                            
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
        function oInterbeatMenu_Callback(oFigure, src, event)
            %Fit a polynomial to the isoelectric points between beats and
            %remove this from the processed data
            
            %Get the polynomial order from the selection made in the popup
            iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
            %Make call to InterbeatVariation
            [aPolyFitData aElectrodeData] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetInterBeatVariation(iPolynomialOrder);
            
            %Open the ComparePlots figure to see the goodness of fit
            oComparePlotsFigure = ComparePlots(oFigure,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                aElectrodeData,aPolyFitData);
            %Add a listener so that the figure knows when a user has
            %accepted the fit
            addlistener(oComparePlotsFigure,'Accepted',@(src,event) oFigure.RemoveInterBeatVariation(src, event));
        end
        
        % --------------------------------------------------------------------
        function oDetectMenu_Callback(oFigure, src, event)
            %Get the data associated with the thresholded beats for Unemap
            %and ECG
            oFigure.oParentFigure.oGuiHandle.oUnemap.GetArrayBeats(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks, 'Sinus');
            
            [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oECG.GetSinusBeats(...
                oFigure.oParentFigure.oGuiHandle.oECG.Original, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks);
            
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats = cell2mat(aOutData(1));
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes = cell2mat(aOutData(2));
            %Mark activation for future analysis
%            oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('SteepestNegativeSlope');
            %Plot the detected beats on the ECG
            oFigure.PlotECG('DetectBeats');
        end
        
        % -----------------------------------------------------------------
        function oDetectPacedBeatsMenu_Callback(oFigure, src, event)
            %Get the data associated with the thresholded beats for Unemap
            %and ECG
            oFigure.oParentFigure.oGuiHandle.oUnemap.GetArrayBeats(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks, 'Paced');
            
            [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oECG.GetPacedBeats(...
                oFigure.oParentFigure.oGuiHandle.oECG.Original, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks);
            
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats = cell2mat(aOutData(1));
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes = cell2mat(aOutData(2));

            %Plot the detected beats on the ECG
            oFigure.PlotECG('DetectBeats');
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
            oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
                iPolynomialOrder, iWindowSize, sSmoothingType);
                                  
            %Plot the computed Vrms
            oFigure.PlotVRMS('Smoothed');
            
        end
        % --------------------------------------------------------------------
        function oBeatSelectionMenu_Callback(oFigure, src, event)
            %Manually select beats
            
            %Must have processed data
            if isempty(oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed)
                error('BeatDetection.oBeatSelectionMenu.VerifyData', 'You need to smooth the RMS data before selecting beats.')
            end
            
            %Get the currently selected electrode
            oSelectDataFigure = SelectData(oFigure,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed,...
                {{'oInstructionText','string','Manually select data for each beat by holding shift'} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oButton','string','Done'} ; ...
                {'oAxes','title','Smoothed RMS Data'}});
            %Add a listener so that the figure knows when a user has
            %selected the data to truncate            
            addlistener(oSelectDataFigure,'DataSelected',@(src,event) oFigure.BeatsSelected(src, event));
        end
        
        function oDeleteSelectedBeatMenu_Callback(oFigure, src, event)
            %Delete the currently selected beat
            if ~isempty(oFigure.SelectedBeat)
                oFigure.oParentFigure.oGuiHandle.oUnemap.DeleteBeat(oFigure.SelectedBeat);
                oFigure.oParentFigure.oGuiHandle.oECG.DeleteBeat(oFigure.SelectedBeat);
            end
            oFigure.SelectedBeat = [];
            %replot
            oFigure.PlotECG('DetectBeats');
        end
        
        function oCurvatureMenu_Callback(oFigure, src, event)
            
            %Calculate the curvature 
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateCurvature(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed, ...
                20,5);
            
            %Open the SelectData figure to apply a threshold
            oGetThresholdFigure = SelectData(oFigure,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values,...
                {{'oInstructionText','string','Select a range of data during electrical quiescence'} ; ...
                {'oBottomText','string','How many standard deviations to apply?'} ; ...
                {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                {'oButton','string','Done'} ; ...
                {'oAxes','title','Curvature'}});
            %Add a listener so that the figure knows when a user has
            %calculated the threshold            
            addlistener(oGetThresholdFigure,'DataSelected',@(src,event) oFigure.ThresholdCurvature(src, event));
            
            %Plot the computed curvature
            oFigure.PlotCurvature();
            
        end
                   
        function ThresholdCurvature(oFigure, src, event)
            % Calculate the standard deviation of the selected data
            dStandardDeviation = std(event.YData);
            % Get the selected multiplier
            dSelection = double(event.Option);
            dThreshold = mean(oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values) + ...
                (dSelection*dStandardDeviation);
            
            %Get the peaks of the Curvature above threshold
            [aPeaks,aLocations] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetPeaks(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Values,dThreshold);
            %Plot the peaks
            hold(oFigure.oGuiHandle.oMiddleAxes,'on');
            plot(oFigure.oGuiHandle.oMiddleAxes,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(aLocations),aPeaks,'*g');
            %Save the peak values and locations
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks = [aPeaks ; aLocations];
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Threshold = dThreshold;
            
        end
        
        function RemoveInterBeatVariation(oFigure,src,event)
            %Take the calculated fit and apply it to the electrode data
            oFigure.oParentFigure.oGuiHandle.oUnemap.RemoveInterBeatVariation(event.Y2Data);
        end
        
        function oBottomAxes_Callback(oFigure, src, event)
             oPoint = get(src,'currentpoint');
             xDim = oPoint(1,1);
             iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(1,xDim);
             %Delete the selected beat
             oFigure.SelectedBeat = iBeatIndexes{1,1};
             
             oFigure.PlotECG('DetectBeats');
        end
    end
    
    methods (Access = private)
        function BeatsSelected(oFigure, src, event)
            %Get the locations of the selected data and create a Peaks
            %array for passing to GetArrayBeats with a filler row of random
            %numbers
            aLocations = find(event.Indexes);
            aPeaks = [rand(1,length(aLocations)) ; aLocations];
            
            %Get the data associated with the thresholded beats for Unemap
            %and ECG
            oFigure.oParentFigure.oGuiHandle.oUnemap.GetArrayBeats(aPeaks);
            
            aOutData = oFigure.oParentFigure.oGuiHandle.oECG.GetSinusBeats(...
                oFigure.oParentFigure.oGuiHandle.oECG.Original, aPeaks);
            
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats = cell2mat(aOutData(1));
            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes = cell2mat(aOutData(2));
            %Mark activation for future analysis
            oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('SteepestSlope');
            %Plot the detected beats on the ECG
            oFigure.PlotECG('DetectBeats');
        end
        
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
        
        function PlotECG(oFigure,sOption)
            % Plot ECG Data
            
            %Clear axes and set to be visible
            cla(oFigure.oGuiHandle.oBottomAxes);
            set(oFigure.oGuiHandle.oBottomAxes,'Visible','On');
            
            %Plot the ECG channel data
            plot(oFigure.oGuiHandle.oBottomAxes, ...
                oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oECG.Original,'k');
            %Check if the user specified detectbeats and plot these as well
            %if so
            switch sOption
                case 'DetectBeats'
                    hold(oFigure.oGuiHandle.oBottomAxes, 'on');
                    plot(oFigure.oGuiHandle.oBottomAxes, ...
                        oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries, ...
                        transpose(oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats),'-g');
                    if ~isempty(oFigure.SelectedBeat)
                        %Get the currently selected beat
                        aSelectedBeat = oFigure.oParentFigure.oGuiHandle.oECG.Processed.Beats(...
                            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes(oFigure.SelectedBeat,1):...
                            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes(oFigure.SelectedBeat,2));
                        aSelectedTime = oFigure.oParentFigure.oGuiHandle.oECG.TimeSeries(...
                            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes(oFigure.SelectedBeat,1):...
                            oFigure.oParentFigure.oGuiHandle.oECG.Processed.BeatIndexes(oFigure.SelectedBeat,2));
                        plot(oFigure.oGuiHandle.oBottomAxes,aSelectedTime,aSelectedBeat,'-b');
                    end
                    hold(oFigure.oGuiHandle.oBottomAxes, 'off');
                otherwise
                    
            end
            title(oFigure.oGuiHandle.oBottomAxes,'ECG');
            set(oFigure.oGuiHandle.oBottomAxes, 'buttondownfcn', @(src, event)  oBottomAxes_Callback(oFigure, src, event));
        end
    end
end

