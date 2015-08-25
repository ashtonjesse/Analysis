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
        
        function ProcessElectrodeData(oBasePotential, iChannel, aInOptions)
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
                for i = 1:length(oBasePotential.Electrodes)
                    oBasePotential.Electrodes(i).Processed.Beats(oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,1): ...
                        oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,2)) = NaN;
                    oBasePotential.Electrodes(i).Processed.BeatIndexes = vertcat(oBasePotential.Electrodes(i).Processed.BeatIndexes(1:iBeat-1,:), ...
                        oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat+1:end,:));
                end
            else
                %Just delete the beat and beatindexes
                oBasePotential.Processed.Beats(oBasePotential.Processed.BeatIndexes(iBeat,1): ...
                    oBasePotential.Processed.BeatIndexes(iBeat,2)) = NaN;
                if iBeat > 1
                    oBasePotential.Processed.BeatIndexes = vertcat(oBasePotential.Processed.BeatIndexes(1:iBeat-1,:), ...
                        oBasePotential.Processed.BeatIndexes(iBeat+1:end,:));
                else
                    oBasePotential.Processed.BeatIndexes = oBasePotential.Processed.BeatIndexes(2:end,:);
                end
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
        
        function UpdateEventRange(oBasePotential, sEventID, aBeats, aElectrodes, aRange)
            %Change the range for the specified event and beat and selected
            %electrodes
            
            %Update range for selected beats (assume applying to all
            %electrodes)
            aRangeStart = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeStart');
            aRangeEnd = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'RangeEnd');
            %Calculate the new event range
            aRangeStart(aBeats,aElectrodes) = aRange(1) + repmat(oBasePotential.Beats.Indexes(aBeats,1),1,length(aElectrodes));
            aRangeEnd(aBeats,aElectrodes) = aRange(2) + repmat(oBasePotential.Beats.Indexes(aBeats,1),1,length(aElectrodes));
            %apply to data
            oBasePotential.Electrodes(aElectrodes) = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes(aElectrodes),sEventID,'RangeStart',aRangeStart);
            oBasePotential.Electrodes(aElectrodes) = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes(aElectrodes),sEventID,'RangeEnd',aRangeEnd);
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
            aThisRangeStart = aRangeStart(aBeats,:);
            aThisRangeEnd = aRangeEnd(aBeats,:);
            %get the current index information
            aAllIndexes = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,sEventID,'Index');
            %Choose the method to apply
            sMethod = sEventID(3:5);
            switch (sMethod)
                case 'sps'
                    %get slope data
                    aSlopeData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Slope');
                    aTheseIndexes =  fSteepestSlope(oBasePotential.TimeSeries, aSlopeData(:,aElectrodes), aThisRangeStart(:,aElectrodes), aThisRangeEnd(:,aElectrodes));
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
                case 'hsm'
                    %get data
                    aData = MultiLevelSubsRef(oBasePotential.oDAL.oHelper,oBasePotential.Electrodes,'Processed','Data');
                    %assume ranges are the same for all electrodes for now
                    aThisRangeStart = aThisRangeStart(:,aElectrodes);
                    aThisRangeEnd = aThisRangeEnd(:,aElectrodes);
                    aTheseIndexes = ones(size(aThisRangeStart,1),aElectrodes);
                    for i = 1:size(aThisRangeStart,1)
                        aBaseLine = mean(aData(aThisRangeStart(i)-15:aThisRangeStart(i),:),1);
                        aBaseLine = aBaseLine(aElectrodes);
                        aPeak = max(aData(aThisRangeStart(i):aThisRangeEnd(i),:),[],1);
                        aPeak = aPeak(aElectrodes);
                        aSignedBaseLine = sign(aBaseLine)*(-1).*abs(aBaseLine);
                        aMagnitude = (aPeak+aSignedBaseLine)./2;
                        aHalfData = aData(aThisRangeStart(i):aThisRangeEnd(i),aElectrodes) - repmat(aMagnitude+aBaseLine,size(aData(aThisRangeStart(i):aThisRangeEnd(i),aElectrodes),1),1);
                        [val aTheseIndexes(i,aElectrodes)] = min(abs(aHalfData),[],1);
                    end
            end
            aAllIndexes(aBeats,aElectrodes) = aTheseIndexes;
            oBasePotential.Electrodes(aElectrodes) = MultiLevelSubsAsgn(oBasePotential.oDAL.oHelper, oBasePotential.Electrodes(aElectrodes), ...
                sEventID, 'Index', aAllIndexes + aRangeStart - repmat(oBasePotential.Beats.Indexes(:,1),1,size(aRangeStart,2)));
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
            oBasePotential.Electrodes(iElectrodeNumber).(sEventID).Index(iBeat) = iIndex; 
        end
        
        function MarkEventOrigin(oBasePotential, iElectrodeNumber, iEventIndex, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).SignalEvent(iEventIndex),'Origin')
                %create the origin array
                for i = 1: numel(oBasePotential.Electrodes)
                    oBasePotential.Electrodes(i).SignalEvent(iEventIndex).Origin = false(size(oBasePotential.Electrodes(i).Processed.BeatIndexes,1),1);
                end
            end
            oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEventIndex).Origin(iBeat) = true;
        end
        
        function ClearEventOrigin(oBasePotential, iElectrodeNumber, iEventIndex, iBeat)
            oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEventIndex).Origin(iBeat) = false;
        end
        
        function MarkEventExit(oBasePotential, iElectrodeNumber, iEventIndex, iBeat)
            if ~isfield(oBasePotential.Electrodes(1).SignalEvent(iEventIndex),'Exit')
                %create the origin array
                for i = 1: numel(oBasePotential.Electrodes)
                    oBasePotential.Electrodes(i).SignalEvent(iEventIndex).Exit = false(size(oBasePotential.Electrodes(i).Processed.BeatIndexes,1),1);
                end
            end
            oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEventIndex).Exit(iBeat) = true;
        end
        
        function ClearEventExit(oBasePotential, iElectrodeNumber, iEventIndex, iBeat)
            oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEventIndex).Exit(iBeat) = false;
        end
    end
    
end

