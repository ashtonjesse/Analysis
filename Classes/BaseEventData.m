classdef BaseEventData < event.EventData
    %   BaseEventData 
    %   This class extends the event.EventData class so that data can be
    %   passed back when events occur through "notify"
    
    %   Currently has no use but really here "just in case" I need some
    %   code common amongst classes that inherit from event.EventData
    properties
        
    end
    
    methods
        function oEventData = BaseEventData()
            
        end
    end
    
end

