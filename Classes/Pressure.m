classdef Pressure < BasePotential
    %   Pressure is a subclass of type BasePotential that is associated
    %   with a Pressure recording from an Experiment.
    %   Pressure inherits all properties and methods from BasePotential.
    
    properties
        oExperiment;
        Original;
        TimeSeries;
        Processed;
    end
    
    methods
        function oPressure = Pressure()
            %% Constructor
            oPressure = oPressure@BasePotential();
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
        %% Inherited methods
        function aOutData = ProcessData(oBasePotential, aInData, varargin)
            aOutData = ProcessData@BasePotential(oBasePotential, aInData, varargin);
        end
        %% Class specific methods
        function TruncateData(oPressure, bIndexesToKeep)
            %This performs a truncation on the Pressure data 
            
            %Truncate the time series
            oPressure.TimeSeries = oPressure.TimeSeries(bIndexesToKeep);
            
            %Truncate the original potential data
            oPressure.Original = oPressure.Original(bIndexesToKeep);
                                
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
        end
        
        function oPressure = GetPressureFromTXTFile(oPressure,sFile)
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
            oPressure.Original = aFileContents(:,oPressure.oExperiment.Unemap.NumberOfChannels + ...
                oPressure.oExperiment.Unemap.ECGChannel + 1);
            oPressure.TimeSeries = [1:1:size(oPressure.Original,1)]*(1/oPressure.oExperiment.Unemap.ADConversion.SamplingRate);
        end       
        
    end
end

