classdef EditValuesEnteredEvent < BaseEventData
    %   EditValuesEnteredEvent
    %   This returns event data after a user has entered values into the
    %   edit text fields of EditControl
    
    properties
        Values;
    end
    
    methods
        %% Constructor
        function oEventData = EditValuesEnteredEvent(aValues)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.Values = aValues;
        end
    end
    
end

