classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
        Helper = DataHelper();
        SelectedConnector = 1;
        SelectedBeat = 1;
        SelectedChannel = 1;
        SubPlotXdim;
        SubPlotYdim;
        LineColours=['r','b','g'];
    end
        
    methods
        %% Properties access
         function set.SelectedChannel(oFigure,Value)
             oFigure.SelectedChannel =  Value + oFigure.SubPlotXdim*oFigure.SubPlotYdim*(oFigure.SelectedConnector-1);
         end
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
            set(oFigure.oGuiHandle.bRejectChannel, 'callback', @(src, event)  bAcceptChannel_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oActivationMenu, 'callback', @(src, event) oActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oToolMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMapElectrodesMenu, 'callback', @(src, event) oMapElectrodesMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.CreateSubPlot();
            oFigure.Replot();

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
            oFigure.SelectedConnector = oFigure.GetPopUpSelectionDouble('oConnectorPopUp');
            oFigure.Replot();
        end
     
        function oSignalPlot_Callback(oFigure, src, event)
            oFigure.SelectedChannel = str2double(get(src,'tag'));
            oFigure.Replot();
        end
        
        function oElectrodePlot_Callback(oFigure, src, event)
            oPoint = get(src,'currentpoint');
            xDim = oPoint(1,1);
            iBeatIndexes = oFigure.oParentFigure.oGuiHandle.oUnemap.GetClosestBeat(oFigure.SelectedChannel,xDim);
            oFigure.SelectedBeat = iBeatIndexes{1,1};
            oFigure.Replot();
        end
        
        function bAcceptChannel_Callback(oFigure,src,event)
            ButtonState = get(oFigure.oGuiHandle.bRejectChannel,'Value');
            if ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Max')
                % Toggle button is pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.RejectChannel(oFigure.SelectedChannel);
            elseif ButtonState == get(oFigure.oGuiHandle.bRejectChannel,'Min')
                % Toggle button is not pressed
                oFigure.oParentFigure.oGuiHandle.oUnemap.AcceptChannel(oFigure.SelectedChannel);
            end
            oFigure.Replot();
        end
        
        %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
                
        % --------------------------------------------------------------------
        function oEditMenu_Callback(oFigure, src, event)

        end
        
        % --------------------------------------------------------------------
        function oToolMenu_Callback(oFigure, src, event)
            
        end
        
        % --------------------------------------------------------------------
        function oActivationMenu_Callback(oFigure, src, event)
            oFigure.oParentFigure.oGuiHandle.oUnemap.MarkActivation('SteepestSlope');
            oFigure.Replot();
        end
        
        % --------------------------------------------------------------------
        function oMapElectrodesMenu_Callback(oFigure, src, event)
            MapElectrodes(oFigure);
        end
        
     end
     
     methods (Access = private)
        
         function iChannelIndex = GetSelectedChannelIndex(oFigure)
             %Convert the channel number into an index of the plots
             %visible.
             iChannelIndex = oFigure.SelectedChannel - ...
                 oFigure.SubPlotXdim*oFigure.SubPlotYdim*(oFigure.SelectedConnector-1);
         end
         
         function Replot(oFigure)
            oFigure.PlotBeat();
            oFigure.PlotElectrode();
            oFigure.CheckRejectToggleButton();
         end
         
         function CheckRejectToggleButton(oFigure)
             if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannel).Accepted
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',0);
             else
                 set(oFigure.oGuiHandle.bRejectChannel,'Value',1);
             end
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
                         sprintf('%d',iIndex));
                     %Set some callbacks
                     
                     aCurrent = aPosition;
                     %Plots are added from left to right
                     aPosition = [aCurrent(1) + yDiv, ((-i+3)*xDiv), yDiv, xDiv];
                 end
                 %Plots are added bottom to top
                 aPosition = [0, aPosition(2) + xDiv, yDiv, xDiv];
             end
         end
         
         function PlotBeat(oFigure)
             %Plot the beats for the selected connector, all channels, in the subplot 
             
             %Get the array of handles to the subplots that are children of
             %pnSignals panel
             aSubPlots = get(oFigure.oGuiHandle.pnSignals,'children');
             %Get the current property values
             iBeat = oFigure.SelectedBeat;
             iCurrentChannel = oFigure.GetSelectedChannelIndex();
             
             for i = oFigure.SubPlotXdim:-1:1
                 for j = 1:oFigure.SubPlotYdim
                     iIndex = ((-i+3)*8)+j;
                     %The channel data to plot on the iIndex subplot
                     iChannelIndex = iIndex + oFigure.SubPlotXdim*oFigure.SubPlotYdim*(oFigure.SelectedConnector-1);
                     oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannelIndex);
                     %Get the data
                     aData = oElectrode.Processed.Data(...
                         oElectrode.Processed.BeatIndexes(iBeat,1):...
                         oElectrode.Processed.BeatIndexes(iBeat,2));
                     aSlope = oElectrode.Processed.Slope(...
                         oElectrode.Processed.BeatIndexes(iBeat,1):...
                         oElectrode.Processed.BeatIndexes(iBeat,2));
                     aTime = oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                         oElectrode.Processed.BeatIndexes(iBeat,1):...
                         oElectrode.Processed.BeatIndexes(iBeat,2));
                     %Get these values so that we can place text in the
                     %right place
                     YMax = max([max(aData),max(aSlope)]);
                     YMin = min([min(aData),min(aSlope)]);
                     TimeMax = max(aTime);
                     TimeMin = min(aTime);
                     %Get the handle to current plot
                     oSignalPlot = oFigure.Helper.GetHandle(aSubPlots, sprintf('%d',iIndex));
                     set(oSignalPlot,'XTick',[],'YTick',[], 'Tag', ...
                         sprintf('%d',iIndex),'NextPlot','replacechildren');
                     %Plot the data and slope
                     if oElectrode.Accepted
                         %If the signal is accepted then plot it as black
                         plot(oSignalPlot,aTime,aData,'k');
                         hold(oSignalPlot,'on');
                         plot(oSignalPlot,aTime,aSlope,'-r');
                         if ~isempty(oElectrode.Activation)
                             %Mark the activation times with a line
                             %Label the line with the activation time

                             oLine = line([aTime(oElectrode.Activation(1).Indexes(iBeat)) ...
                                 aTime(oElectrode.Activation(1).Indexes(iBeat))], ...
                                 [aSlope(oElectrode.Activation(1).Indexes(iBeat)) - 1 ...
                                 aSlope(oElectrode.Activation(1).Indexes(iBeat)) + 1]);
                             set(oLine,'Tag',sprintf('ActLine%d',iChannelIndex),'color','r','parent',oSignalPlot, ...
                                 'linewidth',2);
                             oActivationLabel = text(aTime(oElectrode.Activation(1).Indexes(iBeat)), ...
                                 aSlope(oElectrode.Activation(1).Indexes(iBeat)) + 1.1, ...
                                 num2str(aTime(oElectrode.Activation(1).Indexes(iBeat)),'% 10.4f'));
                             set(oActivationLabel,'color','r','FontWeight','bold','FontUnits','normalized');
                             set(oActivationLabel,'FontSize',0.07);
                             set(oActivationLabel,'parent',oSignalPlot);
                         end
                         hold(oSignalPlot,'off');
                     else
                         %The signal is not accepted so plot it as red
                         %without gradient
                         plot(oSignalPlot,aTime,aData,'-r');
                     end
                     
                     %Set some callbacks for this subplot
                     set(oSignalPlot, 'buttondownfcn', @(src, event)  oSignalPlot_Callback(oFigure, src, event));
                     %Set the axis on the subplot
                     axis(oSignalPlot,[TimeMin, TimeMax, YMin - 0.5, YMax + 1]);
                     %Create a label that shows the channel name
                     oLabel = text(TimeMin,YMax + 0.2,char(oElectrode.Name));
                     if iIndex == iCurrentChannel;
                        set(oLabel,'color','b','FontWeight','bold','FontUnits','normalized');
                        set(oLabel,'FontSize',0.1);
                     end
                     set(oLabel,'parent',oSignalPlot);
                 end
             end
         end
         
         function PlotElectrode(oFigure)
             %Plot all the beats for the selected channel in the axes at
             %the bottom
             
             %Get the current property values
             iBeat = oFigure.SelectedBeat;
             iChannel = oFigure.SelectedChannel;
             oAxes = oFigure.oGuiHandle.oElectrodeAxes;
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
             if oFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(oFigure.SelectedChannel).Accepted
                 %If the signal is accepted then plot it as black
                 plot(oAxes,aTime,aProcessedData,'k');
                 axis(oAxes,[TimeMin, TimeMax, YMin - 0.2, YMax + 0.2]);
                 hold(oAxes,'on');
                 plot(oAxes,aTime,aBeatData,'-g');
                 plot(oAxes,aSelectedTime,aSelectedBeat,'-b');
                 hold(oAxes,'off');
                 %Set callback
                 set(oAxes, 'buttondownfcn', @(src, event)  oElectrodePlot_Callback(oFigure, src, event));
             else
                 %The signal is not accepted so plot it as red
                 %without beats
                 plot(oAxes,aTime,aProcessedData,'-r');
                 axis(oAxes,[TimeMin, TimeMax, YMin - 0.2, YMax + 0.2]);
             end
             
         end
     end
end

