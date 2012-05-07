classdef DataSelectedEvent < BaseEventData
    %   DataSelectedEvent 
    %   This returns selected event data and is designed to be used with
    %   the SelectData figure.
    
    properties
        XData;
        YData;
        Option;
    end
    
    methods
        %% Constructor
        function oEventData = DataSelectedEvent(dSelectedXData,dSelectedYData,sOption)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.XData = dSelectedXData;
            oEventData.YData = dSelectedYData;
            oEventData.Option = sOption;
        end
    end
    
end

