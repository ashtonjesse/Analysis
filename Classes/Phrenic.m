classdef Phrenic < BasePotential
    %Phrenic is a subclass  of type BasePotential that is associated with the
    %Phrenic recording from an Experiment.
    %    Phrenic inherits all properties and methods from BasePotential.
    %    This class is not properly implemented in that some data access
    %    does not go through the DAL so be warned
    %    
    properties
        oExperiment;
        Electrodes = [];
        TimeSeries;
    end
    
    methods
        function oPhrenic = Phrenic(varargin)
            %% Constructor
            oPhrenic = oPhrenic@BasePotential();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Phrenic')
                    oPhrenicStruct = varargin{1};
                    %get the fields
                    sFields = fields(oPhrenicStruct);
                    %loop through and load these fields
                    for i = 1:length(sFields)
                        oPhrenic.(char(sFields{i})) = oPhrenicStruct.(char(sFields{i}));
                    end
                end
            elseif nargin == 3
                %first argument needs to be numeric array and second should
                %be Experiment entity
                % Load the experiment
                oPhrenic.oExperiment = varargin{1};
                %Initialise the Electrodes struct
                oPhrenic.Electrodes = struct('Name','','Location',[],'Status','Potential','Accepted',1,'Potential',[]);
                oPhrenic.Electrodes.Potential.Data = varargin{2};
                oPhrenic.TimeSeries = varargin{3};
            end
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oPhrenic,sPath)
            SaveEntity@BaseEntity(oPhrenic,sPath);
        end
    end
    
    methods (Access = public)
        function ResampleData(oPhrenic, dNewFrequency, dOldFrequency)
            oPhrenic.Electrodes.Processed.Data = oPhrenic.ResampleSignal(oPhrenic.Electrodes.(oPhrenic.Electrodes.Status).Data, dNewFrequency, dOldFrequency);
            oPhrenic.TimeSeries = [1:1:size(oPhrenic.Electrodes.Processed.Data,1)] * (1/dNewFrequency);
            oPhrenic.Electrodes.Status = 'Processed';
        end
        
        function ComputeIntegral(oPhrenic, iBinSize)
            oPhrenic.Electrodes.Processed.Integral = oPhrenic.ComputeRectifiedBinIntegral(oPhrenic.Electrodes.(oPhrenic.Electrodes.Status).Data, iBinSize);
        end
    end
end

