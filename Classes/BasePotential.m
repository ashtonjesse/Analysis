classdef BasePotential < BaseEntity
    %   BasePotential 
    %   This is the base class for all entities that hold experimental data
    %   of the potential type. 
    
    properties
    end
    
    methods
        %% Constructor
        function oEntity = BasePotential()
            oEntity = oEntity@BaseEntity();
        end
    end
    
    methods (Access = protected)
        %% Protected methods that are inherited
        function SaveEntity(oEntity,sPath)
            SaveEntity@BaseEntity(oEntity,sPath);
        end
    end
end

