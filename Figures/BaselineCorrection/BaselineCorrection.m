classdef BaselineCorrection < SubFigure
    %BaselineCorrection Summary
    %   This is the BaselineCorrection class that wraps the
    %   BaselineCorrectionFig. It needs to be called from a parent figure 
    %   (e.g StartFigure) and the class wrapper
    %   for this parent passed as a input into the constructor. 
    
    %   This class assumes that the parent figure remains open while the
    %   BaselineCorrectionFig is open. There is no functionality to handle closing
    %   of the parent figure and auto errors will be thrown if this is done. 
    
    properties 

    end
    
    methods
        function oFigure = BaselineCorrection(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'BaselineCorrection',@BaselineCorrection_OpeningFcn);
            
            %Set the callback functions to the controls
            set(oFigure.oGuiHandle.oSignalSlider, 'callback', @(src, event) oSignalSlider_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.pmPolynomialOrder , 'callback', @(src, event)  pmPolynomialOrder_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.pmSplineOrder, 'callback', @(src, event)  pmSplineOrder_Callback(oFigure, src, event));
                                    
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oBaselineMenu, 'callback', @(src, event) oBaselineMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSplineMenu, 'callback', @(src, event) oSplineMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oApplyMenu, 'callback', @(src, event) oApplyMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
                                   
            %Plot the data of the first signal
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oTopAxes);
            plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, oFigure.oParentFigure.oGuiHandle.oUnemap.Original(:,1),'k');
            axis 'auto';
            
            %Clear the CorrectedOriginal axes
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oMiddleAxes);
            cla;
            axis 'auto';
            
            %If a baseline correction has already been done and the data saved
            %then plot the baseline corrected original data too
            if ~isempty(oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline)
                plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected(:,1),'k');
                sTitle = sprintf('Existing Baseline Corrected Signal');
                title(sTitle);
            end
            
            % --- Executes just before BaselineCorrection is made visible.
            function BaselineCorrection_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                set(handles.pmPolynomialOrder, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                set(handles.pmSplineOrder, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14'});
                
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
    end
    
    methods
        %% Ui control callbacks    
        function oFigure = Close_fcn(oFigure, src, event)
           delete(oFigure);
        end
        
        % --------------------------------------------------------------------
        function oSignalSlider_Callback(oFigure, src, event)

        end
        % --------------------------------------------------------------------
        function pmPolynomialOrder_Callback(oFigure, src, event)
            
        end
        % --------------------------------------------------------------------
        function pmSplineOrder_Callback(oFigure, src, event)

        end
               
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oBaselineMenu_Callback(oFigure, src, event)
            %Takes the polynomial order specified in the popup and applies
            %this polynomial fit to the data 
            
            %Get the polynomial order from the selection made in the popup
            iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
            
            %Remove baseline
            oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                'RemoveMedianAndFitPolynomial', iPolynomialOrder,1);
            
            oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.PolyOrder = iPolynomialOrder;
            
            %Plot the data with the baseline removed.
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oMiddleAxes);
            cla;
            plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected(:,1),'k');
            title('Baseline Corrected Signal');
        end
        
        % --------------------------------------------------------------------
        function oSplineMenu_Callback(oFigure, src, event)
            
            %Get the spline approximation order from the selection made in the popup
            iSplineOrder = oFigure.GetPopUpSelectionDouble('pmSplineOrder');
                        
            %Smooth the data with a spline approximation
            oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected, ...
                'SplineSmoothData',iSplineOrder,1);
            
            oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.SplineOrder = iSplineOrder;
            
            %Set the Top axes to be active
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'CurrentAxes',oFigure.oGuiHandle.oTopAxes);
            cla;
                        
            %Plot the Spline approximation
            plot(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected(:,1),'k');
            
        end
        
        % --------------------------------------------------------------------
        function oApplyMenu_Callback(oFigure, src, event)
            %   Apply the baseline correction and potentially the spline
            %   approximation to all the channels in oUnemap.Original and save.
            
            %   Get the polynomial order from the selection made in the listbox
            %   control
             iPolynomialOrder = oFigure.GetPopUpSelectionDouble('pmPolynomialOrder');
            
             %  Remove baseline (not specifying a channel number so this call
             %  will do all the channels
            oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected = ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                oFigure.oParentFigure.oGuiHandle.oUnemap.Original, ...
                'RemoveMedianAndFitPolynomial', iPolynomialOrder);
            
            %  Check if user wants a spline approximation applied
            blKeepSpline = get(oFigure.oGuiHandle.tbKeepSpline, 'Value');
            if blKeepSpline
                %Get the spline approximation order from the selection made in the popup
                iSplineOrder = oFigure.GetPopUpSelectionDouble('pmSplineOrder');
                
                %Smooth the data with a spline approximation
                oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected = ...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.ProcessData(...
                    oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected, ...
                    'SplineSmoothData',iSplineOrder);
            end
        end
        
    end
   
end
