classdef Potential < handle
    %Potential is a class that is associated with the potential data
    %from an experiment

    properties (SetAccess = public)
        DefaultPath = [];       
        TimeSeries = [];
        Experiment = [];
        Original = [];
        Baseline = [];
        RMS = [];
        Slope = [];
        RejectedElectrodes = [];
    end
    
     properties (SetAccess = private)
            oDAL;
     end
       
    methods
%         Constructor
        function oPotential = Potential()
            oPotential.oDAL = BaseDAL();
        end
        
%         Get an entity by loading a mat file that has been saved
%         previously
        function oPotential = GetEntityFromMATFile(oPotential, sFile)
%             Load the mat file into the workspace
            oData = oPotential.oDAL.LoadFromFile(sFile);
%             Reload all the properties 
            oPotential.TimeSeries = oData.oEntity.TimeSeries;
            oPotential.Experiment = oData.oEntity.Experiment;
            oPotential.Original = oData.oEntity.Original;
            oPotential.Baseline = oData.oEntity.Baseline;
            oPotential.RMS = oData.oEntity.RMS;
            oPotential.Slope = oData.oEntity.Slope;
            oPotential.RejectedElectrodes = oData.oEntity.RejectedElectrodes;
        end
        
%         Get an entity by loading data from a txt file - only done the
%         first time you are creating a PotentiaModel entity
        function oPotential = GetEntityFromTXTFile(oPotential,sFile)
%             If the PotentialModel does not have an Experiment loaded yet
%             then load one
            if isempty(oPotential.Experiment)
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
                oPotential.Experiment = GetEntityFromFile(Experiment, char(aFileFull(1)));
            end
%             Load the potential data from the txt file
            aFileContents = oPotential.DAL.LoadFromFile(sFile);
%             Set the Original and TimeSeries Structured arrays
            oPotential.Original = aFileContents(:,2:oPotential.Experiment.Unemap.NumberOfElectrodes+1);
            oPotential.TimeSeries = [1:1:size(oPotential.Original,1)]*(1/oPotential.Experiment.Unemap.ADConversion.SamplingRate);
        end
        
        function Save(oPotential,sPath)
%             Save this Potential to the specified path sPath

            oPotential.oDAL.SaveEntity(oPotential,sPath);
        end
    end
    
end

