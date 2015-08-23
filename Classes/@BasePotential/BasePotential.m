classdef BasePotential < BaseSignal
    %   BasePotential 
    %   This is the base class for all entities that hold experimental data
    %   of the potential type. 
    
    properties
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
        
        function FinishProcessing(oBasePotential,iChannel)
            %A function to call after applying some processing steps
            %The channel is now processed
            oBasePotential.Electrodes(iChannel).Status = 'Processed';
            %Calculate slope and curvature
            oBasePotential.GetSlope('Data',iChannel);
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
                    oBasePotential.CalculateCurvature(oBasePotential.Electrodes(iElectrodeNumber).Processed.Data,20,5);
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
                    oBasePotential.CalculateCurvature(oBasePotential.Electrodes(iElectrodeNumber).Processed.(sDataType),20,5);
            elseif nargin > 1
                %A datatype has been specified
                sDataType = char(varargin{1});
                if strcmp(oBasePotential.Electrodes(1).Status,'Potential');
                    error('Unemap.GetSlope.VerifyInput:NoProcessedData', 'You need to have processed data');
                end
                %Perform on data of datatype
                for i = 1:size(oBasePotential.Electrodes,2)
                    oBasePotential.Electrodes(i).Processed.Slope = ...
                        oBasePotential.CalculateSlope(oBasePotential.Electrodes(i).Processed.(sDataType),7,3);
                    oBasePotential.Electrodes(i).Processed.Curvature = ...
                        oBasePotential.CalculateCurvature(oBasePotential.Electrodes(i).Processed.(sDataType),20,5);
                end
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
                        oBasePotential.CalculateCurvature(oBasePotential.Electrodes(i).Processed.Data,20,5);
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
        
        function [aRateData dOutPeaks] = CalculateSinusRate(oBasePotential, iElectrodeNumber)
            %Get the peaks associated with the beat data from this
            %electrode and make call to GetHeartRateData
            dPeaks = zeros(size(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes,1),1);
            %Loop through the beats and find max slope
            for i = 1:size(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes,1);
                aSlope = oBasePotential.Electrodes(iElectrodeNumber).Processed.Slope...
                    (oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,1):oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,2));
                [val, loc] = max(aSlope);
                %Add the first index of this beat
                dPeaks(i,1) = loc - 1 + oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,1);
            end
            [aRateData, aRates, dOutPeaks] = oBasePotential.GetRateData(dPeaks);
             %need to add a NaN to the start because otherwise this won't
            %match the beatindexes array
            oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatRates = [NaN aRates];
            oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatRateData = aRateData;
            oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatRateTimes = [NaN oBasePotential.TimeSeries(dOutPeaks(2,:))];
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
        
         function AcceptChannel(oBasePotential,iElectrodeNumber)
            oBasePotential.Electrodes(iElectrodeNumber).Accepted = 1;
        end
        
        function RejectChannel(oBasePotential,iElectrodeNumber)
            oBasePotential.Electrodes(iElectrodeNumber).Accepted = 0;
        end
        
        %% Event related functions
         function CreateNewEvent(oBasePotential, aElectrodes, aBeats, varargin)
             %Create a new event from the provided details
             oWaitbar = waitbar(0,'Please wait...');
             for i = 1:numel(aElectrodes)
                 iElectrodeNumber = aElectrodes(i);
                 if ~isfield(oBasePotential.Electrodes(iElectrodeNumber), 'SignalEvent')
                     %Initialise the SignalEvent field
                     oBasePotential.Electrodes(iElectrodeNumber).SignalEvent = [];
                     iEvent = 1;
                 elseif isfield(oBasePotential.Electrodes(iElectrodeNumber).SignalEvent,'ID')
                     %Check the event ID
                     aEventIDs = {oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(:).ID};
                     sThisEvent = oBasePotential.MakeEventID(char(varargin{1}), char(varargin{2}), char(varargin{3}));
                     bElements = ismember(aEventIDs, sThisEvent);
                     iIndex = find(bElements);
                     if isempty(iIndex)
                         %This event is not present in the EventID array
                         iEvent = length(oBasePotential.Electrodes(iElectrodeNumber).SignalEvent) + 1;
                     else
                         %This event has already been created for this
                         %electrode
                         iEvent = iIndex;
                     end
                 else
                     iEvent = 1;
                 end
                 %Specify the processed beat indexes as the default range
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Range = oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes;
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Index = ones(size(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes,1),1);
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Label.Colour = char(varargin{1});
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Type = char(varargin{2});
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Method = char(varargin{3});
                 %initialise and build ID
                 oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).ID = oBasePotential.MakeEventID(char(varargin{1}), ...
                     oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Type(1),oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Method);
                 
                 oBasePotential.MarkEvent(iElectrodeNumber, iEvent);
                 oBasePotential.MarkEvent(iElectrodeNumber, iEvent, aBeats(m));
                 
                 
                 
                 waitbar(i/numel(aElectrodes),oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
             end
             close(oWaitbar);
         end
        
         function sEventID = MakeEventID(oBasePotential, sColour, sEventType, sMethod)
            %Create an eventid from the inputs
            sEventID = strcat(sColour(1),lower(sEventType(1)));
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
        
        function DeleteEvent(oBasePotential, sEventID, aElectrodes)
            %Delete the specified event for the selected electrodes and all
            %beats
            if isempty(aElectrodes)
                %delete for all electrodes
                aElectrodes = 1:length(oBasePotential.Electrodes);
            end
            for i = 1:length(aElectrodes)
                aEvents = oBasePotential.Electrodes(aElectrodes(i)).SignalEvent;
                if length(aEvents) > 1
                    aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID), aEvents);
                    oBasePotential.Electrodes(aElectrodes(i)).SignalEvent = oBasePotential.Electrodes(aElectrodes(i)).SignalEvent(~aIndices);
                else
                    if strcmpi(aEvents.ID, sEventID)
                        oBasePotential.Electrodes(aElectrodes(i)).SignalEvent = [];
                    end
                end
                
            end
        end
        
        function iIndex = GetEventIndex(oBasePotential, iElectrodeNumber, sEventID)
            aEvents = oBasePotential.Electrodes(iElectrodeNumber).SignalEvent;
            aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID), aEvents);
            [iIndex, col] = find(aIndices);
        end
        
        function UpdateEventRange(oBasePotential, iEventIndex, aBeats, aElectrodes, aRange)
            %Change the range for the specified event and beat and selected
            %electrodes
            
            %Update range for selected beats and electrodes
            oWaitbar = waitbar(0,'Please wait...');
            for i = 1:length(aElectrodes)
                waitbar(i/length(aElectrodes),oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                %Set the new event range
                oBasePotential.Electrodes(aElectrodes(i)).SignalEvent(iEventIndex).Range(aBeats,1) = aRange(1) + oBasePotential.Electrodes(aElectrodes(i)).Processed.BeatIndexes(aBeats,1);
                oBasePotential.Electrodes(aElectrodes(i)).SignalEvent(iEventIndex).Range(aBeats,2) = aRange(2) + oBasePotential.Electrodes(aElectrodes(i)).Processed.BeatIndexes(aBeats,1);
                oBasePotential.MarkEvent(aElectrodes(i),iEventIndex,aBeats);
            end
            close(oWaitbar);
        end
        
        function MarkEvent(oBasePotential, iElectrode, iEvent, varargin)
            %Mark activation for whole array based on the specified method 
            if strcmp(oBasePotential.Electrodes(iElectrode).Status,'Potential')
                error('Unemap.GetActivationTime.VerifyInput:NoProcessedData',...
                    'You need to have processed data before calculating an activation time');
            else
                if isempty(varargin)
                    %only an eventid has been specified so mark activation
                    %times for all beats
                    sMethod = oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Method;
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestPositiveSlope'
                            % Get slope data if this has not been done already
                            if isnan(oBasePotential.Electrodes(iElectrode).Processed.Slope)
                                oBasePotential.GetSlope('Data',iElectrode);
                            end
                            iIndex =  fSteepestSlope(oBasePotential.TimeSeries, ...
                                oBasePotential.Electrodes(iElectrode).Processed.Slope, ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index = iIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(:,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(:,1);
                        case 'SteepestNegativeSlope'
                            % Get slope data if this has not been done already
                            if isnan(oBasePotential.Electrodes(iElectrode).Processed.Slope)
                                oBasePotential.GetSlope('Data',iElectrode);
                            end
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index =  fSteepestNegativeSlope(oBasePotential.TimeSeries, ...
                                oBasePotential.Electrodes(iElectrode).Processed.Slope, ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                        case 'CentralDifference'
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index = fSteepestSlope(oBasePotential.TimeSeries, ...
                                abs(oBasePotential.Electrodes(iElectrode).Processed.CentralDifference), ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                        case 'MaxSignalMagnitude'
                            %Loop through beats
                            for k = 1:size(oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes,1)
                                [C, oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(k)] = ...
                                    max(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1):...
                                    oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2)));
                            end
                        case 'HalfSignalMagnitude'
                            for k = 1:size(oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes,1)
                                dBaseLine = mean(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1)-15:...
                                    oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1)));
                                dPeak = max(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1):...
                                    oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2)));
                                dMagnitude = (dPeak+sign(dBaseLine)*(-1)*abs(dBaseLine))/2;
                                iHalfIndex = find(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1):...
                                    oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2))>(dBaseLine + abs(dMagnitude)),1,'first')-1;
                                if isempty(iHalfIndex)
                                    iHalfIndex = oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2) - oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1) + 1;
                                end
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(k) = iHalfIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1) - ...
                                    oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(k,1);
                            end
                    end
                elseif size(varargin,2) >= 1
                    %Both a method and a beat number have been specified so
                    %only mark activation times for this beat
                    sMethod = oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Method;
                    iBeat = varargin{1};
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestPositiveSlope'
                            % Get slope data if this has not been done already
                            if isnan(oBasePotential.Electrodes(iElectrode).Processed.Slope)
                                oBasePotential.GetSlope('Data',iElectrode);
                            end
                            iIndex =  fSteepestSlope(oBasePotential.TimeSeries, ...
                                oBasePotential.Electrodes(iElectrode).Processed.Slope, ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'SteepestNegativeSlope'
                            % Get slope data if this has not been done already
                            if isnan(oBasePotential.Electrodes(iElectrode).Processed.Slope)
                                oBasePotential.GetSlope('Data',iElectrode);
                            end
                            iIndex = fSteepestNegativeSlope(oBasePotential.TimeSeries, ...
                                oBasePotential.Electrodes(iElectrode).Processed.Slope, ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'CentralDifference'
                            iIndex = fSteepestSlope(oBasePotential.TimeSeries, ...
                                abs(oBasePotential.Electrodes(iElectrode).Processed.CentralDifference), ...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'MaxSignalMagnitude'
                            [C, iIndex] = ...
                                max(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1):...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,2)));
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'HalfSignalMagnitude'
                            dBaseLine = mean(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1)-15:...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1)));
                            dPeak = max(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1):...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,2)));
                            dMagnitude = (dPeak+sign(dBaseLine)*(-1)*abs(dBaseLine))/2;
                            iHalfIndex = find(oBasePotential.Electrodes(iElectrode).Processed.Data(oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1):...
                                oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,2))>(dBaseLine + abs(dMagnitude)),1,'first')-1;
                            if isempty(iHalfIndex) || dPeak < 1.1*dBaseLine
                                iHalfIndex = oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,2) - oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) + 1;
                            end
                            oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iHalfIndex + oBasePotential.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oBasePotential.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                    end
                end
            end
        end
        
        function iIndex = GetIndexFromTime(oBasePotential, iElectrodeNumber, iBeat, dTime)
            %Returns the index of the beat window corresponding to the
            %specified time
            iIndex = oBasePotential.oDAL.oHelper.ConvertTimeToSeriesIndex(oBasePotential.TimeSeries(...
                oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,1):...
                oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,2)), dTime);
        end
        
        function UpdateSignalEventMark(oBasePotential, iElectrodeNumber, iEvent, iBeat, dTime)
            %Update the activation time index for the specified channel and
            %beat number
            
            %Convert the time into an index
            iIndex = oBasePotential.oDAL.oHelper.ConvertTimeToSeriesIndex(oBasePotential.TimeSeries(...
                oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Range(iBeat,1):...
                oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Range(iBeat,2)), dTime);
            oBasePotential.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Index(iBeat) = iIndex; 
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

