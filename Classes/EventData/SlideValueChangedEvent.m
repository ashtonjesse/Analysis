classdef SlideValueChangedEvent < BaseEventData
    %   SlideValueChangedEvent 
    %   This returns the selected value from SlideControl
    
    properties
        Value;
    end
    
    methods
        %% Constructor
        function oEventData = SlideValueChangedEvent(dValue)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.Value = dValue;
        end
    end
    
end

