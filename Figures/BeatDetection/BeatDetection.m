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
    end
    
    methods
        function oFigure = BeatDetection(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BeatDetection',@BeatDetection_OpeningFcn);
            
            %Set the callback functions to the menu items
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothMenu, 'callback', @(src, event) oSmoothMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            GetVRMS(oFigure);
            set(oFigure.oGuiHandle.oMiddleAxes,'Visible','off');
            set(oFigure.oGuiHandle.oBottomAxes,'Visible','off');
            
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
        function delete(oFigure)
            delete@BaseFigure(oFigure);
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
           delete(oFigure);
        end
        
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

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
                oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected, ...
                iPolynomialOrder, iWindowSize, sSmoothingType);
            
            %Save the characteristics of the smoothing
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothing = sSmoothingType;
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.PolyOrder = iPolynomialOrder;
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.WindowSize = iWindowSize;
            
            %Set the top axes to be active
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oTopAxes);
            cla;
            
            %Plot the computed Vrms
            plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed,'k');
            title('Smooth V_R_M_S');
            
        end
        
    end
    
    methods (Access = private)
        % --------------------------------------------------------------------
        function GetVRMS(oFigure)
            %Calculate Vrms
            oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Values = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected)
                            
            %Set the Top axes to be active
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oTopAxes);
            cla;
            
            %Plot the computed Vrms
            plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Values,'k');
            title('V_R_M_S');
        end
    end
end

