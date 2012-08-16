classdef MapElectrodes < SubFigure
    %   AnalyseSignals
    
    
    properties
        SelectedChannels;
        Potentials;
        Activation;
        cmin;
        cmax;
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
            set(oFigure.oGuiHandle.oGenPotentialMenu, 'callback', @(src, event) oGenPotentialMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oGenActivationMenu, 'callback', @(src, event) oGenActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAverageMenu, 'callback', @(src, event) oAverageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.rdTopButton, 'callback', @(src, event) rdTopButton_Callback(oFigure, src, event));
            
            %set up slider
            aSliderTexts = [oFigure.oGuiHandle.oSliderTxtLeft,oFigure.oGuiHandle.oSliderTxtRight];
            sliderPanel(oFigure.oGuiHandle.(oFigure.sFigureTag), {'Title', 'Scan through time'}, {'Min', 1, 'Max', ...
               2, 'Value', 1, 'Callback', @(src, event) oSlider_Callback(oFigure, src, event),'SliderStep',[0.1  0.02]},{},{},'%0.0f',...
                oFigure.oGuiHandle.oSliderPanel, oFigure.oGuiHandle.oSlider,oFigure.oGuiHandle.oSliderEdit,aSliderTexts);
            
            oFigure.PlotElectrodes();
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
                
                %Set ui control creation attributes 
                set(handles.rdTopButton, 'string', 'Show Electrodes');
                set(handles.rdTopButton, 'value', 1);
                set(handles.rdTopButton, 'visible', 'off');
                set(handles.rdMiddleButton, 'string', 'Show Potential');
                set(handles.rdMiddleButton, 'value', 0);
                set(handles.rdMiddleButton, 'visible', 'off');
                set(handles.rdBottomButton, 'string', 'Show Activation');
                set(handles.rdBottomButton, 'value', 1);
                set(handles.rdBottomButton, 'visible', 'off');
                set(handles.oSliderPanel,'visible','off');
                set(handles.txtRows,'string','Enter a kernel row count');
                set(handles.txtCols,'string','Enter a kernel column count');
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
            aInOptions = struct();
            aInOptions.Procedure = 'Mean';
            iRows = oFigure.GetEditInputDouble('edtRows');
            iCols = oFigure.GetEditInputDouble('edtCols');
            aInOptions.KernelBounds = [iRows iCols];
            oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.ApplyNeighbourhoodAverage(aInOptions);
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
        function rdTopButton_Callback(oFigure, src, event)
            ButtonState = get(oFigure.oGuiHandle.rdTopButton,'Value');
            if ButtonState == get(oFigure.oGuiHandle.rdTopButton,'Max')
                % radio button is pressed
                oFigure.PlotElectrodes();
            elseif ButtonState == get(oFigure.oGuiHandle.rdTopButton,'Min')
                % radio button is not pressed
                oFigure.RemoveElectrodes();
                brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
            end
        end

        function oSlider_Callback(oFigure, src, event)
            ButtonState = [get(oFigure.oGuiHandle.rdMiddleButton,'Value') get(oFigure.oGuiHandle.rdBottomButton,'Value')];
            if ButtonState(1) == 1;
                oFigure.PlotPotential(oFigure.cmin, oFigure.cmax);
            elseif ButtonState(2) == 1;
                oFigure.PlotActivation();
            end
            
        end
        
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
            %Make the show electrodes button visible
            set(oFigure.oGuiHandle.rdTopButton,'visible','on');
            set(oFigure.oGuiHandle.rdMiddleButton,'value',1);
            set(oFigure.oGuiHandle.rdBottomButton,'value',0);
            
        end
        
        function oGenActivationMenu_Callback(oFigure, src, event);
            %Generate activation map for the current beat
            oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap();
            %Set up slider
            if strcmp(get(oFigure.oGuiHandle.oSliderPanel,'visible'),'off');
                set(oFigure.oGuiHandle.oSliderPanel,'visible','on');
            end
            set(oFigure.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                size(oFigure.Activation.z,2), 'Value', 1,'SliderStep',[1/size(oFigure.Activation.z,2)  0.02]);
            set(oFigure.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oFigure.oGuiHandle.oSliderTxtRight,'string',size(oFigure.Activation.z,2));
            set(oFigure.oGuiHandle.oSliderEdit,'string',1);
            %Plot the potential field with color bar max and min set
            oFigure.PlotActivation();
            %Make the show electrodes button invisible
            set(oFigure.oGuiHandle.rdTopButton,'visible','off');
            set(oFigure.oGuiHandle.rdMiddleButton,'value',0);
            set(oFigure.oGuiHandle.rdBottomButton,'value',1);
            
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
             
             iBeat = get(oFigure.oGuiHandle.oSlider,'Value');
             if ~isinteger(iBeat)
                 %Round down to nearest integer if a double is supplied
                 iBeat = round(iBeat(1));
             end
             scatter(oFigure.oGuiHandle.oMapAxes, oFigure.Activation.x, oFigure.Activation.y, 100, oFigure.Activation.z(:,iBeat), 'filled');
             title(oFigure.oGuiHandle.oMapAxes,sprintf('Activation Map for beat %d',iBeat));
             colormap(oFigure.oGuiHandle.oMapAxes, colormap(flipud(colormap(jet))));
             colorbar('peer',oFigure.oGuiHandle.oMapAxes);
             colorbar('location','EastOutside');
             set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[]);
         end
         
         function PlotPotential(oFigure,varargin)
             %Plots a map of interpolated potential field
             
             %Get the current time step
             iTimeStep = get(oFigure.oGuiHandle.oSlider,'Value');
             if ~isinteger(iTimeStep)
                 %Round down to nearest integer if a double is supplied
                 iTimeStep = round(iTimeStep(1));
             end
             ButtonState = get(oFigure.oGuiHandle.rdTopButton,'Value');
             if ButtonState == get(oFigure.oGuiHandle.rdTopButton,'Max')
                 % radio button is pressed
                 contourf(oFigure.oGuiHandle.oMapAxes,oFigure.Potentials(iTimeStep).Xi,oFigure.Potentials(iTimeStep).Yi,oFigure.Potentials(iTimeStep).Field);
                 oFigure.PlotElectrodes()
             elseif ButtonState == get(oFigure.oGuiHandle.rdTopButton,'Min')
                 % radio button is not pressed
                 contourf(oFigure.oGuiHandle.oMapAxes,oFigure.Potentials(iTimeStep).Xi,oFigure.Potentials(iTimeStep).Yi,oFigure.Potentials(iTimeStep).Field);
                 set(oFigure.oGuiHandle.oMapAxes,'XTick',[],'YTick',[], 'NextPlot','replacechildren');
             end
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
