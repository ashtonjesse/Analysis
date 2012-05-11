classdef DataSelectedEvent < BaseEventData
    %   DataSelectedEvent 
    %   This returns selected event data and is designed to be used with
    %   the SelectData figure.
    
    properties
        XData;
        YData;
        Indexes;
        Option;
    end
    
    methods
        %% Constructor
        function oEventData = DataSelectedEvent(dSelectedXData,dSelectedYData,dIndexes,sOption)
            %The constructor takes input values and sets the appropriate
            %properties
            oEventData = oEventData@BaseEventData();
            oEventData.XData = dSelectedXData;
            oEventData.YData = dSelectedYData;
            oEventData.Indexes = dIndexes;
            oEventData.Option = sOption;
        end
    end
    
end

