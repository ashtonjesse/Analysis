classdef BasePotential < BaseSignal
    %   BasePotential 
    %   This is the base class for all entities that hold experimental data
    %   of the potential type. 
    
    properties
        oExperiment;
        Electrodes = [];
        TimeSeries = [];
        Beats = [];
        Name;
    end
    
    methods
        %% Constructor
        function oBasePotential = BasePotential()
            oBasePotential = oBasePotential@BaseSignal();
            oBasePotential.oDAL = PotentialDAL();
        end
    end
        
    methods (Access = public)
        function GetBaseline(oBasePotential,iWaveletScale)
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = numel(oBasePotential.Electrodes);
            %Loop through the channels
            for i=1:iTotal
                %Update the waitbar
                waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Signal %d',i));
                oBasePotential.Electrodes(i).Processed.Baseline = ...
                            oBasePotential.ComputeWaveletBaseline(...
                            oBasePotential.Electrodes(i).(oBasePotential.Electrodes(i).Status).Data,...
                            iWaveletScale);
            end
            close(oWaitbar);
        end
        
        function OutData = RemoveLinearInterpolation(oBasePotential, aInData, iOrder)
            %       *RemoveInterpolation - Using linear
            %       interpolation between isoelectric points to remove this
            %       variation between beats
            
            %Split the input cell array into data and beats
            aElectrodeData = cell2mat(aInData(1,1));
            aBeats = cell2mat(aInData(1,2));
            %Loop through each row find the first non-NaN numbers in
            %aBeats.
            [x y] = size(aBeats);
            aAverages = zeros(1,y+1);
            OutData = zeros(x,y);
            iBeatFound = 0;
            for i = 1:x;
                if ~isnan(aBeats(i,1)) && ~iBeatFound && i>30
                    %Take the previous 30 values of
                    %ElectrodeData before the current beat
                    aAverages = [aAverages ; i, mean(aElectrodeData((i-30):i,:))];
                    iBeatFound = 1;
                    %Could get an error if the first beat is within
                    %10 values of the start of the recording
                    %elseif ~isnan(aBeats(i,1)) && i <= 10
                    %%If the beat is within 10 of the beginning
                    %%of the data then take average of as many values as
                    %%there are before the current record.
                    %Averages = [aAverages ; mean(aElectrodeData(1:i,:))];
                elseif isnan(aBeats(i,1))
                    iBeatFound = 0;
                end
            end
            if ~iBeatFound
                aAverages = [aAverages ; i, aElectrodeData(i,:)];
            end
            %Remove zero in first place
            %aAverages(1,:) = aAverages(size(aAverages,1),:);
            aAverages = aAverages(2:size(aAverages,1),:);
            %Initialise the output array and Loop through channels
            OutData = zeros(size(aInData,1),size(aInData,2));
            for j = 1:y;
                %Pass in a cell array with the first element being
                %an array of the indexes of averages and the second
                %being the actual averages them selves.
                OutData(:,j) = fInterpolate({aAverages(:,1),aAverages(:,j+1)},iOrder,x);
            end
        end
        
        function ProcessArrayData(oBasePotential, aInOptions)
            % Loops through all the electrodes in the array and makes calls
            % to the inherited processing methods
            
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = numel(oBasePotential.Electrodes);
            %Loop through the channels
            for i=1:iTotal
                %Update the waitbar
                waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Signal %d',i));
                oBasePotential.ProcessElectrodeData(i,aInOptions);
            end
            close(oWaitbar);
        end
        
        function ProcessElectrodeData(oBasePotential, iChannel, aInOptions)
            % makes a call to the inherited processing method for the
            % specified channel
            for j = 1:size(aInOptions,2)
                %Loop through the entries in aInOptions - an input
                %struct that contains processing procedures to run and
                %and their inputs
                switch(aInOptions(j).Procedure)
                    case 'dFF0'
                        oBasePotential.Electrodes(iChannel).Processed.Data = ...
                            oBasePotential.dFF0(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,oBasePotential.Electrodes(iChannel).Background);
                        oBasePotential.FinishProcessing(iChannel);
                    case 'RemoveMedianAndFitPolynomial'
                        iOrder = aInOptions(j).Inputs;
                        [aOutData, aBaselinePolynomial] = ...
                            oBasePotential.RemoveMedianAndFitPolynomial(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,iOrder);
                        oBasePotential.Electrodes(iChannel).Processed.Data = aOutData;
                        oBasePotential.Electrodes(iChannel).Processed.BaselinePolyOrder = iOrder;
                        oBasePotential.Electrodes(iChannel).Processed.BaselinePoly = aBaselinePolynomial;
                        oBasePotential.FinishProcessing(iChannel);
                    case 'SplineSmoothData'
                        iOrder = aInOptions(j).Inputs;
                        oBasePotential.Electrodes(iChannel).Processed.Data = ...
                            oBasePotential.SplineSmoothData(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,iOrder);
                        oBasePotential.FinishProcessing(iChannel);
                    case 'KeepWaveletScales'
                        iScalesToKeep = aInOptions(j).Inputs;
                        oBasePotential.Electrodes(iChannel).Processed.Data = ...
                            oBasePotential.ComputeDWTFilteredSignalsKeepingScales(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,iScalesToKeep);
                        oBasePotential.Electrodes(iChannel).Processed.WaveletScalesKept= iScalesToKeep;
                        oBasePotential.FinishProcessing(iChannel);
                    case 'FilterData'
                        if strcmp(aInOptions(j).Inputs{1,1},'50HzNotch')
                            dSamplingFreq = aInOptions(j).Inputs{1,2};
                            oBasePotential.Electrodes(iChannel).Processed.Data = ...
                                oBasePotential.FilterData(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,'50HzNotch',dSamplingFreq);
                            oBasePotential.Electrodes(iChannel).Processed.Filter = '50HzNotch';
                        elseif strcmp(aInOptions(j).Inputs{1,1},'SovitzkyGolay')
                            iOrder = aInOptions(j).Inputs{1,2};
                            iWindowSize = aInOptions(j).Inputs{1,3};
                            oBasePotential.Electrodes(iChannel).Processed.Data = ...
                                oBasePotential.FilterData(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,'SovitzkyGolay',iOrder,iWindowSize);
                            oBasePotential.Electrodes(iChannel).Processed.Filter = 'SovitzkyGolay';
                            oBasePotential.Electrodes(iChannel).Processed.WindowSize = iWindowSize;
                            oBasePotential.Electrodes(iChannel).Processed.iOrder = iOrder;
                        end
                        oBasePotential.FinishProcessing(iChannel);
                    case 'RemoveLinearInterpolation'
                        iOrder = aInOptions(j).Inputs;
                        oBasePotential.Electrodes(iChannel).Processed.Data = ...
                            oBasePotential.RemoveLinearInterpolation(oBasePotential.Electrodes(iChannel).(oBasePotential.Electrodes(iChannel).Status).Data,iOrder);
                    case 'ClearData'
                        oBasePotential.ClearProcessedData(iChannel);
                end
            end
        end
        
        function FinishProcessing(oBasePotential,varargin)
            %A function to call after applying some processing steps
            %The channel is now processed
            if nargin > 1
                %channel specified
                iChannel = varargin{1};
                oBasePotential.Electrodes(iChannel).Status = 'Processed';
                %Calculate slope and curvature
                oBasePotential.GetSlope('Data',iChannel);
            else
                [oBasePotential.Electrodes(:).Status] = deal('Processed');
                oBasePotential.GetSlope('Data');
            end
        end
        
        function ClearProcessedData(oBasePotential, iChannel)
            %Clear the Processed data associated with this channel
            oBasePotential.Electrodes(iChannel).Processed.Data = [];
            oBasePotential.Electrodes(iChannel).Status = 'Potential';
        end
        
        function GetCurvature(oBasePotential,iElectrodeNumber)
            if strcmp(oBasePotential.Electrodes(iElectrodeNumber).Status,'Potential');
                error('Unemap.GetCurvature.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Perform on processed data
                oBasePotential.Electrodes(iElectrodeNumber).Processed.Curvature = ...
                    oBasePotential.CalculateCurvature(oBasePotential.Electrodes(iElectrodeNumber).Processed.Data,7,3);
            end
        end
        
        function GetSlope(oBasePotential, varargin)
            if nargin > 2
                %An electrode number has been specified so use this
                sDataType = char(varargin{1});
                iElectrodeNumber = varargin{2};
                if strcmp(oBasePotential.Electrodes(iElectrodeNumber).Status,'Potential');
                    error('Unemap.GetSlope.VerifyInput:NoProcessedData', 'You need to have processed data');
                end
                %Perform on processed data
                oBasePotential.Electrodes(iElectrodeNumber).Processed.Slope = ...
                    oBasePotential.CalculateSlope(oBasePotential.Electrodes(iElectrodeNumber).Processed.(sDataType),7,3);
                oBasePotential.Electrodes(iElectrodeNumber).Processed.Curvature = ...
                    oBasePotential.CalculateCurvature(oBasePotential.Electrodes(iElectrodeNumber).Processed.(sDataType),7,3);
            elseif nargin > 1
                %A datatype has been specified
                sDataType = char(varargin{1});
                if strcmp(oBasePotential.Electrodes(1).Status,'Potential');
                    error('Unemap.GetSlope.VerifyInput:NoProcessedData', 'You need to have processed data');
                end
                %Perform on data of datatype
                                oWaitbar = waitbar(0,'Please wait ...');
                iLength=length(oBasePotential.Electrodes);
                for i = 1:iLength
                    oBasePotential.Electrodes(i).Processed.Slope = ...
                        oBasePotential.CalculateSlope(oBasePotential.Electrodes(i).Processed.(sDataType),7,3);
                    oBasePotential.Electrodes(i).Processed.Curvature = ...
                        oBasePotential.CalculateCurvature(oBasePotential.Electrodes(i).Processed.(sDataType),7,3);
                                        waitbar(i/iLength,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                end
                                close(oWaitbar);
            else
                %No electrode number has been specified so loop through
                %all
                if strcmp(oBasePotential.Electrodes(1).Status,'Potential');
                    error('Unemap.GetSlope.VerifyInput:NoProcessedData', 'You need to have processed data');
                end
                iLength = size(oBasePotential.Electrodes,2);
                                oWaitbar = waitbar(0,'Please wait...');
                for i = 1:iLength
                    oBasePotential.Electrodes(i).Processed.Slope = ...
                        oBasePotential.CalculateSlope(oBasePotential.Electrodes(i).Processed.Data,7,3);
                    oBasePotential.Electrodes(i).Processed.Curvature = ...
                        oBasePotential.CalculateCurvature(oBasePotential.Electrodes(i).Processed.Data,7,3);
                                        waitbar(i/iLength,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                end
                                close(oWaitbar);
            end
        end
        
        function DeleteBeat(oBasePotential, iBeat)
            %Check if there is an electrodes field
            sFields = fields(oBasePotential);
            if max(strcmp(sFields,'Electrodes'))
                %Loop through the electrodes and delete the beat number
                %iBeat
                oWaitbar = waitbar(0,'Please wait ...');
                iLength=length(oBasePotential.Electrodes);
                aBeats = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Beats');
                BeatRates = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRates');
                BeatRateIndexes = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRateIndexes');
                aBeats(oBasePotential.Beats.Indexes(iBeat,1):oBasePotential.Beats.Indexes(iBeat,2),:) = NaN;
                NewBeatRates = vertcat(BeatRates(1:iBeat-1,:), BeatRates(iBeat+1:end,:));
                NewBeatRates(1,:) = NaN;
                NewBeatRateIndexes = vertcat(BeatRateIndexes(1:iBeat-1,:), BeatRateIndexes(iBeat+1:end,:));
                
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Beats',aBeats);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRates',NewBeatRates);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRateIndexes',NewBeatRateIndexes);
                if isfield(oBasePotential.Electrodes(1),'SignalEvents')
                    for j = 1:numel(oBasePotential.Electrodes(1).SignalEvents)
                        sSignalEvent = oBasePotential.Electrodes(1).SignalEvents{j};
                        RangeStart = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'RangeStart');
                        RangeEnd = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'RangeEnd');
                        Index = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Index');
                        if isfield(oBasePotential.Electrodes(1).(sSignalEvent),'Origin')
                            Origin = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Origin');
                            NewOrigin = vertcat(Origin(1:iBeat-1,:), Origin(iBeat+1:end,:));
                            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Origin',NewOrigin);
                        end
                        if isfield(oBasePotential.Electrodes(1).(sSignalEvent),'Exit')
                            Exit = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Exit');
                            NewExit = vertcat(Exit(1:iBeat-1,:), Exit(iBeat+1:end,:));
                            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Exit',NewExit);
                        end
                        NewRangeStart =  vertcat(RangeStart(1:iBeat-1,:), RangeStart(iBeat+1:end,:));
                        NewRangeEnd =  vertcat(RangeEnd(1:iBeat-1,:), RangeEnd(iBeat+1:end,:));
                        NewIndex =  vertcat(Index(1:iBeat-1,:), Index(iBeat+1:end,:));
                        
                        oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'RangeStart',NewRangeStart);
                        oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'RangeEnd',NewRangeEnd);
                        oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sSignalEvent,'Index',NewIndex);
                        
                    end
                    
                end
                waitbar(i/iLength,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                
                oBasePotential.Beats.Indexes = vertcat(oBasePotential.Beats.Indexes(1:iBeat-1,:), ...
                    oBasePotential.Beats.Indexes(iBeat+1:end,:));
                close(oWaitbar);
            end
            
        end
        
        function iIndexes = GetClosestBeat(oBasePotential,iElectrodeNumber,dTime)
            if strcmp(oBasePotential.Electrodes(1).Status,'Potential');
                error('BasePotential.GetClosestBeat.VerifyInput:NoProcessedData', 'You need to have processed data');
            else
                %Get the start times of all the beats
                aIntervalStart = oBasePotential.TimeSeries(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(:,1));
                %Find the index of the closest time to the input time
                [Value, iMinIndex] = min(abs(aIntervalStart - dTime));
                %Return the beat index of this time
                iIndexes = {iMinIndex, oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iMinIndex,:)};
            end
        end
        
        function CalculateSinusRate(oBasePotential)
            %Get the peaks associated with the beat data from all
            % electrodes
            
            %initialise variables
            if ~any(strcmp(properties(oBasePotential), 'Beats'))
                oBasePotential.Beats.Indexes = oBasePotential.Electrodes(1).Processed.BeatIndexes;
            end
            dPeaks = zeros(size(oBasePotential.Beats.Indexes,1),length(oBasePotential.Electrodes));
            aBeatRates = NaN(size(dPeaks,1),size(dPeaks,2));
            aBeatRateIndexes = NaN(size(dPeaks,1),size(dPeaks,2));
            
            %get the electrode slope data
            aSlope = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Slope');
            %get max location for first beat
            [val, loc] = max(aSlope(oBasePotential.Beats.Indexes(1,1):oBasePotential.Beats.Indexes(1,2),:),[],1);
            dPeaks(1,:) = loc - 1 + oBasePotential.Beats.Indexes(1,1);
            aBeatRateIndexes(1,:) = dPeaks(1,:);
            %loop through beats
            for i = 2:size(oBasePotential.Beats.Indexes,1)
                [val, loc] = max(aSlope(oBasePotential.Beats.Indexes(i,1):oBasePotential.Beats.Indexes(i,2),:),[],1);
                %Add the first index of this beat
                dPeaks(i,:) = loc - 1 + oBasePotential.Beats.Indexes(i,1);
                [aBeatRates(i,:), aBeatRateIndexes(i,:)] = oBasePotential.GetBeatRates(dPeaks(i-1,:),dPeaks(i,:));
            end

            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRates', aBeatRates);
            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,...
                oBasePotential.Electrodes,'Processed','BeatRateIndexes', aBeatRateIndexes);
        end
        
        function  [aRateData, dPeaks] = GetHeartRateData(oBasePotential,dPeaks)
            %this function calculates heart rate data based on a set of
            %peak locations
            
            %check that there are not any peaks that are too close together
            %to be real
            dPeaks = dPeaks(:,diff(dPeaks) > 500);
            %make the call to getratedata
            [aRateData aRates dOutPeaks] = oBasePotential.GetRateData(dPeaks);
            oBasePotential.Electrodes.Processed.BeatRates = aRates;
            oBasePotential.Electrodes.Processed.BeatRateData = aRateData;
            oBasePotential.Electrodes.Processed.BeatRateTimes = oBasePotential.TimeSeries(dOutPeaks(2,:));
        end
        
        function [aRateTrace, aRates, dOutPeaks] = CalculateSinusRateFromRMS(oBasePotential)
            %calculate the sinus rate from RMS data instead
            dPeaks = zeros(size(oBasePotential.RMS.HeartRate.BeatIndexes,1),1);
            %Loop through the beats and find max curvature
            for i = 1:size(oBasePotential.RMS.HeartRate.BeatIndexes,1);
                aInData = oBasePotential.RMS.Smoothed...
                    (oBasePotential.RMS.HeartRate.BeatIndexes(i,1):oBasePotential.RMS.HeartRate.BeatIndexes(i,2));
                aCurvature = oBasePotential.CalculateCurvature(aInData, 20, 5);
                [val, loc] = max(aCurvature);
                
                %Add the first index of this beat
                dPeaks(i,1) = loc - 1 + oBasePotential.RMS.HeartRate.BeatIndexes(i,1);
            end
            [aRateData, aRates, dOutPeaks] = oBasePotential.GetRateData(dPeaks);
            oBasePotential.RMS.HeartRate.BeatRates = aRates;
            oBasePotential.RMS.HeartRate.BeatRateData = aRateData;
            oBasePotential.RMS.HeartRate.BeatRateTimes = oBasePotential.TimeSeries(dOutPeaks(2,:));
        end
        
        function [aRates, aPeaks] = GetBeatRates(oBasePotential,aFirstPeak,aSecondPeak)
            %Take the peaks  supplied and create an array of
            %discrete rates
            
            %get the time values for these peaks
            aFirstTimes = oBasePotential.TimeSeries(aFirstPeak);
            aSecondTimes = oBasePotential.TimeSeries(aSecondPeak);
            
            %Get the times in sets of intervals
            aIntervals = aSecondTimes - aFirstTimes;
            %Put rates into bpm
            aRates = 60 ./ aIntervals;
            aPeaks = aSecondPeak;
        end
        
        function aRateTrace = GetBeatRateData(oBasePotential,iElectrodeNumber)
            aRateTrace = NaN(1,length(oBasePotential.TimeSeries));
            %Loop through the beats and insert into aRateTrace
            dPeaks = oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatRateIndexes;
            %Put peaks in pairs
            if size(dPeaks,1) > size(dPeaks,2)
                dPeaks = dPeaks';
            end
            dNewPeaks = [dPeaks(1:end-1) ; dPeaks(2:end)];
            for i = 1:size(dNewPeaks,2)
                aRateTrace(dNewPeaks(1,i):dNewPeaks(2,i)-2) = oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatRates(i+1);
            end
        end
        
        function [aRateTrace, aRates, dPeaks] = GetRateData(oBasePotential,dPeaks)
            %Take the peaks  supplied and create an array of
            %discrete rates
                        
            %aTimes = aTimes';
            
            %get the time values for these peaks
            aTimes = oBasePotential.TimeSeries(dPeaks);
            if size(aTimes,1) > size(aTimes,2)
                aTimes = aTimes';
            end
            %Put peaks in pairs
            if size(dPeaks,1) > size(dPeaks,2)
                dPeaks = dPeaks';
            end
            dPeaks = [dPeaks(1:end-1) ; dPeaks(2:end)];
            %Get the times in sets of intervals
            aNewTimes = [aTimes(1:end-1) ; aTimes(2:end)];
            aIntervals = aNewTimes(2,:) - aNewTimes(1,:);
            %Put rates into bpm
            aRates = 60 ./ aIntervals;
            aRateTrace = NaN(1,length(oBasePotential.TimeSeries));
            %Loop through the peaks and insert into aRateTrace
            for i = 1:size(dPeaks,2)
                aRateTrace(dPeaks(1,i):dPeaks(2,i)-2) = aRates(i);
            end
            
        end
        
        function RefreshBeatData(oBasePotential, varargin)
            %loop through electrodes and refresh data for beat indexes
            if nargin > 0 && ~isempty(varargin)
                %user has specified a specific electrode
                iChannel = varargin{1};
                oBasePotential.Electrodes(iChannel).Processed.Beats = NaN(length(oBasePotential.Electrodes(iChannel).Processed.Data),1);
                for j = 1:size(oBasePotential.Electrodes(iChannel).Processed.BeatIndexes,1)
                    oBasePotential.Electrodes(iChannel).Processed.Beats(oBasePotential.Electrodes(iChannel).Processed.BeatIndexes(j,1): ...
                        oBasePotential.Electrodes(iChannel).Processed.BeatIndexes(j,2)) = oBasePotential.Electrodes(iChannel).Processed.Data(oBasePotential.Electrodes(iChannel).Processed.BeatIndexes(j,1): ...
                        oBasePotential.Electrodes(iChannel).Processed.BeatIndexes(j,2));
                end
            else
                oWaitbar = waitbar(0,'Please wait...');
                iTotal = length(oBasePotential.Electrodes);
                for i = 1:length(oBasePotential.Electrodes)
                    oBasePotential.Electrodes(i).Processed.Beats = NaN(length(oBasePotential.Electrodes(i).Processed.Data),1);
                    for j = 1:size(oBasePotential.Electrodes(i).Processed.BeatIndexes,1)
                        oBasePotential.Electrodes(i).Processed.Beats(oBasePotential.Electrodes(i).Processed.BeatIndexes(j,1): ...
                            oBasePotential.Electrodes(i).Processed.BeatIndexes(j,2)) = oBasePotential.Electrodes(i).Processed.Data(oBasePotential.Electrodes(i).Processed.BeatIndexes(j,1): ...
                            oBasePotential.Electrodes(i).Processed.BeatIndexes(j,2));
                    end
                    waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                end
                close(oWaitbar);
            end
        end
        
        function UpdateBeatIndexes(oBasePotential, iBeat, aIndexRange)
            %Change the beat information to that supplied by the new range
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = length(oBasePotential.Electrodes);
            %Loop through the electrodes
            for i = 1:iTotal
                %Get the current range for this beat
                aCurrentRange = oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,:);
                %Reset the current range of this beat to NaN
                oBasePotential.Electrodes(i).Processed.Beats(aCurrentRange(1):aCurrentRange(2)) = NaN;
                %Set the new beat values
                oBasePotential.Electrodes(i).Processed.Beats(aIndexRange(1):aIndexRange(2)) = ...
                    oBasePotential.Electrodes(i).Processed.Data(aIndexRange(1):aIndexRange(2));
                %Set the new beat indexes
                oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,:) = [aIndexRange(1) aIndexRange(2)];
                %update the signal events if there are any
                if isfield(oBasePotential.Electrodes(i),'SignalEvent')
                    for j = 1:length(oBasePotential.Electrodes(i).SignalEvent)
                        %Get the relative range indexes
                        aCurrentRange = oBasePotential.Electrodes(i).SignalEvent(j).Range(iBeat,:) - [aIndexRange(1) aIndexRange(1)];
                        %set the new range
                        oBasePotential.Electrodes(i).SignalEvent(j).Range(iBeat,:) = aCurrentRange + aIndexRange(1);
                        %Update the event index
                        oBasePotential.MarkEvent(i, j, iBeat);
                    end
                end
                waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
            end
            close(oWaitbar);
        end
        
        function InsertNewBeat(oBasePotential, iPreviousBeat, aNewIndexRange)
            %Insert a new beat after the specified beat with the specified
            %beat indexes
            %Change the beat information to that supplied by the new range
            oWaitbar = waitbar(0,'Please wait...');
            iTotal = length(oBasePotential.Electrodes);
            %Loop through the electrodes
            for i = 1:iTotal
                %Increase the size of the beatIndexes array by 1 and load
                %the old beat indexes
                aOldBeatIndexes = oBasePotential.Electrodes(i).Processed.BeatIndexes;
                aNewBeatIndexes = zeros(size(aOldBeatIndexes,1)+1,2);
                aNewBeatIndexes(iPreviousBeat+1,:) = aNewIndexRange;
                aNewBeatIndexes(1:iPreviousBeat,:) = aOldBeatIndexes(1:iPreviousBeat,:);
                aNewBeatIndexes(iPreviousBeat+2:end,:) = aOldBeatIndexes(iPreviousBeat+1:end,:);
                oBasePotential.Electrodes(i).Processed.BeatIndexes = aNewBeatIndexes;
                %update the beats array
                %Set the new beat values
                oBasePotential.Electrodes(i).Processed.Beats(aNewIndexRange(1):aNewIndexRange(2)) = ...
                    oBasePotential.Electrodes(i).Processed.Data(aNewIndexRange(1):aNewIndexRange(2));
                waitbar(i/iTotal,oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
            end
            close(oWaitbar);
        end
        
        function aSpatialLimits = GetSpatialLimits(oBasePotential)
            %get the coordinates and return extent
            aCoords = cell2mat({oBasePotential.Electrodes(:).Coords});
            aSpatialLimits = [min(aCoords(1,:)), max(aCoords(1,:)); min(aCoords(2,:)), max(aCoords(2,:))];
        end
        
        function iElectrodeNumber = GetNearestElectrodeID(oBasePotential, xLoc, yLoc)
            %Get the electrode whose coordinates are closest to those
            %specified in xLoc and yLoc (I wish this was a spatially
            %indexed database..)
            
            %Get coordinate array and calculate distance between each
            %electrode and specified location
            aCoords = cell2mat({oBasePotential.Electrodes(:).Coords});
            aXArray = aCoords(1,:) - xLoc;
            aYArray = aCoords(2,:) - yLoc;
            aDistance = sqrt(aXArray.^2 + aYArray.^2);
            %Return the index of the electrode with the minimum distance
            [C iElectrodeNumber] = min(aDistance);
        end
        
        function aElectrodes = GetElectrodesWithinRadius(oBasePotential, Loc, dRadius)
            %return logical array to select accepted electrodes within radius of specified location
            %get accepted electrodes
            aCoords = [oBasePotential.Electrodes(:).Coords]';
            RelativeDistVectors = aCoords-repmat(Loc,[size(aCoords,1),1]);
            [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
            aLocalRegion = SupportPoints(Dist <= dRadius);
            aElectrodes = false(1,numel(oBasePotential.Electrodes));
            aElectrodes(aLocalRegion) = true;
        end
        
        function [oElectrode, iIndex] = GetElectrodeByName(oBasePotential,sChannelName)
            %Return the electrode that matches the input name
            %This is a hacky way to do it but IDGF
            oElectrode = [];
            iIndex = 0;
            for i = 1:length(oBasePotential.Electrodes)
                %Revisit this by trying aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID),
                %aEvents);
                if strcmp(oBasePotential.Electrodes(i).Name,sChannelName)
                    oElectrode = oBasePotential.Electrodes(i);
                    iIndex = i;
                end
            end
        end
        
         function AcceptChannel(oBasePotential,iElectrodeNumber)
            oBasePotential.Electrodes(iElectrodeNumber).Accepted = 1;
        end
        
        function RejectChannel(oBasePotential,iElectrodeNumber)
            oBasePotential.Electrodes(iElectrodeNumber).Accepted = 0;
        end
        
        function MarkAxisPoint(oBasePotential, iElectrodeNumber)
             if ~isfield(oBasePotential.Electrodes(1),'AxisPoint')
                %create the axispoint array
                [oBasePotential.Electrodes(:).AxisPoint] = deal(false);
            end
            [oBasePotential.Electrodes(iElectrodeNumber).AxisPoint] = deal(true);
        end
        
        function ClearAxisPoint(oBasePotential, iElectrodeNumber)
            if ~isfield(oBasePotential.Electrodes(1),'AxisPoint')
                %create the axispoint array
                [oBasePotential.Electrodes(:).AxisPoint] = deal(false);
            end
            [oBasePotential.Electrodes(iElectrodeNumber).AxisPoint] = deal(false);
        end
        
        function aNormalisedData = NormaliseDataToPeak(oBasePotential,aData)
            %this function normalises the input data to the peak (designed
            %for a single AP)
            dBaseLine = mean(aData(1:20));
            aNormalisedData = (aData+sign(dBaseLine)*(-1)*abs(dBaseLine));
            dPeak = max(aNormalisedData);
            aNormalisedData = aNormalisedData./dPeak;
        end
        
        function TruncateData(oBasePotential, bIndexesToKeep)
            %This performs a truncation on potential data and processed
            %data as well if there is some
            
            %Truncate the time series
            oBasePotential.TimeSeries = oBasePotential.TimeSeries(bIndexesToKeep);
            
            %Get an array of columns with the potential data from each
            %electrode
            aPotentialData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Potential','Data');
            %Select the indexes to keep
            aPotentialData = aPotentialData(bIndexesToKeep,:);
            %Truncate the potential data
            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Potential','Data',aPotentialData);
            
            if strcmp(oBasePotential.Electrodes(1).Status,'Processed')
                %perform on existing potential data as well
                %processed data
                aProcessedData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Data');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Data',aProcessedData);
                %slope data
                aProcessedData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Slope');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Slope',aProcessedData);
                %curvature data
                aProcessedData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Curvature');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Curvature',aProcessedData);
                %beats data
                aProcessedData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Beats');
                aProcessedData = aProcessedData(bIndexesToKeep,:);
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Beats',aProcessedData);
                %adjust beat indexes
                aIndices = find(~bIndexesToKeep(1:end/2));
                aProcessedData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRateIndexes');
                aProcessedData = aProcessedData - (ones(size(aProcessedData))*max(aIndices));
                if aProcessedData(1,1) < 1
                    aProcessedData(1,:) = deal(1);
                end
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','BeatRateIndexes',aProcessedData);
                aBeatIndexes = oBasePotential.Beats.Indexes - (ones(size(oBasePotential.Beats.Indexes))*max(aIndices));
                if aBeatIndexes(1,1) < 1
                    aBeatIndexes(1,1) = 1;
                end
                oBasePotential.Beats.Indexes = aBeatIndexes;
                %adjust event ranges
                for ii = 1:size(oBasePotential.Electrodes(1).SignalEvents,1)
                    aRangeStart = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes, [oBasePotential.Electrodes(1).SignalEvents{ii}],'RangeStart');
                    aNewRangeStart = aRangeStart - ones(size(aRangeStart))*max(aIndices);
                    if aNewRangeStart(1,1) < 1
                        aNewRangeStart(1,:) = deal(1);
                    end
                    oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,[oBasePotential.Electrodes(1).SignalEvents{ii}],'RangeStart',aNewRangeStart);
                    %repeat for rangeend
                    aRangeEnd = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes, [oBasePotential.Electrodes(1).SignalEvents{ii}],'RangeEnd');
                    aNewRangeEnd = aRangeEnd - ones(size(aRangeEnd))*max(aIndices);
                    oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,[oBasePotential.Electrodes(1).SignalEvents{ii}],'RangeEnd',aNewRangeEnd);
                end
            end
            
        end
        
        %% Event related functions
         function sEventID = CreateNewEvent(oBasePotential, aElectrodes, aBeats, varargin)
             %Create a new event from the provided details
             sThisEvent = oBasePotential.MakeEventID(char(varargin{1}), char(varargin{2}), char(varargin{3}));
             if ~isfield(oBasePotential.Electrodes(1), sThisEvent)
                 %Initialise the SignalEvent field
                 oEvent = struct('RangeStart',oBasePotential.Beats.Indexes(:,1),'RangeEnd',oBasePotential.Beats.Indexes(:,2),...
                     'Index',ones(size(oBasePotential.Beats.Indexes,1),1),'Label',struct('Colour',char(varargin{1})),...
                     'Type',char(varargin{2}),'Method',char(varargin{3}));
                 %distribute to electrodes
                 [oBasePotential.Electrodes(:).(sThisEvent)] = deal(oEvent);
                 %add this id to the signal events array
                 if ~isfield(oBasePotential.Electrodes(1),'SignalEvents')
                     [oBasePotential.Electrodes(:).SignalEvents] = deal(cell(1,1));
                     iIndex = 1;
                 else
                     iIndex = length(oBasePotential.Electrodes(1).SignalEvents)+1;
                 end
                 aSignalEvents = oBasePotential.Electrodes(1).SignalEvents;
                 aSignalEvents{iIndex,1} = sThisEvent;
                 [oBasePotential.Electrodes(:).SignalEvents] = deal(aSignalEvents);
             end
             oBasePotential.MarkEvent(sThisEvent,aBeats);
             sEventID = sThisEvent;
         end
        
         function sEventID = MakeEventID(oBasePotential, sColour, sEventType, sMethod)
            %Create an eventid from the inputs
            sEventID = strcat(lower(sEventType(1)),sColour(1));
            switch (sMethod)
                case 'SteepestPositiveSlope'
                    sEventID = strcat(sEventID,'sps');
                case 'SteepestNegativeSlope'
                    sEventID = strcat(sEventID,'sns');
                case 'CentralDifference'
                    sEventID = strcat(sEventID,'cd');
                case 'MaxSignalMagnitude'
                    sEventID = strcat(sEventID,'msm');
                case 'HalfSignalMagnitude'
                    sEventID = strcat(sEventID,'hsm');
            end
        end
        
        function DeleteEvent(oBasePotential, sEventID)
            %Delete the specified event for the selected electrodes and all
            %beats
            oElectrodes = rmfield(oBasePotential.Electrodes(:),sEventID);
            oBasePotential.Electrodes = oElectrodes';
            if length(oBasePotential.Electrodes(1).SignalEvents) > 1
                %need to remove the right reference
                aSignalEvents = oBasePotential.Electrodes(1).SignalEvents;
                aIndices = ismember(aSignalEvents,sEventID);
                aSignalEvents = aSignalEvents(~aIndices);
                [oBasePotential.Electrodes(:).SignalEvents] = deal(aSignalEvents);
            else
                %remove the signalevents field as no more events to store
                oElectrodes = rmfield(oBasePotential.Electrodes(:),SignalEvents);
                oBasePotential.Electrodes = oElectrodes';
            end
        end
        
        function UpdateEventRange(oBasePotential, sEventID, aBeats, aElectrodes, aRange, iCurrentElectrode)
            %Change the range for the specified event and beat and selected
            %electrodes
            
            %Update range for selected beats (assume applying to all
            %electrodes)
            aRangeStart = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeStart');
            aRangeEnd = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeEnd');
            %Calculate the new event range
            %compute euclidean distance
            %get coords
            if ~isempty(iCurrentElectrode)
                oElectrodes = oBasePotential.Electrodes;
                aCoords = cell2mat({oElectrodes(:).Coords});
                aCurrentCoords = oBasePotential.Electrodes(iCurrentElectrode).Coords;
                aDistance = sqrt((aCurrentCoords(1) - aCoords(1,:)).^2 + ...
                    (aCurrentCoords(2) - aCoords(2,:)).^2);
                aDistance = aDistance(aElectrodes);
            else
                aDistance = zeros(1,numel(aElectrodes));
            end
            aRangeStart(aBeats,aElectrodes) = aRange(1) + repmat(floor(aDistance),numel(aBeats),1) + repmat(oBasePotential.Beats.Indexes(aBeats,1),1,length(aElectrodes)) - 1;
            aRangeEnd(aBeats,aElectrodes) = aRange(2) + repmat(floor(aDistance),numel(aBeats),1) + repmat(oBasePotential.Beats.Indexes(aBeats,1),1,length(aElectrodes)) - 1;
            %apply to data
            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes,sEventID,'RangeStart',aRangeStart);
            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes,sEventID,'RangeEnd',aRangeEnd);
            
            %mark event for these beats
            oBasePotential.MarkEvent(sEventID,aBeats,aElectrodes);
        end
        
        function MarkEvent(oBasePotential, sEventID, varargin)
            %Mark activation for whole array based on the specified method
            
            %get range data
            aRangeStart = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeStart');
            aRangeEnd = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeEnd');
            %get beat information
            if isempty(varargin)
                %only an eventid has been specified so mark activation
                %times for all beats
                aBeats = 1:size(aRangeStart,1);
                aElectrodes = 1:size(aRangeStart,2);
            elseif nargin == 3
                %Both a method and beats have been specified so
                %only mark activation times for these beats
                aBeats = varargin{1};
                aElectrodes = 1:size(aRangeStart,2);
            elseif nargin == 4
                aBeats = varargin{1};
                aElectrodes = varargin{2};
            end
            %select the beats
            aTheseRangeStart = aRangeStart(aBeats,:);
            aTheseRangeEnd = aRangeEnd(aBeats,:);
            %get the current index information
            aAllIndexes = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'Index');
            %Choose the method to apply
            sMethod = sEventID(3:5);
            switch (sMethod)
                case 'sps'
                    %get slope data
                    aSlopeData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Slope');
                    aTheseIndexes =  fSteepestSlope(oBasePotential.TimeSeries, aSlopeData(:,aElectrodes), aTheseRangeStart(:,aElectrodes), aTheseRangeEnd(:,aElectrodes));
                    %insert into allindexes in the right place.
                    
                    %                     case 'sns'
                    %                         oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index =  fSteepestNegativeSlope(oBasePotential.TimeSeries, ...
                    %                             oBasePotential.Electrodes(iElectrode).Processed.Slope, ...
                    %                             oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                    %                     case 'cd'
                    %                         oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index = fSteepestSlope(oBasePotential.TimeSeries, ...
                    %                             abs(oBasePotential.Electrodes(iElectrode).Processed.CentralDifference), ...
                    %                             oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                    %                     case 'msm'
                    %                         %Loop through beats
                    %                         for k = 1:size(oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes,1)
                    %                             [C, oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(k)] = ...
                    %                                 max(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1):...
                    %                                 oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2)));
                    %                         end
                    aAllIndexes(aBeats,aElectrodes) = aTheseIndexes + aRangeStart(aBeats,aElectrodes) - repmat(oBasePotential.Beats.Indexes(aBeats,1),1,length(aElectrodes));
                case 'hsm'
                    %get data
                    aData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Data');
                    %assume ranges are the same for all electrodes for now
                    for i = 1:size(aBeats,2)
                        aThisBeatStart = ones(1,numel(aElectrodes))*oBasePotential.Beats.Indexes(aBeats(i),1);
                        aThisRangeStart = aTheseRangeStart(i,aElectrodes);
                        aThisRangeEnd = aTheseRangeEnd(i,aElectrodes);
                        iBase = 15;
                        aLocs = vertcat(aThisBeatStart,aThisBeatStart+iBase)';
                        BaselineIndexes = (bsxfun(@le,aLocs(:,1),1:size(aData,1)) & bsxfun(@ge,aLocs(:,2),1:size(aData,1))).';
                        aLocs = vertcat(aThisRangeStart,aThisRangeEnd)';
                        PeakIndexes = (bsxfun(@le,aLocs(:,1),1:size(aData,1)) & bsxfun(@ge,aLocs(:,2),1:size(aData,1))).';
                        aBaseLineData = reshape(aData(BaselineIndexes),[iBase+1,size(BaselineIndexes,2)]);
                        aBaseLine = mean(aBaseLineData,1);
                        aBaseLine = aBaseLine(aElectrodes);
                        aPeakData = reshape(aData(PeakIndexes),[aThisRangeEnd(1)-aThisRangeStart(1)+1,size(PeakIndexes,2)]);
                        aPeak = max(aPeakData,[],1);
                        aPeak = aPeak(aElectrodes);
                        aSignedBaseLine = sign(aBaseLine)*(-1).*abs(aBaseLine);
                        aMagnitude = (aPeak+aSignedBaseLine)./2;
                        aHalfData = aPeakData(:,aElectrodes) - repmat(aMagnitude+aBaseLine,size(aPeakData(:,aElectrodes),1),1);
                        [val aTheseIndexes] = min(abs(aHalfData),[],1);
                        aAllIndexes(aBeats(i),aElectrodes) = aTheseIndexes + aRangeStart(aBeats(i),aElectrodes) - repmat(oBasePotential.Beats.Indexes(aBeats(i),1),1,length(aElectrodes));
                    end
            end
            oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                sEventID, 'Index', aAllIndexes);
        end
        
        function iIndex = GetIndexFromTime(oBasePotential, iElectrodeNumber, iBeat, dTime)
            %Returns the index of the beat window corresponding to the
            %specified time
            iIndex = oBasePotential.oDAL.oHelper.ConvertTimeToSeriesIndex(oBasePotential.TimeSeries(...
                oBasePotential.Beats.Indexes(iBeat,1):...
                oBasePotential.Beats.Indexes(iBeat,2)), dTime);
        end
        
        function UpdateSignalEventMark(oBasePotential, iElectrodeNumber, sEventID, iBeat, dTime)
            %Update the activation time index for the specified channel and
            %beat number
            
            %Convert the time into an index
            iIndex = oBasePotential.oDAL.oHelper.ConvertTimeToSeriesIndex(oBasePotential.TimeSeries(...
                oBasePotential.Electrodes(iElectrodeNumber).(sEventID).RangeStart(iBeat):...
                oBasePotential.Electrodes(iElectrodeNumber).(sEventID).RangeEnd(iBeat)), dTime);
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Index(iBeat) = iIndex + ...
                oBasePotential.Electrodes(iElectrodeNumber).(sEventID).RangeStart(iBeat) - oBasePotential.Beats.Indexes(iBeat,1); 
        end
        
        function MarkEventOrigin(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Origin')
                %create the origin array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Origin', false(size(oBasePotential.Beats.Indexes,1),1));
            end
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Origin(iBeat) = true;
        end
        
        function ClearEventOrigin(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Origin')
                %create the Origin array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Origin', false(size(oBasePotential.Beats.Indexes,1),1));
            end
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Origin(iBeat) = false;
        end
        
        function MarkEventExit(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Exit')
                %create the origin array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Exit', false(size(oBasePotential.Beats.Indexes,1),1));
            end
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Exit(iBeat) = true;
        end
        
        function ClearEventExit(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Exit')
                %create the Exit array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Exit', false(size(oBasePotential.Beats.Indexes,1),1));
            end
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Exit(iBeat) = false;
        end
          
        function MapChannel(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            %Add this electrode to the event map for this beat
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Map')
                %create the map array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Map', true(size(oBasePotential.Beats.Indexes,1),1));
            end
            for i = 1:length(iElectrodeNumber)
                oBasePotential.Electrodes(iElectrodeNumber(i)).(sEventID).Map(iBeat) = true;
            end
        end
        
        function HideChannel(oBasePotential, iElectrodeNumber, sEventID, iBeat)
            %Hide this electrode to the event map for this beat
            if ~isfield(oBasePotential.Electrodes(1).(sEventID),'Map')
                %create the map array
                oBasePotential.Electrodes = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes, ...
                    sEventID, 'Map', true(size(oBasePotential.Beats.Indexes,1),1));
            end
            for i = 1:length(iElectrodeNumber)
                oBasePotential.Electrodes(iElectrodeNumber(i)).(sEventID).Map(iBeat) = false;
            end
        end
    end
    
end

