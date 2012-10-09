classdef LoadImage < BaseFigure
% LoadImage Summary of this class goes here
% This figure allows you to load an image 

    properties
        DefaultPath = 'd:\Users\jash042\Documents\PhD\Analysis\Database\Images\Immuno\';
        oSlideControl;
        CurrentZoomLimits = struct();
    end
    
    methods
        %% Constructor
        function oFigure = LoadImage()
            oFigure = oFigure@BaseFigure('LoadImage',@LoadImage_OpeningFcn);

            %Set the call back functions for the controls
            set(oFigure.oGuiHandle.oZoomTool, 'oncallback', @(src, event) oZoomOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oZoomTool, 'offcallback', @(src, event) oZoomOffTool_Callback(oFigure, src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oViewMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolsMenu, 'callback', @(src, event) oToolsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportMenu, 'callback', @(src, event) oExportMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveYStackMenu, 'callback', @(src, event) oSaveYStackMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveXStackMenu, 'callback', @(src, event) oSaveXStackMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            
            
            % --- Executes just before figure is made visible.
            function LoadImage_OpeningFcn(hObject, eventdata, handles, varargin)
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
            if ~isempty(oFigure.oSlideControl)
                deletefigure(oFigure.oSlideControl);
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
            %This function opens a file dialog and loads 2 mat files (containing signal data and ECG data) 
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile(strcat('*.mat'),'Select a file containing an ImageStack entity',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                return
            end
            
            %Get the full file name 
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Load the selected file
            oStack = GetImageStackFromMATFile(ImageStack,sLongDataFileName);
            %load the Entity into gui handles
            oFigure.oGuiHandle.oStack =  oStack;
            
            %Create slider
            if isempty(oFigure.oSlideControl)
                oFigure.oSlideControl = SlideControl(oFigure,'Select Image');
                %Add a listener so that the figure knows when a user has
                %made a beat selection
                addlistener(oFigure.oSlideControl,'SlideValueChanged',@(src,event) oFigure.SlideValueListener(src, event));
            end
            %Set or reset the slider
            iNumImages = size(oFigure.oGuiHandle.oStack.oImages,2);
            set(oFigure.oSlideControl.oGuiHandle.oSlider, 'Min', 1, 'Max', ...
                iNumImages, 'Value', 1,'SliderStep',[1/iNumImages  0.02]);
            set(oFigure.oSlideControl.oGuiHandle.oSliderTxtLeft,'string',1);
            set(oFigure.oSlideControl.oGuiHandle.oSliderTxtRight,'string',iNumImages);
            set(oFigure.oSlideControl.oGuiHandle.oSliderEdit,'string',1);
            
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
            oFigure.CurrentZoomLimits.XLim = get(oFigure.oGuiHandle.oAxes,'XLim');
            oFigure.CurrentZoomLimits.YLim = get(oFigure.oGuiHandle.oAxes,'YLim');
            oFigure.Replot();
            set(oFigure.oGuiHandle.oAxes,'XLim',oFigure.CurrentZoomLimits.XLim);
            set(oFigure.oGuiHandle.oAxes,'YLim',oFigure.CurrentZoomLimits.YLim);
        end
        
        function oFigure = oFileMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oViewMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oUpdateMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oToolsMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oExportMenu_Callback(oFigure, src, event)
            %Export all the images in the current stack
            %Call built-in file dialog to select filename
            sDataPathName=uigetdir(oFigure.DefaultPath,'Select a folder to save to');
            %Make sure the dialogs return char objects
            if ~ischar(sDataPathName)
                return
            end
            
            %Save to file
            oFigure.oGuiHandle.oStack.SaveStackImages(sDataPathName,'tiff');
        end
        
        function oFigure = oSaveYStackMenu_Callback(oFigure, src, event)
            %Export all the images in the current stack resampling in y
            %Call built-in file dialog to select filename
            sDataPathName=uigetdir(oFigure.DefaultPath,'Select a folder to save to');
            %Make sure the dialogs return char objects
            if ~ischar(sDataPathName)
                return
            end
            %Resample stack in y
            oYStack = oFigure.oGuiHandle.oStack.ResampleStack('y');
            sFileName = strcat(sDataPathName,'\','YStack');
            %Save to file
            oYStack.Save(sFileName);
        end
        
        function oFigure = oSaveXStackMenu_Callback(oFigure, src, event)
            %Export all the images in the current stack resampling in x
            %Call built-in file dialog to select filename
            sDataPathName=uigetdir(oFigure.DefaultPath,'Select a folder to save to');
            %Make sure the dialogs return char objects
            if ~ischar(sDataPathName)
                return
            end
            %Resample stack in x
            oXStack = oFigure.oGuiHandle.oStack.ResampleStack('x');
            sFileName = strcat(sDataPathName,'\','XStack');
            %Save to file
            oXStack.Save(sFileName);
        end
        
        function Replot(oFigure)
            iIndex = oFigure.oSlideControl.GetSliderIntegerValue('oSlider');
            set(0,'currentfigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            imshow(oFigure.oGuiHandle.oStack.oImages(iIndex).Data,'Parent',...
                oFigure.oGuiHandle.oAxes);
            set(oFigure.oGuiHandle.oAxes,'visible','on');
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
    end
    
end
