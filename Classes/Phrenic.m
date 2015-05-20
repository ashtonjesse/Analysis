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
            oPhrenic.Electrodes.Processed.Data = oPhrenic.Electrodes.Processed.Data(2:(end-2));
            oPhrenic.TimeSeries = [1:1:size(oPhrenic.Electrodes.Processed.Data,1)] * (1/dNewFrequency);
            oPhrenic.Electrodes.Status = 'Processed';
        end
        
        function ComputeIntegral(oPhrenic, varargin)
            if nargin > 1
                %data has been supplied so use it
                oPhrenic.Electrodes.Processed.Integral = oPhrenic.ComputeRectifiedBinIntegral(varargin{2}, varargin{1});
            elseif nargin == 1
                oPhrenic.Electrodes.Processed.Integral = oPhrenic.ComputeRectifiedBinIntegral(oPhrenic.Electrodes.(oPhrenic.Electrodes.Status).Data, varargin{1});
            end
            if isfield(oPhrenic.Electrodes.Processed,'BurstIndexes')
                %save the magnitude of each burst
                oPhrenic.Electrodes.Processed.BurstMagnitude = zeros(size(oPhrenic.Electrodes.Processed.BurstIndexes,1),1);
                for i = 1:size(oPhrenic.Electrodes.Processed.BurstIndexes,1)
                    oPhrenic.Electrodes.Processed.BurstMagnitude(i) = max(oPhrenic.Electrodes.Processed.Integral(oPhrenic.Electrodes.Processed.BurstIndexes(i,1): ...
                        oPhrenic.Electrodes.Processed.BurstIndexes(i,2)));
                end
            end
        end
        
        function CalculateBurstRate(oPhrenic, aIndices)
            % aIndices provides an array of indexes the length of the
            % phrenic data that indicate where datapoints should belong to
            % a phrenic burst. This function loops through these find the
            % start and end points of each block and then calculating the
            % rate of bursts based on the central point of each block
            aEdges = diff(aIndices) > 1;
            %add a zero to the beginning
            aFirstIndices = aIndices([false ; aEdges]);
            aFirstIndices = aFirstIndices(1:end-1);
            aSecondIndices = aIndices(aEdges);
            aSecondIndices = aSecondIndices(2:end);
            aBurstIndices = (aSecondIndices - aFirstIndices) > 2000;
            oPhrenic.Electrodes.Processed.BurstIndexes = [aFirstIndices(aBurstIndices), aSecondIndices(aBurstIndices)];
            dLocs = oPhrenic.Electrodes.Processed.BurstIndexes(:,2) - oPhrenic.Electrodes.Processed.BurstIndexes(:,1);
            dLocs = floor(dLocs / 2) + oPhrenic.Electrodes.Processed.BurstIndexes(:,1);
            [aRateData, aRates, dPeaks] = GetRateData(oPhrenic,dLocs);
            oPhrenic.Electrodes.Processed.BurstRates = aRates;
            oPhrenic.Electrodes.Processed.BurstRateData = aRateData;
            oPhrenic.Electrodes.Processed.BurstRateTimes = oPhrenic.TimeSeries(dLocs);
            oPhrenic.Electrodes.Processed.BurstDurations = oPhrenic.TimeSeries(oPhrenic.Electrodes.Processed.BurstIndexes(:,2)) - ...
                oPhrenic.TimeSeries(oPhrenic.Electrodes.Processed.BurstIndexes(:,1));
        end
    end
end

