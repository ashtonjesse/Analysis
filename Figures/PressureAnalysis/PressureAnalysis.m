classdef PressureAnalysis < SubFigure
% PressureAnalysis Summary of this class goes here

    properties
        DefaultPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\';
        Plots = [];
        CurrentZoomLimits = [];
        SelectedExperiments = [];
        Colours = ['k','r','b','g','c'];
        CurrentPlotNumber = 0;
        SelectedElectrode;
    end
    
    events
        FigureDeleted;
    end
    
    methods
        %% Constructor
        function oFigure = PressureAnalysis(oParent)
            oFigure = oFigure@SubFigure(oParent,'PressureAnalysis',@OpeningFcn);
                        
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oResampleMenu, 'callback', @(src, event) oResampleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateToUnemapMenu, 'callback', @(src, event) oTruncateToUnemapMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateMenu, 'callback', @(src, event) oTruncateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenSingleMenu, 'callback', @(src, event) oOpenSingleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMultiMenu, 'callback', @(src, event) oOpenMultiMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportMenu, 'callback', @(src, event) oExportMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTimeAlignMenu, 'callback', @(src, event) oTimeAlignMenu_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.cb1, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb2, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb3, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb4, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb5, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.oChannelSelector, 'callback', @(src, event) oChannelSelector_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
           
            %Turn zoom on for this figure
            set(oFigure.oZoom,'enable','on');
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            
            %set up the checkboxes and plots
            sPlotNames = {'Pressure','Reference Signal', 'Unemap Reference Signal', 'Phrenic Integral', 'Electrode', 'Heart Rate', };
            for i = 1:length(sPlotNames)
                oFigure.Plots(i).ID = 0;
                oFigure.Plots(i).Visible = 0;
                oFigure.Plots(i).Name = char(sPlotNames(i));
                oFigure.Plots(i).Checkbox = uicontrol(oFigure.oGuiHandle.oPlotPanel, 'style', 'checkbox', 'string', oFigure.Plots(i).Name, 'position', [3 18-(i-1)*1.875, 34, 1.75], 'callback',  ...
                    @(src, event) oPlotSelector_Callback(oFigure, src, event), 'value', 0, 'visible', 'off','units','characters');
            end
            
            if ~isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %Plot the data
                for i = 1:length(oFigure.Plots)
                    set(oFigure.Plots(i).Checkbox,'visible','on');
                end
                set(oFigure.Plots(1).Checkbox,'value', 1,'visible', 'on');
                oFigure.Plots(1).Visible = 1;
                oFigure.Replot();
            end
            
            sString = oFigure.GetPopUpSelectionString('oChannelSelector');
            oFigure.SelectedElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName(sString);
            
            % --- Executes just before BaselineCorrection is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)

                %Set the output attribute
                aChannelNames = {oParent.oGuiHandle.oUnemap.Electrodes(:).Name};
                set(handles.oChannelSelector,'string',aChannelNames);
                handles.output = hObject;
                %Update the gui handles
                guidata(hObject, handles);
            end
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function deleteme(oFigure)
            notify(oFigure,'FigureDeleted');
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
        function oChannelSelector_Callback(oFigure, src, event)
            %Plot the selected electrode
            sString = oFigure.GetPopUpSelectionString('oChannelSelector');
            oFigure.SelectedElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName(sString);
            oPlot = oFigure.GetPlotByName('Electrode');
            if ~isempty(oPlot)
                cla(oPlot.ID);
                oFigure.PlotElectrode(oPlot.ID, oFigure.SelectedElectrode);
                set(oPlot.ID,'xminortick','off');
                xlabel(oPlot.ID,'');
                set(oPlot.ID,'xticklabel',[]);
                xlim(oPlot.ID,get(oFigure.Plots(1).ID,'xlim'));
            end
            
        end
        
        function oPlot = GetPlotByName(oFigure, sPlotName)
            %Get plot names
            aPlotNames = {oFigure.Plots(:).Name};
            aIndex = strcmpi(aPlotNames, sPlotName);
            oPlot = oFigure.Plots(aIndex);
        end
        
        function oSelection_Callback(oFigure, src, event)
            %Reset the selected experiments
            oFigure.SelectedExperiments = [];
            %Loop through the checkboxes and check their value
            for i = 1:5
                dValue = get(oFigure.oGuiHandle.(sprintf('cb%d',i)),'value');
                dVisible = get(oFigure.oGuiHandle.(sprintf('cb%d',i)),'visible');
                if dValue && strcmp(dVisible,'on')
                    oFigure.SelectedExperiments = [oFigure.SelectedExperiments , i];
                end
            end
        end
        
        function oPlotSelector_Callback(oFigure, src, event)
            %Work out which check box fired this and recreate the plots
            
            %Get the value of the checkbox
            dIndex = find([oFigure.Plots(:).Checkbox] == src);
            if ~isempty(dIndex)
                %check if the selection corresponds to 'Electrode'
                if dIndex == find(strcmp({oFigure.Plots(:).Name},'Electrode'))
                    if get(src, 'value')
                        set(oFigure.oGuiHandle.oChannelSelector,'visible', 'on');
                    else
                        set(oFigure.oGuiHandle.oChannelSelector,'visible', 'off');
                    end
                end
                %update the visibility of this plot
                oFigure.Plots(dIndex).Visible = get(src, 'Value');
                oFigure.Replot();
                
            end
        end
        
        % --------------------------------------------------------------------
        function PostZoom_Callback(oFigure, src, event)
            %Synchronize the zoom of all the axes
            
            %Get the current axes and selected limit
            oCurrentAxes = event.Axes;
            oXLim = get(oCurrentAxes,'XLim');
            oYLim = get(oCurrentAxes,'YLim');
            oFigure.CurrentZoomLimits = [oXLim ; oYLim];
            %Apply to axes
            dIndex = find([oFigure.Plots(:).ID] == oCurrentAxes);
            %get copy of plots
            oPlots = oFigure.Plots;
            oPlots(dIndex) = [];
            for i = 1:length(oPlots)
                if oPlots(i).Visible
                    set(oPlots(i).ID,'XLim',oXLim);
                end
            end
        end
        
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end    
        
                % -----------------------------------------------------------------
        function oExportMenu_Callback(oFigure, src, event)
            %Get the save file path
            %Call built-in file dialog to select filename
            [sFilename, sPathName] = uiputfile('','Specify a directory to save to');
            %Make sure the dialogs return char objects
            if (~ischar(sFilename) && ~ischar(sPathName))
                return
            end
            
            %Get the full file name and save it to string attribute
            sLongDataFileName=strcat(sPathName,sFilename);
           
            oFigure.PrintFigureToFile(sLongDataFileName);
           
        end
        
        function oOpenMultiMenu_Callback(oFigure, src, event)
            %Open a multiple pressure files
            
            %  Call built-in file dialog to select filename
            sDataPathName=uigetdir(oFigure.DefaultPath,'Select a folder containing Pressure data.');
            %Make sure the dialogs return char objects
            if ~ischar(sDataPathName)
                return
            end
            
            %Get all the labview derived files txt in the directory
            aFileFull = fGetFileNamesOnly(sDataPathName,'lb*.txt');
            
            if ~isempty(aFileFull)
                %If there are txt files in this directory then load
                %them
                if isfield(oFigure.oParentFigure.oGuiHandle,'oPressure')
                    %Append a new pressure entity to that already
                    %existing
                    oFigure.oParentFigure.oGuiHandle.oPressure = [oFigure.oParentFigure.oGuiHandle.oPressure ; Pressure()];
                    for i = 1:length(aFileFull)
                        oFigure.oParentFigure.oGuiHandle.oPressure(end) =  GetPressureFromTXTFile(oFigure.oParentFigure.oGuiHandle.oPressure(end),char(aFileFull(i)));
                    end
                else
                    %Create a new pressure entity
                    oFigure.oParentFigure.oGuiHandle.oPressure = Pressure();
                    for i = 1:length(aFileFull)
                        oFigure.oParentFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(oFigure.oParentFigure.oGuiHandle.oPressure,char(aFileFull(i)));
                    end
                end
                
            else
                %There are no txt in this directory files
                return
            end
            
            %Plot the data
            for i = 1:length(oFigure.Plots)
                set(oFigure.Plots(i).Checkbox,'visible','on');
            end
            set(oFigure.Plots(1).Checkbox,'value', 1);
            oFigure.Plots(1).Visible = 1;
            oFigure.Replot();
        end
        
        function oFigure = oOpenSingleMenu_Callback(oFigure, src, event)
            %Open a single pressure file
            
            if isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %  Call built-in file dialog to select filename
                [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing Pressure data',oFigure.DefaultPath);
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                    return
                end
                %Check the extension
                sLongDataFileName=strcat(sDataPathName,sDataFileName);
                %                 sLongDataFileName = 'D:\Users\jash042\Documents\PhD\Analysis\Database\20130221\pbaropacetest004_pressure.mat';
                [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
                switch (ext)
                    case '.txt'
                        oFigure.oParentFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(Pressure,sLongDataFileName);
                    case '.mat'
                        oFigure.oParentFigure.oGuiHandle.oPressure = GetPressureFromMATFile(Pressure,sLongDataFileName);
                end
                
                if ~isfield(oFigure.oParentFigure.oGuiHandle.oPressure, 'oUnemap') && isempty(oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap)
                    [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing Unemap signal data',oFigure.DefaultPath);
                    %Make sure the dialogs return char objects
                    if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                        return
                    end
                    %Check the extension
                    sLongDataFileName=strcat(sDataPathName,sDataFileName);
                    
                    %Get the unemap reference data
                    oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap = GetSpecificElectrodeFromTXTFile(Unemap, 289, sLongDataFileName, oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment);
                end
                
                %Plot the data
                for i = 1:length(oFigure.Plots)
                    set(oFigure.Plots(i).Checkbox,'visible','on');
                end
                set(oFigure.Plots(1).Checkbox,'value', 1);
                oFigure.Plots(1).Visible = 1;
                oFigure.Replot();
            end
        end
                
        function oFigure = oSaveMenu_Callback(oFigure, src, event)
            % Save the current entities
           
            %Call built-in file dialog to select filename
            [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the .mat file',oFigure.DefaultPath);
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName))
                return
            end
            
            %Get the full file name
            sLongDataFileName=strcat(sDataPathName,sDataFileName);
            
            %Save
            oFigure.oParentFigure.oGuiHandle.oPressure.Save(sLongDataFileName);
            
        end
        
        function oFigure = Unused_Callback(oFigure, src, event)
            %Default callback for menu items
        end
        
        function oResampleMenu_Callback(oFigure, src, event)
            %Resample the data to match the sampling frequency of Unemap
            %data
            oFigure.oParentFigure.oGuiHandle.oPressure.ResampleOriginalData(...
                oFigure.oParentFigure.oGuiHandle.oPressure.oExperiment.Unemap.ADConversion.SamplingRate)
            %Plot data
            oFigure.Replot();
        end
        
        function oTimeAlignMenu_Callback(oFigure, src, event)
            %Bring up a dialog box that allows user to enter points to time
            %align
            oEditControl = EditControl(oFigure,'Enter the times of the points to align.',2);
            addlistener(oEditControl,'ValuesEntered',@(src,event) oFigure.TimeAlign(src, event));
        end
        
        function oTruncateToUnemapMenu_Callback(oFigure, src, event)
            %Truncate the data to fit unemap reference signal then provide
            %opportunity to truncate further
            
            %Get Unemap reference signal time series limits
            dMinTime = min(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oUnemap.TimeSeries);
            dMaxTime = max(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).oUnemap.TimeSeries);
            %Get the values below and above these limits
            bLowIndexes = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).Status) < dMinTime;
            bHighIndexes = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).Status) > dMaxTime;
            %Combine these and negate to determine indexes to keep
            bIndexesToKeep = ~(bLowIndexes | bHighIndexes);
            %truncate the data and time series
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TruncateData(bIndexesToKeep);
            %replot
            oFigure.Replot();
        end
        
        function oTruncateMenu_Callback(oFigure, src, event)
            oSelectDataFigure = SelectData(oFigure,oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).Status),...
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).Status).Data,...
                {{'oInstructionText','string','Select a range of data to truncate.'} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oButton','string','Done'} ; ...
                {'oAxes','title','Pressure Data'}});
            %Add a listener so that the figure knows when a user has
            %selected the data to truncate
            addlistener(oSelectDataFigure,'DataSelected',@(src,event) oFigure.TruncateData(src, event));
        end
        
        function TruncateData(oFigure, src, event)
            %Get the boolean time indexes of the data that has been selected
            bIndexes = event.Indexes;
            %Negate this so that we can select the potential data we want
            %to keep.
            bIndexes = ~bIndexes;
            %Truncate data that is not selected
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments).TruncateData(bIndexes);
            oFigure.Replot();
        end
        
        function CreateSubPlot(oFigure)
            %Initialise the subplots
            
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            %Divide up the space for the subplots
            yDiv = 1/(length(oFigure.Plots(logical([oFigure.Plots(:).Visible])))+0.4);
            j = 0;%counter of visible plots
            %Loop through all the plots
            for i = 1:length(oFigure.Plots)
                if oFigure.Plots(i).Visible
                    j = j + 1;
                    aPosition = [0.1, (j-1)*yDiv + 0.08, 0.8, yDiv-0.02];%[left bottom width height]
                    %check if the plot still exists
                    if oFigure.Plots(i).ID > 0 && ~isempty(find(get(oFigure.oGuiHandle.oPanel,'children') == oFigure.Plots(i).ID))
                        %plot already been created so just adjust its
                        %position and make it visible
                        set(oFigure.Plots(i).ID, 'position', aPosition, 'visible', 'on');
                        cla(oFigure.Plots(i).ID);
                    else
                        %create a new subplot
                        oFigure.Plots(i).ID = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel, 'Tag', sprintf('Plot%d',i));
                    end
                else
                    if oFigure.Plots(i).ID > 0
                        %plot has already been created but should not be
                        %visible
                        set(oFigure.Plots(i).ID, 'visible', 'off');
                        cla(oFigure.Plots(i).ID);
                    end
                end
            end
        end
        
        function Replot(oFigure)
            %Plot the appropriate data
            
            %Set up the plots 
            oFigure.CreateSubPlot();
            oPlots = oFigure.Plots(logical([oFigure.Plots(:).Visible]));
            
            %loop through the plots currently visible
            for i = 1:length(oPlots)
                switch (oPlots(i).Name)
                    case 'Pressure'
                        oFigure.PlotPressure(oPlots(i).ID);
                    case 'Reference Signal'
                        oFigure.PlotRefSignal(oPlots(i).ID);
                    case 'Unemap Reference Signal'
                        oFigure.PlotUnemapRefSignal(oPlots(i).ID);
                    case 'Electrode'
                        oFigure.PlotElectrode(oPlots(i).ID,oFigure.SelectedElectrode);
                    case 'Heart Rate'
                        oFigure.PlotHeartRate(oPlots(i).ID);
                    case 'Phrenic Integral'
                        oFigure.PlotIntegral(oPlots(i).ID);
                end
                if i == 1
                    xLimits = get(oFigure.Plots(1).ID,'xlim');
                    set(oPlots(1).ID,'xminortick','on');
                    xlabel(oPlots(1).ID,'Time (s)');
                else
                    set(oPlots(i).ID,'xminortick','off');
                    xlabel(oPlots(i).ID,'');
                    set(oPlots(i).ID,'xticklabel',[]);
                    xlim(oPlots(i).ID,xLimits);
                end
            end
        end

        function PlotIntegral(oFigure, oAxesHandle)
            % Calculate a bin integral for the phrenic signal
            
            for j = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                aPhrenic = oFigure.oParentFigure.oGuiHandle.oPressure(j).Phrenic.(oFigure.oParentFigure.oGuiHandle.oPressure(j).Status);
                aIntegral = zeros(length(aPhrenic),1);
                dIntegrand = 0;
                iBinSize = 50;
                iBinCount = 1;
                for i = 1:length(aIntegral)
                    if (iBinCount * iBinSize) == i
                        iStart = (iBinSize * (iBinCount-1) + 1);
                        iEnd = iStart + iBinSize;
                        dSum = sum(abs(aPhrenic(iStart:iEnd)));
                        dIntegrand = dSum / iBinSize;
                        iBinCount = iBinCount + 1;
                    end
                    aIntegral(i) = dIntegrand;
                end
                %Save the integral data
                oFigure.oParentFigure.oGuiHandle.oPressure(j).Phrenic.Integral = aIntegral;
            end
            
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status),oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral,oFigure.Colours(i));
                ymax = max(ymax,max(oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral));
                ymin = min(ymin,min(oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral));
            end
            set(oAxesHandle,'xticklabel',[]);
            oLabel = ylabel(oAxesHandle,['Phrenic', 10, 'Integral (Vs)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
            hold(oAxesHandle, 'off');
        end
        
        function PlotPressure(oFigure,oAxesHandle)
            %Reset the visibility of the events
            set(oFigure.oGuiHandle.cb1,'visible','off');
            set(oFigure.oGuiHandle.cb2,'visible','off');
            set(oFigure.oGuiHandle.cb3,'visible','off');
            set(oFigure.oGuiHandle.cb4,'visible','off');
            set(oFigure.oGuiHandle.cb5,'visible','off');
            %Plot the pressure trace(s).
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status),...
                    oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data, oFigure.Colours(i));
                ymax = max(ymax,max(oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data));
                ymin = min(ymin,min(oFigure.oParentFigure.oGuiHandle.oPressure(i).(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status).Data));
                set(oFigure.oGuiHandle.(sprintf('cb%d',i)),'string',sprintf('%d_%s',oFigure.oParentFigure.oGuiHandle.oPressure(i).oExperiment.Date, oFigure.Colours(i)));
                set(oFigure.oGuiHandle.(sprintf('cb%d',i)),'visible','on');
            end
            hold(oAxesHandle, 'off');
            oLabel = ylabel(oAxesHandle,['Pressure', 10, '(mmHg)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
            ylim(oAxesHandle,[ymin-abs(ymin/25) ymax+ymax/25]);
        end
        
        function PlotRefSignal(oFigure,oAxesHandle)
            %Plot the ref signal trace(s).
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status),...
                    oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status), oFigure.Colours(i));
                ymax = max(ymax, max(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status)));
                ymin = min(ymin, min(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status)));
            end
            hold(oAxesHandle, 'off');
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            oLabel = ylabel(oAxesHandle,[oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Name, 10, '(V)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
        end
        
        function PlotUnemapRefSignal(oFigure,oAxesHandle)
            %Plot the unemap VRMS data
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.TimeSeries,oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data,'k');
            ymax = max(oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data);
            ymin = min(oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data);
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            oLabel = ylabel(oAxesHandle, ['Unemap Phrenic', 10, 'Signal (V)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
        end
        
        function PlotElectrode(oFigure, oAxesHandle, oElectrode)
            %Plot the selected electrode
            aProcessedData = oElectrode.Processed.Data;
            aBeatData = oElectrode.Processed.Beats;
            aBeatIndexes = oElectrode.Processed.BeatIndexes;
            aTime = transpose(oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries);
            
            %Get these values so that we can place text in the
            %right place and give the axes dimensions
            YMax = max(aProcessedData);
            YMin = min(aProcessedData);
            
            %Plot all the data
            if oElectrode.Accepted
                %If the signal is accepted then plot it as black
                plot(oAxesHandle,aTime,aProcessedData,'k');
                ylim(oAxesHandle,[YMin - 0.2, YMax + 0.2]);
                hold(oAxesHandle,'on');
                plot(oAxesHandle,aTime,aBeatData,'-g');
%                 %Loop through beats and label
%                 for j = 1:size(aBeatIndexes,1);
%                     if mod(j,2)
%                         oBeatLabel = text(aTime(aBeatIndexes(j,1)),YMax, num2str(j));
%                     else
%                         oBeatLabel = text(aTime(aBeatIndexes(j,1)),YMin, num2str(j));
%                     end
%                     set(oBeatLabel,'color','k','FontWeight','bold','FontUnits','normalized');
%                     set(oBeatLabel,'FontSize',0.1);
%                     set(oBeatLabel,'parent',oAxesHandle);
%                 end
                hold(oAxesHandle,'off');
            else
                %The signal is not accepted so plot it as red
                %without beats
                plot(oAxesHandle,aTime,aProcessedData,'-r');
                ylim(oAxesHandle,[YMin - 0.2, YMax + 0.2]);
            end
            oLabel = ylabel(oAxesHandle, ['Electrogram', 10, '(V)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
        end
        
        function PlotHeartRate(oFigure, oAxesHandle)
            %get electrode index
            sString = oFigure.GetPopUpSelectionString('oChannelSelector');
            [d iChannel] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName(sString);
            aRateData = oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateSinusRate(iChannel);
            plot(oAxesHandle, oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries, aRateData,'k');
            YMin = min(aRateData);
            YMax = max(aRateData);
            ylim(oAxesHandle,[YMin - 10, YMax + 10]);
            oLabel = ylabel(oAxesHandle,['Activation', 10, 'Rate (bpm)']);
            set(oLabel, 'FontUnits', 'points');
            set(oLabel,'FontSize',14);
        end
        
        function TimeAlign(oFigure, src, event)
            %Get the times of the points to align
            dFirstTime = event.Values(1);
            dSecondTime = event.Values(2);
            %Shift the time array by the difference
            dDiff = dSecondTime - dFirstTime;
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.Processed = ...
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Status) + dDiff;
            oFigure.Replot();
        end
    end
    
end
