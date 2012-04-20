classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.CreateSubPlot();

            % --- Executes just before BaselineCorrection is made visible.
            function AnalyseSignals_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set ui control creation attributes 
                                
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
        
     end
    
     methods (Access = public)
         %% Ui control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
           deleteme(oFigure);
        end
     end
     
     methods (Access = private)
         function CreateSubPlot(oFigure)
             %Create the space for the subplot that will contain all the
             %signals
             
             %Get the dimensions of the subplot
             xDim = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes.PlotXDimension;
             yDim = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes.PlotYDimension;
             subplot(xDim,yDim,1,'parent', oFigure.oGuiHandle.pnSignals);
             myx = 1/xDim;
             myy = 1/yDim;
             aPosition = [0, 1-myx,  myy, myx];
             %[left bottom width height]
             for i = 1:(xDim*yDim);
                 oFigure.oGuiHandle.oSignalPlot = subplot(xDim,yDim,i);
                 set(oFigure.oGuiHandle.oSignalPlot,'Position',aPosition);
                 plot(oFigure.oGuiHandle.oSignalPlot,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, ...
                     oFigure.oParentFigure.oGuiHandle.oUnemap.Processed.Data(:,i),'k');
                 set(oFigure.oGuiHandle.oSignalPlot,'XTick',[],'YTick',[]);
                 aCurrent = aPosition;
                 aPosition = [aCurrent(1) + myy, 1 - myx, myy, myx];
             end
         end
     end
end

