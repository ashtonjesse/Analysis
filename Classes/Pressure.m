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
        Phrenic = [];
        Status = 'Original';
        oRecording = [];
        RecordingType = 'Extracellular';
    end
    
    methods
        function oPressure = Pressure()
            %% Constructor
            oPressure = oPressure@BaseSignal();
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
            oPressure.TimeSeries.(oPressure.Status) = oPressure.TimeSeries.(oPressure.Status)(bIndexesToKeep);
            
            %Truncate the original  data
            oPressure.(oPressure.Status).Data = oPressure.(oPressure.Status).Data(bIndexesToKeep);
            oPressure.RefSignal.(oPressure.Status) = oPressure.RefSignal.(oPressure.Status)(bIndexesToKeep);
            oPressure.Phrenic.(oPressure.Status) = oPressure.Phrenic.(oPressure.Status)(bIndexesToKeep);
        end
        
        function ResampleOriginalData(oPressure, dNewFrequency)
            %Resamples the original pressure data at the new frequency
             oPressure.Processed.Data = resample(oPressure.Original.Data, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.RefSignal.Processed = resample(oPressure.RefSignal.Original, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.Phrenic.Processed = resample(oPressure.Phrenic.Original, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.TimeSeries.Processed = [1:1:size(oPressure.Processed.Data,1)] * (1/dNewFrequency);
            oPressure.Status = 'Processed';
        end
        
        function oPressure = GetPressureFromMATFile(oPressure, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oPressure.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oPressure.oExperiment = Experiment(oData.oEntity.oExperiment);
            oPressure.Original = oData.oEntity.Original;
            oPressure.TimeSeries = oData.oEntity.TimeSeries;
            oPressure.Processed = oData.oEntity.Processed;
            oPressure.RefSignal = oData.oEntity.RefSignal;
            oPressure.Phrenic = oData.oEntity.Phrenic;
            oPressure.Status =  oData.oEntity.Status;
            %this is a hack to allow backwards compatibility with files
            %saved without a RecordingType property
            if isfield(oData.oEntity,'RecordingType')
                oPressure.RecordingType = oData.oEntity.RecordingType;
            else
                oPressure.RecordingType = 'Extracellular';
            end
            switch (oPressure.RecordingType)
                case 'Extracellular'
                    if isfield(oData.oEntity,'oUnemap')
                        oPressure.oRecording = Unemap(oData.oEntity.oUnemap);
                    else
                        oPressure.oRecording = Unemap(oData.oEntity.oRecording);
                    end
                case 'Optical'
                    oPressure.oRecording = Optical(oData.oEntity.oRecording);
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
                oPressure.Phrenic.Original = [oPressure.Phrenic.Original ; aFileContents(:,oPressure.oExperiment.Phrenic.StorageColumn)];
            else
                %load it for the first time
                oPressure.Original.Data = aFileContents(:,oPressure.oExperiment.PerfusionPressure.StorageColumn);
                oPressure.TimeSeries.Original = aFileContents(:,1);
                oPressure.RefSignal.Original = aFileContents(:,oPressure.oExperiment.PerfusionPressure.RefSignalColumn);
                oPressure.RefSignal.Name = oPressure.oExperiment.PerfusionPressure.RefSignalName;
                oPressure.Phrenic.Original = aFileContents(:,oPressure.oExperiment.Phrenic.StorageColumn);
            end
            
        end       
        
    end
end

