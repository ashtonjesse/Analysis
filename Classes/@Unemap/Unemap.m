classdef Unemap < BasePotential
    %Unemap is a class that wraps the mat binary array that holds the data
    %associated with potential recordings taken using Unemap. It contains
    %methods that can be carried out on this data as well as the methods to
    %construct and save Unemap entities. Most methods act on
    %Unemap.Electrodes(i).Potential but some act on
    %Unemap.Electrodes(i).Activation data. 
    

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
        function [aOutData, aBaselinePolynomial] = RemoveMedianAndFitPolynomial(oUnemap, aInData, iOrder)
            [aOutData, aBaselinePolynomial] = RemoveMedianAndFitPolynomial@BasePotential(oUnemap, aInData, iOrder);
        end
        
        function aOutData = SplineSmoothData(oUnemap, aInData, iOrder)
            aOutData = SplineSmoothData@BasePotential(oUnemap, aInData, iOrder);
        end
        
        function aOutData = FilterData(oUnemap, aInData, sFilterType, varargin)
            aOutData = FilterData@BasePotential(oUnemap, aInData, sFilterType, varargin);
        end
        
        function aOutData = RemoveLinearInterpolation(oUnemap, aInData, iOrder)
            aOutData = RemoveLinearInterpolation@BasePotential(oUnemap, aInData, iOrder);
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
            if strcmp(oUnemap.Electrodes(iElectrodeNumber).Status,'Potential');
                error('Unemap.GetCurvature.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Perform on processed data
                oUnemap.Electrodes(iElectrodeNumber).Processed.Curvature = ...
                    oUnemap.CalculateCurvature(oUnemap.Electrodes(iElectrodeNumber).Processed.Data,20,5);
            end
        end
        
        function GetSlope(oUnemap,iElectrodeNumber)
            if strcmp(oUnemap.Electrodes(iElectrodeNumber).Status,'Potential');
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
            
            if strcmp(oUnemap.Electrodes(1).Status,'Potential');
                error('Unemap.GetInterBeatVariation.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
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
            if strcmp(oUnemap.Electrodes(1).Status,'Potential');
                error('Unemap.RemoveInterBeatVariation.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Get the electrode processed data
                aElectrodeData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
                %Remove the fit
                aOutData = aElectrodeData - aFitData;
                %Save this to the electrode data
                oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aOutData);
            end
        end
        
        function GetArrayBeats(oUnemap, aPeaks)
            %Does some checks and then calls the inherited GetBeats
            %method
            
            if strcmp(oUnemap.Electrodes(1).Status,'Potential');
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
            if strcmp(oUnemap.Electrodes(1).Status,'Potential');
                error('Unemap.GetClosestBeat.VerifyInput:NoProcessedData', 'You need to have processed data');
            else
                %Get the start times of all the beats
                aIntervalStart = oUnemap.TimeSeries(oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(:,1));
                %Find the index of the closest time to the input time
                [Value, iMinIndex] = min(abs(aIntervalStart - dTime));
                %Return the beat index of this time
                iIndexes = {iMinIndex, oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iMinIndex,:)};
            end
        end
        
        function UpdateBeatIndexes(oUnemap, iBeat, aIndexRange)
            %Change the beat information to that supplied by the new range
            
            %Loop through the electrodes
            for i = 1:length(oUnemap.Electrodes)
                %Get the current range for this beat
                aCurrentRange = oUnemap.Electrodes(i).Processed.BeatIndexes(iBeat,:);
                %Reset the current range of this beat to NaN
                oUnemap.Electrodes(i).Processed.Beats(aCurrentRange(1):aCurrentRange(2)) = NaN;
                %Set the new beat values
                oUnemap.Electrodes(i).Processed.Beats(aIndexRange(1):aIndexRange(2)) = ...
                    oUnemap.Electrodes(i).Processed.Data(aIndexRange(1):aIndexRange(2));
                %Set the new beat indexes
                oUnemap.Electrodes(i).Processed.BeatIndexes(iBeat,:) = [aIndexRange(1) aIndexRange(2)];
            end
        end
        
        function ProcessArrayData(oUnemap, aInOptions)
            % Loops through all the electrodes in the array and makes calls
            % to the inherited processing methods
            
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = oUnemap.oExperiment.Unemap.NumberOfChannels;
            %Loop through the channels
            for i=1:iTotal
                %Update the waitbar
                waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Signal %d',i));
                oUnemap.ProcessElectrodeData(i,aInOptions);
            end
            close(oWaitbar);
            
        end
        
        function ProcessElectrodeData(oUnemap, iChannel, aInOptions)
            % makes a call to the inherited processing method for the
            % specified channel
             for j = 1:size(aInOptions,2)
                 %Loop through the entries in aInOptions - an input
                 %struct that contains processing procedures to run and
                 %and their inputs
                 switch(aInOptions(j).Procedure)
                     case 'RemoveMedianAndFitPolynomial'
                         iOrder = aInOptions(j).Inputs;
                         [aOutData, aBaselinePolynomial] = ...
                             oUnemap.RemoveMedianAndFitPolynomial(oUnemap.Electrodes(iChannel).(oUnemap.Electrodes(iChannel).Status).Data,iOrder);
                         oUnemap.Electrodes(iChannel).Processed.Data = aOutData;
                         oUnemap.Electrodes(iChannel).Processed.BaselinePolyOrder = iOrder;
                         oUnemap.Electrodes(iChannel).Processed.BaselinePoly = aBaselinePolynomial;
                         oUnemap.FinishProcessing(iChannel);
                     case 'SplineSmoothData'
                         iOrder = aInOptions(j).Inputs;
                         oUnemap.Electrodes(iChannel).Processed.Data = ...
                             oUnemap.SplineSmoothData(oUnemap.Electrodes(iChannel).(oUnemap.Electrodes(iChannel).Status).Data,iOrder);
                         oUnemap.FinishProcessing(iChannel);
                     case 'FilterData'
                         if strcmp(aInOptions(j).Inputs{1,1},'50HzNotch')
                             dSamplingFreq = aInOptions(j).Inputs{1,2};
                             oUnemap.Electrodes(iChannel).Processed.Data = ...
                                 oUnemap.FilterData(oUnemap.Electrodes(iChannel).(oUnemap.Electrodes(iChannel).Status).Data,'50HzNotch',dSamplingFreq);
                         elseif strcmp(aInOptions(j).Inputs{1,1},'SovitzkyGolay')
                             iOrder = aInOptions(j).Inputs{1,2};
                             iWindowSize = aInOptions(j).Inputs{1,3};
                             oUnemap.Electrodes(iChannel).Processed.Data = ...
                                 oUnemap.FilterData(oUnemap.Electrodes(iChannel).(oUnemap.Electrodes(iChannel).Status).Data,'SovitzkyGolay',iOrder,iWindowSize);
                         end
                         oUnemap.FinishProcessing(iChannel);
                     case 'RemoveLinearInterpolation'
                         iOrder = aInOptions(j).Inputs;
                         oUnemap.Electrodes(iChannel).Processed.Data = ...
                             oUnemap.RemoveLinearInterpolation(oUnemap.Electrodes(iChannel).(oUnemap.Electrodes(iChannel).Status).Data,iOrder);
                     case 'ClearData'
                         oUnemap.ClearProcessedData(iChannel);
                 end
             end
        end
        
        function FinishProcessing(oUnemap,iChannel)
            %A function to call after applying some processing steps
            
            %The channel is now processed
            oUnemap.Electrodes(iChannel).Status = 'Processed';
            %Calculate slope and curvature
            oUnemap.GetSlope(iChannel);
            oUnemap.GetCurvature(iChannel);
            %Each channel is accepted by default
            oUnemap.AcceptChannel(iChannel);
            
        end
        
        function ClearProcessedData(oUnemap, iChannel)
            %Clear the Processed data associated with this channel
            oUnemap.Electrodes(iChannel).Processed.Data = [];
            oUnemap.Electrodes(iChannel).Status = 'Potential';
        end
        
        function TruncateArrayData(oUnemap, bIndexesToKeep)
            %This performs a truncation on potential data and processed
            %data as well if there is some
            
            %Truncate the time series
            oUnemap.TimeSeries = oUnemap.TimeSeries(bIndexesToKeep);
            
            %Get an array of columns with the potential data from each
            %electrode
            aPotentialData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Potential','Data');
            %Select the indexes to keep
            aPotentialData = aPotentialData(bIndexesToKeep,:);
            %Truncate the potential data
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Potential','Data',aPotentialData);

            if strcmp(oUnemap.Electrodes(1).Status,'Processed')
                %perform on existing potential data as well
                aProcessedData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aProcessedData);
            end
            
        end
        
        function [aInterpData, cmin, cmax] = InterpolatePotentialData(oUnemap,iBeat,iInterval,sMethod)
            %Interpolate the potential field for a given beat and return in
            %struct
            
            %Get the beat indexes from the first beat (this assumes that
            %beat indexes for every electrode are the same).
            aBeatIndexes = oUnemap.Electrodes(1).Processed.BeatIndexes;
            %Get the electrode processed data
            aElectrodeData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
            %Turn the coords into a 2 column matrix
            aCoords = [0, 0];
            for j = 1:size(oUnemap.Electrodes,2)
                %I don't give a fuck that this is not an efficient way to
                %do this.
                aCoords = [aCoords; oUnemap.Electrodes(j).Coords(1), oUnemap.Electrodes(j).Coords(2)];
                if ~oUnemap.Electrodes(j).Accepted
                    aElectrodeData(:,j) = NaN;
                end
            end
            aCoords = aCoords(2:end,:);
            aTimeData = oUnemap.TimeSeries(aBeatIndexes(iBeat,1):aBeatIndexes(iBeat,2));
            %Get just the data associated with this beat and transpose it
            %so that it is the same shape as the Coords vector
            aBeat = transpose(aElectrodeData(aBeatIndexes(iBeat,1):aBeatIndexes(iBeat,2),:));
            %Build the interpolation mesh
            [Xi Yi] = meshgrid(min(aCoords(:,1)):iInterval:max(aCoords(:,1)),min(aCoords(:,2)):iInterval:max(aCoords(:,2)));
            %Loop through time getting interpolants and evaluating on mesh
            %grid
            aInterpData = struct();
            %initialise colour limits
            cmin = 100;
            cmax = 0;
            for i = 1:size(aBeat,2);
                newcmin = min(aBeat(:,i));
                if newcmin < cmin
                    cmin = newcmin;
                end
                newcmax = max(aBeat(:,i));
                if newcmax > cmax
                    cmax = newcmax;
                end
                oInterpolant = TriScatteredInterp(aCoords(:,1),aCoords(:,2),aBeat(:,i),sMethod);
                aInterpData(i).Field = oInterpolant(Xi, Yi);
                aInterpData(i).Xi = Xi;
                aInterpData(i).Yi = Yi;
                aInterpData(i).Time =  aTimeData(i);
            end
            
        end
        
        function [row, col] = GetRowColIndexesForElectrode(oUnemap, iElectrodeNumber)
            %Convert the channel number (1...288) into a row and column
            %index in terms of the whole array
            iNumberOfChannels = oUnemap.oExperiment.Unemap.NumberOfChannels;
            iYdim = oUnemap.oExperiment.Plot.Electrodes.yDim; %Actually named the wrong dimension...
            row = ceil((iElectrodeNumber - floor(iElectrodeNumber/((iNumberOfChannels/2) + 1)) * (iNumberOfChannels/2))/iYdim);
            col = iElectrodeNumber + floor(iElectrodeNumber/((iNumberOfChannels/2)+1)) * iYdim - (ceil(iElectrodeNumber/iYdim)-1) * iYdim;
        end
               
        function ApplyNeighbourhoodAverage(oUnemap, aInOptions)
            %This function takes a struct as an input specifying an
            %averaging function to apply and bounds of a kernel over which to apply
            %the function. In this way it performs a subtraction of some
            %neighbourhood average from each signal to remove common
            %components
            
            %Get the average method from aInputs struct
            sAverageMethod = aInOptions.Procedure;
            %Get the template region
            dKernelBounds = aInOptions.KernelBounds;
            %Get the timeseries data for all electrodes
            aArrayTimeSeries = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
            aProcessedTimeSeries = zeros(size(aArrayTimeSeries,1),size(aArrayTimeSeries,2));
            
            %Get the shape of the array information in the form that is
            %suitable for DataHelper.ColToArray
            iRows = oUnemap.oExperiment.Unemap.NumberOfPlugs * oUnemap.oExperiment.Plot.Electrodes.xDim;
            iColumns = oUnemap.oExperiment.Plot.Electrodes.yDim;
            oWaitbar = waitbar(0,'Please wait...');
            iLength = length(oUnemap.TimeSeries);
            switch (sAverageMethod)
                case 'Mean'
                    for i = 1:iLength
                        %update the waitbar
                        waitbar(i/iLength,oWaitbar,sprintf('Please wait... Processing Timepoint %d',i));
                        %Get the data for this time point
                        aTimePoint = aArrayTimeSeries(i,:);
                        %dMean = mean(aTimePoint);
                        %Reshape the vector into an array
                        aReshapedArray = DataHelper.ColToArray(aTimePoint,iRows,iColumns);
                        aSubtractedMean = colfilt(aReshapedArray,dKernelBounds,'sliding',@SubtractMean);
                        %Return the array to the correct shape and save in
                        %processed array
                        aProcessedTimeSeries(i,:) = DataHelper.ArrayToCol(aSubtractedMean);
                    end
                    %Save the result
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aProcessedTimeSeries);
            end
            %close the waitbar
            close(oWaitbar);
            
            %subfunction that does the mean subtraction
            function aOut = SubtractMean(aIn)
                %Loop through columns and 
                %find mean of non-zero elements
                [Xdim Ydim] = size(aIn);
                aOut = zeros(1, Ydim);
                iMidPoint = ceil(Xdim/2);
                for j = 1:Ydim;
                    %Subtract all the nonzero elements from the centre
                    %element
                    dDiff = aIn(iMidPoint,j) - aIn(aIn(:,j)~=0,j);
                    %Count the number of nonzero elements
                    iCount = length(dDiff);
                    %Take the average of these differences (removing the
                    %count of the 0 for the middle element)
                    aOut(1,j) = sum(dDiff)/(iCount - 1);
                    %aOut(1,j) = aIn(iMidPoint,j) - dMean;
                end
            end
            
        end
        
        %% Methods relating to Electrode Activation data
        function MarkActivation(oUnemap, varargin)
            %Mark activation for whole array based on the specified method 
            if strcmp(oUnemap.Electrodes(1).Status,'Potential')
                error('Unemap.GetActivationTime.VerifyInput:NoProcessedData',...
                    'You need to have processed data before calculating an activation time');
            else
                if size(varargin,2) == 1
                    %only a method has been specified so mark activation
                    %times for all beats
                    sMethod = varargin{1}(1);
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestSlope'
                            for i = 1:size(oUnemap.Electrodes,2);
                                % Get slope data if this has not been done already
                                if isnan(oUnemap.Electrodes(i).Processed.Slope)
                                    oUnemap.GetSlope(i);
                                end
                                oUnemap.Electrodes(i).Activation(1).Indexes =  fSteepestSlope(oUnemap.TimeSeries, ...
                                    oUnemap.Electrodes(i).Processed.Slope, ...
                                    oUnemap.Electrodes(i).Processed.BeatIndexes);
                                oUnemap.Electrodes(i).Activation(1).Method = 'SteepestSlope';
                            end
                    end
                elseif size(varargin,2) == 2
                    %Both a method and a beat number have been specified so
                    %only mark activation times for this beat
                    sMethod = varargin{1};
                    iBeat = varargin{2};
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestSlope'
                            for i = 1:size(oUnemap.Electrodes,2);
                                % Get slope data if this has not been done already
                                if isnan(oUnemap.Electrodes(i).Processed.Slope)
                                    oUnemap.GetSlope(i);
                                end
                                oUnemap.Electrodes(i).Activation(1).Indexes(iBeat) =  fSteepestSlope(oUnemap.TimeSeries, ...
                                    oUnemap.Electrodes(i).Processed.Slope, ...
                                    oUnemap.Electrodes(i).Processed.BeatIndexes(iBeat,:));
                                oUnemap.Electrodes(i).Activation(1).Method = 'SteepestSlope';
                            end
                    end
                end
            end
        end
        
        function UpdateActivationMark(oUnemap, iElectrodeNumber, iBeat, dTime)
            %Update the activation time index for the specified channel and
            %beat number
            
            %Convert the time into an index
            iIndex = oUnemap.oDAL.oHelper.ConvertTimeToSeriesIndex(oUnemap.TimeSeries(...
                oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,1):...
                oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,2)), dTime);
            oUnemap.Electrodes(iElectrodeNumber).Activation(1).Indexes(iBeat) = iIndex; 
        end
        
        function oMapData = PrepareActivationMap(oUnemap)
            %Get the inputs for a mapping call for activation times,
            %returning a struct containing the x and y locations of the
            %electrodes and the activation times for each.
            
            %Get the electrode processed data 
            aActivationIndexes = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Activation','Indexes');
            aActivationTimes = zeros(size(aActivationIndexes,1),size(aActivationIndexes,2));
            %Make the activation indexes absolute, normalise them and
            %convert to ms
            aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
            dMaxAcceptedTime = 0;
            for i = 1:size(oUnemap.Electrodes(1).Processed.BeatIndexes,1);
                aActivationIndexes(i,:) = aActivationIndexes(i,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(i,1);
                %Select accepted channels
                aAcceptedActivations = aActivationIndexes(i,logical(aAcceptedChannels));
                aAcceptedTimes = oUnemap.TimeSeries(aAcceptedActivations);
                %Convert to ms
                aActivationTimes(i,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(i,:)) - min(aAcceptedTimes));
                dMaxAcceptedTime = max(max(aActivationTimes(i,logical(aAcceptedChannels))),dMaxAcceptedTime);
            end
            aActivationTimes = transpose(aActivationTimes);
            
            %Turn the coords into a 2 column matrix
            aCoords = [0, 0];
            for j = 1:size(oUnemap.Electrodes,2)
                %I don't give a fck that this is not an efficient way to
                %do this.
                aCoords = [aCoords; oUnemap.Electrodes(j).Coords(1), oUnemap.Electrodes(j).Coords(2)];
                if ~oUnemap.Electrodes(j).Accepted
                    aActivationTimes(j,:) = NaN; 
                end
            end
            aCoords = aCoords(2:end,:);
            oMapData = struct();
            oMapData.x = aCoords(:,1);
            oMapData.y = aCoords(:,2);
            oMapData.z = aActivationTimes;
            oMapData.MaxActivationTime = dMaxAcceptedTime; 
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

