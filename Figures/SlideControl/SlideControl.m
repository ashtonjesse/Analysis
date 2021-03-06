classdef SlideControl < SubFigure
% This figure contains a generic slide control

    events
        SlideValueChanged;
    end
    
    methods
        %% Constructor
        function oFigure = SlideControl(oParent,sTitle,sEvent,aLocation)
            oFigure = oFigure@SubFigure(oParent,'SlideControl',@SlideControl_OpeningFcn);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'position',aLocation);
            %set up slider
            aSliderTexts = [oFigure.oGuiHandle.oSliderTxtLeft,oFigure.oGuiHandle.oSliderTxtRight];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', sTitle}, {'Min', 1, 'Max', ...
               2, 'Value', 1, 'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[0.1  0.02]},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure, 'FigureDeleted', @(src,event) oFigure.ParentFigureDeleted(src, event));
            %Add listeners to all specified events
            for i = 1:length(sEvent)
                addlistener(oFigure.oParentFigure, char(sEvent{i}), @(src,event) oFigure.SlideSelectionChange(src, event));
            end
            
            
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
        function SetSliderValue(oFigure, aRange, dValue)
            %Set the slider value and range
            set(oFigure.oGuiHandle.oSliderTxtLeft, 'string', sprintf('%d',aRange(1)));
            set(oFigure.oGuiHandle.oSliderTxtRight, 'string', sprintf('%d',aRange(2)));
            set(oFigure.oGuiHandle.oSlider, 'Min', aRange(1), 'Max', ...
                aRange(2), 'Value', floor(dValue) ,'SliderStep',[1/aRange(2)  0.02]);
            set(oFigure.oGuiHandle.oSliderEdit,'String',floor(dValue));
        end
        

    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private functions
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end
        
        function oSlider_Callback(oFigure, src, event)
            %Notify listeners and pass the selected value
            notify(oFigure,'SlideValueChanged',DataPassingEvent([],oFigure.GetSliderIntegerValue('oSlider')));
        end
        
        function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
        end
         
        function SlideSelectionChange(oFigure, src, event)
            
            oFigure.SetSliderValue(event.ArrayData, event.Value);
        end
    end
    
end


