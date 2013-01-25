classdef Pressure < BaseSignal
    %   Pressure is a subclass of type BaseSignal that is associated
    %   with a Pressure recording from an Experiment.
    %   Pressure inherits all properties and methods from BaseSignal.
    
    properties
        oExperiment;
        Original;
        TimeSeries;
        RefSignal;
        Processed;
        Status = 'Original';
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
        end
        
        function ResampleOriginalData(oPressure, dNewFrequency)
            %Resamples the original pressure data at the new frequency
             oPressure.Processed.Data = resample(oPressure.Original.Data, dNewFrequency, ...
                oPressure.oExperiment.PerfusionPressure.SamplingRate);
            oPressure.RefSignal.Processed = resample(oPressure.RefSignal.Original, dNewFrequency, ...
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
            oPressure.Status =  oData.oEntity.Status;
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
            oPressure.Original.Data = aFileContents(:,oPressure.oExperiment.PerfusionPressure.StorageColumn);
            oPressure.TimeSeries.Original = aFileContents(:,1);
            oPressure.RefSignal.Original = aFileContents(:,oPressure.oExperiment.PerfusionPressure.RefSignalColumn);
        end       
        
    end
end

