classdef MapElectrodes < SubFigure
    %   MapElectrodes.    
    
    properties
        SelectedChannels;
        Potentials;
        Activation;
        cmin;
        cmax;
        PlotType; %A string specifying the currently displayed plot
    end
    
    events
        ChannelSelection;
    end
    
    methods
        function oFigure = MapElectrodes(oParent,Xdim,Ydim)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'MapElectrodes',@MapElectrodes_OpeningFcn);
            
            %Callbacks
            set(oFigure.oGuiHandle.oDataCursorTool, 'oncallback', @(src, event) oDataCursorOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'offcallback', @(src, event) oDataCursorOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oToolMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            %set(oFigure.oGuiHandle.oGenPotentialMenu, 'callback', @(src, event) oGenPotentialMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGenActivationMenu, 'callback', @(src, event) oGenActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.o2DActivationMenu, 'callback', @(src, event) o2DActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.o3DActivationMenu, 'callback', @(src, event) o3DActivationMenu_Callback(oFigure, src, event));
            %set(oFigure.oGuiHandle.oAverageMenu, 'callback', @(src, event) oAverageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oViewMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oReplotMenu, 'callback', @(src, event) oReplotMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveActivationMenu, 'callback', @(src, event) oSaveActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGenAverageMenu, 'callback', @(src, event) oGenAverageMenu_Callback(oFigure, src, event));
            
            %Add a listener so that the figure knows when a user has
            %made a beat selection
            addlistener(oFigure.oParentFigure.oSlideControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            addlistener(oFigure.oParentFigure,'BeatSelected',@(src,event) oFigure.BeatSelectionListener(src, event));
            
            oFigure.PlotElectrodes();
            oFigure.PlotType = 'JustElectrodes';
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
         function deletefigure(oFigure)
             deleteme(oFigure);
         end
         %% Menu Callbacks
        % -----------------------------------------------------------------
        function oFileMenu_Callback(oFigure, src, event)

        end
        % -----------------------------------------------------------------
        function oToolMenu_Callback(oFigure, src, event)

        end
        
        % -----------------------------------------------------------------
        function oViewMenu_Callback(oFigure, src, event)

        end
        
        % -----------------------------------------------------------------
        function oSaveActivationMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            sPathName = uigetdir('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if ~ischar(sPathName)
                return
            end
            %Loop through the beats and save the axes image
            iNumBeats =  get(oFigure.oParentFigure.oSlideControl.oGuiHandle.oSlider,'max');
            for i = 1:iNumBeats;
                set(oFigure.oParentFigure.oSlideControl.oGuiHandle.oSlider,'Value',i);
                set(oFigure.oParentFigure.oSlideControl.oGuiHandle.oSliderEdit,'String',i);
                oFigure.PlotActivation();
                %Get the full file name
                sFileName = strcat(oFigure.PlotType,sprintf('MapBeat%d',i));
                sLongFileName=strcat(sPathName,'\',sFileName);
                oFigure.PrintFigureToFile(sLongFileName);
            end
        end
        
        % -----------------------------------------------------------------
        function oReplotMenu_Callback(oFigure, src, event)
            cla(oFigure.oGuiHandle.oMapAxes);
            colorbar('peer',oFigure.oGuiHandle.oMapAxes,'off');
            oTitle = get(oFigure.oGuiHandle.oMapAxes,'Title');
            set(oTitle,'String','');
            oFigure.PlotElectrodes();
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
                notify(oFigure,'ChannelSelection');
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
        
        function oGenAverageMenu_Callback(oFigure, src, event)
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
            oPlotData.z = oAverageData.PreStim.z;
            %AxesControl(oFigure,'2DScatter','2DPreStimAverage',oPlotData);
            %During stim singleton
            oPlotData.z = oAverageData.Stim.z;
            %AxesControl(oFigure,'2DScatter','2DStimAverage',oPlotData);
            %Post stim
            oPlotData.z = oAverageData.PostStim.z;
            %AxesControl(oFigure,'2DScatter','2DPostStimAverage',oPlotData);
            %Difference maps
            %Pre minus during 
            oPlotData.z = oAverageData.PreStim.z - oAverageData.Stim.z;
            oPlotData.MaxZLim = max(oPlotData(1).z);
            oPlotData.MaxCLim = max(oPlotData(1).z);
            oPlotData.MinZLim = min(oPlotData(1).z);
            oPlotData.MinCLim = min(oPlotData(1).z);
            AxesControl(oFigure,'2DContour','2DPreMinusDuringDiff',oPlotData);
            %Post minus during
            oPlotData.z = oAverageData.PostStim.z - oAverageData.Stim.z;
            oPlotData.MaxZLim = max(oPlotData(1).z);
            oPlotData.MaxCLim = max(oPlotData(1).z);
            oPlotData.MinZLim = min(oPlotData(1).z);
            oPlotData.MinCLim = min(oPlotData(1).z);
            AxesControl(oFigure,'2DContour','2DPostMinusDuringDiff',oPlotData);
            %Pre minus Post
            oPlotData.z = oAverageData.PreStim.z - oAverageData.PostStim.z;
            oPlotData.MaxZLim = max(oPlotData(1).z);
            oPlotData.MaxCLim = max(oPlotData(1).z);
            oPlotData.MinZLim = min(oPlotData(1).z);
            oPlotData.MinCLim = min(oPlotData(1).z);
            AxesControl(oFigure,'2DContour','2DPostMinusPreDiff',oPlotData);
            %3D
            oPlotData = struct();
            oPlotData(1).x = oAverageData.x;
            oPlotData(1).y = oAverageData.y;
            oPlotData(1).MaxZLim = 0;
            oPlotData(1).MaxCLim = 0;
            oPlotData(1).MinZLim = -ceil(max(max(max(oAverageData.PreStim.z),max(oAverageData.Stim.z)),max(oAverageData.PostStim.z)));
            oPlotData(1).MinCLim = -ceil(max(max(max(oAverageData.PreStim.z),max(oAverageData.Stim.z)),max(oAverageData.PostStim.z)));;
            %Prestim
            oPlotData(1).z = -oAverageData.PreStim.z;
            %AxesControl(oFigure,'3DTriSurf','3DPreStimAverage',oPlotData);
            %During stim
            oPlotData(1).z = -oAverageData.Stim.z;
            %AxesControl(oFigure,'3DTriSurf','3DStimAverage',oPlotData);            
            %Poststim
            oPlotData(1).z = -oAverageData.PostStim.z;
            %AxesControl(oFigure,'3DTriSurf','3DPostStimAverage',oPlotData);
            %Double plots
            oPlotData(2).x = oAverageData.x;
            oPlotData(2).y = oAverageData.y;
            %Pre vs During
            oPlotData(1).z = -oAverageData.PreStim.z;
            oPlotData(2).z = -oAverageData.Stim.z;
%             AxesControl(oFigure,'3DTriSurf','3DPreVsDuringStimAverage',oPlotData);
            %Post vs During
            oPlotData(1).z = -oAverageData.Stim.z;
            oPlotData(2).z = -oAverageData.PostStim.z;
            %AxesControl(oFigure,'3DTriSurf','3DPostVsDuringStimAverage',oPlotData);
            %Pre Vs Post
            oPlotData(1).z = -oAverageData.PreStim.z;
            oPlotData(2).z = -oAverageData.PostStim.z;
            %AxesControl(oFigure,'3DTriSurf','3DPreVsPostStimAverage',oPlotData);
            
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
        
        function oGenPotentialMenu_Callback(oFigure, src, event)
            %Generate potential maps for current beat
            [oFigure.Potentials, oFigure.cmin, oFigure.cmax] = ...
                oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.InterpolatePotentialData(oFigure.oParentFigure.SelectedBeat,0.05,'linear');
            %Set up slider
            if strcmp(get(oFigure.oGuiHandle.oSliderPanel,'visible'),'off');
                set(oFigure.oGuiHandle.oSliderPanel,'visible','on');
            else
                set(oFigure.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                    size(oFigure.Potentials,2), 'Value', 1,'SliderStep',[1/size(oFigure.Potentials,2)  0.02]);
                set(oFigure.oGuiHandle.oSliderTxtLeft,'string',1);
                set(oFigure.oGuiHandle.oSliderTxtRight,'string',size(oFigure.Potentials,2));
            end
            %Plot the potential field with color bar max and min set
            oFigure.PlotPotential(oFigure.cmin,oFigure.cmax);
            
        end
        
        function oGenActivationMenu_Callback(oFigure, src, event);
            %Generate activation map for the current beat
            oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap();
            
            %Plot 2D by default
            %Update the plot type
            oFigure.PlotType = '2DContour';

            %Plot a 2D activation map
            oFigure.PlotActivation();
        end
        
        function o2DActivationMenu_Callback(oFigure, src, event);
            %Update the plot type
            oFigure.PlotType = '2DContour';
            
            %Plot a 2D activation map
            oFigure.PlotActivation();
        end
        
        function o3DActivationMenu_Callback(oFigure, src, event);
            %Update the plot type
            oFigure.PlotType = '3DActivation';
            
            %Plot a 3D activation map
            oFigure.PlotActivation();
        end
               
        function SlideValueListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new beat using the
            %SlideControl
            
            %Choose which plot to call.
            if ~strcmpi(oFigure.PlotType,'JustElectrodes')
                oFigure.PlotActivation();
            end
        end
       
        function BeatSelectionListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new beat using the electrode
            %plot in AnalyseSignals
            
            %Choose which plot to call.
            if ~strcmpi(oFigure.PlotType,'JustElectrodes')
                oFigure.PlotActivation();
            end
        end
     end
     
     methods (Access = private)
         function PlotElectrodes(oFigure)
             %Plots the electrode locations on the map axes
             
             %Set up the axes
             set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[], 'NextPlot','replacechildren');
             %Get the electrodes
             oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
             %Get the number of channels
             [i NumChannels] = size(oElectrodes);
             %Loop through the electrodes plotting their locations
             oWaitbar = waitbar(0,'Please wait...');
             for i = 1:NumChannels;
                 %Plot the electrode point
                 hold(oFigure.oGuiHandle.oMapAxes,'on');
                 plot(oFigure.oGuiHandle.oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.');
                 %Label the point with the channel name
                 oLabel = text(oElectrodes(i).Coords(1) - 0.1, oElectrodes(i).Coords(2) + 0.07, ...
                     oElectrodes(i).Name);
                 if ~oElectrodes(i).Accepted
                    set(oLabel,'color','r');
                 end
                 set(oLabel,'FontWeight','bold','FontUnits','normalized');
                 set(oLabel,'FontSize',0.015);
                 set(oLabel,'parent',oFigure.oGuiHandle.oMapAxes);
             end
             close(oWaitbar);
             hold(oFigure.oGuiHandle.oMapAxes,'off');
         end
         
         function RemoveElectrodes(oFigure)
             %Removes the electrode plots on the map axes
             
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.oMapAxes,'children');
             %Loop through list and delete
             for i = 1:size(aPlotObjects,1)
                 delete(aPlotObjects(i));
             end
             oFigure.PlotPotential(oFigure.cmin,oFigure.cmax);
         end
         
         function  PlotActivation(oFigure)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.oSlideControl.GetSliderIntegerValue('oSlider');
             %Which plot type to use
             switch (oFigure.PlotType)
                 case '2DContour'
                     xlin = linspace(min(oFigure.Activation.x),max(oFigure.Activation.x),length(oFigure.Activation.x));
                     ylin = linspace(min(oFigure.Activation.y),max(oFigure.Activation.y),length(oFigure.Activation.y));
                     [X, Y] = meshgrid(xlin, ylin);
                     Z = griddata(oFigure.Activation.x, oFigure.Activation.y,oFigure.Activation.z(:,iBeat),X,Y,'cubic');
                     contourf(oFigure.oGuiHandle.oMapAxes,X,Y,Z,0:0.25:ceil(oFigure.Activation.MaxActivationTime));
                     colormap(oFigure.oGuiHandle.oMapAxes, colormap(flipud(colormap(jet))));
                     %check if there is an existing colour bar
                     %get figure children
                     oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                     oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                     if oHandle < 0
                         oColorBar = cbarf(Z,0:0.25:ceil(oFigure.Activation.MaxActivationTime));
                         oTitle = get(oColorBar, 'title');
                         set(oTitle,'string','Time (ms)');
                     end
                     set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[]);

                 case '2DActivation'
                     scatter(oFigure.oGuiHandle.oMapAxes, oFigure.Activation.x, oFigure.Activation.y, 100, oFigure.Activation.z(:,iBeat), 'filled');
                     colormap(oFigure.oGuiHandle.oMapAxes, colormap(flipud(colormap(jet))));
                     colorbar('peer',oFigure.oGuiHandle.oMapAxes);
                     colorbar('location','EastOutside');
                     set(oFigure.oGuiHandle.oMapAxes,'CLim',[0 ceil(oFigure.Activation.MaxActivationTime)]);
                     %Remove ticks
                     set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[]);
                 case '3DActivation'
                     aTriangulatedMesh = delaunay(oFigure.Activation.x, oFigure.Activation.y);
                     trisurf(aTriangulatedMesh,oFigure.Activation.x, oFigure.Activation.y,-oFigure.Activation.z(:,iBeat));
                     zlim(oFigure.oGuiHandle.oMapAxes,[-ceil(oFigure.Activation.MaxActivationTime) 0]);
                     set(oFigure.oGuiHandle.oMapAxes,'CLim',[-ceil(oFigure.Activation.MaxActivationTime) 0]);
                     view(oFigure.oGuiHandle.oMapAxes,30,30);
                     colormap(oFigure.oGuiHandle.oMapAxes, colormap(colormap(jet)));
                     colorbar('peer',oFigure.oGuiHandle.oMapAxes);
                     colorbar('location','EastOutside');
             end

             title(oFigure.oGuiHandle.oMapAxes,sprintf('Activation map for beat #%d',iBeat));
         end
         
         function PlotPotential(oFigure,varargin)
             %Plots a map of interpolated potential field
             
             %Get the current time step
             iTimeStep = get(oFigure.oGuiHandle.oSlider,'Value'); 
             if ~isinteger(iTimeStep)
                 %Round down to nearest integer if a double is supplied
                 iTimeStep = round(iTimeStep(1));
             end
             contourf(oFigure.oGuiHandle.oMapAxes,oFigure.Potentials(iTimeStep).Xi,oFigure.Potentials(iTimeStep).Yi,oFigure.Potentials(iTimeStep).Field);
             oFigure.PlotElectrodes()

             title(oFigure.oGuiHandle.oMapAxes,strcat(sprintf('Potential Map at Time %0.4f',oFigure.Potentials(iTimeStep).Time),' ms'));
             %Set the axis on the subplot
             axis(oFigure.oGuiHandle.oMapAxes,[min(min(oFigure.Potentials(iTimeStep).Xi)) - 0.5, max(max(oFigure.Potentials(iTimeStep).Xi)) + 0.5, ...
                 min(min(oFigure.Potentials(iTimeStep).Yi)) - 0.5, max(max(oFigure.Potentials(iTimeStep).Yi) + 0.5)]);
             colormap(oFigure.oGuiHandle.oMapAxes,jet);
             if ~isempty(varargin)
                 set(oFigure.oGuiHandle.oMapAxes,'CLim',[varargin{1,1} varargin{1,2}]);
             end
             colorbar('peer',oFigure.oGuiHandle.oMapAxes);
             colorbar('location','EastOutside');
         end
     end
end
