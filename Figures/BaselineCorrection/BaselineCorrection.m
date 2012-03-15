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
            
            %%%%%% Just moved this to BaseFigure...
                                   
            %Plot the data of the first signal
            set(oFigure.oGuiHandle.BaselineFigure,'CurrentAxes',oFigure.oGuiHandle.oTopAxes);
            plot(oFigure.oParentFigure.oGuiHandle.oPotential.TimeSeries, oFigure.oParentFigure.oGuiHandle.oPotential.Original(:,1),'k');
            axis 'auto';
            
            %Clear the CorrectedOriginal axes
            set(oFigure.oGuiHandle.BaselineFigure,'CurrentAxes',oFigure.oGuiHandle.oMiddleAxes);
            cla;
            axis 'auto';
            
            %If a baseline correction has already been done and the data saved
            %then plot the baseline corrected original data too
            if(oFigure.oParentFigure.oGuiHandle.oPotential.Baseline)
                plot(oFigure.oParentFigure.oGuiHandle.oPotential.TimeSeries,...
                    oFigure.oParentFigure.oGuiHandle.oPotential.Baseline.Corrected(:,1),'k');
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
            delete@SubFigure(oFigure);
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
            Close_fcn@SubFigure(oFigure, src, event);
        end
   end
    
    methods
        %% Ui control callbacks    
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
            aString = get(oFigure.oGuiHandle.pmPolynomialOrder,'String');
            iIndex = get(oFigure.oGuiHandle.pmPolynomialOrder,'Value');
            iPolynomialOrder = aString(iIndex);
            % Make sure inputs are of type integer
            iPolynomialOrder = str2double(char(iPolynomialOrder));
            
            %Remove baseline
            oFigure.oParentFigure.oGuiHandle.oPotential.RemoveMedianAndFitPolynomial(iPolynomialOrder,1);
                                    
            %Plot the data with the baseline removed.
            set(oFigure.oGuiHandle.BaselineFigure,'CurrentAxes',oFigure.oGuiHandle.oMiddleAxes);
            cla;
            plot(oFigure.oParentFigure.oGuiHandle.oPotential.TimeSeries,...
                oFigure.oParentFigure.oGuiHandle.oPotential.Baseline.Corrected(:,1),'k');
            title('Baseline Corrected Signal');
        end
        
        % --------------------------------------------------------------------
        function oSplineMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oApplyMenu_Callback(oFigure, src, event)

        end
        
    end
   
end

