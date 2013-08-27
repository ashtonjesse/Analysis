classdef PressureAnalysis < SubFigure
% PressureAnalysis Summary of this class goes here

    properties
        DefaultPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\';
        aPlots;
        CurrentZoomLimits = [];
        SelectedExperiments = [];
        Colours = ['k','r','b','g','c'];
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
            set(oFigure.oGuiHandle.oPlotUnemapRefSignal, 'callback', @(src, event) oPlotUnemapRef_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportMenu, 'callback', @(src, event) oExportMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTimeAlignMenu, 'callback', @(src, event) oTimeAlignMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oHeartRateMenu, 'callback', @(src, event) oHeartRateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oIntegralMenu, 'callback', @(src, event) oIntegralMenu_Callback(oFigure, src, event));
            
            set(oFigure.oGuiHandle.cb1, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb2, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb3, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb4, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.cb5, 'callback', @(src, event) oSelection_Callback(oFigure, src, event));
                        
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
           
            %Turn zoom on for this figure
            set(oFigure.oZoom,'enable','on');
            set(oFigure.oZoom,'ActionPostCallback',@(src, event) PostZoom_Callback(oFigure, src, event));
            
            if ~isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %Plot the data
                oFigure.CreateSubPlot(2);
                oFigure.PlotPressure(oFigure.aPlots(1));
                oFigure.PlotRefSignal(oFigure.aPlots(2));
            end
            
            % --- Executes just before BaselineCorrection is made visible.
            function OpeningFcn(hObject, eventdata, handles, varargin)
                % This function has no output args, see OutputFcn.
                % hObject    handle to figure 
                % eventdata  reserved - to be defined in a future version of MATLAB
                % handles    structure with handles and user data (see GUIDATA)
                % varargin   command line arguments to BaselineCorrection (see VARARGIN)
                
                %Set the output attribute
                set(handles.cb1,'visible','off');
                set(handles.cb2,'visible','off');
                set(handles.cb3,'visible','off');
                set(handles.cb4,'visible','off');
                set(handles.cb5,'visible','off');
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
        % --------------------------------------------------------------------
        function PostZoom_Callback(oFigure, src, event)
            %Synchronize the zoom of all the axes
            
            %Get the current axes and selected limit
            oCurrentAxes = event.Axes;
            oXLim = get(oCurrentAxes,'XLim');
            oYLim = get(oCurrentAxes,'YLim');
            oFigure.CurrentZoomLimits = [oXLim ; oYLim];
            %Apply to axes
            set(oFigure.aPlots(1),'XLim',oXLim);
            set(oFigure.aPlots(2),'XLim',oXLim);
            set(oFigure.aPlots(3),'XLim',oXLim);
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
            oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            
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
                oFigure.CreateSubPlot(2);
                oFigure.PlotPressure(oFigure.aPlots(1));
                oFigure.PlotRefSignal(oFigure.aPlots(2));
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
            oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
        
        function oIntegralMenu_Callback(oFigure, src, event)
            % Calculate a bin integral for the phrenic signal
            
            for j = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                aPhrenic = oFigure.oParentFigure.oGuiHandle.oPressure(j).Phrenic.(oFigure.oParentFigure.oGuiHandle.oPressure(j).Status);
                aIntegral = zeros(length(aPhrenic),1);
                dIntegrand = 0;
                iBinSize = 100;
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
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            
            %Plot the data
            oFigure.CreateSubPlot(3);
            oFigure.PlotPressure(oFigure.aPlots(1));
            %oFigure.PlotRefSignal(oFigure.aPlots(2));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            oFigure.PlotIntegral(oFigure.aPlots(3));
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
            oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            
            
            
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
             oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
        
        function oHeartRateMenu_Callback(oFigure, src, event)
            [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetSinusBeats(...
                oFigure.oParentFigure.oGuiHandle.oECG.Original, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks);
            aRateData = oFigure.oParentFigure.oGuiHandle.oUnemap.GetHeartRateData(dMaxPeaks);
            oFigure.CreateSubPlot(3);
            oFigure.PlotPressure(oFigure.aPlots(1));
            %             oFigure.PlotRefSignal(oFigure.aPlots(2));
            
            plot(oFigure.aPlots(2),oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,aRateData,'k');
            set(oFigure.aPlots(2),'XTick',[]);
            ylabel(oFigure.aPlots(2),'Heart rate (bpm)');
            oFigure.PlotUnemapRefSignal(oFigure.aPlots(3));
        end
        
        function CreateSubPlot(oFigure,iPlotCount)
            %Initialise the subplots
            
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            
            %Check what plots are present on the panel
            %Loop through list and delete
            for i = 1:size(oFigure.aPlots,1)
                delete(oFigure.aPlots(i));
            end
            
            %Divide up the space for the subplots
            yDiv = 1/(iPlotCount+0.4);
            oFigure.aPlots = zeros(iPlotCount,1);
            
            %Loop through the plot count
            for i = 1:iPlotCount;
                %Create subplot
                aPosition = [0.1, (i-1)*yDiv + 0.08, 0.8, yDiv-0.02];%[left bottom width height]
                oPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel, 'Tag', sprintf('Plot%d',i));
                
                %Save the subplots to the array
                oFigure.aPlots(i) = oPlot;
            end
            
            
        end
        
        function oPlotUnemapRef_Callback(oFigure, src, event)
            %Plot the reference signal from the Unemap data
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            
            %Plot the data
            oFigure.CreateSubPlot(3);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            oFigure.PlotUnemapRefSignal(oFigure.aPlots(3));
        end
        
        function PlotIntegral(oFigure, oAxesHandle)
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            hold(oAxesHandle, 'on');
            ymax = 0;
            ymin = 9999999;
            for i = 1:length(oFigure.oParentFigure.oGuiHandle.oPressure)
                plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure(i).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(i).Status),oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral,oFigure.Colours(i));
                ymax = max(ymax,max(oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral));
                ymin = min(ymin,min(oFigure.oParentFigure.oGuiHandle.oPressure(i).Phrenic.Integral));
            end
            set(oAxesHandle,'XTick',[]);
            ylabel(oAxesHandle,'Phrenic Integral (Vs)');
            ylim(oAxesHandle,[ymin-abs(ymin/25) ymax+ymax/25]);
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
            xlabel(oAxesHandle,'Time (s)');
            ylabel(oAxesHandle,'Pressure (mmHg)');
            set(oAxesHandle,'xminortick','on');
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
            %             axis(oAxesHandle,'tight');
            set(oAxesHandle,'XTick',[]);
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            ylabel(oAxesHandle,strcat(oFigure.oParentFigure.oGuiHandle.oPressure(i).RefSignal.Name,' (V)'));
        end
        
        function PlotUnemapRefSignal(oFigure,oAxesHandle)
            %Plot the unemap VRMS data
            %Get channel to plot
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.TimeSeries,oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data,'k');
            xLimits = get(oFigure.aPlots(1),'xlim');
            xlim(oAxesHandle,xLimits);
            set(oAxesHandle,'XTick',[]);
            set(oAxesHandle,'YTick',[]);
            ymax = max(oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data);
            ymin = min(oFigure.oParentFigure.oGuiHandle.oPressure.oUnemap.Electrodes.Potential.Data);
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            ylabel(oAxesHandle,'Phrenic signal as recorded via Unemap');
            
            %             oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName('15-09');
            %             plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,oElectrode.Processed.Data,'k');
            %             set(oAxesHandle,'XTick',[]);
            %             set(oAxesHandle,'YTick',[]);
            %             ymax = max(oElectrode.Processed.Data);
            %             ymin = min(oElectrode.Processed.Data);
            %             ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            %             ylabel(oAxesHandle,'Electrogram at x');
            
            %             plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status), ...
            %                 oFigure.oParentFigure.oGuiHandle.oPressure.Phrenic.(oFigure.oParentFigure.oGuiHandle.oPressure.Status),'k');
            %             set(oAxesHandle,'XTick',[]);
            %             set(oAxesHandle,'YTick',[]);
            %             ymax = max(oFigure.oParentFigure.oGuiHandle.oPressure.Phrenic.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
            %             ymin = min(oFigure.oParentFigure.oGuiHandle.oPressure.Phrenic.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
            %             ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            %             ylabel(oAxesHandle,'Phrenic Nerve Signal');
        end
        
        function TimeAlign(oFigure, src, event)
            %Get the times of the points to align
            dFirstTime = event.Values(1);
            dSecondTime = event.Values(2);
            %Shift the time array by the difference
            dDiff = dSecondTime - dFirstTime;
            oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.Processed = ...
                oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Status) + dDiff;
%             oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Status = 'Processed';
%             oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Processed = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).RefSignal.Original;
%             oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Processed.Data = oFigure.oParentFigure.oGuiHandle.oPressure(oFigure.SelectedExperiments(1)).Original.Data;
            oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
    end
    
end
