classdef MapElectrodes < SubFigure
    %   MapElectrodes.    
    
    properties
        SelectedChannels;
        Overlay = 0;
        ElectrodeMarkerVisible = 1;
        ColourBarVisible = 1;
        AxesVisible = 1;
        ColourBarOrientation = 'vert';
        ColourBarLevels = 0:1:12;
        Potential = [];
        EventData = [];
        CV = [];
        cbarmin;
        cbarmax;
        PlotType; %A string specifying the currently selected type of plot
        PlotPosition; %An array that can be used to store the position of the oMapAxes 
        PlotLimits = [];
        oHiddenAxes;
        oRootFigure;
        BasePotentialFile;
        AxesOrder = {'HiddenPlot','SchematicOverLay','PointsPlot','MapPlot','cbarf_vertical_linear'};
        ImageLine;
        CVSupportPoints = 35;
    end
    
    events
        ChannelGroupSelection;
        ElectrodeSelected;
        SaveButtonPressed;
        BeatChange;
        FigureDeleted;
    end
    
    methods
        function oFigure = MapElectrodes(oParent,oRootFigure,sBasePotentialFile)
            %% Constructor
            oFigure = oFigure@SubFigure(oParent,'MapElectrodes',@MapElectrodes_OpeningFcn);
            oFigure.oRootFigure = oRootFigure;
            oFigure.BasePotentialFile = sBasePotentialFile;
            %Callbacks
            set(oFigure.oGuiHandle.oDataCursorTool, 'oncallback', @(src, event) oDataCursorOnTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDataCursorTool, 'offcallback', @(src, event) oDataCursorOffTool_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEditMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oUpdateMenu, 'callback', @(src, event) oUpdateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEventContourMenu, 'callback', @(src, event) oEventContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oReplotMenu, 'callback', @(src, event) oReplotMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOverlayMenu, 'callback', @(src, event) oOverlayMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMapMenu, 'callback', @(src, event) oSaveMapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportToTextMenu, 'callback', @(src, event) oExportToTextMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDeltaVmContourMenu, 'callback', @(src, event) oDeltaVmContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oEventDiffMenu, 'callback', @(src, event) oEventDiffMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oAmplitudeContourMenu, 'callback', @(src, event) oAmplitudeContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPotContourMenu, 'callback', @(src, event) oPotContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCVScatterMenu, 'callback', @(src, event) oCVScatterMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRefreshEventMenu, 'callback', @(src, event) oRefreshEventMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMontageMenu, 'callback', @(src, event) oMontageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToggleColourBarMenu, 'callback', @(src, event) oToggleColourBarMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToggleAxesBarMenu, 'callback', @(src, event) oToggleAxesBarMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToggleElectrodeMarkerMenu, 'callback', @(src, event) oToggleElectrodeMarkerMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRotateArrayMenu, 'callback', @(src, event) oRotateArrayMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRefreshBeatEventMenu, 'callback', @(src, event) oRefreshBeatEventMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMarkOriginMenu, 'callback', @(src, event) oMarkOriginMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oClearOriginMenu, 'callback', @(src, event) oClearOriginMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMarkExitMenu, 'callback', @(src, event) oMarkExitMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oClearExitMenu, 'callback', @(src, event) oClearExitMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMarkAxisMenu, 'callback', @(src, event) oMarkAxisMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oClearAxisMenu, 'callback', @(src, event) oClearAxisMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMapChannelsMenu, 'callback', @(src, event) oMapChannelsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oHideChannelsMenu, 'callback', @(src, event) oHideChannelsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSavePlotLimitsMenu, 'callback', @(src, event) oSavePlotLimitsMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewSchematicMenu, 'callback', @(src, event) oViewSchematicMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oLineToolMenu, 'oncallback', @(src, event) oLineToolMenu_OnCallback(oFigure, src, event));
            set(oFigure.oGuiHandle.oLineToolMenu, 'offcallback', @(src, event) oLineToolMenu_OffCallback(oFigure, src, event));
            
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
            addlistener(oFigure.oParentFigure,'EventRangeChange',@(src,event) oFigure.SignalEventMarkChangeListener(src, event));
            addlistener(oFigure.oParentFigure,'SignalEventLoaded',@(src,event) oFigure.SignalEventSelectionListener(src, event));
            addlistener(oFigure.oParentFigure,'EventMarkChange',@(src,event) oFigure.SignalEventMarkChangeListener(src, event));
                        
            %Set plot position and plot type 
            oFigure.PlotPosition = [0.05 0.05 0.88 0.88];
            oFigure.PlotType = 'JustElectrodes';
            %             oFigure.PlotLimits = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetSpatialLimits()+[-0.1,0.1;-0.1,0.1];
            %Plot the electrodes
            oFigure.CreatePlots();
            oFigure.PlotData();
            %Set default selection
            oFigure.SelectedChannels = 1:length(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes);
            %set the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', @(src,event) ThisKeyPressFcn(oFigure, src, event));
            %save the old keypressfcn
            oldKeyPressFcnHook = get(oFigure.oGuiHandle.(oFigure.sFigureTag), 'KeyPressFcn');
            %disable the listeners hold
            hManager = uigetmodemanager(oFigure.oGuiHandle.(oFigure.sFigureTag));
            set(hManager.WindowListenerHandles,'Enable','off');
            %reset the keypressfcn
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'keypressfcn', oldKeyPressFcnHook);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'position',[0.575521 0.286111 0.419271 0.636111]);
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
            notify(oFigure,'FigureDeleted');
            deleteme@BaseFigure(oFigure);
        end
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            nValue = GetPopUpSelectionDouble@BaseFigure(oFigure,sPopUpMenuTag);
        end
        
     end
    
     methods (Access = public)
         function ThisKeyPressFcn(oFigure, src, event)
             switch event.Key
                case 's'
                    %save the signal event times
                    if ~isempty(oFigure.oParentFigure.EventFilePath)
                        notify(oFigure,'SaveButtonPressed',DataPassingEvent([],oFigure.oParentFigure.EventFilePath));
                    end
                 case 'leftarrow'
                     %shift to the previous beat
                     notify(oFigure,'BeatChange',DataPassingEvent([],oFigure.oParentFigure.SelectedBeat-1));
                 case 'rightarrow'
                     %shift to the next beat
                     notify(oFigure,'BeatChange',DataPassingEvent([],oFigure.oParentFigure.SelectedBeat+1));
                 case 'r'
                     oFigure.RefreshEventData(oFigure.oParentFigure.SelectedBeat);
             end
         end
        
         function oFigure = Close_fcn(oFigure, src, event)
             deleteme(oFigure);
             clear('oFigure');
         end
         
         %% Menu Callbacks
        % -----------------------------------------------------------------
        function oMenu_Callback(oFigure, src, event)

        end
        
        % -----------------------------------------------------------------
        function oSaveMapMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            %             [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %             %Make sure the dialogs return char objects
            %             if (~ischar(sFilename) && ~ischar(sPathName))
            %                 return
            %             end
            % %                         Save individual beat activation time
            iBeat = oFigure.oParentFigure.SelectedBeat;
            sLongDataFileName=strcat(oFigure.oParentFigure.DefaultDirectory,'\',sprintf('Beat%d_',iBeat),oFigure.PlotType,'.bmp');
            oFigure.PrintFigureToFile(sLongDataFileName);
            sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sLongDataFileName)});
            sChopString = strcat(sChopString, {' -gravity South -chop 0x25 -gravity West -chop 50x0 -gravity East -chop 50x0'}, {sprintf(' %s',sLongDataFileName)});
            sStatus = dos(char(sChopString{1}));
            
%                         %Save series of activation maps
            
%             for i =1:size(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes,1);
%             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperunits','inches');
%             iStartBeat = oFigure.oParentFigure.SelectedBeat;
%             %Set figure size
%             iMontageX = 5;%5
%             iMontageY = 9;%9
%             dMontageWidth = 8.27 - 2; %in inches, with borders
%             dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
%             dWidth = dMontageWidth/iMontageX; %in inches
%             dHeight = dMontageHeight/iMontageY; %in inches
%             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperposition',[0 0 dWidth dHeight])
%             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'papersize',[dWidth dHeight])
%             aSubPlots = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
%             oMapPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'MapPlot');
%             oHiddenPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'HiddenPlot');
%             axis(oMapPlot,'on');
%             axis(oHiddenPlot,'off');
%             set(oMapPlot,'units','normalized');
%             set(oMapPlot,'outerposition',[0 0 1 1]);
%             aTightInset = get(oMapPlot, 'TightInset');
%             aPosition(1) = aTightInset(1);
%             aPosition(2) = aTightInset(2);
%             aPosition(3) = 1-aTightInset(1)-aTightInset(3);
%             aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
%             set(oMapPlot, 'Position', aPosition);
%             sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',oFigure.oParentFigure.SelectedBeat),'.bmp');
%             oFigure.PlotData(0);
%             drawnow; pause(.2);
%             
%             
%             set(oMapPlot,'FontUnits','points');
%             set(oMapPlot,'FontSize',6);
%             aYticks = get(oMapPlot,'ytick');
%             aYticks = aYticks - aYticks(1);
%             aYtickstring = cell(length(aYticks),1);
%             for i=1:length(aYticks)
%                 %Check if the label has a decimal place and hide this label
%                 if ~mod(aYticks(i),1) == 0
%                     aYtickstring{i} = '';
%                 else
%                     aYtickstring{i} = num2str(aYticks(i));
%                 end
%             end
%             set(oMapPlot,'xticklabel',[]);
%             set(oMapPlot,'xtickmode','manual');
%             set(oMapPlot,'yticklabel', char(aYtickstring));
%             set(oMapPlot,'ytickmode','manual');
%             set(oMapPlot,'Box','off');
%             oXLim = get(oMapPlot,'xlim');
%             oYLim = get(oMapPlot,'ylim');
%             oBeatLabel = text(oXLim(1)+0.1,oYLim(2)-0.5, sprintf('%d',oFigure.oParentFigure.SelectedBeat));
%             set(oBeatLabel,'units','normalized');
%             set(oBeatLabel,'fontsize',14,'fontweight','bold');
%             set(oBeatLabel,'parent',oMapPlot);
%             oFigure.PrintFigureToFile(sLongDataFileName);
%             
%             for i = oFigure.oParentFigure.SelectedBeat+1:min(size(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes,1),oFigure.oParentFigure.SelectedBeat+iMontageX*iMontageY-1)
%                 %Get the full file name and save it to string attribute
%                 sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
%                 oFigure.oParentFigure.SelectedBeat = i;
%                 oFigure.PlotData(0);
%                 drawnow; pause(.2);
%                 oBeatLabel = text(oXLim(1)+0.1,oYLim(2)-0.5, sprintf('%d',i));
%                 set(oBeatLabel,'units','normalized');
%                 set(oBeatLabel,'fontsize',14,'fontweight','bold');
%                 set(oBeatLabel,'parent',oMapPlot);
%                 axis(oMapPlot, 'off');
%                 
%                 oFigure.PrintFigureToFile(sLongDataFileName);
%             end
%             %reset the beat to what was originally selected
%             oFigure.oParentFigure.SelectedBeat = iStartBeat;
        end
        
        % -----------------------------------------------------------------
        function oMontageMenu_Callback(oFigure, src, event)
            %             %Get the save file path
            %             %Call built-in file dialog to select filename
            % %             [sFileName,sPathName]=uigetfile('*.*','Select image file(s)','multiselect','on');
            % %             %Make sure the dialogs return char objects
            % %             if iscell(sFileName)
            % %                 if (~ischar(sFileName{1}) && ~ischar(sPathName))
            % %                     return
            % %                 end
            % %                 sDosString = 'D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ';
            % %                 for i = 1:length(sFileName)
            % %                     %Loop through files adding them to list
            % %                     sDosString = strcat(sDosString, {sprintf(' %s%s',sPathName,char(sFileName{i}))});
            % %                 end
            % %                 iMontageX = 5;%5
            % %                 iMontageY = 9;%9
            % %                 dMontageWidth = 8.27 - 2; %in inches, with borders
            % %                 dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
            % %                 dWidth = dMontageWidth/iMontageX; %in inches
            % %                 dHeight = dMontageHeight/iMontageY; %in inches
            % %                 iPixelWidth = dWidth*300;
            % %                 iPixelHeight = dHeight*300;
            % %                 sDosString = strcat(sDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sPathName, 'montage.png');
            % %
            % %             else
            % %                 if (~ischar(sFileName) && ~ischar(sPathName))
            % %                     return
            % %                 end
            % %             end
            % %             sStatus = dos(char(sDosString{1}));
            % %             if ~sStatus
            % % %                 figure();
            % % %                 disp(char(sDosString));
            % % %                 imshow(strcat(sPathName, 'montage.png'));
            % %             end
            % %             oFigure.ColourBarVisible = true;
            % %             oFigure.ColourBarOrientation = 'horiz';
            % %
            % %             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperunits','inches');
            % %             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperposition',[0 0 dMontageWidth dMontageHeight]);
            % %             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'papersize',[dMontageWidth dMontageHeight]);
            % %
            % %             oFigure.PlotData(0);
            % %             switch (oFigure.PlotType)
            % %                 case 'Event2DContour'
            % %                     sSaveCbarFilePath = fullfile(sPathName,'ATcolorbar.bmp');
            % %                     sSaveFilePath = fullfile(sPathName,'ATmontage_cbar.png');
            % %                 case 'CV2DScatter'
            % %                     sSaveCbarFilePath = fullfile(sPathName,'CVcolorbar.bmp');
            % %                     sSaveFilePath = fullfile(sPathName,'CVmontage_cbar.png');
            % %             end
            % %             aPathFolders = regexp(sPathName,'\\','split');
            % %             sFigureTitle = char(aPathFolders{end-1});
            % %             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
            % %             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
            % %             oFigureTitle = text('string', sFigureTitle, 'parent', oHandle);
            % %             set(oFigureTitle, 'units', 'normalized');
            % %             set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
            % %             set(oFigureTitle, 'position', [0 3.2]);
            % %             oFigure.PrintFigureToFile(sSaveCbarFilePath);
            % %             sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveCbarFilePath)}, ...
            % %                 {' -gravity North -chop 0x2180'},{' -gravity South -chop 0x100'}, {sprintf(' %s', sSaveCbarFilePath)});
            % %             sStatus = dos(char(sChopString{1}));
            % %
            % %             sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveCbarFilePath)}, ...
            % %                 {sprintf(' %s', sPathName)}, 'montage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
            % %             sStatus = dos(char(sAppend{1}));
            
            %Save series of potential fields
            iBeat = oFigure.oParentFigure.SelectedBeat;
            oFigure.PlotType = 'Potential2DContour';
            sDirectory = strcat(oFigure.oParentFigure.DefaultDirectory,'\',sprintf('Beat%d',iBeat));
            if ~isdir(sDirectory)
                mkdir(sDirectory);
            end
            sFileNames = cell(1,13);
            iCount = 0;
            for i = oFigure.oParentFigure.SelectedTimePoint:oFigure.oParentFigure.SelectedTimePoint+10;
                iCount = iCount + 1;
                %Get the full file name and save it to string attribute
                sFileNames{iCount}=strcat(sDirectory,'\',oFigure.PlotType,sprintf('_%d',i),'.bmp');
                oFigure.oParentFigure.SelectedTimePoint = i;
                oFigure.PlotData(0);
                drawnow; pause(.2);
                oFigure.PrintFigureToFile(char(sFileNames{iCount}));
                sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',char(sFileNames{iCount}))});
                sChopString = strcat(sChopString, {' -gravity South -chop 0x50 -gravity West -chop 50x0 -gravity East -chop 50x0'}, {sprintf(' %s',char(sFileNames{iCount}))});
                sStatus = dos(char(sChopString{1}));
            end
            %run virtualdub to create video
            sCommandString = strcat({'D:\Users\jash042\Documents\InstallationFiles\VirtualDub-1.9.11-AMD64\Veedub64.exe  '}, ...
                {'/i D:\Users\jash042\Documents\InstallationFiles\VirtualDub-1.9.11-AMD64\CreateMovie.vcf '},...
                char(sFileNames{2}),{' '},sDirectory,'.avi /x');
            sStatus = dos(char(sCommandString));
        end
        
        function oSavePlotLimitsMenu_Callback(oFigure, src, event)
            aSubPlots = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
            oPointsPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'PointsPlot');
            aXLim = get(oPointsPlot,'xlim');
            aYLim = get(oPointsPlot,'ylim');
            oFigure.PlotLimits = [aXLim ; aYLim];
            sFileType = (oFigure.BasePotentialFile);
            oFigure.oRootFigure.oGuiHandle.(sFileType).oExperiment.(sFileType(2:end)).AxisOffsets = oFigure.PlotLimits;
            fprintf('Plot limits [%4.2f,%4.2f;%4.2f,%4.2f]\n',aXLim(1),aXLim(2),aYLim(1),aYLim(2));
        end
        
        function oRotateArrayMenu_Callback(oFigure, src, event)
            %Calls a function to rotate the array
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).RotateArray();
            oFigure.Activation = [];
            oFigure.PlotPosition = [0.05 0.05 0.88 0.88];
            oFigure.PlotLimits = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetSpatialLimits()+[-0.1,0.1;-0.1,0.1];
            %Plot the electrodes
            oFigure.ReplotElectrodes();
            %Notify listeners
            notify(oFigure,'ChannelGroupSelection',DataPassingEvent(oFigure.SelectedChannels,[]));
        end
        
        function oExportToTextMenu_Callback(oFigure, src, event)
            %Export the currently selected data to a text file
            %check first that there is activation data
            if ~isempty(oFigure.Activation)
                [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
                
                %Make sure the dialogs return char objects
                if (~ischar(sFilename) && ~ischar(sPathName))
                    return
                end
                sOutFile = fullfile(sPathName,char([sFilename '.txt']));
                switch (oFigure.PlotType)
                    case 'Event2DContour'
                        %Export the activation data
                    case 'CV2DScatter'
                        %Export the CV data
                        idxCV = find(~isnan(oFigure.Activation.Beats(1).CVApprox));
                        %Need to update if I have multiple events I want to
                        %write out 
                        aRowHeader = cell2mat({oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(idxCV).Name});
                        aRowHeader = reshape(aRowHeader,5,length(idxCV));
                        aRowHeader = cellstr(aRowHeader');
                        aRowData = cell2mat({oFigure.Activation.Beats(:).CVApprox});
                        aRowData = aRowData';
                        oFigure.oDAL.oHelper.ExportDataToTextFile(sOutFile,aRowHeader,aRowData(:,idxCV),'%5.2f,');
                end
            end
        end
        
        % -----------------------------------------------------------------
        function oToggleColourBarMenu_Callback(oFigure, src, event)
            oFigure.ColourBarVisible = ~oFigure.ColourBarVisible;
            oFigure.PlotData(0);
        end
         
        function oToggleAxesBarMenu_Callback(oFigure,src,event)
            oFigure.AxesVisible = ~oFigure.AxesVisible;
            oFigure.PlotData(0);
        end
        
        function oViewSchematicMenu_Callback(oFigure, src, event)
            %rearrange plots so that points and maps are above schematic
            if strcmp(oFigure.AxesOrder{2},'SchematicOverLay')
                oFigure.AxesOrder = {'HiddenPlot','PointsPlot','MapPlot','SchematicOverLay','cbarf_vertical_linear'};
            else
                oFigure.AxesOrder = {'HiddenPlot','SchematicOverLay','PointsPlot','MapPlot','cbarf_vertical_linear'};
            end
            oFigure.RearrangePlots(oFigure.AxesOrder);
        end
        % -----------------------------------------------------------------
        function oToggleElectrodeMarkerMenu_Callback(oFigure, src, event)
            oFigure.ElectrodeMarkerVisible = ~oFigure.ElectrodeMarkerVisible;
            oFigure.PlotData(0);
        end
        
        % -----------------------------------------------------------------
        function oReplotMenu_Callback(oFigure, src, event)
            oFigure.ReplotElectrodes();
        end
        
        % -----------------------------------------------------------------
        function oOverlayMenu_Callback(oFigure, src, event)
            %toggle an overlay of the electrode points on the existing plot
            
            oFigure.Overlay = ~oFigure.Overlay;
            oFigure.PlotData(0);
        end
        
        function oRefreshEventMenu_Callback(oFigure, src, event)
            %Refresh the data
            switch (oFigure.PlotType)
                case 'Potential2DContour'
                    oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.oParentFigure.SelectedEventID,[],[]);
                    oFigure.PlotData(1);
                case {'Event2DContour','DeltaVm2DContour','Amplitude2DContour','CV2DScatter'}
                    oFigure.RefreshEventData();
            end
            
        end
        
        function oRefreshBeatEventMenu_Callback(oFigure, src, event)
            %Refresh the map data just for the currently selected beat
            oFigure.RefreshEventData(oFigure.oParentFigure.SelectedBeat);
        end
        
        % -----------------------------------------------------------------
        function oUpdateMenu_Callback(oFigure, src, event)
            % Find the brushline object in the figure
            hBrushLine = findall(oFigure.oGuiHandle.(oFigure.sFigureTag),'tag','Brushing');
            % Get the Xdata and Ydata attitributes of this
            brushedData = get(hBrushLine, {'Xdata','Ydata'});
            % The data that has not been selected is labelled as NaN so get
            % rid of this
            %find the points that actually contain info we want
            aIndices = zeros(size(brushedData,1),1);
            for i = 1:size(brushedData,1)
                aData = brushedData{i};
                if size(aData,2) > 2 %should always have more than 2 columns
                    aIndices(i) = 1;
                end
            end
            %get the x and y data for these points
            aData = [brushedData{logical(aIndices),1}];
            aXData = aData(~isnan(aData));
            aData = [brushedData{logical(aIndices),2}];
            aYData = aData(~isnan(aData));
            %             [row, colIndices] = find(brushedIdx);
            %find the indices for these locations
            aIndices = zeros(numel(aXData),1);
            for i = 1:numel(aXData)
                %get id for this location
                aIndices(i) = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetNearestElectrodeID(aXData(i), aYData(i));
            end
            oFigure.SelectedChannels = aIndices;
            %Notify listeners
            notify(oFigure,'ChannelGroupSelection',DataPassingEvent(aIndices,[]));
            oFigure.PlotData(0);
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
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).ApplyNeighbourhoodAverage(aInOptions);
        end
               
        function oDataCursorOnTool_Callback(oFigure, src, event)
            %Turn brushing on so that the user can select a range of data
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'on');
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'red');
            %rearrange axes so that points plot is on top
            
            oFigure.AxesOrder = {'PointsPlot','MapPlot','HiddenPlot','SchematicOverLay','cbarf_vertical_linear'};
            oFigure.RearrangePlots(oFigure.AxesOrder);
        end
        
        function oDataCursorOffTool_Callback(oFigure, src, event)
            %Turn brushing off 
            brush(oFigure.oGuiHandle.(oFigure.sFigureTag),'off');
            oFigure.AxesOrder = {'HiddenPlot','SchematicOverLay','PointsPlot','MapPlot','cbarf_vertical_linear'};
            oFigure.PlotData(0);
        end
        
        %% Callbacks
        function oPotContourMenu_Callback(oFigure, src, event)
            %Generate potential map for the current beat
            
            %Check if the potential data needs to be prepared
            if isempty(oFigure.Potential)
                oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.oParentFigure.SelectedEventID,[],[]);
            elseif isempty(oFigure.Potential.Beats(oFigure.oParentFigure.SelectedBeat).Fields)
                oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.oParentFigure.SelectedEventID,oFigure.Potential,[]);
            end
            
            %Update the plot type
            if strcmp(oFigure.PlotType,'Potential2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Potential2DContour';
                bUpdateColorBar = 1;
            end

            %Plot a potential contour map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function oEventContourMenu_Callback(oFigure, src, event)
            %Generate event map for the current beat and event
            
            %Check if the event data needs to be prepared
            oFigure.CheckEventData();
            %get the event map
            iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            if isempty(oFigure.EventData(iEvent).Beats(oFigure.oParentFigure.SelectedBeat).EventTimes)
                oFigure.EventData(iEvent)  = GetEventMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
            end
            %Update the plot type
            if strcmp(oFigure.PlotType,'Event2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Event2DContour';
                bUpdateColorBar = 1;
            end
            %Plot a 2D event map
            oFigure.PlotData(bUpdateColorBar);
        end
       
        function oDeltaVmContourMenu_Callback(oFigure, src, event)
            %Generate deltavm map for the current beat and event
            
            oFigure.CheckEventData();
            iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            if ~(sum(oFigure.EventData(iEvent).Beats(oFigure.oParentFigure.SelectedBeat).DeltaVmData) > 0)
                oFigure.EventData(iEvent) = GetDeltaVmMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
            end
            %Update the plot type
            if strcmp(oFigure.PlotType,'DeltaVm2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'DeltaVm2DContour';
                bUpdateColorBar = 1;
            end
            %Plot a 2D activation map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function oAmplitudeContourMenu_Callback(oFigure, src, event)
            %Generate ampltidue map for the current beat and event
            
            oFigure.CheckEventData();
            iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            if ~(sum(oFigure.EventData(iEvent).Beats(oFigure.oParentFigure.SelectedBeat).AmplitudeData) > 0)
                oFigure.EventData(iEvent) = GetAmplitudeMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
            end
            
            %Update the plot type
            if strcmp(oFigure.PlotType,'Amplitude2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Amplitude2DContour';
                bUpdateColorBar = 1;
            end
            %Plot a 2D activation map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function oEventDiffMenu_Callback(oFigure, src, event)
            %Generate activation map for the current beat
            
            oFigure.CheckEventData();
            iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            if isempty(oFigure.EventData(iEvent).Beats(oFigure.oParentFigure.SelectedBeat).EventTimes)
                oFigure.EventData(iEvent) = GetEventMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
            end
            %Update the plot type
            if strcmp(oFigure.PlotType,'Difference2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Difference2DContour';
                bUpdateColorBar = 1;
            end
            %Plot a 2D activation map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function oCVScatterMenu_Callback(oFigure, src, event)
            %Generate conduction velocity map for the current beat
            
            %Check if the conduction velocity data needs to be prepared
            oFigure.CheckEventData();
            iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            if ~(sum(oFigure.EventData(iEvent).Beats(oFigure.oParentFigure.SelectedBeat).CVApprox) > 0)
                oFigure.EventData(iEvent) =  GetCVMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent),oFigure.CVSupportPoints,oFigure.oParentFigure.SelectedBeat);
            end
           
            %Update the plot type
            if strcmp(oFigure.PlotType,'CV2DScatter')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'CV2DScatter';
                bUpdateColorBar = 1;
            end
            
            %Plot a 2D activation map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function BeatSelectionListener(oFigure,src,event)
            %An event listener callback
            %Is called when the user selects a new beat using the electrode
            %plot in AnalyseSignals
            switch (oFigure.PlotType)
                case { 'Event2DContour','CV2DScatter','DeltaVm2DContour','Amplitude2DContour'}
                    oFigure.RefreshEventData(oFigure.oParentFigure.SelectedBeat);
                case 'Potential2DContour'
                    if isempty(oFigure.Potential)
                        oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.oParentFigure.SelectedEventID,[],[]);
                    elseif isempty(oFigure.Potential.Beats(oFigure.oParentFigure.SelectedBeat).Fields)
                        oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.oParentFigure.SelectedEventID,oFigure.Potential,[]);
                    end
                    oFigure.PlotData(0);
                case 'Difference2DContour'
                    oFigure.PlotData(0);
            end

        end
        
        function TimeSelectionListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new time point using the
            %slidecontrol
                        
            if strncmpi(oFigure.PlotType,'Pot',3)
                oFigure.PlotData(0);
            end
        end
        
        function ChannelSelectionListener(oFigure, src, event)
            %An event listener callback
            %Is called when the user selects a new channel
            
            oFigure.PlotData(0);
        end
        
        function SignalEventSelectionListener(oFigure, src, event)
            %Change the map according to the new signalevent selection

           switch (oFigure.PlotType)
                case 'JustElectrodes'
                    oFigure.ReplotElectrodes();
                case {'Event2DContour','DeltaVm2DContour','Amplitude2DContour','CV2DScatter'}
                    oFigure.RefreshEventData(oFigure.oParentFigure.SelectedBeat);
               case 'Potential2DContour'
                   if isempty(oFigure.Potential)
                       oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,[],[]);
                   elseif isempty(oFigure.Potential.Beats(oFigure.oParentFigure.SelectedBeat).Fields)
                       oFigure.Potential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).PreparePotentialMap(100,oFigure.oParentFigure.SelectedBeat,oFigure.Potential,[]);
                   end
                   oFigure.PlotData(0);
            end
        end
        
        function SignalEventMarkChangeListener(oFigure, src, event)
            %Change the map according to the new signalevent selection
            switch (oFigure.PlotType)
                case 'JustElectrodes'
                    oFigure.ReplotElectrodes();
                case 'Event2DContour'
                    oFigure.RefreshEventData(oFigure.oParentFigure.SelectedBeat);
            end
        end
                
        function oHiddenAxes_Callback(oFigure, src, event)
            %Get the selected point and find the closest electrode 
            oPoint = get(src,'currentpoint');
            xLoc = oPoint(1,1);
            yLoc = oPoint(1,2);
            iChannel = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).GetNearestElectrodeID(xLoc, yLoc);
            fprintf('[%4.1f;%4.1f] %3.0f\n',oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(iChannel).Coords,iChannel);
            %Notify listeners about the new electrode selection
            notify(oFigure, 'ElectrodeSelected', DataPassingEvent([],iChannel));
        end
        
        function oMarkOriginMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).MarkEventOrigin(oFigure.oParentFigure.SelectedChannel,...
                oFigure.oParentFigure.SelectedEventID,oFigure.oParentFigure.SelectedBeat);
            oFigure.PlotData(0);
        end
        
        function oClearOriginMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).ClearEventOrigin(oFigure.oParentFigure.SelectedChannel,...
                oFigure.oParentFigure.SelectedEventID,oFigure.oParentFigure.SelectedBeat);
            oFigure.PlotData(0);
        end
        
        function oMarkExitMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).MarkEventExit(oFigure.oParentFigure.SelectedChannel,...
                oFigure.oParentFigure.SelectedEventID,oFigure.oParentFigure.SelectedBeat);
            oFigure.PlotData(0);
        end
        
        function oClearExitMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).ClearEventExit(oFigure.oParentFigure.SelectedChannel,...
                oFigure.oParentFigure.SelectedEventID,oFigure.oParentFigure.SelectedBeat);
            oFigure.PlotData(0);
        end
        
        function oMarkAxisMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).MarkAxisPoint(oFigure.oParentFigure.SelectedChannel);
            oFigure.PlotData(0);
        end
        
        function oClearAxisMenu_Callback(oFigure, src, event)
            oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).ClearAxisPoint(oFigure.oParentFigure.SelectedChannel);
            oFigure.PlotData(0);
        end
        
        function oMapChannelsMenu_Callback(oFigure, src, event)
            %open edit box to select beat range
            oEditControl = EditControl(oFigure,'Enter range of beats to apply to:',2);
            addlistener(oEditControl,'ValuesEntered',@(src,event) oFigure.MapChannels(src, event));
        end
        
        function oHideChannelsMenu_Callback(oFigure, src, event)
            oEditControl = EditControl(oFigure,'Enter range of beats to apply to:',2);
            addlistener(oEditControl,'ValuesEntered',@(src,event) oFigure.HideChannels(src, event));
        end
        
        % --------------------------------------------------------------------
        function oLineToolMenu_OnCallback(oFigure,src,event)
            oFigure.ImageLine = imline;
            %get children 
            oChildren = get(oFigure.ImageLine,'children');
            oPoints = {get(oChildren(2)), get(oChildren(1))};
            %get nearest electrode to each point
            iStartElectrode = GetNearestElectrodeID(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile), oPoints{1}.XData, oPoints{1}.YData);
            iEndElectrode = GetNearestElectrodeID(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile), oPoints{2}.XData, oPoints{2}.YData);
            %calc conduction time and velocity
            iAtrialEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
            %             iSANEvent = oFigure.GetEventIndexFromID('aghsm');
            oBasePotential = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile);
            for iBeat = 1:size(oBasePotential.Beats.Indexes,1)
                aTime =  oBasePotential.TimeSeries(...
                    oBasePotential.Beats.Indexes(iBeat,1):...
                    oBasePotential.Beats.Indexes(iBeat,2));
                dStartTime = aTime(oBasePotential.Electrodes(iStartElectrode).(oBasePotential.Electrodes(iStartElectrode).SignalEvents{iAtrialEvent}).Index(iBeat));
                dEndTime = aTime(oBasePotential.Electrodes(iEndElectrode).(oBasePotential.Electrodes(iEndElectrode).SignalEvents{iAtrialEvent}).Index(iBeat));
                dConductionTime = (dEndTime - dStartTime)*1000;
                dDistance = sqrt((oPoints{1}.XData - oPoints{2}.XData).^2 + ...
                    (oPoints{1}.YData - oPoints{2}.YData).^2);
                dVelocity = (dDistance/10)/(dConductionTime/1000);
                fprintf('%2.0f,%4.2f,%4.2f,%4.2f\n',[iBeat dConductionTime dDistance dVelocity]);
            end
        end
        function oLineToolMenu_OffCallback(oFigure,src,event)
            delete(oFigure.ImageLine);
            oFigure.ImageLine = [];
        end
     end
     
     methods (Access = private)
         
         function CheckEventData(oFigure)
             %Check if the event data needs to be prepared
             if isempty(oFigure.oParentFigure.SelectedEventID)
                 oFigure.oParentFigure.SelectedEventID = 'arsps';
             end
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             if isempty(oFigure.EventData)
                 oFigure.EventData = PrepareEventData(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),100, 'Contour', oFigure.oParentFigure.SelectedEventID, oFigure.oParentFigure.SelectedBeat, []);
             elseif iEvent > numel(oFigure.EventData)
                 oFigure.EventData(iEvent) = PrepareEventData(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),100, 'Contour', oFigure.oParentFigure.SelectedEventID, oFigure.oParentFigure.SelectedBeat, []);
             elseif isempty(oFigure.EventData(iEvent).AverageAmplitude)
                 oFigure.EventData(iEvent) = PrepareEventData(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),100, 'Contour', oFigure.oParentFigure.SelectedEventID, oFigure.oParentFigure.SelectedBeat, []);
             end
         end
         
         function MapChannels(oFigure,src,event)
             oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).MapChannel(oFigure.oParentFigure.SelectedChannels,...
                 oFigure.oParentFigure.SelectedEventID,event.Values(1):event.Values(2));
             oFigure.PlotData(0);
         end
         
         function HideChannels(oFigure,src,event)
             oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).HideChannel(oFigure.oParentFigure.SelectedChannels,...
                 oFigure.oParentFigure.SelectedEventID,event.Values(1):event.Values(2));
             oFigure.PlotData(0);
         end
         
         function RearrangePlots(oFigure,aPlotNames)
             aChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             aSubPlots = aChildren;
             iCount = 1;             
             for i = 1:numel(aSubPlots)
                 if strcmp(get(aSubPlots(i),'type'),'axes')
                     aSubPlots(i) = oFigure.oDAL.oHelper.GetHandle(aChildren, char(aPlotNames{iCount}));
                     iCount = iCount + 1;
                     if iCount > numel(aPlotNames)
                         break
                     end
                 end
             end
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'children',aSubPlots);
         end
         
         function CreatePlots(oFigure)
             %Create the plots that will be used
             
             %Create a subplot in the position specified
             oMapPlot = axes('Position',oFigure.PlotPosition,'Tag', 'MapPlot','color','none');
             oSchematicOverLay = axes('Position',oFigure.PlotPosition,'xtick',[],'ytick',[],'Tag', 'SchematicOverLay','color','none');
             oPointsPlot = axes('Position',oFigure.PlotPosition,'xtick',[],'ytick',[],'Tag', 'PointsPlot','color','none');
             oHiddenPlot = axes('Position',oFigure.PlotPosition,'xtick',[],'ytick',[],'Tag', 'HiddenPlot','color','none');
         end
         
         function PlotData(oFigure,bUpdateColorBar)
             %Get the array of handles to the subplots that are children of
             %oPanel
             aSubPlots = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oMapPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'MapPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oMapPlot, 'Tag', 'MapPlot', 'NextPlot', 'replacechildren','color','none');
             cla(oMapPlot);
             
             %Do the same for the overlay
             oSchematicOverLay = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'SchematicOverLay');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oSchematicOverLay, 'Tag', 'SchematicOverLay', 'NextPlot', 'replacechildren');
             cla(oSchematicOverLay);
             
             %Do the same for the points plot
             oPointsPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'PointsPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oPointsPlot, 'Tag', 'PointsPlot', 'NextPlot', 'replacechildren');
             set(oPointsPlot, 'buttondownfcn', @(src, event) oHiddenAxes_Callback(oFigure, src, event));
             cla(oPointsPlot);
             
             %Do the same for the hidden plot
             oHiddenPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'HiddenPlot');
             %Rename it as this is deleted after each load and hide
             %ticks
             set(oHiddenPlot, 'Tag', 'HiddenPlot', 'NextPlot', 'replacechildren');
             set(oHiddenPlot, 'buttondownfcn', @(src, event) oHiddenAxes_Callback(oFigure, src, event));
             cla(oHiddenPlot);
             
             %plot the schematic if there is one
             if isfield(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oExperiment.(oFigure.BasePotentialFile(2:end)),'SchematicFilePath')
                 oFigure.PlotSchematic(oSchematicOverLay);
                 if isfield(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oExperiment.(oFigure.BasePotentialFile(2:end)),'AxisOffsets') && ...
                         isempty(oFigure.PlotLimits)
                     oFigure.PlotLimits = oFigure.oRootFigure.oGuiHandle.oOptical.oExperiment.Optical.AxisOffsets;
                 end
             end
             %                           oFigure.PlotLimits =  [-1.24,8.46;-0.23,9.47];
             
             %Call the appropriate plotting function
             switch (oFigure.PlotType)
                 case 'JustElectrodes'
                     oFigure.PlotElectrodes(oPointsPlot);
                     %Don't need a colorbar if the plot is just of
                     %electrodes
                     %check if there is an existing colour bar and delete it
                     %get figure children
                     oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                     oColorBar = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                     if oColorBar > 0
                         delete(oColorBar);
                         set(oMapPlot,'userdata',[]);
                         set(oMapPlot,'Position',oFigure.PlotPosition);
                     end
                     oTitle = get(oMapPlot,'Title');
                     set(oTitle,'String','');
                     axis(oMapPlot, 'on');
                 case 'Event2DContour'
                     oFigure.PlotEvent(oMapPlot,oPointsPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oPointsPlot);
                     end
                     oTitle = get(oMapPlot,'Title');
                     set(oTitle,'String','');
                 case 'Potential2DContour'
                     oFigure.PlotPotential(oMapPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oPointsPlot);
                     end
                 case 'CV2DScatter'
                     oFigure.PlotCV(oMapPlot,bUpdateColorBar);
                 case 'DeltaVm2DContour'
                     oFigure.PlotDeltaVm(oMapPlot,oPointsPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oPointsPlot);
                     end
                     oTitle = get(oMapPlot,'Title');
                     set(oTitle,'String','');
                 case 'Amplitude2DContour'
                     oFigure.PlotAmplitude(oMapPlot,oPointsPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oPointsPlot);
                     end
                     oTitle = get(oMapPlot,'Title');
                     set(oTitle,'String','');
                 case 'Difference2DContour'
                     oFigure.PlotAPD(oMapPlot,oPointsPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oPointsPlot);
                     end
                     oTitle = get(oMapPlot,'Title');
                     set(oTitle,'String','');
             end
             oFigure.PlotRegionRing(oMapPlot);
             %Reset the hiddenplot and overlay position in case mapplot has moved
             set(oPointsPlot,'Position',get(oMapPlot,'Position'));
             set(oSchematicOverLay,'Position',get(oMapPlot,'Position'));
             set(oHiddenPlot,'Position',get(oMapPlot,'Position'));
             %plot the reference points if needed
             if isempty(oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints)
                 %get the files
                 aFiles = oFigure.oRootFigure.oGuiHandle.oOptical.oDAL.oHelper.GetFiles();
                 oFigure.oRootFigure.oGuiHandle.oOptical.GetReferencePointLocations(aFiles);
             end
             
             dRes = oFigure.oRootFigure.oGuiHandle.oOptical.oExperiment.Optical.SpatialResolution;
             oPlot = oPointsPlot;
%              for n = 1:numel(oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints)
%                  hold(oPlot,'on');
%                  plot(oPlot,oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints(n).Line1(1:2)*dRes, ...
%                      oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints(n).Line1(3:4)*dRes, '-k','LineWidth', 2)
%                  plot(oPlot,oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints(n).Line2(1:2)*dRes, ...
%                      oFigure.oRootFigure.oGuiHandle.oOptical.ReferencePoints(n).Line2(3:4)*dRes, '-k','LineWidth', 2)
%                  hold(oPlot,'off');
%              end
             
             %Set the axis limits
             axis(oMapPlot, 'equal');
             set(oMapPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             if oFigure.AxesVisible
                 axis(oMapPlot, 'on');
             else
                 axis(oMapPlot, 'off');
             end
             %              set(oMapPlot,'xticklabel',{},'yticklabel',{});
             axis(oPointsPlot, 'equal');
             set(oPointsPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             axis(oHiddenPlot, 'equal');
             set(oHiddenPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));

             if oFigure.AxesVisible
                 axis(oPointsPlot, 'on');
                 axis(oHiddenPlot, 'on');
             else
                 axis(oPointsPlot, 'off');
                 axis(oHiddenPlot, 'off');
             end
             %              axes(oSchematicOverLay);
             %Refocus on HiddenPlot has this needs to be on the top to
             %receive user clicks.
             oFigure.RearrangePlots(oFigure.AxesOrder);
             axes(oHiddenPlot);
         end
         
         function ReplotElectrodes(oFigure)
             oFigure.PlotType = 'JustElectrodes';
             oFigure.PlotData();
         end
         
         function RefreshEventData(oFigure,varargin)
             oFigure.CheckEventData();
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             oFigure.CVSupportPoints = 24;
             if isempty(varargin)
                 %refresh the whole event data
                 oFigure.EventData(iEvent) = PrepareEventData(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),100, 'Contour', oFigure.oParentFigure.SelectedEventID, oFigure.oParentFigure.SelectedBeat, []);
             end
             %rerun the map creation
             switch (oFigure.PlotType)
                 case 'Event2DContour'
                     oFigure.EventData(iEvent) = GetEventMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
                 case 'DeltaVm2DContour' 
                     oFigure.EventData(iEvent) = GetDeltaVmMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
                 case 'Amplitude2DContour'
                     oFigure.EventData(iEvent) = GetAmplitudeMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent), oFigure.oParentFigure.SelectedBeat);
                 case 'CV2DScatter'
                     oFigure.EventData(iEvent) =  GetCVMap(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile),oFigure.EventData(iEvent),oFigure.CVSupportPoints,oFigure.oParentFigure.SelectedBeat);
             end
             %Plot a 2D activation map
             oFigure.PlotData(true);
         end
         
         function ParentFigureDeleted(oFigure,src, event)
             deleteme(oFigure);
         end
         
         function PlotElectrodes(oFigure,oMapAxes)
             %Plots the electrode locations on the map axes
             
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             
             %Get the electrodes
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             aCoords = cell2mat({oElectrodes(:).Coords});
             aAccepted = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                 oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes,'Accepted');
             aAcceptedCoords = aCoords(:,logical(aAccepted));
             aRejectedCoords = aCoords(:,~logical(aAccepted));
             %Get the number of channels
             [i NumChannels] = size(oElectrodes);
             %Loop through the electrodes plotting their locations
             
             %Plot the electrode point
             hold(oMapAxes,'on');
             %Just plotting the electrodes so add a text label
             scatter(oMapAxes, aRejectedCoords(1,:), aRejectedCoords(2,:),'r.', ...
                 'sizedata', 196);%1.5 for posters
             scatter(oMapAxes, aAcceptedCoords(1,:), aAcceptedCoords(2,:),'k.', ...
                 'sizedata', 196);%1.5 for posters
             if isfield(oElectrodes(1),'AxisPoint')
                 aAxisData = cell2mat({oElectrodes(:).AxisPoint});
                 oAxesElectrodes = oElectrodes(aAxisData);
                 if ~isempty(oAxesElectrodes)
                     aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
                     scatter(oMapAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
                         'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');
                     if numel(oAxesElectrodes) == 2
                         aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linewidth',2,'color','k');
                     end
                 end
             end
             if ~isempty(oFigure.oParentFigure.SelectedChannels)
                 scatter(oMapAxes, aCoords(1,oFigure.oParentFigure.SelectedChannels), aAcceptedCoords(2,oFigure.oParentFigure.SelectedChannels),'g.', ...
                 'sizedata', 100);%1.5 for posters
             end
             %Label the point with the channel name
             for i = 1:4:numel(oElectrodes)
                 oLabel = text(aCoords(1,i), aCoords(2,i) + 0.07, oElectrodes(i).Name);
                 set(oLabel,'FontWeight','bold','FontUnits','normalized');
                 set(oLabel,'FontSize',0.015);
                 set(oLabel,'parent',oMapAxes);
                 if ~oElectrodes(i).Accepted
                     %Just the label is red if the electrode is
                     %rejected
                     set(oLabel,'color','r');
                 end
                 
             end
             hold(oMapAxes,'off');
         end
         
         function PlotEvent(oFigure, oMapAxes, oPointAxes, bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             oEventData = oFigure.EventData(iEvent);
             %check if there is an existing colour bar
             %get figure children
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 %there might be a horizontal bar
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end
             aContourRange = oFigure.ColourBarLevels;
             aContourRange = 0:1.2:12;
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             %Assuming the potential field has been normalised.
             [C, oContour] = contourf(oMapAxes,oEventData.x,oEventData.y,oEventData.Beats(iBeat).z,aContourRange);
             set(oContour,'linewidth',1.5);
             caxis([aContourRange(1) aContourRange(end)]);
             colormap(oMapAxes, colormap(flipud(colormap(jet))));
             if oHandle < 0 
                 if oFigure.ColourBarVisible
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 end
             else
                 if ~oFigure.ColourBarVisible
                     % if the colour bar should not be visible then
                     % delete the existing one
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 elseif bUpdateColorBar
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 else
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'fontsize',12);
                     set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
                 end
             end
             
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             %              if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Origin')
             %                  %will have to change this if I have multiple signal
             %                  %events...
             if isfield(oElectrodes(1).aghsm,'Origin')
                 aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,'aghsm','Origin');
                 
                 aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oPointAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',1000,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 122 for posters
                 end
             end
             %              aEarlySites = find(oActivation.Beats(iBeat).FullActivationTimes == min(oActivation.Beats(iBeat).FullActivationTimes));
             %              aEarlyCoords =
             %              [oElectrodes(aEarlySites).Coords];
             %              scatter(oPointAxes, aEarlyCoords(1,:), aEarlyCoords(2,:), ...
             %                  'sizedata',12,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
             
             if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Exit')
                 %will have to change this if I have multiple signal
                 %events...
                 aExitData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,oFigure.oParentFigure.SelectedEventID,'Exit');
                 aCoords = cell2mat({oElectrodes(aExitData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','g');%size 6 for posters
                 end
             end
             %              if isfield(oElectrodes(1),'AxisPoint')
             %                  aAxisData = cell2mat({oElectrodes(:).AxisPoint});
             %                  oAxesElectrodes = oElectrodes(aAxisData);
             %                  if ~isempty(oAxesElectrodes)
             %                      aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
             %                      scatter(oMapAxes,aAxesCoords(1,:),aAxesCoords(2,:), ...
             %                          'sizedata',122,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');
             %                      if numel(oAxesElectrodes) == 2
             %                          aAxesLine = line(aAxesCoords(1,:),aAxesCoords(2,:),'linewidth',2,'color','k');
             %                          z = [1 2 3 4 5 6];
             %                          slabels = {'1','2','3','4','5','6'};
             %                          scatter(oMapAxes,((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2),...
             %                              ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2),'Marker','+',...
             %                              'sizedata',144,'MarkerEdgeColor','w');
             %                          text(((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2)+0.1,...
             %                              ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2)+0.1,slabels,'fontweight','bold','color','w');
             %                      end
             %                  end
             %              end
             hold(oMapAxes,'off');
             
             %              set(oMapAxes,'fontsize',8);
             %              set(oMapAxes,'ytick',1:5);
             %              set(get(oMapAxes,'ylabel'),'string','Length (mm)');
             %              set(oMapAxes,'ytick',[],'xtick',[]);
             %              oTitle = title(oMapAxes,sprintf('%d',iBeat));
             %              set(oTitle,'units','normalized');
             %              set(oTitle,'fontsize',22,'fontweight','bold');
         end
         
         function PlotAPD(oFigure, oMapAxes, oPointAxes, bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             oActivation = oFigure.EventData(iEvent);
             iEvent = oFigure.GetEventIndexFromID('ryhsm');
             oRepolarisation = oFigure.EventData(iEvent);
             %check if there is an existing colour bar
             %get figure children
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 %there might be a horizontal bar
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end
             aContourRange = oFigure.ColourBarLevels;
             aContourRange = 10:1.2:28;
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             
             oInterpolant = TriScatteredInterp(oActivation.DT,(oRepolarisation.Beats(iBeat).NonZeroedEventTimes-oActivation.Beats(iBeat).NonZeroedEventTimes)*1000);
             %evaluate interpolant
             oInterpolatedField = oInterpolant(oActivation.x,oActivation.y);
             %rearrange to be able to apply boundary
             aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
             %apply boundary
             aQZArray(~oActivation.Boundary) = NaN;
             %save result back in proper format
             aAPD  = reshape(aQZArray,size(oActivation.x,1),size(oActivation.x,2));
             
             %Assuming the potential field has been normalised.
             [C, oContour] = contourf(oMapAxes,oActivation.x,oActivation.y,aAPD,aContourRange);
             set(oContour,'linewidth',1.5);
             caxis([aContourRange(1) aContourRange(end)]);
             colormap(oMapAxes, colormap(flipud(colormap(jet))));
             if oHandle < 0 
                 if oFigure.ColourBarVisible
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 end
             else
                 if ~oFigure.ColourBarVisible
                     % if the colour bar should not be visible then
                     % delete the existing one
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 elseif bUpdateColorBar
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 else
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'fontsize',12);
                     set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
                 end
             end
             
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             %              if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Origin')
             %                  %will have to change this if I have multiple signal
             %                  %events...
             if isfield(oElectrodes(1).aghsm,'Origin')
                 aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,'aghsm','Origin');
                 
                 aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oPointAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',1000,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 122 for posters
                 end
             end
             
             if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Exit')
                 %will have to change this if I have multiple signal
                 %events...
                 aExitData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,oFigure.oParentFigure.SelectedEventID,'Exit');
                 aCoords = cell2mat({oElectrodes(aExitData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','g');%size 6 for posters
                 end
             end
             hold(oMapAxes,'off');
             
         end
         
         function PlotDeltaVm(oFigure, oMapAxes, oPointAxes, bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             oEventData = oFigure.EventData(iEvent);
             %check if there is an existing colour bar
             %get figure children
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 %there might be a horizontal bar
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end

             aContourRange = -30:1:30;%-2:0.1:2;%0:10:300;%
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             %Assuming the potential field has been normalised.
             [C, oContour] = contourf(oMapAxes,oEventData.x,oEventData.y,oEventData.Beats(iBeat).DeltaVmMap,aContourRange);
             set(oContour,'linewidth',1.5);
             caxis([aContourRange(1) aContourRange(end)]);
             colormap(oMapAxes, colormap(jet));
             if oHandle < 0 
                 if oFigure.ColourBarVisible
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 end
             else
                 if ~oFigure.ColourBarVisible
                     % if the colour bar should not be visible then
                     % delete the existing one
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 elseif bUpdateColorBar
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 else
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'fontsize',12);
                     set(oTitle,'string','DeltaVm (Vs)','position',[0.5 1.02]);
                 end
             end
             
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;

             if isfield(oElectrodes(1).aghsm,'Origin')
                 aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,'aghsm','Origin');
                 
                 aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oPointAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',1000,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 122 for posters
                 end
             end
             
             if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Exit')
                 %will have to change this if I have multiple signal
                 %events...
                 aExitData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,oFigure.oParentFigure.SelectedEventID,'Exit');
                 aCoords = cell2mat({oElectrodes(aExitData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','g');%size 6 for posters
                 end
             end
             hold(oMapAxes,'off');
         end
         
         function PlotAmplitude(oFigure, oMapAxes, oPointAxes, bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             oEventData = oFigure.EventData(iEvent);
             %check if there is an existing colour bar
             %get figure children
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 %there might be a horizontal bar
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end

             aContourRange = -0.6:0.05:0.2;%-20:1:20;%-5:0.2:2;%0:50:1000;%
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             %Assuming the potential field has been normalised.
             [C, oContour] = contourf(oMapAxes,oEventData.x,oEventData.y,oEventData.Beats(iBeat).AmplitudeMap,aContourRange);
             set(oContour,'linewidth',1.5);
             caxis([aContourRange(1) aContourRange(end)]);
             colormap(oMapAxes, colormap(jet));
             if oHandle < 0 
                 if oFigure.ColourBarVisible
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 end
             else
                 if ~oFigure.ColourBarVisible
                     % if the colour bar should not be visible then
                     % delete the existing one
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 elseif bUpdateColorBar
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                     oColorBar = oFigure.MakeColorBar(aContourRange, oFigure.ColourBarOrientation);
                 else
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'fontsize',12);
                     set(oTitle,'string','APA (a.u)','position',[0.5 1.02]);
                 end
             end
             
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             if oFigure.ElectrodeMarkerVisible
                 plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                     'MarkerSize',8,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for posters
             end

             if isfield(oElectrodes(1).aghsm,'Origin')
                 aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,'aghsm','Origin');
                 
                 aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oPointAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',1000,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 122 for posters
                 end
             end
             
             if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Exit')
                 %will have to change this if I have multiple signal
                 %events...
                 aExitData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                     oElectrodes,oFigure.oParentFigure.SelectedEventID,'Exit');
                 aCoords = cell2mat({oElectrodes(aExitData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                 if ~isempty(aCoords)
                     scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                         'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','g');%size 6 for posters
                 end
             end
             hold(oMapAxes,'off');
             
         end
         
         function PlotCV(oFigure,oMapAxes,bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
             idxCV = find(~isnan(oFigure.EventData(iEvent).Beats(iBeat).CVApprox));
             aCVdata = oFigure.EventData(iEvent).Beats(iBeat).CVApprox(idxCV);
             aCVdata(aCVdata > 1) = 1;

             scatter(oMapAxes,oFigure.EventData(iEvent).CVx(idxCV),oFigure.EventData(iEvent).CVy(idxCV),81,aCVdata,'filled');
             hold(oMapAxes, 'on');
             oQuivers = quiver(oMapAxes,oFigure.EventData(iEvent).CVx(idxCV),oFigure.EventData(iEvent).CVy(idxCV),oFigure.EventData(iEvent).Beats(iBeat).CVVectors(idxCV,1),oFigure.EventData(iEvent).Beats(iBeat).CVVectors(idxCV,2),'color','k','linewidth',0.6);
             % %              set(oQuivers,'autoscale','on');
             % %              set(oQuivers,'AutoScaleFactor',0.4);
             hold(oMapAxes, 'off');
             colormap(oMapAxes, colormap(jet));
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end
             oFigure.cbarmin = 0;
             oFigure.cbarmax = 1;
             caxis([oFigure.cbarmin oFigure.cbarmax]);
             if oHandle < 0 
                 if oFigure.ColourBarVisible
                     %if the colour bar should be visible then make
                     %a new one
                     oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):0.1:ceil(oFigure.cbarmax),oFigure.ColourBarOrientation);
                     oTitle = get(oColorBar, 'title');
                     if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',8);
                         set(oTitle,'string','Conduction Velocity (m/s)','position',[0.5 2.5]);
                     else
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',12);
                         set(oTitle,'string','Conduction Velocity (m/s)','position',[0.5 1.02]);
                     end
                 end
             else
                 if ~oFigure.ColourBarVisible
                     % if the colour bar should not be visible then
                     % delete the existing one
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                 elseif bUpdateColorBar
                     delete(oHandle);
                     set(oMapAxes,'userdata',[]);
                     set(oMapAxes,'Position',oFigure.PlotPosition);
                     oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):0.1:ceil(oFigure.cbarmax),oFigure.ColourBarOrientation);
                     oTitle = get(oColorBar, 'title');
                    if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',8);
                         set(oTitle,'string','Conduction Velocity (m/s)','position',[0.5 2.5]);
                     else
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',12);
                         set(oTitle,'string','Conduction Velocity (m/s)','position',[0.5 1.02]);
                     end
                 else
                     oTitle = get(oHandle, 'title');
                     set(oTitle,'units','normalized');
                     set(oTitle,'fontsize',12);
                     set(oTitle,'string','Conduction Velocity (m/s)','position',[0.5 1.02]);
                 end
             end
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                 oElectrodes,'aghsm','Origin');
             %              aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
             %              if ~isempty(aCoords)
             %                  scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
             %                          'sizedata',1000,'Marker','p','MarkerEdgeColor','k','MarkerFaceColor','w');%size 122 for posters
             %              end
             hold(oMapAxes,'off');
             %              set(oMapAxes,'fontsize',8);
             %              %              set(oMapAxes,'ytick',1:5);
             %              %              set(get(oMapAxes,'ylabel'),'string','Length (mm)');
             %              set(oMapAxes,'ytick',[],'xtick',[]);
             %              oTitle = title(oMapAxes,sprintf('%d',iBeat));
             %              set(oTitle,'units','normalized');
             %              set(oTitle,'fontsize',22,'fontweight','bold');
         end
         
         function PlotPotential(oFigure, oMapAxes, bUpdateColorBar)
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the selected beat
             iBeat = oFigure.oParentFigure.SelectedBeat;
             iEvent = oFigure.GetEventIndexFromID(oFigure.oParentFigure.SelectedEventID);
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
                         oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
                     end
                     if oHandle < 0 || bUpdateColorBar
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
                         oFigure.cbarmax = round(oFigure.cbarmax); 
                         oFigure.cbarmin = round(oFigure.cbarmin); %arbitrary
                     end
                     %Assuming the potential field has been normalised.
                     oFigure.cbarmax = 1;
                     oFigure.cbarmin = -0.1;
                     Difference = 0.05;
%                      Difference = (oFigure.cbarmax - oFigure.cbarmin)/60;
                     aContourRange = oFigure.cbarmin:Difference:oFigure.cbarmax;
                     set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
                     contourf(oMapAxes,oFigure.Potential.x(1,:),oFigure.Potential.y(:,1),oFigure.Potential.Beats(iBeat).Fields(iTimeIndex).z,aContourRange);
                     caxis([oFigure.cbarmin oFigure.cbarmax]);
                     colormap(oMapAxes, colormap(jet));
                     if oHandle < 0
                         if oFigure.ColourBarVisible
                             %if the colour bar should be visible then make
                             %a new one
                             oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], aContourRange,oFigure.ColourBarOrientation);
                             oTitle = get(oColorBar, 'title');
                             if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                                 set(oTitle,'units','normalized');
                                 set(oTitle,'fontsize',8);
                                 set(oTitle,'string','Potential (V)','position',[0.5 2.5]);
                             else
                                 set(oTitle,'units','normalized');
                                 set(oTitle,'fontsize',12);
                                 set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                             end
                         end
                     else
                         if ~oFigure.ColourBarVisible
                             % if the colour bar should not be visible then
                             % delete the existing one
                             delete(oHandle);
                             set(oMapAxes,'userdata',[]);
                             set(oMapAxes,'Position',oFigure.PlotPosition);
                         elseif bUpdateColorBar
                             delete(oHandle);
                             set(oMapAxes,'userdata',[]);
                             set(oMapAxes,'Position',oFigure.PlotPosition);
                             oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], aContourRange,oFigure.ColourBarOrientation);
                             oTitle = get(oColorBar, 'title');
                             if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                                 set(oTitle,'units','normalized');
                                 set(oTitle,'fontsize',8);
                                 set(oTitle,'string','Potential (V)','position',[0.5 2.5]);
                             else
                                 set(oTitle,'units','normalized');
                                 set(oTitle,'fontsize',12);
                                 set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                             end
                         else
                             oTitle = get(oHandle, 'title');
                             set(oTitle,'units','normalized');
                             set(oTitle,'fontsize',12);
                             set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                         end
                     end
                     %Reset the axes limits
                     set(oMapAxes,'XLim',oXLim,'YLim',oYLim);
                     iChannel = oFigure.oParentFigure.SelectedChannel;
                     %Get the electrodes
                     hold(oMapAxes,'on');
                     oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
                     if oFigure.ElectrodeMarkerVisible
                         plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                             'MarkerSize',8,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');
                     end
                     if isfield(oElectrodes(1).aghsm,'Origin')
                         %will have to change this if I have multiple signal
                         %events...
                         aOriginData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                             oElectrodes,'aghsm','Origin');%oFigure.oParentFigure.SelectedEventID
                         aCoords = cell2mat({oElectrodes(aOriginData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                         if ~isempty(aCoords)
                             scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
                                 'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
                         end
                         %                      else
                         %                          [C iFirstActivationChannel] = min(oFigure.Activation(iEvent).Beats(iBeat).FullActivationTimes);
                         %                          plot(oMapAxes, oElectrodes(iFirstActivationChannel).Coords(1), oElectrodes(iFirstActivationChannel).Coords(2), ...
                         %                              'MarkerSize',8,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
                     end
                     if isfield(oElectrodes(1).(oFigure.oParentFigure.SelectedEventID),'Exit')
                         %will have to change this if I have multiple signal
                         %events...
                         aExitData = MultiLevelSubsRef(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oDAL.oHelper,...
                             oElectrodes,oFigure.oParentFigure.SelectedEventID,'Exit');
                         aCoords = cell2mat({oElectrodes(aExitData(oFigure.oParentFigure.SelectedBeat,:)).Coords});
                         if ~isempty(aCoords)
%                              scatter(oMapAxes, aCoords(1,:), aCoords(2,:), ...
%                                  'sizedata',122,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','g');%size 6 for posters
                         end
                     end
%                      for i = 1:length(oElectrodes)
%                          if (oElectrodes(i).Accepted) && (oElectrodes(i).(oFigure.oParentFigure.SelectedEventID).Index(iBeat) <= iTimeIndex)
%                              plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.', ...
%                                  'MarkerSize',18,'color','k');
%                          elseif ~oElectrodes(i).Accepted
%                              plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), '.', ...
%                                  'MarkerSize',18,'color','r');
%                          end
%                      end
                     
                     hold(oMapAxes,'off');
             end
             oTitle = title(oMapAxes,sprintf('Potential Field for time %5.5f s',oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).TimeSeries(...
                 oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Beats.Indexes(iBeat,1)+iTimeIndex)));
             set(oTitle,'fontsize',14,'fontweight','bold');
         end
         
         function PlotSchematic(oFigure, oAxes)
             %use schematic with guide
             sFilePath = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).oExperiment.(oFigure.BasePotentialFile(2:end)).SchematicFilePath;
%                           sGuideFile = 'D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\20140723Schematic_rotated_highres.bmp';
                          sGuideFile = strrep(sFilePath, '.bmp', '_guide.bmp');
                          oImage = imshow(sGuideFile,'Parent', oAxes, 'Border', 'tight');
%              oImage = imshow(sFilePath,'Parent', oAxes, 'Border', 'tight');
             %make it transparent in the right places
             aCData = get(oImage,'cdata');
             aBlueData = aCData(:,:,3);
             aAlphaData = aCData(:,:,3);
             aAlphaData(aBlueData < 100) = 1;
             aAlphaData(aBlueData > 100) = 1;
             aAlphaData(aBlueData == 100) = 0;
             aAlphaData = double(aAlphaData);
             set(oImage,'alphadata',aAlphaData);
             set(oAxes,'box','off','color','none');
             axis(oAxes,'tight');
             axis(oAxes,'off');
         end
         
         function oColorBar = MakeColorBar(oFigure, aContourRange, sColourBarOrientation)
             %make a new one
             oColorBar = cbarf([aContourRange(1) aContourRange(end)], aContourRange, sColourBarOrientation);
             oTitle = get(oColorBar, 'title');
             switch (oFigure.PlotType)
                 case 'Event2DContour'
                     sString = 'Time (ms)';
                 case 'DeltaVm2DContour'
                     sString = 'DeltaVm (Vs)';
                 case 'Amplitude2DContour'
                     sString = 'APA (a.u)';
                 case 'Difference2DContour'
                     sString = 'APD (ms)';
             end
             if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                 set(oTitle,'units','normalized');
                 set(oTitle,'fontsize',8);
                 set(oTitle,'string',sString,'position',[0.5 2.5]);
             else
                 set(oTitle,'units','normalized');
                 set(oTitle,'fontsize',12);
                 set(oTitle,'string',sString,'position',[0.5 1.02]);
             end
         end
         
         function iIndex = GetEventIndexFromID(oFigure,sEventID)
             %return the index for this event
             aIndices = ismember(oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes(1).SignalEvents,sEventID);
             iIndex = find(aIndices);
         end

         function PlotRegionRing(oFigure, oMapAxes)
             iChannel = oFigure.oParentFigure.SelectedChannel;
             %Get the electrodes and plot the selected electrode
             %and the electrode with the earliest activation
             dDiameter = [0.5;1.0];
             hold(oMapAxes,'on');
             oElectrodes = oFigure.oRootFigure.oGuiHandle.(oFigure.BasePotentialFile).Electrodes;
             if oFigure.ElectrodeMarkerVisible
                 plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                     'MarkerSize',8,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for posters
                 th = 0:pi/50:2*pi;
                 xunit = dDiameter * cos(th) + repmat(oElectrodes(iChannel).Coords(1),size(dDiameter,1),size(th,2));
                 yunit = dDiameter * sin(th) + repmat(oElectrodes(iChannel).Coords(2),size(dDiameter,1),size(th,2));
                 for ii = 1:size(xunit,1)
                     plot(oMapAxes,xunit(ii,:),yunit(ii,:),'k','linewidth',1.5);
                 end
             end
             hold(oMapAxes,'off');
         end
     end
end
