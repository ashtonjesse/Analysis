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
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oViewMenu, 'callback', @(src, event) Unused_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oPlotVRMS, 'callback', @(src, event) oPlotVRMS_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oTimeAlignMenu, 'callback', @(src, event) oTimeAlignMenu_Callback(oFigure, src, event));
           
            
            %Sets the figure close function. This lets the class know that
            %the figure wants to close and thus the class should cleanup in
            %memory as well
            set(oFigure.oGuiHandle.(oFigure.sFigureTag),  'closerequestfcn', @(src,event) Close_fcn(oFigure, src, event));
            
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
                    oFigure.oGuiHandle.oPressure =  GetPressureFromTXTFile(Pressure,sLongDataFileName);
                case '.mat'
                    oFigure.oGuiHandle.oPressure = GetPressureFromMATFile(Pressure,sLongDataFileName);
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
            oFigure.oGuiHandle.oUnemap.Save(sLongDataFileName);
            
        end
        
        function oFigure = Unused_Callback(oFigure, src, event)
            %Default callback for menu items
        end
        
        function oResampleMenu_Callback(oFigure, src, event)
            %Resample the data to match the sampling frequency of Unemap
            %data
            oData = resample(oFigure.oGuiHandle.oPressure.Original,oFigure.oGuiHandle.oPressure.oExperiment.Unemap.ADConversion.SamplingRate, ...
                oFigure.oGuiHandle.oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oData2 = resample(oFigure.oGuiHandle.oPressure.RefSignal,oFigure.oGuiHandle.oPressure.oExperiment.Unemap.ADConversion.SamplingRate, ...
                oFigure.oGuiHandle.oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oTimeSeries = [1:1:size(oData,1)]*(1/oFigure.oGuiHandle.oPressure.oExperiment.Unemap.ADConversion.SamplingRate);
            plot(oFigure.aPlots(1),oTimeSeries,oData);
            plot(oFigure.aPlots(2),oTimeSeries,oData2);
        end
        
        function oTimeAlignMenu_Callback(oFigure, src, event)
            %Bring up a dialog box that allows user to enter points to time
            %align
            oFigure.oEditControl = EditControl(oFigure,'Enter the times of the points to align.',2);
            addlistener(oFigure.oEditControl,'ValuesEntered',@(src,event) oFigure.TimeAlign(src, event));
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
             yDiv = 1/(iPlotCount); 
             oFigure.aPlots = zeros(iPlotCount,1);
             %Loop through the plot count
             for i = 1:iPlotCount;
                 %Create subplot
                 aPosition = [0.1, 0.2 + (yDiv*(i-1)-0.1), 0.8, yDiv-0.1];%[left bottom width height]
                 oPlot = subplot('Position',aPosition,'parent', oFigure.oGuiHandle.oPanel, 'Tag', sprintf('Plot%d',i));
                 %Save the subplots to the array
                 oFigure.aPlots(i) = oPlot;
             end
             
             
        end
        
        function PlotPressure(oFigure,oAxesHandle)
            %Plot the pressure trace.
            plot(oAxesHandle,oFigure.oGuiHandle.oPressure.TimeSeries,oFigure.oGuiHandle.oPressure.Original);
            
        end
        
        function PlotRefSignal(oFigure,oAxesHandle)
            %Plot the ref signal trace.
            plot(oAxesHandle,oFigure.oGuiHandle.oPressure.TimeSeries,oFigure.oGuiHandle.oPressure.RefSignal);
        end
        
        function PlotVRMS(oFigure,oAxesHandle)
            %Plot the unemap VRMS data
            plot(oAxesHandle,oFigure.oParentFigure.oGuiHandle.oUnemap.TimeSeries,oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed);

        end
        
        function TimeAlign(oFigure, src, event)
            %Get the times of the points to align
            dFirstTime = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_1');
            dSecondTime = oFigure.oEditControl.GetEditInputDouble(oFigure.oEditControl.oGuiHandle.oPanel,'oEdit_2');
            %Shift the time array by the difference
            dDiff = dFirstTime - dSecondTime;
            oFigure.oGuiHandle.oPressure.TimeSeries = oFigure.oGuiHandle.oPressure.TimeSeries + dDiff;
            oFigure.PlotPressure(oFigure.aPlots(1));
            oFigure.PlotRefSignal(oFigure.aPlots(2));
        end
    end
    
end
