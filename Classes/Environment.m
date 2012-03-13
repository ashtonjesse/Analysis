classdef Environment
    %Environment wraps the oEnvironment structured array
    %   This struct contains information regarding the experimental
    %   conditions at the time of recording
     
    properties (SetAccess = private)
        m_oDAL;
    end
    
    methods

        function oEnvironment = Environment()
%          Constructor

%             Create a new instance of BaseDAL for this Environment
            oEnvironment.m_oDAL = BaseDAL();
        end
        

        function oEnvironment = GetEntityFromFile(oEnvironment, sFile)
%         Create a Environment entity from a metadata file

%             Get the entity via the DAL
            oEnvironment = oEnvironment.m_oDAL.CreateEntityFromFile(sFile);
        end
    end
    
end

