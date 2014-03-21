classdef Experiment < BaseEntity
    %The Experiment Class.
    %   The handle class for all information associated with an experiment
        
    properties 
        Date;
        Material;
        Unemap;
        PerfusionPressure;
        Phrenic;
        ECG;
        Plot;
        Array;
        Optical;
    end
        
    methods
        function oExperiment = Experiment(varargin)
            %% Constructor
            oExperiment = oExperiment@BaseEntity();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Experiment')
                    oExperimentStruct = varargin{1};
                    %get the fields
                    sFields = fields(oExperimentStruct);
                    %loop through and load these fields
                    for i = 1:length(sFields)
                        oExperiment.(char(sFields{i})) = oExperimentStruct.(char(sFields{i}));
                    end
                end
            end
        end
        
        %% Public methods
        function oExperiment = GetExperimentFromTxtFile(oExperiment, sFile)
            %   Create a Experiment entity from a metadata file

            %   Get the entity via the DAL
            oExperiment = oExperiment.oDAL.CreateEntityFromFile(oExperiment,sFile);
        end
    end
    
end

