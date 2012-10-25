classdef LineSpecificDragEvent < BaseEventData
    %   LineSpecificDragEvent
    %   This returns event data associated with dragging a line on a set of
    %   axes where there are multiple lines
    
    properties
        ParentAxesHandle;
        LineTag;
    end
    
    methods
        %% Constructor
        function oEventData = LineSpecificDragEvent(oParentAxesHandle, sLineTag)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.ParentAxesHandle = oParentAxesHandle;
            oEventData.LineTag = sLineTag;
        end
    end
    
end

