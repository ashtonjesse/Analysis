classdef Unemap < BasePotential
    %Potential is a class that is associated with the potential data
    %from an experiment

    properties (SetAccess = public)
        DefaultPath = [];       
        TimeSeries = [];
        oExperiment;
        Original = [];
        Baseline = [];
        RMS = [];
        Slope = [];
        RejectedElectrodes = [];
    end
            
    methods
        function oUnemap = Unemap()
            %% Constructor
            oUnemap = oUnemap@BasePotential();
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function SaveEntity(oUnemap,sPath)
            SaveEntity@BaseEntity(oUnemap,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oUnemap,sPath)
            SaveEntity(oUnemap,sPath);
        end
        
        function aOutData = ProcessData(oBasePotential, aInData, varargin)
            aOutData = ProcessData@BasePotential(oBasePotential, aInData, varargin);
        end
               
        function oUnemap = GetUnemapFromMATFile(oUnemap, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oUnemap.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oUnemap.TimeSeries = oData.oEntity.TimeSeries;
            oUnemap.oExperiment = Experiment(oData.oEntity.oExperiment);
            oUnemap.Original = oData.oEntity.Original;
            oUnemap.Baseline = oData.oEntity.Baseline;
            oUnemap.RMS = oData.oEntity.RMS;
            oUnemap.Slope = oData.oEntity.Slope;
            oUnemap.RejectedElectrodes = oData.oEntity.RejectedElectrodes;
        end
        

        function oUnemap = GetUnemapFromTXTFile(oUnemap,sFile)
            %   Get an entity by loading data from a txt file - only done the
            %   first time you are creating a PotentiaModel entity
            
            %   If the PotentialModel does not have an Experiment loaded yet
            %   then load one
            if isempty(oUnemap.oExperiment)
                %   Look for a metadata file in the same directory that will
                %   contain the Experiment data
                [sPath] = fileparts(sFile);
                aFileFull = fGetFileNamesOnly(sPath,'*_metadata.txt');
                %   There should be one experiment file and no more
                if (size(aFileFull,1) > 1 || size(aFileFull,1) == 0)
                    ME = MException('VerifyInput:TooManyInputFiles', sprintf('There is the wrong number of experimental metadata files in the directory %s',sPath));
                    throw(ME);
                end
                %   Get the Experiment entity
                oUnemap.oExperiment = GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            end
            %   Load the potential data from the txt file
            aFileContents = oUnemap.oDAL.LoadFromFile(sFile);
            %   Set the Original and TimeSeries Structured arrays
            oUnemap.Original = aFileContents(:,2:oUnemap.oExperiment.Unemap.NumberOfElectrodes+1);
            oUnemap.TimeSeries = [1:1:size(oUnemap.Original,1)]*(1/oUnemap.oExperiment.Unemap.ADConversion.SamplingRate);
        end
    end
end

