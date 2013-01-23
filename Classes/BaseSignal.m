classdef BaseSignal < BaseEntity
    %BaseSignal 
    %   This is the base class for any signal acquired.
    
    properties
    end
    
    methods
         %% Constructor
        function oBaseSignal = BaseSignal()
            oBaseSignal = oBaseSignal@BaseEntity();
        end
    end
    
end

