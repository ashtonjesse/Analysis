classdef Protocol
    %Protocol wraps the oProtocol structured array
    %   This struct contains information regarding the pacing protocols
    %   used during a recording
    
    properties (SetAccess = private)
        m_oDAL;
    end
    
    methods

        function oProtocol = Protocol()
%          Constructor

%             Create a new instance of BaseDAL for this Protocol
            oProtocol.m_oDAL = BaseDAL();
        end
        

        function oProtocol = GetEntityFromFile(oProtocol, sFile)
%         Create a Protocol entity from a metadata file

%             Get the entity via the DAL
            oProtocol = oProtocol.m_oDAL.CreateEntityFromFile(sFile);
        end
    end
    
end

