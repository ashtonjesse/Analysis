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
                      
        function aOutData = CalculateCurvature(oUnemap, aInData ,iNumberofPoints,iModelOrder)
            aOutData = CalculateCurvature@BasePotential(oUnemap, aInData, iNumberofPoints,iModelOrder);
        end
        
        function aGradient = CalculateSlope(oUnemap, aInData ,iNumberofPoints,iModelOrder)
            aGradient = CalculateSlope@BasePotential(oUnemap, aInData, iNumberofPoints,iModelOrder);
        end
        
        function aOutData = GetBeats(oUnemap, aInData, aPeaks)
            aOutData = GetBeats@BasePotential(oUnemap, aInData, aPeaks);
        end
                
        %% Methods relating to Electrode potential raw and processed data
        function AcceptChannel(oUnemap,iElectrodeNumber)
            oUnemap.Electrodes(iElectrodeNumber).Accepted = 1;
        end
        
        function RejectChannel(oUnemap,iElectrodeNumber)
            oUnemap.Electrodes(iElectrodeNumber).Accepted = 0;
        end
        
        function GetCurvature(oUnemap,iElectrodeNumber)
            if isnan(oUnemap.Electrodes(iElectrodeNumber).Processed.Data(iElectrodeNumber))
                error('Unemap.GetCurvature.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Perform on processed data
                oUnemap.Electrodes(iElectrodeNumber).Processed.Curvature = ...
                    oUnemap.CalculateCurvature(oUnemap.Electrodes(iElectrodeNumber).Processed.Data,20,5);
            end
        end
        
        function GetSlope(oUnemap,iElectrodeNumber)
            if isnan(oUnemap.Electrodes(iElectrodeNumber).Processed.Data(iElectrodeNumber))
                error('Unemap.GetSlope.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Perform on processed data
                oUnemap.Electrodes(iElectrodeNumber).Processed.Slope = ...
                    oUnemap.CalculateSlope(oUnemap.Electrodes(iElectrodeNumber).Processed.Data,20,5);
            end
        end
        
        function [aFitData aElectrodeData] = GetInterBeatVariation(oUnemap,iOrder)
            %Makes a call to ProcessData to calculate the interbeat variation
            %in amplitude by fitting a polynomial to the isoelectric lines
            %preceeding each beat
            
            if isnan(oUnemap.Electrodes(1).Processed.Data(1))
                error('Unemap.RemoveInterBeatVariation.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Get the electrode processed data and detected beats
                aElectrodeData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
                aBeats = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Beats');
                %Concatenate these arrays into a cell array for passing to
                %ProcessData
                aInData = {aElectrodeData,aBeats};
                aFitData = oUnemap.ProcessData(aInData,'RemoveInterpolation',iOrder);
            end
        end
        
        function RemoveInterBeatVariation(oUnemap, aFitData)
            %Get the electrode processed data 
            aElectrodeData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
            %Remove the fit
            aOutData = aElectrodeData - aFitData;
            %Save this to the electrode data
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aOutData); 
        end
        
        function GetArrayBeats(oUnemap, aPeaks)
            %Does some checks and then calls the inherited GetBeats
            %method
            
            if isnan(oUnemap.Electrodes(1).Processed.Data(1))
                error('Unemap.GetArrayBeats.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Detect beats on the processed data
                %Concatenate all the electrode processed data into one
                %array
                aInData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
            end
            aOutData = oUnemap.GetBeats(aInData,aPeaks);
            %Split again into the Electrodes
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Beats',cell2mat(aOutData(1)));
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','BeatIndexes',cell2mat(aOutData(2)));
        end
        
        function iIndexes = GetClosestBeat(oUnemap,iElectrodeNumber,dTime)
                %Get the start times of all the beats
                aIntervalStart = oUnemap.TimeSeries(oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(:,1));
                %Find the index of the closest time to the input time 
                [Value, iMinIndex] = min(abs(aIntervalStart - dTime));
                %Return the beat index of this time
                iIndexes = {iMinIndex, oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iMinIndex,:)};
        end
        
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
                    oUnemap.GetSlope(i);
                    oUnemap.GetCurvature(i);
                    oUnemap.AcceptChannel(i);
                    %Update the waitbar
                        waitbar(i/iTotal,oWaitbar,sprintf(...
                            'Please wait... Baseline Correcting Signal %d',i));
                end
            else
                %Perform the processing on already processed data
                for i=1:iTotal
                    oUnemap.Electrodes(i).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(i).Processed.Data,sProcedure,iOrder);
                    oUnemap.GetSlope(i);
                    oUnemap.GetCurvature(i);
                    oUnemap.AcceptChannel(i);
                    %Update the waitbar
                    waitbar(i/iTotal,oWaitbar,sprintf(...
                        'Please wait... Spline Smoothing Signal %d',i));
                end
            end
            close(oWaitbar);
        end
        
        function ProcessElectrodeData(oUnemap, sProcedure, iOrder, iElectrodeNumber)
            %Does some checks and then calls the inherited ProcessData
            %method
            
            if isnan(oUnemap.Electrodes(iElectrodeNumber).Processed.Data(1))
                %Perform the processing on the original data
                oUnemap.Electrodes(iElectrodeNumber).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(iElectrodeNumber).Potential,sProcedure,iOrder);
            else
                %Perform the processing on already processed data
                oUnemap.Electrodes(iElectrodeNumber).Processed.Data = ...
                        oUnemap.ProcessData(oUnemap.Electrodes(iElectrodeNumber).Processed.Data,sProcedure,iOrder);
            end
            oUnemap.GetSlope(iElectrodeNumber);
            oUnemap.GetCurvature(iElectrodeNumber);
            oUnemap.AcceptChannel(iElectrodeNumber);
        end
        
        function FilterElectrodeData(oUnemap, iElectrodeNumber)
            %Build 50Hz notch filter and apply to selected channel
            
            %Get nyquist frequency
            wo = oUnemap.oExperiment.Unemap.ADConversion.SamplingRate/2;
            [z p k] = butter(3, [49 51]./wo, 'stop'); % 10th order filter
            [sos,g] = zp2sos(z,p,k); % Convert to 2nd order sections form
            oFilter = dfilt.df2sos(sos,g); % Create filter object
            %Check if this filter should be applied to processed or
            %original data
            if isnan(oUnemap.Electrodes(iElectrodeNumber).Processed.Data(1))
                aFilteredData = filter(oFilter,oUnemap.Electrodes(iElectrodeNumber).Potential);
                oUnemap.Electrodes(iElectrodeNumber).Processed.Data = aFilteredData;
            else
                aFilteredData = filter(oFilter,oUnemap.Electrodes(iElectrodeNumber).Processed.Data);
                oUnemap.Electrodes(iElectrodeNumber).Processed.Data = aFilteredData;
            end
        end
        
        function TruncateArrayData(oUnemap, bIndexesToKeep)
            %This performs a truncation on potential data and processed
            %data as well if there is some
            
            %Truncate the time series
            oUnemap.TimeSeries = oUnemap.TimeSeries(bIndexesToKeep);
            
            %Get an array of columns with the potential data from each
            %electrode
            aPotentialData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Potential');
            %Select the indexes to keep
            aPotentialData = aPotentialData(bIndexesToKeep,:);
            %Truncate the potential data
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Potential',aPotentialData);

            if ~isnan(oUnemap.Electrodes(1).Processed.Data(1))
                %perform on existing potential data as well
                aProcessedData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aProcessedData);
            end
            
        end
        
        %% Methods relating to Electrode Activation data
        function MarkActivation(oUnemap, sMethod)
             if isnan(oUnemap.Electrodes(1).Processed.Data(1))
                error('Unemap.GetActivationTime.VerifyInput:NoProcessedData',...
                    'You need to have processed data before calculating an activation time');
             else
                 %Choose the method to apply
                 switch (sMethod)
                     case 'SteepestSlope'
                         for i = 1:size(oUnemap.Electrodes,2);
                             % Get slope data if this has not been done already
                             if isnan(oUnemap.Electrodes(i).Processed.Slope)
                                 oUnemap.GetSlope(i);
                             end
                             oUnemap.Electrodes(i).Activation(1).Indexes = fSteepestSlope(oUnemap.TimeSeries, ...
                                 oUnemap.Electrodes(i).Processed.Slope, ...
                                 oUnemap.Electrodes(i).Processed.BeatIndexes);
                             oUnemap.Electrodes(i).Activation(1).Method = 'SteepestSlope';
                         end
                         
                 end
            end
        end
        %% Functions for reconstructing entity
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

