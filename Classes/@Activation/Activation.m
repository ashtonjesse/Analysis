classdef Activation < handle
    %Activation is an object associated with the activation markings from
    %an Experiment.
    %   Activation has an associated Experiment object.
    
    properties
        Experiment;
        Times;
    end
    
    methods
        function oActivation = Activation(oExperiment, oTimes)
            if nargin > 0
                oActivation.Experiment = oExperiment;
                oActivation.Times = oTimes;
            end
        end
    end
    
end

