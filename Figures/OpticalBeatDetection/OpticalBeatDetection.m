classdef OpticalBeatDetection < BaseFigure
    %this figure is designed to load a csv file containing optical mapping
    %data and enable the user to detect beats
    properties
        DataAxes = 1;
        HeartRateAxes = 2;
    end
    
    methods
        function oFigure = OpticalBeatDetection()
            oFigure = oFigure@BaseFigure('OpticalBeatDetection',@OpeningFcn);
            %Set the callback functions to the menu items
            set(oFigure.oGuiHandle.oFileMenu, 'callback', @(src, event) oDummy_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oOpenMenu, 'callback', @(src, event) oOpenMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSaveMenu, 'callback', @(src, event) oSaveMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oExitMenu, 'callback', @(src, event) Close_fcn(oFigure, src, event));
            set(oFigure.oGuiHandle.oToolsMenu, 'callback', @(src, event) oDummy_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oSmoothMenu, 'callback', @(src, event) oSmoothMenu_Callback(oFigure, src, event));
            set(oFigure.oGuiHandle.oDetectBeatsMenu, 'callback', @(src, event) oDetectBeatsMenu_Callback(oFigure, src, event));
            
            
            %set up axes
            oFigure.oGuiHandle.oPanel = panel(oFigure.oGuiHandle.(oFigure.sFigureTag));
            oFigure.oGuiHandle.oPanel.pack(1,1);
            oFigure.oGuiHandle.oOptical = [];
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
    
    methods (Access = private)
        %% Private UI control callbacks
        function oFigure = Close_fcn(oFigure, src, event)
            deleteme(oFigure);
        end   
        
        function oFigure = oDummy_Callback(oFigure, src, event)
            
        end
        
        function oFigure = oSaveMenu_Callback(oFigure, src, event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                % Save the current entities
                
                %Call built-in file dialog to select filename
                [sDataFileName,sDataPathName]=uiputfile('*.mat','Select a location for the .mat file');
                %Make sure the dialogs return char objects
                if (~ischar(sDataFileName))
                    return
                end
                
                %Get the full file name
                sLongDataFileName=strcat(sDataPathName,sDataFileName);
                
                %Save
                oFigure.oGuiHandle.oOptical.Save(sLongDataFileName);
            end
        end
        
        function oFigure = oOpenMenu_Callback(oFigure,src,event)
            [sDataFileName,sDataPathName]=uigetfile('*.*','Select a CSV file that contains an optical transmembrane recording');
            %Make sure the dialogs return char objects
            if (~ischar(sDataFileName) && ~ischar(sDataPathName))
                return
            end
            %get the optical data
            sLongDataFileName=strcat(sDataPathName,char(sDataFileName));
            oFigure.oGuiHandle.oOptical = GetOpticalRecordingFromCSVFile(Optical, sLongDataFileName, []);
            oFigure.Replot();
        end
        
        function oFigure = oSmoothMenu_Callback(oFigure,src,event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %Smooth the signal being used for beat detection
                aInOptions = struct('Procedure','','Inputs',cell(1,1));
                aInOptions.Procedure = 'FilterData';
                aInOptions.Inputs = {'SovitzkyGolay',3,25};%19
                oFigure.oGuiHandle.oOptical.ProcessElectrodeData(1, aInOptions);
                if isfield(oFigure.oGuiHandle.oOptical.Electrodes.Processed,'Beats')
                    oFigure.oGuiHandle.oOptical.RefreshBeatData();
                end
                oFigure.Replot();
            end
        end
        
        function oFigure = oDetectBeatsMenu_Callback(oFigure,src,event)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %Detect the beats through the selected signal
                
                sThresholdType = 'Peaks';
                aTimeSeries = oFigure.oGuiHandle.oOptical.TimeSeries;
                oElectrodes = oFigure.oGuiHandle.oOptical.Electrodes;
                %Process the data if it isn't already
                if strcmp(oElectrodes.Status,'Potential')
                    oElectrodes.Processed.Data = oElectrodes.Potential.Data;
                    oElectrodes.Status = 'Processed';
                end
                aData = oFigure.oGuiHandle.oOptical.CalculateCurvature(oElectrodes.Processed.Data,20,5);
                aOptions = {{'oInstructionText','string','Select a range of data during quiescence'} ; ...
                    {'oBottomText','string','How many standard deviations to apply?'} ; ...
                    {'oBottomPopUp','string',{'1','2','3','4','5'}} ; ...
                    {'oReturnButton','string','Done'} ; ...
                    {'oAxes','title','Curvature'}};
                oGetThresholdFigure = ThresholdData(oFigure, aTimeSeries, aData, sThresholdType, aOptions);
                %Add a listener so that the figure knows when a user has
                %calculated the threshold
                addlistener(oGetThresholdFigure,'ThresholdCalculated',@(src,event) oFigure.ThresholdCurvature(src, event));
            end
        end
        
        function Replot(oFigure)
            if ~isempty(oFigure.oGuiHandle.oOptical)
                %plot data
                oElectrode = oFigure.oGuiHandle.oOptical.Electrodes(1);
                if strcmp(oElectrode.Status,'Processed')
                    if isfield(oElectrode.Processed,'Beats')
                        %then need to set up axes for plotting both HR and
                        %data
                        oFigure.oGuiHandle.oPanel = panel(oFigure.oGuiHandle.(oFigure.sFigureTag));
                        oFigure.oGuiHandle.oPanel.pack(2,1);
                        oFigure.oGuiHandle.oPanel.margin = [10 5 5 5];
                        oFigure.oGuiHandle.oPanel(oFigure.DataAxes).margin = [5 5 0 0];
                        oFigure.oGuiHandle.oPanel(oFigure.HeartRateAxes).margin = [5 5 0 0];
                        %plot the processed data
                        oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                        hold(oDataAxes,'on');
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical.TimeSeries,oElectrode.Processed.Beats,'-g');
                        hold(oDataAxes,'off');
                        %plot the rate data
                        oRateAxes = oFigure.oGuiHandle.oPanel(oFigure.HeartRateAxes,1).select();
                        [aRateData dPeaks] = oFigure.oGuiHandle.oOptical.CalculateSinusRate(1);
                        hline = plot(oRateAxes,oFigure.oGuiHandle.oOptical.TimeSeries, aRateData,'k');
                        set(hline,'linewidth',1.5);
                    else
                        %just plot processed data
                        oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                        plot(oDataAxes,oFigure.oGuiHandle.oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                    end
                else
                    %just plot potential data
                    oDataAxes = oFigure.oGuiHandle.oPanel(oFigure.DataAxes,1).select();
                    plot(oDataAxes,oFigure.oGuiHandle.oOptical.TimeSeries,oElectrode.(oElectrode.Status).Data,'k');
                end
            end
        end
        
        %% event listeners
        function ThresholdCurvature(oFigure, src, event)
            [aOutData dMaxPeaks] = oFigure.oGuiHandle.oOptical.GetSinusBeats(...
                oFigure.oGuiHandle.oOptical.Electrodes.(oFigure.oGuiHandle.oOptical.Electrodes.Status).Data, event.ArrayData);
            
            oFigure.oGuiHandle.oOptical.Electrodes.Processed.Beats = cell2mat(aOutData(1));
            oFigure.oGuiHandle.oOptical.Electrodes.Processed.BeatIndexes = cell2mat(aOutData(2));
            oFigure.oGuiHandle.oOptical.CalculateSinusRate(1);
            oFigure.Replot();
        end
    end
end
