classdef SlideControl < SubFigure
% This figure contains a generic slide control

    events
        SlideValueChanged;
    end
    
    methods
        %% Constructor
        function oFigure = SlideControl(oParent,sTitle)
            oFigure = oFigure@SubFigure(oParent,'SlideControl',@SlideControl_OpeningFcn);
            
            %set up slider
            aSliderTexts = [oFigure.oGuiHandle.oSliderTxtLeft,oFigure.oGuiHandle.oSliderTxtRight];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', sTitle}, {'Min', 1, 'Max', ...
               2, 'Value', 1, 'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[0.1  0.02]},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
           
            % --- Executes just before BaselineCorrection is made visible.
            function SlideControl_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set the output attribute
                handles.output = hObject;
                %Update the gui handles
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = public)
        function deletefigure(oFigure)
            %A function that can be called by other figures to delete this
            %one.
             deleteme(oFigure);
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private UI control callbacks
        function oSlider_Callback(oFigure, src, event)
            %Notify listeners and pass the selected value
            notify(oFigure,'SlideValueChanged');
        end
    end
    
end


