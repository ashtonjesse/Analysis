classdef StartFigureClass < handle
    %StartFigure Summary of this class goes here
    %   Detailed explanation goes here
    
   properties (Access = private)
        m_oGuiHandle;
    end
    
    methods
        function oFigure = StartFigureClass()
            %function - class constructor - creates and initialises the gui
            
            %Make the gui figure handle and store it locally
            oFigure.m_oGuiHandle = guihandles(StartFigure);
            
            %Set the callback functions to the two buttons
            set(oFigure.m_oGuiHandle.bBaselineCorrection, 'callback', @(src, event) bBaselineCorrection_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.bDetectBeats , 'callback', @(src, event)  bDetectBeats_Callback(oFigure, src, event));
            
            %Set the callback functions to the menu items 
            set(oFigure.m_oGuiHandle.oFileMenu, 'callback', @(src, event) oFileMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oSavePotentialMenu, 'callback', @(src, event) oSavePotentialMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oExitMenu, 'callback', @(src, event) oExitMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oViewMenu, 'callback', @(src, event) oViewMenu_Callback(oFigure, src, event));
            set(oFigure.m_oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.m_oGuiHandle.Figure1,  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
        end
    end
    
    methods (Access = private)
        
        function delete(oFigure)
            %Class deconstructor - handles the cleaning up of the class &
            %figure. Either the class or the figure can initiate the closing
            %condition, this function makes sure both are cleaned up
            
            %remove the closerequestfcn from the figure, this prevents an
            %infitie loop with the following delete command
            set(oFigure.m_oGuiHandle.Figure1,  'closerequestfcn', '');
            %delete the figure
            delete(oFigure.m_oGuiHandle.Figure1);
            %clear out the pointer to the figure - prevents memory leaks
            oFigure.m_oGuiHandle = [];
        end
               
        function oFigure = Close_fcn(oFigure, src, event)
            %This is the closerequestfcn of the figure. All it does here is
            %call the class delete function (presented above)
            delete(oFigure);
        end    
 
        function oFigure = oExitMenu_Callback(oFigure, src, event)
            %This runs a closerequest of the figure (same as closing the
            %window)
            closereq;
        end
        
        function oFigure = oOpenMenu_Callback(oFigure, src, event)
            %This function opens a file dialog and loads a mat file (containing signal data) 
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uigetfile('*.mat','Select .mat containing a Data structured array','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            set(oFigure.m_oGuiHandle.ePath,'String',sLongDataFileName);
            
            %Load the selected file
            oPotential = GetEntityFromMATFile(Potential,sLongDataFileName);
            %Save the Entity to gui handles
            oFigure.m_oGuiHandle.oPotential =  oPotential;
            
        end
        
        function oFigure = oSavePotentialMenu_Callback(oFigure, src, event)
            % Save the current Potential entity
            % hObject    handle to oSavePotentialMenu (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for this .mat file','H:\Data\Database\20111124\');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sExpFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.m_oGuiHandle.oPotential.Save(sLongDataFileName);
        end
        
        function oFigure = oFileMenu_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oViewMenu_Callback(oFigure, src, event)
           
        end
        
        function oFigure = oUpdateMenu_Callback(oFigure, src, event)
            
        end
            
    end
    
end

