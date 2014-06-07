classdef MapElectrodes < SubFigure
    %   MapElectrodes.    
    
    properties
        SelectedChannels;
        Overlay = 0;
        ElectrodeMarkerVisible = 1;
        ColourBarVisible = 1;
        ColourBarOrientation = 'vert';
        Potential = [];
        Activation = [];
        CV = [];
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
            set(oFigure.oGuiHandle.oActContourMenu, 'callback', @(src, event) oActContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oActAverageMenu, 'callback', @(src, event) oActAverageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) oMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oReplotMenu, 'callback', @(src, event) oReplotMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOverlayMenu, 'callback', @(src, event) oOverlayMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMapMenu, 'callback', @(src, event) oSaveMapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportToTextMenu, 'callback', @(src, event) oExportToTextMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPotContourMenu, 'callback', @(src, event) oPotContourMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oCVScatterMenu, 'callback', @(src, event) oCVScatterMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRefreshActivationMenu, 'callback', @(src, event) oRefreshActivationMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oMontageMenu, 'callback', @(src, event) oMontageMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToggleColourBarMenu, 'callback', @(src, event) oToggleColourBarMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToggleElectrodeMarkerMenu, 'callback', @(src, event) oToggleElectrodeMarkerMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oRotateArrayMenu, 'callback', @(src, event) oRotateArrayMenu_Callback(oFigure, src, event));

            
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
            oFigure.PlotLimits = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.GetSpatialLimits()+[-0.1,0.1;-0.1,0.1];
            %Plot the electrodes
            oFigure.CreatePlots();
            oFigure.PlotData();
            %Set default selection
            oFigure.SelectedChannels = 1:length(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes);
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
%                         Save individual beat activation time
%                         iBeat = oFigure.oParentFigure.SelectedBeat;
%                         sLongDataFileName=strcat(sPathName,sFilename,'.bmp');
%                         oFigure.PrintFigureToFile(sLongDataFileName);
%                         sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s',sLongDataFileName)});
%                         sChopString = strcat(sChopString, {' -gravity South -chop 0x50 -gravity West -chop 50x0 -gravity East -chop 50x0'}, {sprintf(' %s',sLongDataFileName)});
%                         sStatus = dos(char(sChopString{1}));
                        
            %Save series of potential fields
%             iBeat = oFigure.oParentFigure.SelectedBeat;
%             oFigure.PlotType = 'Potential2DContour';
%             for i = 1:length(oFigure.Potential.Beats(iBeat).Fields)
%                 %Get the full file name and save it to string attribute
%                 sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
%                 oFigure.oParentFigure.SelectedTimePoint = i;
%                 oFigure.PlotData();
%                 drawnow; pause(.2);
%                 oFigure.PrintFigureToFile(sLongDataFileName);
%             end
            
%                         %Save series of activation maps
            
            %             for i =
            %             1:size(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperunits','inches');
            iStartBeat = oFigure.oParentFigure.SelectedBeat;
            %Set figure size
            iMontageX = 5;%5
            iMontageY = 9;%9
            dMontageWidth = 8.27 - 2; %in inches, with borders
            dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
            dWidth = dMontageWidth/iMontageX; %in inches
            dHeight = dMontageHeight/iMontageY; %in inches
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperposition',[0 0 dWidth dHeight])
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'papersize',[dWidth dHeight])
            aSubPlots = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
            oMapPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'MapPlot');
            oHiddenPlot = oFigure.oDAL.oHelper.GetHandle(aSubPlots, 'HiddenPlot');
            axis(oMapPlot,'on');
            axis(oHiddenPlot,'off');
            set(oMapPlot,'units','normalized');
            set(oMapPlot,'outerposition',[0 0 1 1]);
            aTightInset = get(oMapPlot, 'TightInset');
            aPosition(1) = aTightInset(1);
            aPosition(2) = aTightInset(2);
            aPosition(3) = 1-aTightInset(1)-aTightInset(3);
            aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
            set(oMapPlot, 'Position', aPosition);
            sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',oFigure.oParentFigure.SelectedBeat),'.bmp');
            oFigure.PlotData(0);
            drawnow; pause(.2);
            
            
            set(oMapPlot,'FontUnits','points');
            set(oMapPlot,'FontSize',6);
            aYticks = get(oMapPlot,'ytick');
            aYticks = aYticks - aYticks(1);
            aYtickstring = cell(length(aYticks),1);
            for i=1:length(aYticks)
                %Check if the label has a decimal place and hide this label
                if ~mod(aYticks(i),1) == 0
                    aYtickstring{i} = '';
                else
                    aYtickstring{i} = num2str(aYticks(i));
                end
            end
            set(oMapPlot,'xticklabel',[]);
            set(oMapPlot,'xtickmode','manual');
            set(oMapPlot,'yticklabel', char(aYtickstring));
            set(oMapPlot,'ytickmode','manual');
            set(oMapPlot,'Box','off');
            oXLim = get(oMapPlot,'xlim');
            oYLim = get(oMapPlot,'ylim');
            oBeatLabel = text(oXLim(1)+0.1,oYLim(2)-0.5, sprintf('%d',oFigure.oParentFigure.SelectedBeat));
            set(oBeatLabel,'units','normalized');
            set(oBeatLabel,'fontsize',14,'fontweight','bold');
            set(oBeatLabel,'parent',oMapPlot);
            oFigure.PrintFigureToFile(sLongDataFileName);
            
            for i = oFigure.oParentFigure.SelectedBeat+1:min(size(oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(1).Processed.BeatIndexes,1),oFigure.oParentFigure.SelectedBeat+iMontageX*iMontageY-1)
                %Get the full file name and save it to string attribute
                sLongDataFileName=strcat(sPathName,sFilename,sprintf('%d',i),'.bmp');
                oFigure.oParentFigure.SelectedBeat = i;
                oFigure.PlotData(0);
                drawnow; pause(.2);
                oBeatLabel = text(oXLim(1)+0.1,oYLim(2)-0.5, sprintf('%d',i));
                set(oBeatLabel,'units','normalized');
                set(oBeatLabel,'fontsize',14,'fontweight','bold');
                set(oBeatLabel,'parent',oMapPlot);
                axis(oMapPlot, 'off');
                
                oFigure.PrintFigureToFile(sLongDataFileName);
            end
            %reset the beat to what was originally selected
            oFigure.oParentFigure.SelectedBeat = iStartBeat;
        end
        
        % -----------------------------------------------------------------
        function oMontageMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            [sFileName,sPathName]=uigetfile('*.*','Select image file(s)','multiselect','on');
            %Make sure the dialogs return char objects
            if iscell(sFileName)
                if (~ischar(sFileName{1}) && ~ischar(sPathName))
                    return
                end
                sDosString = 'D:\Users\jash042\Documents\PhD\Analysis\Utilities\montage.exe ';
                for i = 1:length(sFileName)
                    %Loop through files adding them to list
                    sDosString = strcat(sDosString, {sprintf(' %s%s',sPathName,char(sFileName{i}))});
                end
                iMontageX = 5;%5
                iMontageY = 9;%9
                dMontageWidth = 8.27 - 2; %in inches, with borders
                dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
                dWidth = dMontageWidth/iMontageX; %in inches
                dHeight = dMontageHeight/iMontageY; %in inches
                iPixelWidth = dWidth*300;
                iPixelHeight = dHeight*300;
                sDosString = strcat(sDosString, {' -quality 98 -tile '},{sprintf('%d',iMontageX)},'x',{sprintf('%d',iMontageY)},{' -geometry '},{sprintf('%d',iPixelWidth)},'x',{sprintf('%d',iPixelHeight)},{'+0+0 '}, sPathName, 'montage.png');

            else
                if (~ischar(sFileName) && ~ischar(sPathName))
                    return
                end
            end
            sStatus = dos(char(sDosString{1}));
            if ~sStatus
%                 figure();
%                 disp(char(sDosString));
%                 imshow(strcat(sPathName, 'montage.png'));
            end
            oFigure.ColourBarVisible = true;
            oFigure.ColourBarOrientation = 'horiz';

            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperunits','inches');
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'paperposition',[0 0 dMontageWidth dMontageHeight]);
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),'papersize',[dMontageWidth dMontageHeight]);

            oFigure.PlotData(0);
            switch (oFigure.PlotType)
                case 'Activation2DContour'
                    sSaveCbarFilePath = fullfile(sPathName,'ATcolorbar.bmp');
                    sSaveFilePath = fullfile(sPathName,'ATmontage_cbar.png');
                case 'CV2DScatter'
                    sSaveCbarFilePath = fullfile(sPathName,'CVcolorbar.bmp');
                    sSaveFilePath = fullfile(sPathName,'CVmontage_cbar.png');
            end
            aPathFolders = regexp(sPathName,'\\','split');
            sFigureTitle = char(aPathFolders{end-1});
            oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
            oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
            oFigureTitle = text('string', sFigureTitle, 'parent', oHandle);
            set(oFigureTitle, 'units', 'normalized');
            set(oFigureTitle,'fontsize',12, 'fontweight', 'bold');
            set(oFigureTitle, 'position', [0 3.2]);
            oFigure.PrintFigureToFile(sSaveCbarFilePath);
            sChopString = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveCbarFilePath)}, ...
                {' -gravity North -chop 0x2180'},{' -gravity South -chop 0x100'}, {sprintf(' %s', sSaveCbarFilePath)});
            sStatus = dos(char(sChopString{1}));
            
            sAppend = strcat('D:\Users\jash042\Documents\PhD\Analysis\Utilities\convert.exe', {sprintf(' %s', sSaveCbarFilePath)}, ...
                {sprintf(' %s', sPathName)}, 'montage.png',{' -append'}, {sprintf(' %s', sSaveFilePath)});
            sStatus = dos(char(sAppend{1}));
        end
        
        function oRotateArrayMenu_Callback(oFigure, src, event)
            %Calls a function to rotate the array
            oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.RotateArray();
            oFigure.Activation = [];
            oFigure.PlotPosition = [0.05 0.05 0.88 0.88];
            oFigure.PlotLimits = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.GetSpatialLimits()+[-0.1,0.1;-0.1,0.1];
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
                    case 'Activation2DContour'
                        %Export the activation data
                    case 'CV2DScatter'
                        %Export the CV data
                        idxCV = find(~isnan(oFigure.Activation.Beats(1).CVApprox));
                        %Need to update if I have multiple events I want to
                        %write out 
                        aRowHeader = cell2mat({oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(idxCV).Name});
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
            if strcmp(oFigure.PlotType,'Potential2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Potential2DContour';
                bUpdateColorBar = 1;
            end

            %Plot a potential contour map
            oFigure.PlotData(bUpdateColorBar);
        end
        
        function oActContourMenu_Callback(oFigure, src, event)
            %Generate activation map for the current beat
            
            %Check if the activation data needs to be prepared
            if isempty(oFigure.Activation)
                oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(100, 'Contour', oFigure.oParentFigure.SelectedEventID);
            end
            
            %Update the plot type
            if strcmp(oFigure.PlotType,'Activation2DContour')
                bUpdateColorBar = 0;
            else
                oFigure.PlotType = 'Activation2DContour';
                bUpdateColorBar = 1;
            end
            %Plot a 2D activation map
            oFigure.PlotData(bUpdateColorBar);
        end
       
        function oCVScatterMenu_Callback(oFigure, src, event)
            %Generate conduction velocity map for the current beat
            
            %Check if the conduction velocity data needs to be prepared
            if isempty(oFigure.Activation)
                oFigure.Activation = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.PrepareActivationMap(100, 'Scatter',oFigure.oParentFigure.SelectedEventID);
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
            
            oFigure.PlotData(0);
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
                case 'Activation2DContour'
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
         
         function PlotData(oFigure,bUpdateColorBar)
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
                     axis(oMapPlot, 'on');
                 case 'Activation2DContour'
                     oFigure.PlotActivation(oMapPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oMapPlot);
                     end
                 case 'Potential2DContour'
                     oFigure.PlotPotential(oMapPlot,bUpdateColorBar);
                     if oFigure.Overlay
                         oFigure.PlotElectrodes(oMapPlot);
                     end
                 case 'CV2DScatter'
                     oFigure.PlotCV(oMapPlot,bUpdateColorBar);
             end
             %Reset the hiddenplot position in case mapplot has moved
             set(oHiddenPlot,'Position',get(oMapPlot,'Position'));
             %Set the axis limits
             axis(oMapPlot, 'equal');
             set(oMapPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             %              axis(oMapPlot, 'off');
             %              set(oMapPlot,'xticklabel',{},'yticklabel',{});
             axis(oHiddenPlot, 'equal');
             set(oHiddenPlot,'xlim',oFigure.PlotLimits(1,:),'ylim',oFigure.PlotLimits(2,:));
             %              axis(oHiddenPlot, 'off');
             
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
             oFigure.PlotData(0);
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
                     plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), 'k.', ...
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
                             'MarkerSize', 14);%1.5 for posters
                     else
                         %else just plot black
                         plot(oMapAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2),'k.', ...
                             'MarkerSize', 14);%1.5 for posters
                     end
                 end
             end
             
             if strcmpi(oFigure.PlotType,'JustElectrodes')
                 %Don't need a colorbar if the plot is just of electrodes
                 %check if there is an existing colour bar and delete it
                 %get figure children
                 oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
                 oColorBar = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
                 if oColorBar < 0
                     oColorBar = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
                 end
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
         
         function PlotActivation(oFigure, oMapAxes, bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             
             %check if there is an existing colour bar
             %get figure children
             oChildren = get(oFigure.oGuiHandle.(oFigure.sFigureTag),'children');
             oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_vertical_linear');
             if oHandle < 0
                 %there might be a horizontal bar
                 oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
             end
             if oHandle < 0 || bUpdateColorBar
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
                 %Might need to change this if I start analysing pacing
                 %data but at the moment sinus will always start at 0.
             end
             
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             %Assuming the potential field has been normalised.
             [C, oContour] = contourf(oMapAxes,oFigure.Activation.x,oFigure.Activation.y,oFigure.Activation.Beats(iBeat).z,floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
             caxis([oFigure.cbarmin oFigure.cbarmax]);
             colormap(oMapAxes, colormap(flipud(colormap(jet))));
             if oHandle < 0
                 if oFigure.ColourBarVisible
                     %if the colour bar should be visible then make
                     %a new one
                     oColorBar = cbarf([0 oFigure.cbarmax], 0:1:ceil(oFigure.cbarmax),oFigure.ColourBarOrientation);
                     oTitle = get(oColorBar, 'title');
                     if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',8);
                         set(oTitle,'string','Activation Time (ms)','position',[0.5 2.5]);
                     else
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',12);
                         set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
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
                     oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax),oFigure.ColourBarOrientation);
                     oTitle = get(oColorBar, 'title');
                     if strcmpi(oFigure.ColourBarOrientation, 'horiz')
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',8);
                         set(oTitle,'string','Activation Time (ms)','position',[0.5 2.5]);
                     else
                         set(oTitle,'units','normalized');
                         set(oTitle,'fontsize',12);
                         set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
                     end
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
             oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
             if oFigure.ElectrodeMarkerVisible
                 plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                     'MarkerSize',6,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for posters
             end
             [C iFirstActivationChannel] = min(oFigure.Activation.Beats(iBeat).FullActivationTimes);
             plot(oMapAxes, oElectrodes(iFirstActivationChannel).Coords(1), oElectrodes(iFirstActivationChannel).Coords(2), ...
                 'MarkerSize',6,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
             hold(oMapAxes,'off');
             
             %              set(oMapAxes,'fontsize',8);
             %              set(oMapAxes,'ytick',1:5);
             %              set(get(oMapAxes,'ylabel'),'string','Length (mm)');
             %              set(oMapAxes,'ytick',[],'xtick',[]);
             %              oTitle = title(oMapAxes,sprintf('%d',iBeat));
             %              set(oTitle,'units','normalized');
             %              set(oTitle,'fontsize',22,'fontweight','bold');
         end
         
         function PlotCV(oFigure,oMapAxes,bUpdateColorBar)
             %Plots a map of non-intepolated activation times
             %Make sure the current figure is MapElectrodes
             set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
             %Get the beat number from the slide control
             iBeat = oFigure.oParentFigure.SelectedBeat;
             set(oFigure.oGuiHandle.(oFigure.sFigureTag),'currentaxes',oMapAxes);
             idxCV = find(~isnan(oFigure.Activation.Beats(iBeat).CVApprox));
             aCVdata = oFigure.Activation.Beats(iBeat).CVApprox(idxCV);
             aCVdata(aCVdata > 1) = 1;
             scatter(oMapAxes,oFigure.Activation.CVx(idxCV),oFigure.Activation.CVy(idxCV),12,aCVdata,'filled');
             hold(oMapAxes, 'on');
             oQuivers = quiver(oMapAxes,oFigure.Activation.CVx(idxCV),oFigure.Activation.CVy(idxCV),oFigure.Activation.Beats(iBeat).CVVectors(idxCV,1),oFigure.Activation.Beats(iBeat).CVVectors(idxCV,2),'color','k','linewidth',0.6);
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
             oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
             if oFigure.ElectrodeMarkerVisible
                 plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                     'MarkerSize',6,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');%size 6 for posters
             end
             [C iFirstActivationChannel] = min(oFigure.Activation.Beats(iBeat).FullActivationTimes);
             plot(oMapAxes, oElectrodes(iFirstActivationChannel).Coords(1), oElectrodes(iFirstActivationChannel).Coords(2), ...
                 'MarkerSize',6,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','w');%size 6 for posters
             hold(oMapAxes,'off');
             %              set(oMapAxes,'fontsize',8);
             %              %              set(oMapAxes,'ytick',1:5);
             %              %              set(get(oMapAxes,'ylabel'),'string','Length (mm)');
             %              set(oMapAxes,'ytick',[],'xtick',[]);
             %              oTitle = title(oMapAxes,sprintf('%d',iBeat));
             %              set(oTitle,'units','normalized');
             %              set(oTitle,'fontsize',22,'fontweight','bold');
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
                         oHandle = oFigure.oDAL.oHelper.GetHandle(oChildren,'cbarf_horiz_linear');
                     end
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
                         if oFigure.ColourBarVisible
                             %if the colour bar should be visible then make
                             %a new one
                             oColorBar = cbarf([oFigure.cbarmin oFigure.cbarmax], floor(oFigure.cbarmin):1:ceil(oFigure.cbarmax));
                             oTitle = get(oColorBar, 'title');
                             set(oTitle,'units','normalized');
                             set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                         end
                     else
                         if ~oFigure.ColourBarVisible
                             % if the colour bar should not be visible then
                             % delete the existing one
                             delete(oHandle);
                             set(oMapAxes,'userdata',[]);
                             set(oMapAxes,'Position',oFigure.PlotPosition);
                         else
                             oTitle = get(oHandle, 'title');
                             set(oTitle,'units','normalized');
                             set(oTitle,'string','Potential (V)','position',[0.5 1.02]);
                         end
                     end
                     %Reset the axes limits
                     set(oMapAxes,'XLim',oXLim,'YLim',oYLim);
                     iChannel = oFigure.oParentFigure.SelectedChannel;
                     %Get the electrodes
                     hold(oMapAxes,'on');
                     oElectrodes = oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes;
                     if oFigure.ElectrodeMarkerVisible
                         plot(oMapAxes, oElectrodes(iChannel).Coords(1), oElectrodes(iChannel).Coords(2), ...
                             'MarkerSize',18,'Marker','o','MarkerEdgeColor','w','MarkerFaceColor','k');
                     end
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
             oTitle = title(oMapAxes,sprintf('Potential Field for time %5.5f s',oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries(...
                 oFigure.oParentFigure.oParentFigure.oGuiHandle.oUnemap.Electrodes(iChannel).Processed.BeatIndexes(iBeat,1)+iTimeIndex)));
             set(oTitle,'fontsize',20,'fontweight','bold');
         end
     end
end
