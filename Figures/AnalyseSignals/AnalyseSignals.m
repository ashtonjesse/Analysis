classdef AnalyseSignals < SubFigure
    %   AnalyseSignals
    %   Detailed explanation goes here
    
    properties
        SelectedBeat = 1;
        SelectedChannel = 1;
        SubPlotXdim;
        SubPlotYdim;
        NumberofChannels;
        LineColours=['r','b','g'];
        oMapElectrodesFigure;
        Dragging;
    end
        
    methods
        %% Properties access
         
    end
    
    methods
        function oFigure = AnalyseSignals(oParent)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'AnalyseSignals',@AnalyseSignals_OpeningFcn);
            
            %Get constants
            oFigure.SubPlotXdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.xDim;
            oFigure.SubPlotYdim = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Plot.Electrodes.yDim;
            oFigure.NumberofChannels = oFigure.oParentFigure.oGuiHandle.oUnemap.oExperiment.Unemap.NumberOfChannels;
            
            %Set callbacks
            set(oFigure.oGuiHandle.bRejectChannel, 'callback', @(src, event)  bAcceptChannel_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oEditMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oActivationMenu, 'callback', @(src, event) oActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oToolMenu_Callback(oFigure, src, event));
            
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            oFigure.oMapElectrodesFigure = MapElectrodes(oFigure,oFigure.SubPlotXdim,oFigure.SubPlotYdim);
            %Add a listener so that the figure knows when a user has
            %made a channel selection
            addlistener(oFigure.oMapElectrodesFigure,'ChannelSelection',@(src,event) oFigure.ChannelSelectionChange(src, event));
            
            %Draw plots
            oFigure.CreateSubPlot();
            %Fill plots
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
            deletefigure(oFigure.oMapElectrodesFigure);
            deleteme(oFigure);
        end
    
        function StartDrag(oFigure, src, event)
            %The function that fires when a line on a subplot is dragged
            oFigure.Dragging = 1;
            oSignalPlot = get(src,'Parent');
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', @(src,event) Drag(oFigure, src, DragEvent(oSignalPlot)));
        end
        
        function StopDrag(oFigure, src, event)
            %The function that fires when the user lets go of a line on a
            %subplot
            if oFigure.Dragging
                %Make sure that the windowbuttonmotionfcn is no longer active
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', '');
                oFigure.Dragging = 0;
                %The tag of the current axes is the channel number
                iChannelNumber = oFigure.SelectedChannel;
                %Get the handle to these axes from the panel children
                oPanelChildren = get(oFigure.oGuiHandle.pnSignals,'children');
                oAxes = oFigure.oDAL.oHelper.GetHandle(oPanelChildren, sprintf('%d',iChannelNumber));
                %Get the handle to the line on these axes
                oAxesChildren = get(oAxes,'children');
                oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, sprintf('ActLine%d',iChannelNumber));
                %Get the xdata of this line and convert it into a timeseries
                %index
                dXdata = get(oLine, 'XData');
                %Update the activation for this electrode and beat number
                oFigure.oParentFigure.oGuiHandle.oUnemap.UpdateActivationMark(iChannelNumber, oFigure.SelectedBeat, dXdata(1));
                %Refresh the plot
                oFigure.Replot();
            end
        end
        
        function Drag(oFigure, src, event)
            %The function that fires while a line on a subplot is being
            %dragged
            oPoint = get(event.ParentAxesHandle, 'CurrentPoint');
            oAxesTag = get(event.ParentAxesHandle,'tag');
            oAxesChildren = get(event.ParentAxesHandle,'children');
            oLine = oFigure.oDAL.oHelper.GetHandle(oAxesChildren, sprintf('ActLine%s',oAxesTag));
            set(oLine, 'XData', oPoint(1)*[1 1]);
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
       
        function ChannelSelectionChange(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new set of channels and hits
            %the update selection menu option in MapElectrodes.fig
            %Draw plots
            oFigure.CreateSubPlot();
            %Fill plots
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
        
        
        
     end
     
     methods (Access = private)
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
            
             %Find the bounds of the selected area
             iMinChannel = min(oFigure.oMapElectrodesFigure.SelectedChannels);
             iMaxChannel = max(oFigure.oMapElectrodesFigure.SelectedChannels);
             %Convert into row and col indices
             [iMinRow iMinCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMinChannel);
             [iMaxRow iMaxCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(iMaxChannel);
             %Divide up the space for the subplots
             xDiv = 1/(iMaxRow-iMinRow+1); 
             yDiv = 1/(iMaxCol-iMinCol+1);
                         
             %Loop through the selected channels
             for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
                 [iRow iCol] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetRowColIndexesForElectrode(oFigure.oMapElectrodesFigure.SelectedChannels(i));
                 %Normalise the row and columns to the minimum.
                 iRow = iRow - iMinRow;
                 iCol = iCol - iMinCol;
                 %Create the position vector for the next plot
                 aPosition = [iCol*yDiv, iRow*xDiv, yDiv, xDiv];%[left bottom width height]
                 %Create a subplot in the position specified
                 oSignalPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.pnSignals, 'Tag', ...
                     sprintf('%d',oFigure.oMapElectrodesFigure.SelectedChannels(i)));
             end
         end
         
         function PlotBeat(oFigure)
             %Plot the beats for the selected channels in the subplot 
             
             %Get the array of handles to the subplots that are children of
             %pnSignals panel
             aSubPlots = get(oFigure.oGuiHandle.pnSignals,'children');
             %Get the current property values
             iBeat = oFigure.SelectedBeat;
             
             for i = 1:size(oFigure.oMapElectrodesFigure.SelectedChannels,2);
                 iChannelIndex = oFigure.oMapElectrodesFigure.SelectedChannels(i);
                 %The channel data to plot on the iIndex subplot
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
                 oSignalPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, sprintf('%d',iChannelIndex));
                 set(oSignalPlot,'XTick',[],'YTick',[], 'Tag', ...
                     sprintf('%d',iChannelIndex),'NextPlot','replacechildren');
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
                             'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
                         set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
                         oActivationLabel = text(aTime(oElectrode.Activation(1).Indexes(iBeat)), ...
                             aSlope(oElectrode.Activation(1).Indexes(iBeat)) + 1.1, ...
                             num2str(aTime(oElectrode.Activation(1).Indexes(iBeat)),'% 10.4f'));
                         set(oActivationLabel,'color','r','FontWeight','bold','FontUnits','normalized');
                         set(oActivationLabel,'FontSize',0.12);
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
                 if iChannelIndex == oFigure.SelectedChannel;
                     set(oLabel,'color','b','FontWeight','bold','FontUnits','normalized');
                     set(oLabel,'FontSize',0.18);
                 else
                     set(oLabel,'FontUnits','normalized');
                     set(oLabel,'FontSize',0.15);
                 end
                 set(oLabel,'parent',oSignalPlot);
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

