classdef PotentialModel < handle
    %PotentialModel is a class that is associated with the potential data
    %from an experiment
%     %% Environment
% Data.Environment.Temperature = input('Temperature (degC): ');
% Data.Environment.PumpFlowRate = input('Pump Flow Rate (mL/min): ');
% Data.Environment.PerfusionPressure = input('Prefusion Pressure (mmHg): ');
% Data.Environment.Drugs = input('Most recent drugs (time, concentration, volume): ');
% 
% %% Protocols
% Data.Protocols.Pacing.Electrodes = [];
% Data.Protocols.Pacing.Current = input('Pacing Current: ');
% Data.Protocols.Pacing.Frequency = input('Pacing Frequency: ');

    properties (SetAccess = public)
        TimeSeries = [];
        Experiment = [];
        Original = [];
        Baseline = [];
        RMS = [];
        Slope = [];
        RejectedElectrodes = [];
    end
    
     properties (SetAccess = private)
            m_oDAL;
     end
       
    methods
%         Constructor
        function oPotentialModel = PotentialModel()
            oPotentialModel.m_oDAL = BaseDAL();
        end
        
%         Get an entity by loading a mat file that has been saved
%         previously
        function oPotentialModel = GetEntityFromMATFile(oPotentialModel, sFile)
%             Load the mat file into the workspace
            oData = oPotentialModel.m_oDAL.LoadFromFile(sFile);
%             Reload all the properties 
            oPotentialModel.TimeSeries = oData.oPotentialModel.TimeSeries;
            oPotentialModel.Experiment = oData.oPotentialModel.Experiment;
            oPotentialModel.Original = oData.oPotentialModel.Original;
            oPotentialModel.Baseline = oData.oPotentialModel.Baseline;
            oPotentialModel.RMS = oData.oPotentialModel.RMS;
            oPotentialModel.Slope = oData.oPotentialModel.Slope;
            oPotentialModel.RejectedElectrodes = oData.oPotentialModel.RejectedElectrodes;
        end
        
%         Get an entity by loading data from a txt file - only done the
%         first time you are creating a PotentiaModel entity
        function oPotentialModel = GetEntityFromTXTFile(oPotentialModel,sFile)
%             If the PotentialModel does not have an Experiment loaded yet
%             then load one
            if isempty(oPotentialModel.Experiment)
%                 Look for a metadata file in the same directory that will
%                 contain the Experiment data
                [sPath] = fileparts(sFile); 
                aFileFull = fGetFileNamesOnly(sPath,'*_metadata.txt');
%                 There should be one experiment file and no more
                if (size(aFileFull,1) > 1 || size(aFileFull,1) == 0)
                    ME = MException('VerifyInput:TooManyInputFiles', sprintf('There is the wrong number of experimental metadata files in the directory %s',sPath));
                    throw(ME);
                end
%                 Get the Experiment entity
                oPotentialModel.Experiment = GetEntityFromFile(Experiment, char(aFileFull(1)));
            end
%             Load the potential data from the txt file
            aFileContents = oPotentialModel.m_oDAL.LoadFromFile(sFile);
%             Set the Original and TimeSeries Structured arrays
            oPotentialModel.Original = aFileContents(:,2:oPotentialModel.Experiment.Unemap.NumberOfElectrodes+1);
            oPotentialModel.TimeSeries = [1:1:size(oPotentialModel.Original,1)]*(1/oPotentialModel.Experiment.Unemap.ADConversion.SamplingRate);
        end
        
        function Save(oPotentialModel,sPath)
%             Save this PotentialModel to the specified path sPath
            oPotentialModel.m_oDAL.SaveEntity(oPotentialModel,sPath);
        end
    end
    
end

