classdef BaselineCorrectionClass < handle
    %BaselineCorrectionClass Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        m_oGuiHandle;
    end
    
    methods
        function oFigure = BaselineCorrectionClass()
            %function - class constructor - creates and initialises the gui
            
            %Make the gui figure handle and store it locally
            oFigure.m_oGuiHandle = guihandles(BaselineCorrection);
            
            %Set the callback functions to the controls
            set(oFigure.m_oGuiHandle.oSignalSlider, 'callback', @(src, event) oSignalSlider_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.pmPolynomialOrder , 'callback', @(src, event)  pmPolynomialOrder_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.pmSplineOrder, 'callback', @(src, event)  pmSplineOrder_Callback(oFigure, src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.m_oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oBaselineMenu, 'callback', @(src, event) oBaselineMenuMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oSplineMenu, 'callback', @(src, event) oSplineMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oApplyMenu, 'callback', @(src, event) oApplyMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oExitMenu, 'callback', @(src, event) oExitMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.m_oGuiHandle.BaselineFigure,  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
                %Set the default signal
                iDefaultSignal = 1;
                set(oOriginalAxes,'UserData',[]);
                set(oOriginalAxes,'UserData',iDefaultSignal);
                
                %Plot the data of the default signal
                set(oBaselineMainFigure,'CurrentAxes',oOriginalAxes);
                plot(Data.Unemap.Time,Data.Unemap.Potential.Original(:,iDefaultSignal),'k');
                axis 'auto';
                
                %Clear the CorrectedOriginal axes
                set(oBaselineMainFigure,'CurrentAxes',oCorrectedOriginal);
                cla;
                axis 'auto';
                %If there a baseline correction has already been done and the data saved
                %then plot the baseline corrected original data too
                if(Data.Unemap.Potential.Baseline.Corrected)
                    plot(Data.Unemap.Time,...
                        Data.Unemap.Potential.Baseline.Corrected(:,iDefaultSignal),'k');
                    sTitle = sprintf('Existing Baseline Corrected Signal');
                    title(sTitle);
                    set(oCorrectedOriginal,'UserData',[]);
                    set(oCorrectedOriginal,'UserData',...
                        Data.Unemap.Potential.Baseline.Corrected(:,iDefaultSignal));
                end
            
        end
    end
    
    methods (Access = private)
        %% Delete and exit methods
        function delete(oFigure)
            %Class deconstructor - handles the cleaning up of the class &
            %figure. Either the class or the figure can initiate the closing
            %condition, this function makes sure both are cleaned up
            
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(oFigure.m_oGuiHandle.BaselineFigure,  'closerequestfcn', '');
            %delete the figure
            delete(oFigure.m_oGuiHandle.BaselineFigure);
            %clear out the pointer to the figure - prevents memory leaks
            oFigure.m_oGuiHandle = [];
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
            %This is the closerequestfcn of the figure. All it does here is
            %call the class delete function (presented above)
            delete(oFigure);
        end

        % --------------------------------------------------------------------
        function oExitMenu_Callback(oFigure, src, event)
            %This runs a closerequest of the figure (same as closing the
            %window)
            closereq;
        end
        
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

        end
        
        % --------------------------------------------------------------------
        function oSplineMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oApplyMenu_Callback(oFigure, src, event)

        end
        
    end
   
end

