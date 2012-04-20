classdef Unemap < BasePotential
    %Unemap is a class that is associated with the potential data
    %from an experiment

    properties (SetAccess = public)
        TimeSeries = [];
        oExperiment;
        Electrodes = [];       
        RMS = [];
    end
            
    methods
        function oUnemap = Unemap()
            %% Constructor
            oUnemap = oUnemap@BasePotential();
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oUnemap,sPath)
            SaveEntity@BaseEntity(oUnemap,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oUnemap,sPath)
            SaveEntity(oUnemap,sPath);
        end
        %% Inherited methods
        function aOutData = ProcessData(oUnemap, aInData, sProcedure, iOrder)
            aOutData = ProcessData@BasePotential(oUnemap, aInData, sProcedure, iOrder);
        end
                      
        function aOutData = CalculateVrms(oBasePotential, aInData, varargin)
            aOutData = CalculateVrms@BasePotential(oBasePotential, aInData, varargin);
        end

        function aOutData = CalculateCurvature(oBasePotential, aInData ,iNumberofPoints,iModelOrder)
            aOutData = CalculateCurvature@BasePotential(oBasePotential, aInData, iNumberofPoints,iModelOrder);
        end
        
        %% Class specific methods
        function ProcessArrayData(oUnemap, sProcedure, iOrder)
            %Does some checks and then calls the inherited ProcessData
            %method
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = oUnemap.oExperiment.Unemap.NumberOfChannels;
            if isnan(oUnemap.Electrodes(1).Processed.Data(1))
                %Perform the processing on the original data
                for i=1:iTotal
                    oUnemap.Electrodes(i).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(i).Potential,sProcedure,iOrder);
                     %Update the waitbar
                        waitbar(i/iTotal,oWaitbar,sprintf(...
                            'Please wait... Baseline Correcting Signal %d',i));
                end
            else
                %Perform the processing on already processed data
                for i=1:iTotal
                    oUnemap.Electrodes(i).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(i).Processed.Data,sProcedure,iOrder);
                    %Update the waitbar
                    waitbar(i/iTotal,oWaitbar,sprintf(...
                        'Please wait... Spline Smoothing Signal %d',i));
                end
            end
            close(oWaitbar);
        end
        
        function ProcessElectrodeData(oUnemap, sProcedure, iOrder, iChannel)
            %Does some checks and then calls the inherited ProcessData
            %method
            
            if isnan(oUnemap.Electrodes(iChannel).Processed.Data(1))
                %Perform the processing on the original data
                oUnemap.Electrodes(iChannel).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(iChannel).Potential,sProcedure,iOrder);
            else
                %Perform the processing on already processed data
                oUnemap.Electrodes(iChannel).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(iChannel).Processed.Data,sProcedure,iOrder);
            end
        end
            
        function oUnemap = GetUnemapFromMATFile(oUnemap, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oUnemap.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties 
            oUnemap.TimeSeries = oData.oEntity.TimeSeries;
            oUnemap.oExperiment = Experiment(oData.oEntity.oExperiment);
            oUnemap.Electrodes = oData.oEntity.Electrodes;
            oUnemap.RMS = oData.oEntity.RMS;
        end
        

        function oUnemap = GetUnemapFromTXTFile(oUnemap,sFile)
            %   Get an entity by loading data from a txt file - only done the
            %   first time you are creating a Unemap entity
            
            %   Get the path
            [sPath] = fileparts(sFile);
            %   If the Unemap does not have an Experiment loaded yet
            %   then load one
            if isempty(oUnemap.oExperiment)
                %   Look for a metadata file in the same directory that will
                %   contain the Experiment data
                aFileFull = fGetFileNamesOnly(sPath,'*_experiment.txt');
                %   There should be one experiment file and no more
                if ~(size(aFileFull,1) == 1)
                    error('VerifyInput:TooManyInputFiles', 'There is the wrong number of experimental metadata files in the directory %s',sPath);
                end
                %   Get the Experiment entity
                oUnemap.oExperiment = GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            end
            
            %   Look for an array config file in the same directory that will
            %   contain the electrode names/positions
            aFileFull = fGetFileNamesOnly(sPath,'*.cnfg');
            %   There should be one config file and no more
            if ~(size(aFileFull,1) == 1)
                error('VerifyInput:TooManyInputFiles', 'There is the wrong number of config files in the directory %s',sPath);
            end
            % Get the electrodes 
            oUnemap.Electrodes = oUnemap.oDAL.GetElectrodesFromConfigFile(...
                oUnemap.oExperiment.Unemap.NumberOfChannels, char(aFileFull(1)));
            % Get the electrode data
            oUnemap.oDAL.GetDataFromSignalFile(oUnemap,sFile);
        end
    end
end

