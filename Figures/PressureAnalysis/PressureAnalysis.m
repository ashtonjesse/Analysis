classdef PressureAnalysis < SubFigure
% PressureAnalysis Summary of this class goes here

    properties
        DefaultPath = 'D:\Users\jash042\Documents\PhD\Analysis\Database\';
        oEditControl;
        aPlots;
    end
    
    methods
        %% Constructor
        function oFigure = PressureAnalysis(oParent)
            oFigure = oFigure@SubFigure(oParent,'PressureAnalysis',@OpeningFcn);
                        
            %Set the callback functions to the menu items 
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oResampleMenu, 'callback', @(src, event) oResampleMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTruncateMenu, 'callback', @(src, event) oTruncateMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPlotVRMS, 'callback', @(src, event) oPlotVRMS_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExportMenu, 'callback', @(src, event) oExportMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTimeAlignMenu, 'callback', @(src, event) oTimeAlignMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oHeartRateMenu, 'callback', @(src, event) oHeartRateMenu_Callback(oFigure, src, event));
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
            if isempty(oFigure.oParentFigure.oGuiHandle.oPressure)
                %Call built-in file dialog to select filename
                [sDataFileName,sDataPathName]=uigetfile('*.*','Select a file containing Pressure data',oFigure.DefaultPath);
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                    return
                end
                %Check the extension
                sLongDataFileName=strcat(sDataPathName,sDataFileName);
                [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
                switch (ext)
                    case '.txt'
                        oFigure.oParentFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(Pressure,sLongDataFileName);
                    case '.mat'
                        oFigure.oParentFigure.oGuiHandle.oPressure = GetPressureFromMATFile(Pressure,sLongDataFileName);
                end
            end
             
            
            %Plot the data
            oFigure.CreateSubPlot(2);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            % --- Executes just before BaselineCorrection is made visible.
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
            deleteme@BaseFigure(oFigure);
        end
    end
    
    methods (Access = private)
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
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
        
        function oTimeAlignMenu_Callback(oFigure, src, event)
            %Bring up a dialog box that allows user to enter points to time
            %align
            oFigure.oEditControl = EditControl(oFigure,'Enter the times of the points to align.',2);
            addlistener(oFigure.oEditControl,'ValuesEntered',@(src,event) oFigure.TimeAlign(src, event));
        end
        
        function oTruncateMenu_Callback(oFigure, src, event)
            %Open the SelectData figure to select the data to truncate
            sInstructions = 'Select a range of data to truncate.';
            
            oSelectDataFigure = SelectData(oFigure,oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status),...
                oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data,...
                {{'oInstructionText','string',sInstructions} ; ...
                {'oBottomText','visible','off'} ; ...
                {'oBottomPopUp','visible','off'} ; ...
                {'oButton','string','Done'} ; ...
                {'oAxes','title',sprintf('Pressure %s Data',oFigure.oParentFigure.oGuiHandle.oPressure.Status)}});
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
            oFigure.oParentFigure.oGuiHandle.oPressure.TruncateData(bIndexes);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
        
        function oPlotVRMS_Callback(oFigure, src, event)
            %Plot the VRMS from the Unemap data
            %Make sure the current figure is PressureAnalysis
            set(0,'CurrentFigure',oFigure.oGuiHandle.(oFigure.sFigureTag));
            
            %Plot the data
            oFigure.CreateSubPlot(3);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            oFigure.PlotVRMS(oFigure.aPlots(3));
        end
        
        function oHeartRateMenu_Callback(oFigure, src, event)
            [aOutData dMaxPeaks] = oFigure.oParentFigure.oGuiHandle.oUnemap.GetBeats(...
                oFigure.oParentFigure.oGuiHandle.oECG.Original, ...
                oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Curvature.Peaks);
            aRateData = oFigure.oParentFigure.oGuiHandle.oUnemap.GetHeartRateData(dMaxPeaks);
            oFigure.CreateSubPlot(4);
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
            oFigure.PlotVRMS(oFigure.aPlots(4));
            plot(oFigure.aPlots(3),oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,aRateData,'k');
            set(oFigure.aPlots(3),'XTick',[]);
            ylabel(oFigure.aPlots(3),'Heart rate (bpm)');
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
        
        function PlotPressure(oFigure,oAxesHandle)
            %Plot the pressure trace.
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status),...
                oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data,'k');
            xlabel(oAxesHandle,'Time (s)');
            ylabel(oAxesHandle,'Pressure (mmHg)');
            ymax = max(oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data);
            ymin = min(oFigure.oParentFigure.oGuiHandle.oPressure.(oFigure.oParentFigure.oGuiHandle.oPressure.Status).Data);
            ylim(oAxesHandle,[ymin-abs(ymin/10) ymax+ymax/10]);
        end
        
        function PlotRefSignal(oFigure,oAxesHandle)
            %Plot the ref signal trace.
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status),...
                oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure.Status),'k');
%             axis(oAxesHandle,'tight');
            set(oAxesHandle,'XTick',[]);
            ymax = max(oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
            ymin = min(oFigure.oParentFigure.oGuiHandle.oPressure.RefSignal.(oFigure.oParentFigure.oGuiHandle.oPressure.Status));
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            ylabel(oAxesHandle,'ECG');
        end
        
        function PlotVRMS(oFigure,oAxesHandle)
            %Plot the unemap VRMS data
            %Get channel to plot
            oElectrode = oFigure.oParentFigure.oGuiHandle.oUnemap.GetElectrodeByName('15-09');
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,oElectrode.Processed.Data,'k');
            set(oAxesHandle,'XTick',[]);
            ymax = max(oElectrode.Processed.Data);
            ymin = min(oElectrode.Processed.Data);
            ylim(oAxesHandle,[ymin-abs(ymin/5) ymax+ymax/5]);
            
        end
        
        function TimeAlign(oFigure, src, event)
            %Get the times of the points to align
            dFirstTime = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_1');
            dSecondTime = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_2');
            %Shift the time array by the difference
            dDiff = dFirstTime - dSecondTime;
            oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.Processed = ...
                oFigure.oParentFigure.oGuiHandle.oPressure.TimeSeries.(oFigure.oParentFigure.oGuiHandle.oPressure.Status) + dDiff;
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
    end
    
end
