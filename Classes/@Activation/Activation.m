classdef Activation < BaseEntity
    %   Activation is an entity associated with the activation markings from
    %   an Experiment.
    %   This is currently unused as the relavant methods are under the
    %   Unemap entity. Not sure if this is the best data model but will
    %   work for now.
    
    properties
        TimeSeries;
        SteepestSlope;
    end
    
    methods
        function oActivation = Activation(aTimeSeries)
            oActivation.TimeSeries = aTimeSeries;
        end
    end
    
end

