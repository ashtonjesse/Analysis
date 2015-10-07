classdef Pressure < BaseSignal
    %   Pressure is a subclass of type BaseSignal that is associated
    %   with a Pressure recording from an Experiment.
    %   Pressure inherits all properties and methods from BaseSignal.
    
    properties
        oExperiment;
        Original = [];
        TimeSeries = [];
        RefSignal = [];
        Processed = [];
        oPhrenic = [];
        Status = 'Original';
        oRecording = [];
        RecordingType = 'Extracellular';
        Increase = [];
        Plateau = [];
        Baseline = [];
        HeartRate = [];
        Threshold = [];
    end
    
    methods
        function oPressure = Pressure(varargin)
            %% Constructor
            oPressure = oPressure@BaseSignal();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Unemap')
                    oPressureStruct = varargin{1};
                    oPressure.oPhrenic = Phrenic(oPressureStruct.Phrenic);
                end
            end
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oPressure,sPath)
            SaveEntity@BaseEntity(oPressure,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oPressure,sPath)
            SaveEntity(oPressure,sPath);
        end
        %% Class specific methods
        function TruncateData(oPressure, bIndexesToKeep)
            %This performs a truncation on the current pressure data 
            
            %Truncate the time series
            aCurrentTimeSeries = oPressure.TimeSeries.(oPressure.TimeSeries.Status);
            oPressure.TimeSeries.(oPressure.TimeSeries.Status) = aCurrentTimeSeries(bIndexesToKeep);
            oPressure.oPhrenic.TimeSeries = aCurrentTimeSeries(bIndexesToKeep);
            %Truncate the original  data
            oPressure.(oPressure.Status).Data = oPressure.(oPressure.Status).Data(bIndexesToKeep);
            oPressure.RefSignal.(oPressure.RefSignal.Status) = oPressure.RefSignal.(oPressure.RefSignal.Status)(bIndexesToKeep);
            oPressure.oPhrenic.Electrodes.(oPressure.oPhrenic.Electrodes.Status).Data = ...
                oPressure.oPhrenic.Electrodes.(oPressure.oPhrenic.Electrodes.Status).Data(bIndexesToKeep);
        end
        
        function SmoothData(oPressure, iCutoff)
            %apply lowpass filter to data
            oPressure.Processed.Data = oPressure.FilterData(oPressure.(oPressure.Status).Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, iCutoff);
            oPressure.Status = 'Processed';
            %take a second off each end to remove end effects
            bOver = oPressure.TimeSeries.(oPressure.TimeSeries.Status) > 1;
            bUnder = oPressure.TimeSeries.(oPressure.TimeSeries.Status) < max(oPressure.TimeSeries.(oPressure.TimeSeries.Status)) - 1;
            bIndexesToKeep = bOver & bUnder;
            oPressure.oPhrenic.Electrodes.Processed.Data = oPressure.oPhrenic.Electrodes.(oPressure.oPhrenic.Electrodes.Status).Data;
            oPressure.RefSignal.Processed = oPressure.RefSignal.(oPressure.RefSignal.Status);
            oPressure.oPhrenic.Electrodes.Status  = 'Processed';
            oPressure.RefSignal.Status = 'Processed';
            oPressure.TruncateData(bIndexesToKeep);
        end
        
        function ResampleOriginalData(oPressure, dNewFrequency)
            %Resamples the original pressure data at the new frequency
             oPressure.Processed.Data = resample(oPressure.Original.Data, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.Processed.Data = oPressure.Processed.Data(2:(end-2)); 
            oPressure.RefSignal.Processed = resample(oPressure.RefSignal.Original, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.RefSignal.Processed = oPressure.RefSignal.Processed(2:(end-2)); 
            oPressure.oPhrenic.ResampleData(dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.TimeSeries.Processed = [1:1:size(oPressure.Processed.Data,1)] * (1/dNewFrequency);
            oPressure.TimeSeries.Status = 'Processed';
            oPressure.RefSignal.Status = 'Processed';
            oPressure.Status = 'Processed';
        end
        
        function oPressure = GetPressureFromMATFile(oPressure, sFile, sRecordingType)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oPressure.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oPressure.RecordingType = sRecordingType;
            oPressure.oExperiment = Experiment(oData.oEntity.oExperiment);
            oPressure.Original = oData.oEntity.Original;
            oPressure.TimeSeries = oData.oEntity.TimeSeries;
            oPressure.Processed = oData.oEntity.Processed;
            oPressure.RefSignal = oData.oEntity.RefSignal;
            oPressure.oPhrenic = Phrenic(oData.oEntity.oPhrenic);
            oPressure.Status =  oData.oEntity.Status;
            %this is a hack to allow backwards compatibility with files
            %saved without a RecordingType property
            switch (oPressure.RecordingType)
                case 'Extracellular'
                    if isfield(oData.oEntity,'oUnemap')
                        oPressure.oRecording = Unemap(oData.oEntity.oUnemap);
                    else
                        oPressure.oRecording = Unemap(oData.oEntity.oRecording);
                    end
                case 'Optical'
                    for i = 1:length(oData.oEntity.oRecording)
                        oPressure.oRecording = [oPressure.oRecording Optical(oData.oEntity.oRecording(i))];
                    end
            end
            
            if ~isfield(oPressure.TimeSeries,'Status')
                oPressure.TimeSeries.Status = oPressure.Status;
                oPressure.RefSignal.Status = oPressure.Status;
            end
            
            if oData.oEntity.IsProp('Increase')
                oPressure.Increase = oData.oEntity.Increase;
            else
                oPressure.Increase = [];
            end
            
            if oData.oEntity.IsProp('Plateau')
                oPressure.Plateau = oData.oEntity.Plateau;
            else
                oPressure.Plateau = [];
            end
            
            if oData.oEntity.IsProp('Baseline')
                oPressure.Baseline = oData.oEntity.Baseline;
            else
                oPressure.Baseline = [];
            end
            
            if oData.oEntity.IsProp('HeartRate')
                oPressure.HeartRate = oData.oEntity.HeartRate;
            else
                oPressure.HeartRate = [];
            end
            
            if oData.oEntity.IsProp('Threshold')
                oPressure.Threshold = oData.oEntity.Threshold;
            else
                oPressure.Threshold = [];
            end
        end
        
        function [oPressure] = GetPressureFromTXTFile(oPressure,sFile)
            %   Get an entity by loading data from a txt file - only done the
            %   first time you are creating a Pressure entity
            
            %   If the Pressure does not have an Experiment loaded yet
            %   then load one
            if isempty(oPressure.oExperiment)
                %   Look for a metadata file in the same directory that will
                %   contain the Experiment data
                [sPath] = fileparts(sFile);
                aFileFull = fGetFileNamesOnly(sPath,'*_experiment.txt');
                %   There should be one experiment file and no more
                if ~(size(aFileFull,1) == 1)
                    error('VerifyInput:TooManyInputFiles', 'There is the wrong number of experimental metadata files in the directory %s',sPath);
                end
                %   Get the Experiment entity
                oPressure.oExperiment = GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            end
            
            %   Load the data from the txt file
            aFileContents = oPressure.oDAL.LoadFromFile(sFile);
            %   Set the Original and TimeSeries Structured arrays
            % check if there is already data loaded
            if isfield(oPressure.Original, 'Data')
                %append to existing data
                oPressure.Original.Data = [oPressure.Original.Data ; aFileContents(:,oPressure.oExperiment.PerfusionPressure.StorageColumn)];
                oPressure.TimeSeries.Original = [oPressure.TimeSeries.Original ; oPressure.TimeSeries.Original(end) + aFileContents(:,1)];
                oPressure.RefSignal.Original = [oPressure.RefSignal.Original ; aFileContents(:,oPressure.oExperiment.PerfusionPressure.RefSignalColumn)];
                oPressure.oPhrenic.Electrodes.Potential.Data = [oPressure.oPhrenic.Electrodes.Potential.Data ; aFileContents(:,oPressure.oExperiment.Phrenic.StorageColumn)];
                oPressure.oPhrenic.TimeSeries = oPressure.TimeSeries.Original;
            else
                %load it for the first time
                oPressure.Original.Data = aFileContents(:,oPressure.oExperiment.PerfusionPressure.StorageColumn);
                oPressure.TimeSeries.Original = aFileContents(:,1);
                oPressure.RefSignal.Original = aFileContents(:,oPressure.oExperiment.PerfusionPressure.RefSignalColumn);
                oPressure.RefSignal.Name = oPressure.oExperiment.PerfusionPressure.RefSignalName;
                oPressure.oPhrenic = Phrenic(oPressure.oExperiment,aFileContents(:,oPressure.oExperiment.Phrenic.StorageColumn),oPressure.TimeSeries.Original);
            end
            oPressure.TimeSeries.Status = 'Original';
            oPressure.RefSignal.Status = 'Original';
        end       
        
        
    end
end

