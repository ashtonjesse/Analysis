classdef Activation < handle
    %Activation is an object associated with the activation markings from
    %an Experiment.
    %   Activation has an associated Experiment object.
    
    properties
        oExperiment;
        Times;
    end
    
    methods
        function oActivation = Activation(oExperiment, oTimes)
            if nargin > 0
                oActivation.oExperiment = oExperiment;
                oActivation.Times = oTimes;
            end
        end
    end
    
end

