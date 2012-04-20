classdef ECG < BasePotential
    %   ECG is a subclass of type Potential that is associated with the ECG
    %   recording from an Experiment.
    %   ECG inherits all properties and methods from BasePotential.
    
    properties
        oExperiment;
        Original;
        TimeSeries;
        Processed;
    end
    
    methods
        function oECG = ECG()
            %% Constructor
            oECG = oECG@BasePotential();
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oECG,sPath)
            SaveEntity@BaseEntity(oECG,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oECG,sPath)
            SaveEntity(oECG,sPath);
        end
        %% Inherited methods
        function aOutData = ProcessData(oBasePotential, aInData, varargin)
            aOutData = ProcessData@BasePotential(oBasePotential, aInData, varargin);
        end
        %% Class specific methods
        function oECG = GetECGFromMATFile(oECG, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oECG.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oECG.oExperiment = Experiment(oData.oEntity.oExperiment);
            oECG.Original = oData.oEntity.Original;
            oECG.TimeSeries = oData.oEntity.TimeSeries;
            oECG.Processed = oData.oEntity.Processed;
        end
        
        function oECG = GetECGFromTXTFile(oECG,sFile)
            %   Get an entity by loading data from a txt file - only done the
            %   first time you are creating an ECG entity
            
            %   If the ECG does not have an Experiment loaded yet
            %   then load one
            if isempty(oECG.oExperiment)
                %   Look for a metadata file in the same directory that will
                %   contain the Experiment data
                [sPath] = fileparts(sFile);
                aFileFull = fGetFileNamesOnly(sPath,'*_experiment.txt');
                %   There should be one experiment file and no more
                if ~(size(aFileFull,1) == 1)
                    error('VerifyInput:TooManyInputFiles', 'There is the wrong number of experimental metadata files in the directory %s',sPath);
                end
                %   Get the Experiment entity
                oECG.oExperiment = GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            end
            %   Load the potential data from the txt file
            aFileContents = oECG.oDAL.LoadFromFile(sFile);
            %   Set the Original and TimeSeries Structured arrays
            oECG.Original = aFileContents(:,oECG.oExperiment.Unemap.NumberOfChannels + ...
                oECG.oExperiment.Unemap.ECGChannel + 1);
            oECG.TimeSeries = [1:1:size(oECG.Original,1)]*(1/oECG.oExperiment.Unemap.ADConversion.SamplingRate);
        end       
        
    end
end

