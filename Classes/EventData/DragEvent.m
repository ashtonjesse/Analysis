classdef DragEvent < BaseEventData
    %   DragEvent 
    %   This returns event data associated with dragging a line on a set of
    %   axes
    
    properties
        ParentAxesHandle;
    end
    
    methods
        %% Constructor
        function oEventData = DragEvent(oParentAxesHandle)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.ParentAxesHandle = oParentAxesHandle;
        end
    end
    
end

