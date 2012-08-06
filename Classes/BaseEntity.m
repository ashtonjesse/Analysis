classdef BaseEntity < handle
    %	BaseEntity 
    %   This is the base class from which all other entities inherit.
    
    properties (SetAccess = protected)
            oDAL;
     end
    
    methods
        %% Constructor
        function oEntity = BaseEntity()
            oEntity.oDAL = BaseDAL();
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function SaveEntity(oEntity,sPath)
            % Save the Entity to the specified location
            oEntity.oDAL.SaveThisEntity(oEntity,sPath);
        end

    end
    
end

