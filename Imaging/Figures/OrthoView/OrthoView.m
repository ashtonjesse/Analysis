classdef OrthoView < BaseFigure
% OrthoView Summary of this class goes here
% This figure allows you to load an image and view it in 3D

    properties
        DefaultPath = 'd:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\';
        oSlideZControl;
        oSlideXControl;
        oSlideYControl;
        oStackVolume;
        CurrentZoomLimits = struct();
        Dragging;
    end
    
    methods
        %% Constructor
        function oFigure = OrthoView()
            oFigure = oFigure@BaseFigure('OrthoView',@OpeningFcn);

            %Set the call back functions for the controls
            set(oFigure.oGuiHandle.oZoomTool, 'oncallback', @(src, event) oZoomOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'offcallback', @(src, event) oZoomOffTool_Callback(oFigure, src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oUnused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oUnused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUnused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolsMenu, 'callback', @(src, event) oUnused_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Hide the panel
            set(oFigure.oGuiHandle.oPanel,'visible','off');
            % --- Executes just before figure is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
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
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            if ~isempty(oFigure.oSlideXControl)
                deletefigure(oFigure.oSlideXControl);
            end
            if ~isempty(oFigure.oSlideYControl)
                deletefigure(oFigure.oSlideYControl);
            end
            if ~isempty(oFigure.oSlideZControl)
                deletefigure(oFigure.oSlideZControl);
            end
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end    
        
        function oZoomOnTool_Callback(oFigure, src, event)
             %Turn zoom on for this figure
            set(oFigure.oZoom,'enable','on'); 
        end
        
        function oZoomOffTool_Callback(oFigure, src, event)
            set(oFigure.oZoom,'enable','off'); 
        end
        
        function oFigure = oOpenMenu_Callback(oFigure, src, event)
            %This function opens a file dialog and loads 3 mat files (containing Z, X and Y stacks) 
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile(strcat('*.mat'),'Select a file containing a Z ImageStack entity',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                return
            end
            
            %Get the full file name 
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Load the selected file
            oZStack = GetImageStackFromMATFile(ImageStack,sLongDataFileName);
            %load the Entity into gui handles
            oFigure.oGuiHandle.oZStack =  oZStack;
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile(strcat('*.mat'),'Select a file containing an X ImageStack entity',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                return
            end
            
            %Get the full file name 
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Load the selected file
            oXStack = GetImageStackFromMATFile(ImageStack,sLongDataFileName);
            %load the Entity into gui handles
            oFigure.oGuiHandle.oXStack =  oXStack;
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile(strcat('*.mat'),'Select a file containing a Y ImageStack entity',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                return
            end
            
            %Get the full file name 
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Load the selected file
            oYStack = GetImageStackFromMATFile(ImageStack,sLongDataFileName);
            %load the Entity into gui handles
            oFigure.oGuiHandle.oYStack =  oYStack;
            
            %Create sliders
            if isempty(oFigure.oSlideZControl)
                oFigure.oSlideZControl = SlideControl(oFigure,'Select Z Image');
                %Set up slider
                iNumImages = size(oFigure.oGuiHandle.oZStack.oImages,2);
                set(oFigure.oSlideZControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                    iNumImages, 'Value', 1,'SliderStep',[1/iNumImages  0.02]);
                set(oFigure.oSlideZControl.oGuiHandle.oSliderTxtLeft,'string',1);
                set(oFigure.oSlideZControl.oGuiHandle.oSliderTxtRight,'string',iNumImages);
                set(oFigure.oSlideZControl.oGuiHandle.oSliderEdit,'string',1);
                
                %Add a listener so that the figure knows when a user has
                %made a selection
                addlistener(oFigure.oSlideZControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            end
            
            if isempty(oFigure.oSlideXControl)
                oFigure.oSlideXControl = SlideControl(oFigure,'Select X Image');
                %Set up slider
                iNumImages = size(oFigure.oGuiHandle.oXStack.oImages,2);
                set(oFigure.oSlideXControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                    iNumImages, 'Value', 1,'SliderStep',[1/iNumImages  0.02]);
                set(oFigure.oSlideXControl.oGuiHandle.oSliderTxtLeft,'string',1);
                set(oFigure.oSlideXControl.oGuiHandle.oSliderTxtRight,'string',iNumImages);
                set(oFigure.oSlideXControl.oGuiHandle.oSliderEdit,'string',1);
                
                %Add a listener so that the figure knows when a user has
                %made a beat selection
                addlistener(oFigure.oSlideXControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            end
            
            if isempty(oFigure.oSlideYControl)
                oFigure.oSlideYControl = SlideControl(oFigure,'Select Y Image');
                %Set up slider
                iNumImages = size(oFigure.oGuiHandle.oYStack.oImages,2);
                set(oFigure.oSlideYControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                    iNumImages, 'Value', 1,'SliderStep',[1/iNumImages  0.02]);
                set(oFigure.oSlideYControl.oGuiHandle.oSliderTxtLeft,'string',1);
                set(oFigure.oSlideYControl.oGuiHandle.oSliderTxtRight,'string',iNumImages);
                set(oFigure.oSlideYControl.oGuiHandle.oSliderEdit,'string',1);
                
                %Add a listener so that the figure knows when a user has
                %made a beat selection
                addlistener(oFigure.oSlideYControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            end
            %Get stack volume
            oFigure.oStackVolume = oFigure.oGuiHandle.oZStack.GetStackVolume();
            
            %Check if there are any subplots already
            aPlotObjects = get(oFigure.oGuiHandle.oPanel,'children');
            if isempty(aPlotObjects)
                %Create the subplots
                oFigure.CreateSubPlot();
            end
            %Plot the image
            oFigure.Replot();
        end
        
        function oFigure = oSaveMenu_Callback(oFigure, src, event)
            % Save the current Potential entity
           
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the file',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.oGuiHandle.oStack.Save(sLongDataFileName);
            
        end
        
        function SlideValueListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new image using the
            %SlideControl

            oFigure.Replot();
        end
        
        function oFigure = oUnused_Callback(oFigure, src, event)
            
        end
        
        function CreateSubPlot(oFigure)
            %Create the space for the subplot that will contain all the
             %image views
             
             %Clear the panel first
             %Get the array of handles to the plot objects
             aPlotObjects = get(oFigure.oGuiHandle.oPanel,'children');
             %Loop through list and delete
             for i = 1:size(aPlotObjects,1)
                 delete(aPlotObjects(i));
             end
             %Divide up the space for the subplots
             xDiv = 1/2; 
             yDiv = 1/2;
                         
             %Create the position vector for the next plot
             aPosition = [0*yDiv, 0*xDiv, yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent',oFigure.oGuiHandle.oPanel,'Tag','LeftLowAxes');
             aPosition = [0*yDiv, 1*xDiv, yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent',oFigure.oGuiHandle.oPanel,'Tag','LeftHighAxes');
             aPosition = [1*yDiv, 0*xDiv, yDiv, xDiv];%[left bottom width height]
             subplot('Position',aPosition,'parent',oFigure.oGuiHandle.oPanel,'Tag','RightLowAxes');
        end
            
        function Replot(oFigure)
            %Plot the currently selected images
            %Get the array of handles to the subplots that are children of
            %oPanel
            aSubPlots = get(oFigure.oGuiHandle.oPanel,'children');
            %Get the handles to the appropriate plots
            oLeftHighAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'LeftHighAxes');
            oLeftLowAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'LeftLowAxes');
            oRightLowAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'RightLowAxes');
            %Get the indexes of the currently selected images
            iYIndex = oFigure.oSlideYControl.GetSliderIntegerValue('oSlider');
            iZIndex = oFigure.oSlideZControl.GetSliderIntegerValue('oSlider');
            iXIndex = oFigure.oSlideXControl.GetSliderIntegerValue('oSlider');
            %Make sure this figure is the current figure
            set(0,'currentfigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            %Display the images
            image('cdata',oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,'Parent',...
               oRightLowAxes);
            image('cdata',oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,'Parent',...
                oLeftLowAxes);
            image('cdata',oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,'Parent',...
                oLeftHighAxes);
            %Hold on and plot a line where the other stack images are located on each
            hold(oRightLowAxes,'on');
            oZLineOnX = line([0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,2)], [iZIndex iZIndex]);
            set(oZLineOnX,'Tag','oZLineOnX','color','g','parent',oRightLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            oYLineOnX = line([iYIndex iYIndex],[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,1)]);
            set(oYLineOnX,'Tag','oYLineOnX','color','g','parent',oRightLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            hold(oRightLowAxes,'off');
            
            hold(oLeftHighAxes,'on');
            oZLineOnY = line([0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,2)], [iZIndex iZIndex]);
            set(oZLineOnY,'Tag','oZLineOnY','color','g','parent',oLeftHighAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            oXLineOnY = line([iXIndex iXIndex],[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,1)]);
            set(oXLineOnY,'Tag','oXLineOnY','color','g','parent',oLeftHighAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            hold(oLeftHighAxes,'off');
            
            hold(oLeftLowAxes,'on');
            oXLineOnZ = line([iXIndex iXIndex],[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,1)]);
            set(oXLineOnZ,'Tag','oXLineOnZ','color','g','parent',oLeftLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            oYLineOnZ = line([0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,2)], [iYIndex iYIndex]);
            set(oYLineOnZ,'Tag','oYLineOnZ','color','g','parent',oLeftLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            hold(oLeftLowAxes,'off');
            %Set the stop drag function
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
            %Prepare the subplots
            set(oLeftHighAxes,'layer','top');
            set(oLeftHighAxes,'linewidth',2,'Box','on','XColor','r','YColor','r','XTick',[],'YTick',[]);
            set(oLeftHighAxes,'XLim',[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data-2,2)]);
            set(oLeftHighAxes,'YLim',[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data-2,1)]);
            set(oLeftHighAxes,'Tag', 'LeftHighAxes', 'NextPlot','replacechildren');
            
            set(oLeftLowAxes,'layer','top');
            set(oLeftLowAxes,'linewidth',2,'Box','on','XColor','g','YColor','g','XTick',[],'YTick',[]);
            set(oLeftLowAxes,'XLim',[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data-2,2)]);
            set(oLeftLowAxes,'YLim',[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data-2,1)]);
            set(oLeftLowAxes,'Tag', 'LeftLowAxes', 'NextPlot','replacechildren');
            
            set(oRightLowAxes,'layer','top');
            set(oRightLowAxes,'linewidth',2,'Box','on','XColor','y','YColor','y','XTick',[],'YTick',[]);
            set(oRightLowAxes,'XLim',[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data-2,2)]);
            set(oRightLowAxes,'YLim',[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data-2,1)]);
            set(oRightLowAxes,'Tag', 'RightLowAxes', 'NextPlot','replacechildren');
            set(oFigure.oGuiHandle.oPanel,'visible','on');
        end
        
        function RelabelSlider(oFigure)
            %Relabel the existing slider
             if ~isempty(oFigure.oSlideControl)
                iNumImages = size(oFigure.oGuiHandle.oStack.oImages,2);
                set(oFigure.oSlideControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                    iNumImages, 'Value', 1,'SliderStep',[1/iNumImages  0.02]);
                set(oFigure.oSlideControl.oGuiHandle.oSliderTxtLeft,'string',1);
                set(oFigure.oSlideControl.oGuiHandle.oSliderTxtRight,'string',iNumImages);
                set(oFigure.oSlideControl.oGuiHandle.oSliderEdit,'string',1);
             end
        end
        
        function StartDrag(oFigure, src, event)
            %The function that fires when a line on a subplot is dragged
            oFigure.Dragging = 1;
            oAxes = get(src,'Parent');
            sLineTag = get(src,'tag');
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', @(src,event) Drag(oFigure, src, LineSpecificDragEvent(oAxes,sLineTag)));
        end
        
        function StopDrag(oFigure, src, event)
            %The function that fires when the user lets go of a line on a
            %subplot
            if oFigure.Dragging
                %Make sure that the windowbuttonmotionfcn is no longer active
                set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonMotionFcn', '');
                oFigure.Dragging = 0;
                
                %Refresh the plot
                oFigure.Replot();
            end
        end
        
        function Drag(oFigure, src, event)
            %The function that fires while a line on a subplot is being
            %dragged
            
            %Get the current point information
            oPoint = get(event.ParentAxesHandle, 'CurrentPoint');
            %Set the new location
            switch (event.LineTag)
                case {'oXLineOnY', 'oXLineOnZ'};
                    oFigure.oSlideXControl.SetSliderValue(oPoint(1,1));
                case 'oYLineOnX'
                    oFigure.oSlideYControl.SetSliderValue(oPoint(1,1));
                case 'oYLineOnZ'
                    oFigure.oSlideYControl.SetSliderValue(oPoint(1,2));
                case {'oZLineOnY','oZLineOnX'};
                    oFigure.oSlideZControl.SetSliderValue(oPoint(1,2));
            end
            
        end

    end
    
end
