classdef Experiment < BaseEntity
    %The Experiment Class.
    %   The handle class for all information associated with an experiment
        
    properties 
        Date;
        Material;
        Unemap;
        PerfusionPressureAmp;
        PhrenicAmp;
        ECGAmp;
        Plot;
    end
        
    methods
        function oExperiment = Experiment(varargin)
            %% Constructor
            oExperiment = oExperiment@BaseEntity();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Experiment')
                    oExperimentStruct = varargin{1};
                    oExperiment.Date = oExperimentStruct.Date;
                    oExperiment.Material = oExperimentStruct.Material;
                    oExperiment.Unemap = oExperimentStruct.Unemap;
                    oExperiment.PerfusionPressureAmp = oExperimentStruct.PerfusionPressureAmp;
                    oExperiment.PhrenicAmp = oExperimentStruct.PhrenicAmp;
                    oExperiment.ECGAmp = oExperimentStruct.ECGAmp;
                    oExperiment.Plot = oExperimentStruct.Plot;
                end
            end
        end
        
        %% Public methods
        function oExperiment = GetExperimentFromTxtFile(oExperiment, sFile)
            %   Create a Experiment entity from a metadata file

            %   Get the entity via the DAL
            oExperiment = oExperiment.oDAL.CreateEntityFromFile(sFile);
        end
    end
    
end

