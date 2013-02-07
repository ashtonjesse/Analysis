classdef Phrenic < BaseSignal
    %Phrenic is a subclass  of type BaseSignal that is associated with the
    %Phrenic recording from an Experiment.
    %    Phrenic inherits all properties and methods from BaseSignal.
    
    properties
        oExperiment;
        Original;
        TimeSeries;
        RefSignal;
        Processed;
        Status = 'Original';
    end
    
    methods
        function oPhrenic = Phrenic()
            %% Constructor
            oPhrenic = oPhrenic@BaseSignal();
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oPressure,sPath)
            SaveEntity@BaseEntity(oPressure,sPath);
        end
    end
    
    
end

