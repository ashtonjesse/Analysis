classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
        SubPlotXdim;
        SubPlotYdim;
        Helper = DataHelper();
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            
            %Get constants
            oFigure.SubPlotXdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.xDim;
            oFigure.SubPlotYdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.yDim;
            
            %Set callbacks
            set(oFigure.oGuiHandle.oConnectorPopUp, 'callback', @(src, event)  oConnectorPopUp_Callback(oFigure, src, event));
            %Set up the slider panels
            aBeatSliderTexts = [oFigure.oGuiHandle.txtBeatLeft,oFigure.oGuiHandle.txtBeatRight];
            iNumberOfBeats = size(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Beats'}, {'Min', 1, 'Max', iNumberOfBeats , 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[1/iNumberOfBeats  0.1]},{'string',1},{},'%0.0f',...
                oFigure.oGuiHandle.pnBeats, oFigure.oGuiHandle.oBeatSlider,oFigure.oGuiHandle.oBeatEdit,aBeatSliderTexts);
            aChannelSliderTexts = [oFigure.oGuiHandle.txtChannelLeft,oFigure.oGuiHandle.txtChannelRight];
            iNumberOfChannels =  oFigure.SubPlotXdim*oFigure.SubPlotYdim;
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Select Channel'}, {'Min', 1, 'Max', iNumberOfChannels , 'Value', 1, ...
                'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[1/iNumberOfChannels 0.1]},{'string',1},{},'%0.0f',...
                oFigure.oGuiHandle.pnChannels, oFigure.oGuiHandle.oChannelSlider,oFigure.oGuiHandle.oChannelEdit,aChannelSliderTexts);
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.PlotElectrode(1,1);           
            oFigure.CreateSubPlot();
            oFigure.PlotBeat(1,1,1);

            
            % --- Executes just before BaselineCorrection is made visible.
            function AnalyseSignals_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)
                
                %Set ui control creation attributes 
                set(handles.oConnectorPopUp, 'string', {'1','2','3','4','5','6','7','8','9','10','11','12'});
                
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
        
        function oConnectorPopUp_Callback(oFigure, src, event)
            oFigure.Replot();
        end
        
        function oSlider_Callback(oFigure, src, event)
           oFigure.Replot();
        end
               
     end
     
     methods (Access = private)
         function iBeatNumber = GetSelectedBeat(oFigure)
             iBeatNumber = round(get(oFigure.oGuiHandle.oBeatSlider,'Value'));
         end
         
         function iChannelNumber = GetSelectedChannel(oFigure)
             iChannelNumber = round(get(oFigure.oGuiHandle.oChannelSlider,'Value'));
         end
         
         function Replot(oFigure)
             dCurrentConnector = oFigure.GetPopUpSelectionDouble('oConnectorPopUp');
            iChannelNumber = oFigure.GetSelectedChannel();
            iBeatNumber = oFigure.GetSelectedBeat();
            oFigure.PlotBeat(dCurrentConnector,iChannelNumber,iBeatNumber);
            oFigure.PlotElectrode(iChannelNumber + oFigure.SubPlotXdim*oFigure.SubPlotYdim*(dCurrentConnector-1),iBeatNumber);
         end
         
         function CreateSubPlot(oFigure)
             %Create the space for the subplot that will contain all the
             %signals
             
             %Divide up the space for the subplots
             xDiv = 1/oFigure.SubPlotXdim;
             yDiv = 1/oFigure.SubPlotYdim;
             %Initialise the position of the subplots
             aPosition = [0, 0,  yDiv, xDiv]; %[left bottom width height]
             
             for i = oFigure.SubPlotXdim:-1:1
                 for j = 1:oFigure.SubPlotYdim
                     %Get the subplot index
                     iIndex = ((-i+3)*8)+j;
                     %Create a subplot in the position specified
                     oSignalPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals, 'Tag', ...
                         sprintf('oSignalplot%d',iIndex));
                     aCurrent = aPosition;
                     %Plots are added from left to right
                     aPosition = [aCurrent(1) + yDiv, ((-i+3)*xDiv), yDiv, xDiv];
                 end
                 %Plots are added bottom to top
                 aPosition = [0, aPosition(2) + xDiv, yDiv, xDiv];
             end
         end
         
         function PlotBeat(oFigure,dCurrentConnector,dCurrentChannel,dBeat)
             %Plot the beats for the selected connector, all channels, in the subplot 
             
             %Get the array of handles to the subplots that are children of
             %pnSignals panel
             aSubPlots = get(oFigure.oGuiHandle.pnSignals,'children');
             
             for i = oFigure.SubPlotXdim:-1:1
                 for j = 1:oFigure.SubPlotYdim
                     iIndex = ((-i+3)*8)+j;
                     %The channel data to plot on the iIndex subplot
                     iChannel = iIndex + 24*(dCurrentConnector-1);
                     aData = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data(...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,1):...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,2));
                     aSlope = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Slope(...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,1):...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,2));
                     aTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,1):...
                         oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(dBeat,2));
                     %Get these values so that we can place text in the
                     %right place
                     YMax = max([max(aData),max(aSlope)]);
                     YMin = min([min(aData),min(aSlope)]);
                     TimeMax = max(aTime);
                     TimeMin = min(aTime);
                     %Get the handle to current plot
                     oSignalPlot = oFigure.Helper.GetHandle(aSubPlots, sprintf('oSignalplot%d',iIndex));
                     %Plot the data and slope
                     plot(oSignalPlot,aTime,aData,'k');
                     hold(oSignalPlot,'on');
                     plot(oSignalPlot,aTime,aSlope,'-r');
                     hold(oSignalPlot,'off');
                     set(oSignalPlot,'XTick',[],'YTick',[], 'Tag', ...
                         sprintf('oSignalplot%d',iIndex),'NextPlot','replacechildren');
                     axis(oSignalPlot,[TimeMin, TimeMax, YMin - 0.5, YMax + 1]);
                     %Create a label that shows the channel name
                     oLabel = text(TimeMin,YMax + 0.2,char(oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Name));
                     if iIndex == dCurrentChannel;
                        set(oLabel,'color','b','FontWeight','bold','FontUnits','normalized');
                        set(oLabel,'FontSize',0.1);
                     end
                     set(oLabel,'parent',oSignalPlot);
                 end
             end
         end
         
         function PlotElectrode(oFigure,iChannel,iBeat)
             %Plot all the beats for the selected channel in the axes at
             %the bottom
             oAxes = oFigure.oGuiHandle.oSignalAxes;
             aProcessedData = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data;
             aBeatData = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Beats;
             aTime = transpose(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries);
             %Get these values so that we can place text in the
             %right place and give the axes dimensions
             YMax = max(aProcessedData);
             YMin = min(aProcessedData);
             TimeMax = max(aTime);
             TimeMin = min(aTime);
             %Get the currently selected beat
             
             aSelectedBeat = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.Data(...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1):...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,2));
             aSelectedTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1):...
                 oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,2));
             %Plot all the data        
             cla(oAxes);
             plot(oAxes,aTime,aProcessedData,'k');
             axis(oAxes,[TimeMin, TimeMax, YMin - 0.2, YMax + 0.2]);
             hold(oAxes,'on');
             plot(oAxes,aTime,aBeatData,'-g');
             plot(oAxes,aSelectedTime,aSelectedBeat,'-b');
             hold(oAxes,'off');
                         
         end
     end
end

