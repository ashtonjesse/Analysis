classdef MapElectrodes < SubFigure
    %   MapElectrodes.    
    
    properties
        SelectedChannels;
        Overlay = 0;
        Potential = [];
        Activation = [];
        cbarmin;
        cbarmax;
        PlotType; %A string specifying the currently selected type of plot
        PlotPosition; %An array that can be used to store the position of the oMapAxes 
        PlotLimits;
        oHiddenAxes;
    end
    
    events
        ChannelGroupSelection;
        ElectrodeSelected;
    end
    
    methods
        function oFigure = MapElectrodes(oParent,Xdim,Ydim)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'MapElectrodes',@MapElectrodes_OpeningFcn);
            
            %Callbacks
            set(oFigure.oGuiHandle.oDataCursorTool, 'oncallback', @(src, event) oDataCursorOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'offcallback', @(src, event) oDataCursorOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oActScatterMenu, 'callback', @(src, event) oActScatterMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oActContourMenu, 'callback', @(src, event) oActContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oActAverageMenu, 'callback', @(src, event) oActAverageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oReplotMenu, 'callback', @(src, event) oReplotMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOverlayMenu, 'callback', @(src, event) oOverlayMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMapMenu, 'callback', @(src, event) oSaveMapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPotContourMenu, 'callback', @(src, event) oPotContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRefreshActivationMenu, 'callback', @(src, event) oRefreshActivationMenu_Callback(oFigure, src, event));
           
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Add a listener so that the figure knows when a user has
            %made a beat selection
            addlistener(oFigure.oParentFigure,'BeatSelectionChange',@(src,event) oFigure.BeatSelectionListener(src, event));
            %Add one so the figure knows when it's parent has been deleted
            addlistener(oFigure.oParentFigure,'FigureDeleted',@(src,event) oFigure.ParentFigureDeleted(src, event));
            %Add a listener so the figure knows when a new time point has
            %been selected.
            addlistener(oFigure.oParentFigure,'TimeSelectionChange',@(src,event) oFigure.TimeSelectionListener(src, event));
            %Add a listener so the figure knows when a new channel has been
            %selected
            addlistener(oFigure.oParentFigure,'ChannelSelected',@(src,event) oFigure.ChannelSelectionListener(src, event));
            %Add a listener so the figure knows when a signal event
            %selection change has been made
            addlistener(oFigure.oParentFigure,'SignalEventSelectionChange',@(src,event) oFigure.SignalEventSelectionListener(src, event));
            %Set plot position and plot type 
            oFigure.PlotPosition = [0.05 0.05 0.88 0.88];
            oFigure.PlotType = 'JustElectrodes';
            oFigure.PlotLimits = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.GetSpatialLimits();
            %Plot the electrodes
            oFigure.CreatePlots();
            oFigure.PlotData();
            %Set default selection
            oFigure.SelectedChannels = 1:(Xdim*Ydim);
            % --- Executes just before BaselineCorrection is made visible.
            function MapElectrodes_OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Can actually access oParent from here as this is a
                %subfunction :) :)

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
         function oFigure = Close_fcn(oFigure, src, event)
             deleteme(oFigure);
         end
         
         %% Menu Callbacks
        % -----------------------------------------------------------------
        function oMenu_Callback(oFigure, src, event)

        end
        
        % -----------------------------------------------------------------
        function oSaveMapMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if (~ischar(sFilename) && ~ischar(sPathName))
                return
            end
            %             %Save individual beat activation time
            %             iBeat = oFigure.oParentFigure.SelectedBeat;
            %             sLongDataFileName=strcat(sPathName,sFilename,'.bmp');
            %             oFigure.PrintFigureToFile(sLongDataFileName);
            
            %Save series of potential fields
            iBeat = oFigure.oParentFigure.SelectedBeat;
            oFigure.PlotType = 'Potential2DContour';
            for i = 1:length(oFigure.Potential.Beats(iBeat).Fields)
                %Get the full file name and save it to string attribute
                sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
                oFigure.oParentFigure.SelectedTimePoint = i;
                oFigure.PlotData();
                drawnow; pause(.2);
                oFigure.PrintFigureToFile(sLongDataFileName);
            end
            
%             %             %Save series of activation maps
%             for i = 1:size(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
%                 %Get the full file name and save it to string attribute
%                 sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
%                 oFigure.oParentFigure.SelectedBeat = i;
%                 oFigure.PlotActivation();
%                 drawnow; pause(.2);
%                 oFigure.PrintFigureToFile(sLongDataFileName);
%             end
            
            %end
        end
        
        % -----------------------------------------------------------------
        function oReplotMenu_Callback(oFigure, src, event)
            oFigure.ReplotElectrodes();
        end
        
        % -----------------------------------------------------------------
        function oOverlayMenu_Callback(oFigure, src, event)
            %toggle an overlay of the electrode points on the existing plot
            
            oFigure.Overlay = ~oFigure.Overlay;
            oFigure.PlotData();
        end
        
        function oRefreshActivationMenu_Callback(oFigure, src, event)
            %Refresh the data
            oFigure.RefreshActivationData();
        end
        % -----------------------------------------------------------------
        function oUpdateMenu_Callback(oFigure, src, event)
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            brushedIdx = ~isnan([brushedData{:,1}]);
            [row, colIndices] = find(brushedIdx);
            if ~isempty(colIndices)
                oFigure.SelectedChannels = colIndices;
                %Notify listeners
                notify(oFigure,'ChannelGroupSelection',DataPassingEvent(colIndices,[]));
            else
                error('MapElectrodes.oUpdateMenu_Callback:NoSelectedChannels', 'You need to select at least 1 channel');
            end
            
        end
        
        function oAverageMenu_Callback(oFigure, src, event)
            %Prepare the input options for the ApplyNeighbourhoodAverage
            %function
            %This is currently not in operation as I removed the controls
            %edtRows and edtCols
            aInOptions = struct();
            aInOptions.Procedure = 'Mean';
            iRows = oFigure.GetEditInputDouble('edtRows');
            iCols = oFigure.GetEditInputDouble('edtCols');
            aInOptions.KernelBounds = [iRows iCols];
            oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.ApplyNeighbourhoodAverage(aInOptions);
        end
        
        function oActAverageMenu_Callback(oFigure, src, event)
            %Prepare average activation maps for beats preceeding, during
            %and after stimulation period
            oAverageData = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.CalculateAverageActivationMap(oFigure.Activation);
            %Produce average maps
            oPlotData = struct();
            oPlotData.x = oAverageData.x;
            oPlotData.y = oAverageData.y;
            oPlotData.MinCLim = 0;
            oPlotData.MaxCLim = ceil(max(max(max(oAverageData.PreStim.z),max(oAverageData.Stim.z)),max(oAverageData.PostStim.z)));
            %2D
            %The prestim
            oPlotData.z = oAverageData.Stim.z;
            oPlotData.MaxCLim = max(oPlotData.z);
            oPlotData.MinCLim = min(oPlotData.z);
            oPlotData.XLim = get(oFigure.oGuiHandle.oMapAxes,'xlim');
            oPlotData.YLim = get(oFigure.oGuiHandle.oMapAxes,'ylim');
            AxesControl(oFigure,'Activation2DScatter','2DDuringStim',oPlotData);
          
        end
        
        function oDataCursorOnTool_Callback(oFigure, src, event)
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
        end
        
        function oDataCursorOffTool_Callback(oFigure, src, event)
            %Turn brushing off 
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
        end
        
        %% Callbacks
        function oPotContourMenu_Callback(oFigure, src, event)
            %Generate potential map for the current beat
            
            %Check if the potential data needs to be prepared
            if isempty(oFigure.Potential)
                oFigure.Potential = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PreparePotentialMap(50);
            end
            
            %Update the plot type
            oFigure.PlotType = 'Potential2DContour';

            %Plot a potential contour map
            oFigure.PlotData();
        end
        
        function oActScatterMenu_Callback(oFigure, src, event)
            %Generate activation map for the current beat
            
            %Check if the activation data needs to be prepared
            if isempty(oFigure.Activation)
                oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(50, 'Scatter',oFigure.oParentFigure.SelectedEventID);
            end
            
            %Update the plot type
            oFigure.PlotType = 'Activation2DScatter';

            %Plot a 2D activation map
            oFigure.PlotData();
        end
        
        function oActContourMenu_Callback(oFigure, src, event)
            %Generate activation map for the current beat
            
            %Check if the activation data needs to be prepared
            if isempty(oFigure.Activation)
                oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(50, 'Contour', oFigure.oParentFigure.SelectedEventID);
            end
            
            %Update the plot type
            oFigure.PlotType = 'Activation2DContour';

            %Plot a 2D activation map
            oFigure.PlotData();
        end
       
        function BeatSelectionListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new beat using the electrode
            %plot in AnalyseSignals
            
            oFigure.PlotData();
        end
        
        function TimeSelectionListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new time point using the
            %slidecontrol
                        
            if strncmpi(oFigure.PlotType,'Pot',3)
                oFigure.PlotData();
            end
        end
        
        function ChannelSelectionListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new channel
            
            oFigure.PlotData();
        end
        
        function SignalEventSelectionListener(oFigure, src, event)
            %Change the map according to the new signalevent selection
            if isempty(event.Value)
                oFigure.ReplotElectrodes();
            else
                oFigure.RefreshActivationData();
            end
            
        end
        
        function oHiddenAxes_Callback(oFigure, src, event)
            %Get the selected point and find the closest electrode 
            oPoint = get(src,'currentpoint');
            xLoc = oPoint(1,1);
            yLoc = oPoint(1,2);
            iChannel = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.GetNearestElectrodeID(xLoc, yLoc);
            %Notify listeners about the new electrode selection
            notify(oFigure, 'ElectrodeSelected', DataPassingEvent([],iChannel));
        end
     end
     
     methods (Access = private)
         function CreatePlots(oFigure)
             %Create the plots that will be used
             
             %Create a subplot in the position specified
             oMapPlot = axes('Position',oFigure.PlotPosition,'Tag', 'MapPlot');
             oHiddenPlot = axes('Position',oFigure.PlotPosition,'xtick',[],'ytick',[],'Tag', 'HiddenPlot','color','none');
         end
         
         function PlotData(oFigure)
             %Get the array of handles to the subplots that are children of
             %oPanel
             aSubPlots = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oMapPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'MapPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oMapPlot, 'Tag', 'MapPlot', 'NextPlot', 'replacechildren');
             cla(oMapPlot);
             
             %Do the same for the hidden plot
             oHiddenPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'HiddenPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oHiddenPlot, 'Tag', 'HiddenPlot', 'NextPlot', 'replacechildren');
             set(oHiddenPlot, 'buttondownfcn', @(src, event) oHiddenAxes_Callback(oFigure, src, event));
             cla(oHiddenPlot);
             %Call the appropriate plotting function
             switch (oFigure.PlotType)
                 case 'JustElectrodes'
                     oFigure.PlotElectrodes(oMapPlot);
                 case {'Activation2DContour','Activation3DSurface'}
                     oFigure.PlotActivation(oMapPlot);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oMapPlot);
                     end
                 case 'Potential2DContour'
                     oFigure.PlotPotential(oMapPlot);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oMapPlot);
                     end
             end
             %Reset the hiddenplot position in case mapplot has moved
             set(oHiddenPlot,'Position',get(oMapPlot,'Position'));
             %Set the axis limits
             axis(oMapPlot, 'equal');
             set(oMapPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             axis(oHiddenPlot, 'equal');
             set(oHiddenPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             %Refocus on HiddenPlot has this needs to be on the top to
             %receive user clicks.
             axes(oHiddenPlot);
         end
         
         function ReplotElectrodes(oFigure)
             oFigure.PlotType = 'JustElectrodes';
             oFigure.PlotData();
         end
         
         function RefreshActivationData(oFigure)
             %Choose which routine to call.
             if strcmpi(oFigure.PlotType,'Activation2DScatter')
                 oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(50, 'Scatter',oFigure.oParentFigure.SelectedEventID);
             elseif strcmpi(oFigure.PlotType,'Activation2DContour')
                 oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(50, 'Contour',oFigure.oParentFigure.SelectedEventID);
             end
             %Plot a 2D activation map
             oFigure.PlotData();
         end
         
         function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
         end
         
         function PlotElectrodes(oFigure,oMapAxes)
             %Plots the electrode locations on the map axes
             
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             
             %Get the electrodes
             oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
             %Get the number of channels
             [i NumChannels] = size(oElectrodes);
             %Loop through the electrodes plotting their locations
%              oWaitbar = waitbar(0,'Please wait...');

             for i = 1:NumChannels;
                 %Plot the electrode point
                 hold(oMapAxes,'on');
                 if strcmpi(oFigure.PlotType,'JustElectrodes')
                     %Just plotting the electrodes so add a text label
                     plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.', ...
                         'MarkerSize',12);
                     %Label the point with the channel name
                     oLabel = text(oElectrodes(i).Coords(1) - 0.1, oElectrodes(i).Coords(2) + 0.07, ...
                         oElectrodes(i).Name);
                     set(oLabel,'FontWeight','bold','FontUnits','normalized');
                     set(oLabel,'FontSize',0.015);
                     set(oLabel,'parent',oMapAxes);
                     if ~oElectrodes(i).Accepted
                         %Just the label is red if the electrode is
                         %rejected
                         set(oLabel,'color','r');
                     end
                 elseif (oFigure.Overlay)
                     %Plotting the electrodes on top of something else
                     if ~oElectrodes(i).Accepted
                         %plot the point as red
                         plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2),'r.', ...
                             'MarkerSize', 12);
                     else
                         %else just plot the default color
                         plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2),'.', ...
                             'MarkerSize', 12);
                     end
                 end
             end
             
             if strcmpi(oFigure.PlotType,'JustElectrodes')
                 %Don't need a colorbar if the plot is just of electrodes
                 %check if there is an existing colour bar and delete it
                 %get figure children
                 oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                 oColorBar = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                 if oColorBar > 0
                     delete(oColorBar);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 end
                 oTitle = get(oMapAxes,'Title');
                 set(oTitle,'String','');
             end
             %              close(oWaitbar);
             hold(oMapAxes,'off');
         end
         
         function PlotActivation(oFigure, oMapAxes)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             %Which plot type to use
             switch (oFigure.PlotType)
                 case 'Activation2DContour'
                     %check if there is an existing colour bar
                     %get figure children
                     oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                     oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                     if oHandle < 0
                         %Get a new min and max
                         oFigure.cbarmax = 0; 
                         oFigure.cbarmin = 2000; %arbitrary
                         ibmax = 0;
                         ibmin = 0;
                         for i = 1:length(oFigure.Activation.Beats)
                             %Loop through the beats to find max and min
                             dMin = min(min(oFigure.Activation.Beats(i).z));
                             dMax = max(max(oFigure.Activation.Beats(i).z));
                             if dMin < oFigure.cbarmin
                                 oFigure.cbarmin = dMin;
                                 ibmin = i;
                             end
                             if dMax > oFigure.cbarmax
                                 oFigure.cbarmax = dMax;
                                 ibmax = i;
                             end
                         end
                     end
                     set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
                     %Assuming the potential field has been normalised.
                     [C, oContour] = contourf(oMapAxes,oFigure.Activation.x,oFigure.Activation.y,oFigure.Activation.Beats(iBeat).z,floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
                     colormap(oMapAxes, colormap(flipud(colormap(jet))));
                     if oHandle < 0
                         oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
                         oTitle = get(oColorBar, 'title');
                     else
                         oTitle = get(oHandle, 'title');
                     end
                     set(oTitle,'units','normalized');
                     set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
                     iChannel = oFigure.oParentFigure.SelectedChannel;
                     %Get the electrodes and plot the selected electrode
                     %and the electrode with the earliest activation
                     hold(oMapAxes,'on');
                     oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
                     plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                         'MarkerSize',18,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');
                     [C iFirstActivationChannel] = min(oFigure.Activation.Beats(iBeat).FullActivationTimes);
                     plot(oMapAxes, oElectrodes(iFirstActivationChannel).Coords(1), oElectrodes(iFirstActivationChannel).Coords(2), ...
                         'MarkerSize',15,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','r');
                     hold(oMapAxes,'off');
                     
                 case 'Activation2DScatter'
                     set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
                     scatter(oMapAxes, oFigure.Activation.x, oFigure.Activation.y, 100, oFigure.Activation.z(:,iBeat), 'filled');
                     
                     colormap(oMapAxes, colormap(flipud(colormap(jet))));
                     oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                     oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                     if oHandle < 0
                         oHandle = cbarf(oFigure.Activation.z(:,iBeat),ceil(0:oFigure.Activation.MaxActivationTime/20):ceil(oFigure.Activation.MaxActivationTime));
                     end
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
                     
                 case 'Activation3DSurface'
                     aTriangulatedMesh = delaunay(oFigure.Activation.x, oFigure.Activation.y);
                     trisurf(aTriangulatedMesh,oFigure.Activation.x, oFigure.Activation.y,-oFigure.Activation.z(:,iBeat));
                     zlim(oMapAxes,[-ceil(oFigure.Activation.MaxActivationTime) 0]);
                     set(oMapAxes,'CLim',[-ceil(oFigure.Activation.MaxActivationTime) 0]);
                     view(oMapAxes,30,30);
                     colormap(oMapAxes, colormap(colormap(jet)));
                     colorbar('peer',oMapAxes);
                     colorbar('location','EastOutside');
             end
             
             title(oMapAxes,sprintf('Activation map for beat #%d',iBeat));
         end
         
         function PlotPotential(oFigure, oMapAxes)
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the selected beat
             iBeat = oFigure.oParentFigure.SelectedBeat;
             %Get the time point selected
             iTimeIndex = oFigure.oParentFigure.SelectedTimePoint;
             %Which plot type to use
             switch (oFigure.PlotType)
                 case 'Potential2DContour'
                     %Save axes limits
                     oXLim = get(oMapAxes,'xlim');
                     oYLim = get(oMapAxes,'ylim');
                     
                     %check if there is an existing colour bar
                     %get figure children
                     oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                     oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                     if oHandle < 0
                         %Get a new min and max
                         oFigure.cbarmax = 0; 
                         oFigure.cbarmin = 2000; %arbitrary
                         ibmax = 0;
                         ibmin = 0;
                         for i = 1:length(oFigure.Potential.Beats(iBeat).Fields)
                             %Loop through the timepoint fields (not including the first 25 that cover the stimulus) for
                             %this beat to find max and min
                             dMin = min(min(oFigure.Potential.Beats(iBeat).Fields(i).z));
                             dMax = max(max(oFigure.Potential.Beats(iBeat).Fields(i).z));
                             if dMin < oFigure.cbarmin
                                 oFigure.cbarmin = dMin;
                                 ibmin = i;
                             end
                             if dMax > oFigure.cbarmax
                                 oFigure.cbarmax = dMax;
                                 ibmax = i;
                             end
                         end
                     end
                     %Assuming the potential field has been normalised.
                     set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
                     contourf(oMapAxes,oFigure.Potential.x,oFigure.Potential.y,oFigure.Potential.Beats(iBeat).Fields(iTimeIndex).z,floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
                     colormap(oMapAxes, colormap(flipud(colormap(jet))));
                     if oHandle < 0
                         oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
                         oTitle = get(oColorBar, 'title');
                     else
                         oTitle = get(oHandle, 'title');
                     end
                     set(oTitle,'units','normalized');
                     set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                     %Reset the axes limits
                     set(oMapAxes,'XLim',oXLim,'YLim',oYLim);
                     iChannel = oFigure.oParentFigure.SelectedChannel;
                     %Get the electrodes
                     hold(oMapAxes,'on');
                     oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
                     plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                         'MarkerSize',18,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');
                     
                     for i = 1:length(oElectrodes)
                         if (oElectrodes(i).Accepted) && (oElectrodes(i).SignalEvent(1).Index(iBeat) <= iTimeIndex)
                             plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.', ...
                                 'MarkerSize',20,'color','k');
                         elseif ~oElectrodes(i).Accepted
                             plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.', ...
                                 'MarkerSize',20,'color','r');
                         end
                     end
                     
                     hold(oMapAxes,'off');
             end
             title(oMapAxes,sprintf('Potential Field for time %5.5f s',oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                 oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1)+iTimeIndex)));
         end
     end
end
