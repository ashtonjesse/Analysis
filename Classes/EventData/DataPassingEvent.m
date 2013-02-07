classdef DataPassingEvent < BaseEventData
    %   DataSelectedEvent 
    %   This returns data
    
    properties
        ArrayData;
        Value;
    end
    
    methods
        %% Constructor
        function oEventData = DataPassingEvent(aArrayData,dValue)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.ArrayData = aArrayData;
            oEventData.Value = dValue;
        end
    end
    
end

