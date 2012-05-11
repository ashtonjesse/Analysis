classdef DataAcceptedEvent < BaseEventData
    %   DataSelectedEvent 
    %   This returns accepted event data and is designed to be used with
    %   the ComparePlots figure.
    
    properties
        XData;
        Y1Data;
        Y2Data;
    end
    
    methods
        %% Constructor
        function oEventData = DataAcceptedEvent(dXData,dY1Data,dY2Data)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.XData = dXData;
            oEventData.Y1Data = dY1Data;
            oEventData.Y2Data = dY2Data;
        end
    end
    
end

