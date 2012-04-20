classdef StartFigure < BaseFigure
% StartFigure Summary of this class goes here
% This figure allows you to open other figures:
% -BaselineCorrectionFig (class type: BaselineCorrection) 

% Currently there is no functionality to handle deletion of the reference 
% to the child figure so a Warning is posted to the command window automatically   

    properties
        
    end
    
    methods
        %% Constructor
        function oFigure = StartFigure()
            oFigure = oFigure@BaseFigure('StartFigure',@StartFigure_OpeningFcn);
            
            %Set the call back functions for the controls
            set(oFigure.oGuiHandle.bPreprocessing, 'callback', @(src, event) bPreprocessing_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bDetectBeats, 'callback', @(src, event) bDetectBeats_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.bAnalyseSignals, 'callback', @(src, event) bAnalyseSignals_Callback(oFigure, src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSavePotentialMenu, 'callback', @(src, event) oSavePotentialMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oViewMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            % --- Executes just before BaselineCorrection is made visible.
            function StartFigure_OpeningFcn(hObject, eventdata, handles, varargin)
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
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end    
        
        function oFigure = oOpenMenu_Callback(oFigure, src, event)
            %This function opens a file dialog and loads 2 mat files (containing signal data and ECG data) 
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile('*.mat','Select .mat containing a Unemap entity','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            set(oFigure.oGuiHandle.ePath,'String',sLongDataFileName);
            
            %Load the selected file
            oUnemap = GetUnemapFromMATFile(Unemap,sLongDataFileName);
            %load the Entity into gui handles
            oFigure.oGuiHandle.oUnemap =  oUnemap;
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile('*.mat','Select .mat containing an ECG entity','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
                        
            %Load the selected file
            oECG = GetECGFromMATFile(ECG,sLongDataFileName);
            %Save the Entity to gui handles of the parent figure
            oFigure.oGuiHandle.oECG =  oECG;
            
        end
        
        function oFigure = oSavePotentialMenu_Callback(oFigure, src, event)
            % Save the current Potential entity
           
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the unemap .mat file','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.oGuiHandle.oUnemap.Save(sLongDataFileName);
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the ecg .mat file','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.oGuiHandle.oECG.Save(sLongDataFileName);
            
        end
        
        function oFigure = bPreprocessing_Callback(oFigure, src, event)
            %Open the Preprocessing figure passing this figure as the
            %parent
            Preprocessing(oFigure);
        end
        
        function oFigure = bDetectBeats_Callback(oFigure, src, event)
            %Open the BeatDetection figure passing this figure as the
            %parent
            BeatDetection(oFigure);
        end
        
        function oFigure = bAnalyseSignals_Callback(oFigure, src, event)
            %Open the AnalyseSignals figure passing this figure as the
            %parent
            AnalyseSignals(oFigure);
        end
        
        function oFigure = oFileMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oViewMenu_Callback(oFigure, src, event)
           
        end
        
        function oFigure = oUpdateMenu_Callback(oFigure, src, event)
            
        end
            
    end
    
end

