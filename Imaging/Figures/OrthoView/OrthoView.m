classdef OrthoView < BaseFigure
% OrthoView Summary of this class goes here
% This figure allows you to load an image and view it in 3D

    properties
        DefaultPath = 'd:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\';
        oSlideZControl; %The SlideControl figure handle for the Z axes 
        oSlideXControl;
        oSlideYControl;
        oROIControl; %The ROIControl figure handle
        oStackVolume; %A three dimensional array containing the whole Z stack
        CurrentZoomLimits = struct();
        Dragging;
        oZROI = []; %Handle to the Region Of Interest object for the Z axes
        oXROI = [];
        oYROI = [];
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
            set(oFigure.oGuiHandle.oSubSampleMenu, 'callback', @(src, event) oSubSampleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFrangiFilterMenu, 'callback', @(src, event) oFrangiFilterMenu_Callback(oFigure, src, event));

            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            %Hide the panel
            %set(oFigure.oGuiHandle.oPanel,'visible','off');
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
            if ~isempty(oFigure.oROIControl)
                deletefigure(oFigure.oROIControl);
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
            if length(aPlotObjects) <= 1
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
        
        function oSubSampleMenu_Callback(oFigure, src, event)
            %Open an ROI selection control
            oFigure.oROIControl = ROIControl(oFigure,'Select ROI volume for sub sampling');
            %add event listeners
            addlistener(oFigure.oROIControl,'SelectROINow',@(src,event) oFigure.SelectROIListener(src, event));
            addlistener(oFigure.oROIControl,'DoneSelecting',@(src,event) oFigure.FinishedROISelection(src, event));
            addlistener(oFigure.oROIControl,'ClearROI',@(src,event) oFigure.ClearROISelection(src, event));
        end
        
        function oFrangiFilterMenu_Callback(oFigure, src, event)
            %Get the inputs for a call to frangi filter
            oEditControl = EditControl(oFigure,'Enter values for the small scale min, max and stepsize, large scale min, max and stepsize, and alpha and beta constants.', 8);                
            addlistener(oEditControl,'ValuesEntered',@(src,event) oFigure.FrangiFilterListener(src, event));
        end
        
        function FrangiFilterListener(oFigure, src, event)
            %Apply a frangi filter to the image volume to pick out features
            %of interest.
            oImageVolume = oFigure.oStackVolume;
            aInputs = [];
            aInputs.BlackWhite = false;
            aInputs.FrangiScaleRange = [event.Values(1) event.Values(2)];
            aInputs.FrangiScaleRatio = event.Values(3);
            aInputs.FrangiAlpha = event.Values(7);
            aInputs.FrangiBeta = event.Values(8);
            aInputs.FrangiC = max(oImageVolume(:))/4;
            
            % Use single or double for calculations
            if(~isa(oImageVolume,'double'))
                oImageVolume = single(oImageVolume); 
            end 
            
            %Filter the volume using the small scales
            [oProcessedImageVolume, aOutScales] = fFrangiFilter(oImageVolume, aInputs);

            %Apply Threshold
            oProcessedImageVolume = fBOSauvolaThreshold3D(oProcessedImageVolume,3,3,1,128); 
            
            %clear stack information
            oFigure.oGuiHandle.oZStack = [];
            oFigure.oGuiHandle.oXStack = [];
            oFigure.oGuiHandle.oYStack = [];
            %Split the processed stack in to separate dimensions
            [oFigure.oGuiHandle.oZStack, oFigure.oGuiHandle.oXStack, oFigure.oGuiHandle.oYStack] = ...
                fSplitStackVolume(oProcessedImageVolume);
            
            %Replot
            oFigure.Replot();
        end
        
        function SelectROIListener(oFigure, src, event)
            %An event listener callback for the ROI control
            %Allow selection of an ROI on the currently selected axes
            sAxesSelection = char(oFigure.oROIControl.GetPopUpSelectionString('oAxesSelect'));
            %Get the array of handles to the subplots that are children of
            %oPanel
            aSubPlots = get(oFigure.oGuiHandle.oPanel,'children');
            %Get the handles to the appropriate plots, delete any existing
            %ROI's and create new ones
            switch (sAxesSelection)
                case 'x'
                    oRightLowAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'RightLowAxes');
                    if strcmp(class(oFigure.oXROI),'imrect') 
                        %Can only have 1 ROI at a time
                        delete(oFigure.oXROI);
                    end
                    oFigure.oXROI = imrect(oRightLowAxes);
                    dPosition = wait(oFigure.oXROI);
                case 'y'
                    oLeftHighAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'LeftHighAxes');
                    if strcmp(class(oFigure.oYROI),'imrect')
                        %Can only have 1 ROI at a time
                        delete(oFigure.oYROI);
                    end
                    oFigure.oYROI = imrect(oLeftHighAxes);
                    dPosition = wait(oFigure.oYROI);
                case 'z'
                    oLeftLowAxes = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'LeftLowAxes');
                    if strcmp(class(oFigure.oZROI),'imrect')
                        %Can only have 1 ROI at a time
                        delete(oFigure.oZROI);
                    end
                    oFigure.oZROI = imrect(oLeftLowAxes);
                    dPosition = wait(oFigure.oZROI);
            end
            
            %Convert the ROI to a cell array
            dPosition = num2cell(dPosition);
            %Check if there is already data in the ROI table
            oData = get(oFigure.oROIControl.oGuiHandle.oROITable,'data');
            if ~isempty(oData{1,1})
                %Append the new data to the existing data
                oNewData = cat(2,sAxesSelection,dPosition);
                oData = cat(1,oData,oNewData);
                %Set the selected region as the ROITable data
                set(oFigure.oROIControl.oGuiHandle.oROITable,'data',oData);
            else
                oData = cat(2,sAxesSelection,dPosition);
                %Set the selected region as the ROITable data
                set(oFigure.oROIControl.oGuiHandle.oROITable,'data',oData);
            end
            
        end
        
        function FinishedROISelection(oFigure, src, event)
            %Convert the ROI into dimensions for the subsample
            
            %Initialise the struct to hold the info
            oDimensions = struct();
            %Get the ROI info from the ROIControl
            oROIData = get(oFigure.oROIControl.oGuiHandle.oROITable,'data');
            sSpecifiedAxes = strcat(char(oROIData(1,1)),char(oROIData(2,1)));
            oROIData = round(cell2mat(oROIData(:,2:end)));
            switch (sSpecifiedAxes)
                case 'xy'
                    %horizontal (x)
                    oDimensions(1).Range = [oROIData(2,1), oROIData(2,1) + oROIData(2,3)];
                    %vertical (y)
                    oDimensions(2).Range = [oROIData(1,1), oROIData(1,1) + oROIData(1,3)];
                    %depth (z)
                    oDimensions(3).Range = [oROIData(1,2), oROIData(1,2) + oROIData(1,4)];
                    %Specify filename for saving
                    sFileName = strcat(sprintf('%d',oROIData(2,1)),'_',sprintf('%d',oROIData(2,3)),'_', ...
                        sprintf('%d',oROIData(1,1)),'_',sprintf('%d',oROIData(1,3)),'_', ...
                        sprintf('%d',oROIData(1,2)),'_',sprintf('%d',oROIData(1,4)));
                case 'yx'
                    %horizontal (x)
                    oDimensions(1).Range = [oROIData(1,1), oROIData(1,1) + oROIData(1,3)];
                    %vertical (y)
                    oDimensions(2).Range = [oROIData(2,1), oROIData(2,1) + oROIData(2,3)];
                    %depth (z)
                    oDimensions(3).Range = [oROIData(2,2), oROIData(2,2) + oROIData(2,4)];
                    %Specify filename for saving
                    sFileName = strcat(sprintf('%d',oROIData(1,1)),'_',sprintf('%d',oROIData(1,3)),'_', ...
                        sprintf('%d',oROIData(2,1)),'_',sprintf('%d',oROIData(2,3)),'_', ...
                        sprintf('%d',oROIData(2,2)),'_',sprintf('%d',oROIData(2,4)));
                case {'zy','zx'}
                    %horizontal (x)
                    oDimensions(1).Range = [oROIData(1,1), oROIData(1,1) + oROIData(1,3)];
                    %vertical (y)
                    oDimensions(2).Range = [oROIData(1,2), oROIData(1,2) + oROIData(1,4)];
                    %depth (z)
                    oDimensions(3).Range = [oROIData(2,2), oROIData(2,2) + oROIData(2,4)];
                    %Specify filename for saving
                    sFileName = strcat(sprintf('%d',oROIData(1,1)),'_',sprintf('%d',oROIData(1,3)),'_', ...
                        sprintf('%d',oROIData(1,2)),'_',sprintf('%d',oROIData(1,4)),'_', ...
                        sprintf('%d',oROIData(2,2)),'_',sprintf('%d',oROIData(2,4)));
                case {'yz','xz'}
                    %horizontal (x)
                    oDimensions(1).Range = [oROIData(2,1), oROIData(2,1) + oROIData(2,3)];
                    %vertical (y)
                    oDimensions(2).Range = [oROIData(2,2), oROIData(2,2) + oROIData(2,4)];
                    %depth (z)
                    oDimensions(3).Range = [oROIData(1,2), oROIData(1,2) + oROIData(1,4)];
                    %Specify filename for saving
                    sFileName = strcat(sprintf('%d',oROIData(2,1)),'_',sprintf('%d',oROIData(2,3)),'_', ...
                        sprintf('%d',oROIData(2,2)),'_',sprintf('%d',oROIData(2,4)),'_', ...
                        sprintf('%d',oROIData(1,2)),'_',sprintf('%d',oROIData(1,4)));
            end
            %Create the ROI as a new stack
            oSubSampledStack = oFigure.oGuiHandle.oZStack.SubsampleStack(oDimensions);
            %Call built-in file dialog to select filename
            sDataPathName = uigetdir(oFigure.DefaultPath,'Select a location for the file');
            %Make sure the dialogs return char objects
            if (~ischar(sDataPathName))
                return
            end
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,'\',oFigure.oGuiHandle.oZStack.Name,sFileName);
            %Save stack
            oSubSampledStack.Save(sLongDataFileName);
            %Close the ROIControl and clean up the memory
            oFigure.oROIControl.deletefigure();
            oFigure.oROIControl = [];
            oFigure.oZROI = [];
            oFigure.oXROI = [];
            oFigure.oYROI = [];
        end
        
        function ClearROISelection(oFigure, src, event)
            %Clear any ROI boxes left on the images
            if strcmp(class(oFigure.oXROI),'imrect')
                delete(oFigure.oXROI);
                oFigure.oXROI = [];
            end
            if strcmp(class(oFigure.oYROI),'imrect')
                delete(oFigure.oYROI);
                oFigure.oYROI = [];
            end
            if strcmp(class(oFigure.oZROI),'imrect')
                delete(oFigure.oZROI);
                oFigure.oZROI = [];
            end
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
             
             %Get the panel dimensions
             aDimensions = get(oFigure.oGuiHandle.oPanel,'Position');
             %Divide up the space for the subplots
             xDiv = (aDimensions(3)-aDimensions(1))/2; 
             yDiv = (aDimensions(4)-aDimensions(2))/2;
             
             oLeftHighAxes = subplot(2,2,1,'parent',oFigure.oGuiHandle.oPanel,'Tag','LeftHighAxes');
             set(oLeftHighAxes,'Units','Pixels');
             aPosition = [2, yDiv+4, xDiv-4, yDiv-3];%[left bottom width height]
             set(oLeftHighAxes,'Position',aPosition);                        
             
             oLeftLowAxes = subplot(2,2,3,'parent',oFigure.oGuiHandle.oPanel,'Tag','LeftLowAxes');
             set(oLeftLowAxes,'Units','Pixels');
             aPosition = [(xDiv - yDiv)/2, 2, yDiv, yDiv-3];%[left bottom width height]
             set(oLeftLowAxes,'Position',aPosition);
             
             oRightLowAxes = subplot(2,2,4,'parent',oFigure.oGuiHandle.oPanel,'Tag','RightLowAxes');
             set(oRightLowAxes,'Units','Pixels');
             aPosition = [xDiv + 2, 2, xDiv-4, yDiv-3];%[left bottom width height]
             set(oRightLowAxes,'Position',aPosition);
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

            %Delete any image information currently on the axes
            aImages = findall(oLeftHighAxes,'type','image');
            delete(aImages);
            aImages = findall(oLeftLowAxes,'type','image');
            delete(aImages);
            aImages = findall(oRightLowAxes,'type','image');
            delete(aImages);
            
            %plot a line where the other stack images are located on each
            %check if a line already exists
            oZLineOnX = findall(aSubPlots,'tag','oZLineOnX');
            if isempty(oZLineOnX)
                %if not then create one
                oZLineOnX = line([0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,2)], [iZIndex iZIndex]);
            else
                %if so just update the location
                set(oZLineOnX,'XData',[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,2)]);
                set(oZLineOnX,'YData',[iZIndex iZIndex]);
            end
            %reset the buttondownfcn because this is overwritten
            set(oZLineOnX,'Tag','oZLineOnX','color','c','parent',oRightLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
            oYLineOnX = findall(aSubPlots,'tag','oYLineOnX');
            if isempty(oYLineOnX)
                oYLineOnX = line([iYIndex iYIndex],[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,1)]);
            else
                set(oYLineOnX,'XData',[iYIndex iYIndex]);
                set(oYLineOnX,'YData',[0 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,1)]);
            end
            set(oYLineOnX,'Tag','oYLineOnX','color','r','parent',oRightLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
            oZLineOnY = findall(aSubPlots,'tag','oZLineOnY');
            if isempty(oZLineOnY)
                oZLineOnY = line([0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,2)], [iZIndex iZIndex]);
            else
                set(oZLineOnY,'XData',[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,2)]);
                set(oZLineOnY,'YData',[iZIndex iZIndex]);
            end
            set(oZLineOnY,'Tag','oZLineOnY','color','c','parent',oLeftHighAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
            oXLineOnY = findall(aSubPlots,'tag','oXLineOnY');
            if isempty(oXLineOnY)
                oXLineOnY = line([iXIndex iXIndex],[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,1)]);
            else
                set(oXLineOnY,'XData',[iXIndex iXIndex]);
                set(oXLineOnY,'YData',[0 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,1)]);
            end
            set(oXLineOnY,'Tag','oXLineOnY','color','y','parent',oLeftHighAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
            oXLineOnZ = findall(aSubPlots,'tag','oXLineOnZ');
            if isempty(oXLineOnZ)
                oXLineOnZ = line([iXIndex iXIndex],[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,1)]);
            else
                set(oXLineOnZ,'XData',[iXIndex iXIndex]); 
                set(oXLineOnZ,'YData',[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,1)]);
            end
            set(oXLineOnZ,'Tag','oXLineOnZ','color','y','parent',oLeftLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
            oYLineOnZ = findall(aSubPlots,'tag','oYLineOnZ');
            if isempty(oYLineOnZ)
                oYLineOnZ = line([0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,2)], [iYIndex iYIndex]);
            else
                set(oYLineOnZ,'XData',[0 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,2)]);
                set(oYLineOnZ,'YData',[iYIndex iYIndex]);
            end
            set(oYLineOnZ,'Tag','oYLineOnZ','color','r','parent',oLeftLowAxes, ...
                'linewidth',2,'ButtonDownFcn',@(src,event) StartDrag(oFigure, src, event));
            
             %Prepare the subplots
            set(oLeftHighAxes,'linewidth',2,'Box','on','XColor','r','YColor','r','XTick',[],'YTick',[]);
            set(oLeftHighAxes,'XLim',[1 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,2)]);
            set(oLeftHighAxes,'YLim',[1 size(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data,1)]);
            set(oLeftHighAxes,'Tag', 'LeftHighAxes');
            
            set(oLeftLowAxes,'linewidth',2,'Box','on','XColor','c','YColor','c','XTick',[],'YTick',[]);
            set(oLeftLowAxes,'XLim',[1 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,2)]);
            set(oLeftLowAxes,'YLim',[1 size(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data,1)]);
            set(oLeftLowAxes,'Tag', 'LeftLowAxes');
            
            set(oRightLowAxes,'linewidth',2,'Box','on','XColor','y','YColor','y','XTick',[],'YTick',[]);
            set(oRightLowAxes,'XLim',[1 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,2)]);
            set(oRightLowAxes,'YLim',[1 size(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data,1)]);
            set(oRightLowAxes,'Tag', 'RightLowAxes');
            
            %Display the images
            imagesc('cdata',(oFigure.oGuiHandle.oXStack.oImages(iXIndex).Data),'Parent',...
                oRightLowAxes);
            imagesc('cdata',(oFigure.oGuiHandle.oZStack.oImages(iZIndex).Data),'Parent',...
                oLeftLowAxes);
            imagesc('cdata',(oFigure.oGuiHandle.oYStack.oImages(iYIndex).Data),'Parent',...
                oLeftHighAxes);
            
            %Reorder the children - assuming the image is always in
            %position 1
            aChildren = get(oLeftHighAxes,'children');
            uistack(aChildren(1),'bottom');
            aChildren = get(oLeftLowAxes,'children');
            uistack(aChildren(1),'bottom');
            aChildren = get(oRightLowAxes,'children');
            uistack(aChildren(1),'bottom');
            
            %Finish up by setting the stop drag function and the panel to
            %visible
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'WindowButtonUpFcn',@(src, event) StopDrag(oFigure, src, event));
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
