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
            oBasePotential.GetCurvature(iChannel);
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
                    oBasePotential.CalculateSlope(oBasePotential.Electrodes(iElectrodeNumber).Processed.(sDataType),5,3);
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
                        oBasePotential.CalculateSlope(oBasePotential.Electrodes(i).Processed.(sDataType),5,3);
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
                        oBasePotential.CalculateSlope(oBasePotential.Electrodes(i).Processed.Data,5,3);
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
                oBasePotential.Processed.BeatIndexes = vertcat(oBasePotential.Processed.BeatIndexes(1:iBeat-1,:), ...
                    oBasePotential.Processed.BeatIndexes(iBeat+1:end,:));
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
        
        function [aRateData dPeaks] = CalculateSinusRate(oBasePotential, iElectrodeNumber)
            %Get the peaks associated with the beat data from this
            %electrode and make call to GetHeartRateData
            dPeaks = zeros(size(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes,1),1);
            %Loop through the beats and find max curvature
            for i = 1:size(oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes,1);
                aInData = oBasePotential.Electrodes(iElectrodeNumber).Processed.Data...
                    (oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,1):oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,2));
                aCurvature = oBasePotential.CalculateCurvature(aInData, 20, 5);
                [val, loc] = max(aCurvature);
                %Add the first index of this beat
                dPeaks(i,1) = loc + oBasePotential.Electrodes(iElectrodeNumber).Processed.BeatIndexes(i,1);
            end
            [aRateData, aRates, dPeaks] = oBasePotential.GetHeartRateData(dPeaks);
        end
        
        function [aRateTrace, aRates, dPeaks] = CalculateSinusRateFromRMS(oBasePotential)
            %calculate the sinus rate from RMS data instead
            dPeaks = zeros(size(oBasePotential.Electrodes(1).Processed.BeatIndexes,1),1);
            %Loop through the beats and find max curvature
            for i = 1:size(oBasePotential.Electrodes(1).Processed.BeatIndexes,1);
                aInData = oBasePotential.RMS.Smoothed...
                    (oBasePotential.Electrodes(1).Processed.BeatIndexes(i,1):oBasePotential.Electrodes(1).Processed.BeatIndexes(i,2));
                aCurvature = oBasePotential.CalculateCurvature(aInData, 20, 5);
                [val, loc] = max(aCurvature);
                
                %Add the first index of this beat
                dPeaks(i,1) = loc + oBasePotential.Electrodes(1).Processed.BeatIndexes(i,1);
            end

            [aRateTrace, aRates, dPeaks] = oBasePotential.GetHeartRateData(dPeaks);
        end
        
        function [aRateTrace, aRates, dPeaks] = GetHeartRateData(oBasePotential,dPeaks)
            %Take the peaks  supplied and create an array of
            %discrete heart rates
            
            
            %aTimes = aTimes';
            %Put peaks in pairs
            aTimes = oBasePotential.TimeSeries(dPeaks);
            if size(aTimes,1) > size(aTimes,2)
                aTimes = aTimes';
            end
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
    end
    
end

