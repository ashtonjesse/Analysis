classdef Experiment < handle
    %The Experiment Class.
    %   The handle class for all information associated with a experiment
        
    properties (SetAccess = public)
        Date;
        Material;
        Unemap;
        PerfusionPressureAmp;
        PhrenicAmp;
        ECGAmp;
    end
    
    properties (SetAccess = private)
        oDAL;
    end
    
    methods

        function oExperiment = Experiment()
%          Constructor

%             Create a new instance of BaseDAL for this Experiment
            oExperiment.oDAL = BaseDAL();
        end
        

        function oExperiment = GetEntityFromFile(oExperiment, sFile)
%         Create a Experiment entity from a metadata file

%             Get the entity via the DAL
            oExperiment = oExperiment.oDAL.CreateEntityFromFile(sFile);
        end
    end
    
end

