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
        function oUnemap = Unemap(varargin)
            %% Constructor
            oUnemap = oUnemap@BasePotential();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Unemap')
                    oUnemapStruct = varargin{1};
                    oUnemap.TimeSeries = oUnemapStruct.TimeSeries;
                    oUnemap.oExperiment = Experiment(oUnemapStruct.oExperiment);
                    oUnemap.Electrodes = oUnemapStruct.Electrodes;
                    oUnemap.RMS = oUnemapStruct.RMS;
                    if ~isfield(oUnemap.RMS,'Electrodes')
                        oUnemap.RMS.Electrodes = [];
                    end
                end
            end
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
        
        function aOutData = SplineSmoothData(oUnemap, aInData, varargin)
            aOutData = SplineSmoothData@BasePotential(oUnemap, aInData, varargin);
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
        
        %% Methods relating to Electrode potential raw and processed data
        function AcceptChannel(oUnemap,iElectrodeNumber)
            oUnemap.Electrodes(iElectrodeNumber).Accepted = 1;
        end
        
        function RejectChannel(oUnemap,iElectrodeNumber)
            oUnemap.Electrodes(iElectrodeNumber).Accepted = 0;
        end
        
        function AddChannelToRMS(oUnemap, iElectrodeNumber)
            %check if this index is already in the array
            ind = find(oUnemap.RMS.Electrodes==iElectrodeNumber);
            if isempty(ind)
                %if not then add it 
                oUnemap.RMS.Electrodes = [oUnemap.RMS.Electrodes ; iElectrodeNumber];
            end
        end
        
        function RemoveChannelFromRMS(oUnemap, iElectrodeNumber)
            %check if this index is in the array
            ind = find(oUnemap.RMS.Electrodes==iElectrodeNumber);
            if ~isempty(ind)
                %if so, remove it
                oUnemap.RMS.Electrodes(ind) = [];
            end
        end
        
        function bResult = IsChannelIncludedInRMS(oUnemap, iElectrodeNumber)
            ind = find(oUnemap.RMS.Electrodes==iElectrodeNumber);
            if isempty(ind)
                bResult = 0;
            else
                bResult = 1;
            end
        end
                
        function [oElectrode, iIndex] = GetElectrodeByName(oUnemap,sChannelName)
            %Return the electrode that matches the input name
            %This is a hacky way to do it but IDGF
            oElectrode = [];
            iIndex = 0;
            for i = 1:length(oUnemap.Electrodes)
                %Revisit this by trying aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID),
                %aEvents);
                if strcmp(oUnemap.Electrodes(i).Name,sChannelName)
                    oElectrode = oUnemap.Electrodes(i);
                    iIndex = i;
                end
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
        
        function GetArrayBeats(oUnemap, aPeaks, sBeatType)
            %Does some checks and then calls the appropriate inherited GetBeats
            %method
            
            if strcmp(oUnemap.Electrodes(1).Status,'Potential');
                error('Unemap.GetArrayBeats.VerifyInput:NoProcessedData', 'You need to have processed data before removing interbeat variation');
            else
                %Detect beats on the processed data
                %Concatenate all the electrode processed data into one
                %array
                aInData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
            end
            switch (sBeatType)
                case 'Paced'
                    [aOutData aPacingIndexes] = oUnemap.GetPacedBeats(aInData,aPeaks);
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Pacing','Index',aPacingIndexes);
                case 'Sinus'
                    [aOutData dMaxPeaks] = oUnemap.GetSinusBeats(aInData,aPeaks);
            end
            %Split again into the Electrodes
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Beats',cell2mat(aOutData(1)));
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','BeatIndexes',cell2mat(aOutData(2)));
            %save info to RMS field too
            oUnemap.RMS.HeartRate.BeatIndexes = cell2mat(aOutData(2));
            [~, ~, ~] = oUnemap.CalculateSinusRateFromRMS();
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
            iNumberOfChannels = 288; %oUnemap.oExperiment.Unemap.NumberOfChannels;
            iYdim = 8;%oUnemap.oExperiment.Plot.Electrodes.yDim; %Actually named the wrong dimension...
            row = ceil((iElectrodeNumber - floor(iElectrodeNumber/((iNumberOfChannels/2) + 1)) * (iNumberOfChannels/2))/iYdim);
            col = iElectrodeNumber + floor(iElectrodeNumber/((iNumberOfChannels/2)+1)) * iYdim - (ceil(iElectrodeNumber/iYdim)-1) * iYdim;
            
        end
               
        function ApplyNeighbourhoodAverage(oUnemap, aInOptions)
            %This function takes a struct as an input specifying an
            %averaging function to apply and bounds of a kernel over which to apply
            %the function. 
            
            %Get the average method from aInputs struct
            sAverageMethod = aInOptions.Procedure;
            %Mean: Calculate the mean signal within the kernel and
            %subtract from the central signal
            %EnvelopeSubtraction: Take the average of the derivatives of smoothed
            %electrograms in the kernel and subtract from the
            %derivative of the central signal
            
            %Get the template region
            dKernelBounds = aInOptions.KernelBounds;
            
            %Get the shape of the array information in the form that is
            %suitable for DataHelper.ColToArray
            %             iRows = oUnemap.oExperiment.Unemap.NumberOfPlugs * oUnemap.oExperiment.Plot.Electrodes.xDim;
            aLocs = cell2mat({oUnemap.Electrodes(:).Location});
            aLocs = aLocs';
            iRows = max(aLocs(:,1));
            iColumns = max(aLocs(:,2));
            %             iColumns = oUnemap.oExperiment.Plot.Electrodes.yDim;
            oWaitbar = waitbar(0,'Please wait...');
            iLength = length(oUnemap.TimeSeries);
            
            %Get the data for all electrodes
            switch (sAverageMethod)
                case 'Mean'
                    aArrayData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data');
                case 'GradientEnvelopeSubtraction'
                    %Calculate smoothed electrograms
                    aSelectedData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Processed','Data','FillRejectedColumns');
                    aSelectedData = oUnemap.SplineSmoothData(aSelectedData,3);
                    %Get the slope data for all channels
                    aSlopeData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Processed','Slope','FillRejectedColumns');
                    %Initialise array to hold derivatives of smoothed
                    %electrograms
                    aArrayData = zeros(size(aSelectedData,1),size(aSelectedData,2));
                    for i = 1:size(aSelectedData,2)
                        aArrayData(:,i) = oUnemap.CalculateSlope(aSelectedData(:,i),5,3);
                    end
                    %Initialise array to hold calculated envelopes
                    aEnvelopeData = zeros(size(aArrayData,1),size(aArrayData,2));
                case 'SignalEnvelopeSubtraction'
                    %Calculate smoothed electrograms
                    aSelectedData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Processed','Data','FillRejectedColumns');
                    aArrayData = oUnemap.SplineSmoothData(aSelectedData,3);
                    %Initialise array to hold calculated envelopes
                    aEnvelopeData = zeros(size(aArrayData,1),size(aArrayData,2));
                case 'CentralDifference'
                    %                     %Get the data for the selected channels
                    aArrayData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Processed','Data','FillRejectedColumns');
                    aFullCoords = cell2mat({oUnemap.Electrodes(:).Coords});
                    aFullCoords = aFullCoords';
                    %Get location data
                    aXData = zeros(size(aArrayData,2),1);
                    aYData = zeros(size(aArrayData,2),1);
                    for i = 1:length(oUnemap.Electrodes)
                        aXData(i,1) = oUnemap.Electrodes(i).Coords(1);
                        aYData(i,1) = oUnemap.Electrodes(i).Coords(2);
                    end
                    %Arrange as in array
                    aXArray = DataHelper.ColToArray(aXData,iRows,iColumns);
                    aYArray = DataHelper.ColToArray(aYData,iRows,iColumns);
                    %Reshape column vector to match colfilt
                    iIndex = 1;
                    for m = 1:size(aXArray,1)
                        for n = 1:size(aXArray,2)
                            aXData(iIndex,1) = aXArray(m,n);
                            aYData(iIndex,1) = aYArray(m,n);
                            iIndex = iIndex + 1;
                        end
                    end
            end
            %The array that will hold the resulting data following
            %processing
            aProcessedData = zeros(size(aArrayData,1),size(aArrayData,2));
            
            for i = 1:iLength
                %update the waitbar
                waitbar(i/iLength,oWaitbar,sprintf('Please wait... Processing Timepoint %d',i));
                %Get the data for this time point
                aTimePoint = aArrayData(i,:);
                %dMean = mean(aTimePoint);
                %Reshape the vector into an array
                aReshapedArray = DataHelper.ColToArray(aTimePoint,iRows,iColumns);
                %Perform the average subtraction
                switch (sAverageMethod)
                    case 'Mean'
                        aSubtractedAverage = colfilt(aReshapedArray,dKernelBounds,'sliding',@CalculateMean);
                        %Return the array to the correct shape and save in
                        %processed array
                        aProcessedData(i,:) = DataHelper.ArrayToCol(aSubtractedAverage);
                    case 'GradientEnvelopeSubtraction'
                        %Get the mean slope in a neighbourhood
                        aMeanSlope = colfilt(aReshapedArray,dKernelBounds,'sliding',@CalculateMean);
                        aCalculatedEnvelope = DataHelper.ArrayToCol(aMeanSlope);
                        %Return the array to the correct shape and save in
                        %processed array and envelope array
                        aEnvelopeData(i,:)  = aCalculatedEnvelope.';
                        aProcessedData(i,:) = aSlopeData(i,:) - aEnvelopeData(i,:);
                    case 'SignalEnvelopeSubtraction'
                        %Get the mean signal in a neighbourhood. 
                        aMeanSignal = colfilt(aReshapedArray,dKernelBounds,'sliding',@CalculateMean);
                        aCalculatedEnvelope = DataHelper.ArrayToCol(aMeanSignal);
                        %Return the array to the correct shape and save in
                        %processed array and envelope array
                        aEnvelopeData(i,:)  = aCalculatedEnvelope.';
                        %Take the difference
                        aProcessedData(i,:) = aSelectedData(i,:) - aEnvelopeData(i,:);
                    case 'CentralDifference'
                        %Perform a central difference on a 3x3
                        %neighbourhood
                        %Take a transpose because the colfilt moves down
                        %then across and I want it to do the opposite.
                        aReshapedArray = aReshapedArray.';
                        aCentralDifference = colfilt(aReshapedArray,dKernelBounds,'sliding',@CalculateCentralDifference);
                        %Undo transpose
                        aCentralDifference = aCentralDifference.';
                        aColumnArray = DataHelper.ArrayToCol(aCentralDifference);
                        %Return the array to the correct shape and save in
                        %processed array and envelope array
                        aProcessedData(i,:)  = aColumnArray.';
                end
                
            end
            %Save the result
            switch (sAverageMethod)
                case 'Mean'
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Data',aProcessedData);
                case 'GradientEnvelopeSubtraction'
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','EnvelopeSubtracted',aProcessedData);
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Envelope',aEnvelopeData);
                case 'SignalEnvelopeSubtraction'
                    %calculate slope of difference
                    for i = 1:size(aSelectedData,2)
                        aArrayData(:,i) = oUnemap.CalculateSlope(aProcessedData(:,i),5,3);
                    end
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','EnvelopeSubtracted',aArrayData);
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Envelope',aEnvelopeData);
                case 'CentralDifference'
                    oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','CentralDifference',aProcessedData);
            end
            %close the waitbar
            close(oWaitbar);
            
            %-------------------------------------------------------------
            %subfunction that does the mean subtraction
            function aOut = CalculateMean(aIn)
                %Loop through columns and 
                %find mean of non-zero elements
                [Xdim Ydim] = size(aIn);
                aOut = zeros(1, Ydim);
                iMidPoint = ceil(Xdim/2);
                %Only do this if the central point is an accepted channel
                for j = 1:Ydim;
                    if abs(aIn(iMidPoint,j)) > 0
                        %Subtract all the nonzero elements from the centre
                        %element
                        %dDiff = aIn(iMidPoint,j) - aIn(aIn(:,j)~=0,j);
                        %Count the number of nonzero elements
                        %iCount = length(dDiff);
                        %Take the average of these differences (removing the
                        %count of the 0 for the middle element)...
                        %slim possibility that this could result in div
                        %by 0 - will deal with this if and when it
                        %arises.
                        %aOut(1,j) = sum(dDiff)/(iCount - 1);
                        %Get the mean of the nonzero elements
                        aAbsVals = abs(aIn(:,j));
                        aCheckVals = aIn(aAbsVals > (1*10^-6),j);
                        aOut(1,j) = mean(aCheckVals);
                    end
                end
            end
            
            %-------------------------------------------------------------
            %subfunction that does the central difference calculation
            function aOut = CalculateCentralDifference(aIn)
                %get dimensions of array
                [Xdim Ydim] = size(aIn);
                %Initialise the output array
                aOut = zeros(1, Ydim);
                %set corner elements to zero as they play no part
                %in the central difference
                aIn(1,:) = 0;
                aIn(3,:) = 0;
                aIn(7,:) = 0;
                aIn(9,:) = 0;
                %Check the middle elements and set all corresponding outs
                %to 0
                aNonZeroMiddles = abs(aIn(5,:)) > 0;
                aOut(1,~aNonZeroMiddles) = 0;
                aNonZeroIndices = find(aNonZeroMiddles);
                aNonZeroTotals = sum(abs(aIn(:,aNonZeroIndices))) > 0;
                %Loop through remaining columns
                aNonZeroIndices = aNonZeroIndices(aNonZeroTotals);
                %Initialise variables
                iThisIndex = 0;
                aKernelData = zeros(size(aIn,1),1);
                for j = 1:length(aNonZeroIndices);
                    %get the data for this iteration
                    iThisIndex = aNonZeroIndices(j);
                    aKernelData = aIn(:,iThisIndex);
                    aNonZeroKernelIndices = abs(aKernelData) > 0;
                    if length(aKernelData(aNonZeroKernelIndices)) <= 2
                        %Not enough elements to construct complete dxdy
                        %difference
                        aOut(1,iThisIndex) = 0;
                    else
                        aNonMiddleIndices = find(aNonZeroKernelIndices);
                        %remove the middle member
                        aNonMiddleIndices = aNonMiddleIndices(aNonMiddleIndices > 5 | aNonMiddleIndices < 5);
                        if sum(aNonMiddleIndices) == 10
                            %Case where just three indices in x or
                            %y (not both) are present so cannot
                            %construct full central difference
                            aOut(1,iThisIndex) = 0;
                        else
                            %Get length values
                            iStep = 2*iColumns;
                            if length(aNonMiddleIndices) > 3
                                %All 5 elements are present so do full
                                %central difference
                                y1 = aYData(iThisIndex+iStep,1) - aYData(iThisIndex,1);
                                y2 = aYData(iThisIndex,1) - aYData(iThisIndex - iStep,1);
                                x1 = aXData(iThisIndex+1,1) - aXData(iThisIndex,1);
                                x2 = aXData(iThisIndex,1) - aXData(iThisIndex-1,1);
                                %dy = aKernelData(8)/(2*y1) - aKernelData(2)/(2*y2);
                                %dx = aKernelData(6)/(2*x1) - aKernelData(4)/(2*x2);
                                dy = -0.25*aKernelData(8) + 0.5*aKernelData(5) - 0.25*aKernelData(2);
                                dx = -0.25*aKernelData(6) + 0.5*aKernelData(5) - 0.25*aKernelData(4);
                            else
                                %Determine what difference to perform
                                dy = 0;
                                if aKernelData(8) == 0
                                    %then aKernelData(2) must be non zero
                                    %so perform a backward difference in y
                                    %dy = (aKernelData(5) - aKernelData(2))/(aYData(iThisIndex,1) - aYData(iThisIndex - iStep,1));
                                    dy = 0.5*aKernelData(5) - 0.5*aKernelData(2);
                                else
                                    %then aKernelData(8) must be non zero
                                    %so perform a forward difference in y
                                     %dy = (aKernelData(8) - aKernelData(5))/(aYData(iThisIndex + iStep,1) - aYData(iThisIndex,1));
                                     dy = 0.5*aKernelData(8) - 0.5*aKernelData(5);
                                end
                                dx = 0;
                                if aKernelData(6) == 0
                                    %then aKernelData(4) must be non zero
                                    %so perform a backward difference in x
                                    %dx = (aKernelData(5) - aKernelData(4))/(aXData(iThisIndex,1) - aXData(iThisIndex - 1,1));
                                    dx = 0.5*aKernelData(5) - 0.5*aKernelData(4);
                                else
                                    %then aKernelData(6) must be non zero
                                    %so perform a forward difference in x
                                    %dx = (aKernelData(6) - aKernelData(5))/(aXData(iThisIndex + 1,1) - aXData(iThisIndex,1));
                                    dx = 0.5*aKernelData(6) - 0.5*aKernelData(5);
                                end
                            end
                            %Calculate magnitude
                            aOut(1,iThisIndex) = sqrt(dy^2 + dx^2);
                            %aOut(1,iThisIndex) = dx;
                        end
                    end
                end
            end
        end
       
        function NormaliseBeat(oUnemap, iBeat)
            %Normalise the specified beat making the most negative value 0
            %and the most positive value 1.
            
            %Get the electrode processed data
            aProcessedData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Slope');
            aBeatData = aProcessedData(oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,1):...
                oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,2),:);
            %Blank the first 25 values to ignore the stimulus artifact
            aMinValues = min(aBeatData, [], 1);
            aNewData = zeros(size(aBeatData));
            for i = 1:size(aBeatData,2)
                %Loop through the electrodes
                aNewData(:,i) = -sign(aMinValues(i))*abs(aMinValues(i)) + aBeatData(:,i);
                
                aNewData(:,i) = aNewData(:,i) / max(aNewData(:,i));
            end
            aBeatData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Beats');
            aBeatData(oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,1):...
                oUnemap.Electrodes(1).Processed.BeatIndexes(iBeat,2),:) = aNewData;
            %Reload the beat data
            oUnemap.Electrodes = MultiLevelSubsAsgn(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Processed','Slope',aBeatData);
        end
        
        function oOutData = GetDataForPlotting(oUnemap, iBeat, aSelectedChannels)
            %This returns signal, slope and envelope data (if there is
            %some) and decimates data to minimum of 20 data points if there
            %is more than total 10,000 data points to plot.
            
            %Initialise the struct that will hold the data to plot
            %Get the data for these electrodes
            oElectrode = oUnemap.Electrodes(1); %just needed to define the beat range
            aSelectedElectrodes = oUnemap.Electrodes(aSelectedChannels);
            aData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aSelectedElectrodes,'Processed','Data');
            aSlope = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aSelectedElectrodes,'Processed','Slope');
            aEnvelope = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aSelectedElectrodes,'Processed','CentralDifference');
            %Select the data for this beat
            aTime =  oUnemap.TimeSeries(...
                oElectrode.Processed.BeatIndexes(iBeat,1):...
                oElectrode.Processed.BeatIndexes(iBeat,2));
            aData = aData(oElectrode.Processed.BeatIndexes(iBeat,1):...
                oElectrode.Processed.BeatIndexes(iBeat,2),:);
            aSlope = aSlope(oElectrode.Processed.BeatIndexes(iBeat,1):...
                oElectrode.Processed.BeatIndexes(iBeat,2),:);
            %Record the total length of this data - used to check if
            %we need to reduce this through interpolation for plotting
            %purposes
            iDataLength = size(aData,1)*size(aData,2) + size(aSlope,1)*size(aSlope,2);
            if ~isempty(aEnvelope)
                % If there was aEnvelope data stored then get the data
                % for this beat
                aEnvelope = abs(aEnvelope(oElectrode.Processed.BeatIndexes(iBeat,1):...
                    oElectrode.Processed.BeatIndexes(iBeat,2),:));
                iDataLength = iDataLength + size(aEnvelope,1)*size(aEnvelope,2) ;
            end
            %Reduce the size of the data arrays depending on the
            %number of plots to make
            if iDataLength > 10000
                iLeftover = iDataLength - 10000;
                dLengthToShortenTo = max(20,size(aTime,2) - floor(iLeftover / length(aSelectedElectrodes)));
                %Calc the interpolated time array
                aTimeToPlot = linspace(min(aTime),max(aTime),dLengthToShortenTo).';
                %Initialise arrays to hold interpolated data
                aDataToPlot = zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                aSlopeToPlot = zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                aEnvelopeToPlot =  zeros(dLengthToShortenTo,size(aSelectedElectrodes,2));
                %Shorten data for all selected electroes
                for i = 1:size(aSelectedElectrodes,2);
                    aDataToPlot(:,i) = interp1(aTime,aData(:,i),aTimeToPlot);
                    aSlopeToPlot(:,i) = interp1(aTime,aSlope(:,i),aTimeToPlot);
                    if ~isempty(aEnvelope)
                        aEnvelopeToPlot(:,i) = interp1(aTime,aEnvelope(:,i),aTimeToPlot);
                    end
                end
            else
                %No need for interpolation
                aTimeToPlot = aTime;
                aDataToPlot = aData;
                aSlopeToPlot = aSlope;
                aEnvelopeToPlot = aEnvelope;
            end
            %assign to output struct
            aCellArray = mat2cell(aDataToPlot,size(aDataToPlot,1),ones(1,size(aDataToPlot,2)));
            oOutData= struct('Data',aCellArray);
            aCellArray = mat2cell(aSlopeToPlot,size(aSlopeToPlot,1),ones(1,size(aSlopeToPlot,2)));
            [oOutData(:).Slope] = aCellArray{:};
            [oOutData(:).Time] = deal(aTimeToPlot);
            if ~isempty(aEnvelope)
                aCellArray = mat2cell(aEnvelopeToPlot,size(aEnvelopeToPlot,1),ones(1,size(aEnvelopeToPlot,2)));
                [oOutData(:).Envelope] = aCellArray{:};
            else
                [oOutData(:).Envelope] = deal([]);
            end
        end
        
        function oPlotLimits = GetPlotLimits(oUnemap, oDataToPlot, aSelectedChannels)
            %Calculate the plotting limits
            
            %Initialise the oPlotLimits struct that will hold the limits
            oPlotLimits = [];
            %Get the indices of the accepted electrodes in the list
            [rowIndexes, colIndexes, vector] = find(cell2mat({oUnemap.Electrodes(aSelectedChannels).Accepted}));
            %Select the accepted channels if there are any
            if ~isempty(colIndexes)
                aAcceptedElectrodes = colIndexes;
            else
                aAcceptedElectrodes = true(length(oDataToPlot),1);
            end
           
            oPlotLimits.Time = [min(oDataToPlot(1).Time),max(oDataToPlot(1).Time)]; %All time arrays are the same...
            oPlotLimits.Data = [min(min(cell2mat({oDataToPlot(aAcceptedElectrodes).Data}))), ...
                max(max(cell2mat({oDataToPlot(aAcceptedElectrodes).Data})))];
            oPlotLimits.Data = [(1-sign(oPlotLimits.Data(1))*0.1)*oPlotLimits.Data(1), (1+sign(oPlotLimits.Data(2))*0.1)*oPlotLimits.Data(2)];
            oPlotLimits.Slope = [min(min(cell2mat({oDataToPlot(aAcceptedElectrodes).Slope}))), ...
                max(max(cell2mat({oDataToPlot(aAcceptedElectrodes).Slope})))];
            oPlotLimits.Slope = [(1-sign(oPlotLimits.Slope(1))*0.1)*oPlotLimits.Slope(1), (1+sign(oPlotLimits.Slope(2))*0.1)*oPlotLimits.Slope(2)];
            if ~isempty(oDataToPlot(aAcceptedElectrodes(1)).Envelope)
                oPlotLimits.Envelope = [min(min(cell2mat({oDataToPlot(aAcceptedElectrodes).Envelope}))), ...
                    max(max(cell2mat({oDataToPlot(aAcceptedElectrodes).Envelope})))];
                oPlotLimits.Envelope = [(1-sign(oPlotLimits.Envelope(1))*0.1)*oPlotLimits.Envelope(1), ...
                    (1+sign(oPlotLimits.Envelope(2))*0.1)*oPlotLimits.Envelope(2)];
            else
                oPlotLimits.Envelope = [];
            end
        end
                
        function iElectrodeNumber = GetNearestElectrodeID(oUnemap, xLoc, yLoc)
            %Get the electrode whose coordinates are closest to those
            %specified in xLoc and yLoc (I wish this was a spatially
            %indexed database..)
            
            %Get coordinate array and calculate distance between each
            %electrode and specified location
            aCoords = oUnemap.oDAL.oHelper.MultiLevelSubsRef(oUnemap.Electrodes,'Coords');
            aXArray = aCoords(1,:) - xLoc;
            aYArray = aCoords(2,:) - yLoc;
            aDistance = sqrt(aXArray.^2 + aYArray.^2);
            %Return the index of the electrode with the minimum distance
            [C iElectrodeNumber] = min(aDistance);
        end
        
        function RotateArray(oUnemap)
            %Rotates the array locations 90 deg clockwise
            
            %Get the coord and location arrays
            aCoords = cell2mat({oUnemap.Electrodes(:).Coords});
            aLocations = cell2mat({oUnemap.Electrodes(:).Location});
            %Carry out first transpose so now 16 rows and 18 columns
            aNewCoords = [aCoords(2,:) ; aCoords(1,:)]';
            aNewLocs = [aLocations(2,:) ; aLocations(1,:)]';
            iMaxIndex = max(aNewLocs(:,2));
            %Loop through the array rows
            for i = 1:iMaxIndex
                %switch the rows so 1st row = last row etc
                aThisCol = find(aNewLocs(:,2) == i);
                aNewLocs(aThisCol,:) = flipud(aNewLocs(aThisCol,:));
                aNewCoords(aThisCol,:) = flipud(aNewCoords(aThisCol,:));
            end
            aNewCoords = aNewCoords';
            aNewLocs = aNewLocs';
            %switch the x and y coords and locations
            aNewCoords = num2cell([aNewCoords(1,:) ; aNewCoords(2,:)]',2);
            aNewLocs = num2cell([aNewLocs(1,:) ; aNewLocs(2,:)]',2);
            %Set the coords to be vertical arrays
            
            [oUnemap.Electrodes(:).Coords] = deal(aNewCoords{:});
            [oUnemap.Electrodes(:).Location] = deal(aNewLocs{:});
            for i = 1:length(oUnemap.Electrodes)
                oUnemap.Electrodes(i).Coords = [oUnemap.Electrodes(i).Coords(1) ; oUnemap.Electrodes(i).Coords(2)];
                oUnemap.Electrodes(i).Location = [oUnemap.Electrodes(i).Location(1) ; oUnemap.Electrodes(i).Location(2)];
            end
        end
        %% Methods relating to Electrode Activation data
        function UpdateEventRange(oUnemap, iEventIndex, aBeats, aElectrodes, aRange)
            %Change the range for the specified event and beat and selected
            %electrodes
            
            %Update range for selected beats and electrodes
            oWaitbar = waitbar(0,'Please wait...');
            for i = 1:length(aElectrodes)
                waitbar(i/length(aElectrodes),oWaitbar,sprintf('Please wait... Processing Electrode %d',i));
                for j = 1:length(aBeats)
                    %Set the new event range
                    oUnemap.Electrodes(aElectrodes(i)).SignalEvent(iEventIndex).Range(aBeats(j),:) = aRange + oUnemap.Electrodes(i).Processed.BeatIndexes(aBeats(j),1);
                    %Update the event index
                    oUnemap.MarkEvent(aElectrodes(i), iEventIndex, j);
                end
            end
            close(oWaitbar);

            
        end
        
        function MarkEvent(oUnemap, iElectrode, iEvent, varargin)
            %Mark activation for whole array based on the specified method 
            if strcmp(oUnemap.Electrodes(iElectrode).Status,'Potential')
                error('Unemap.GetActivationTime.VerifyInput:NoProcessedData',...
                    'You need to have processed data before calculating an activation time');
            else
                if isempty(varargin)
                    %only an eventid has been specified so mark activation
                    %times for all beats
                    sMethod = oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Method;
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestPositiveSlope'
                            % Get slope data if this has not been done already
                            if isnan(oUnemap.Electrodes(iElectrode).Processed.Slope)
                                oUnemap.GetSlope('Data',iElectrode);
                            end
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index =  fSteepestSlope(oUnemap.TimeSeries, ...
                                oUnemap.Electrodes(iElectrode).Processed.Slope, ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                        case 'SteepestNegativeSlope'
                            % Get slope data if this has not been done already
                            if isnan(oUnemap.Electrodes(iElectrode).Processed.Slope)
                                oUnemap.GetSlope('Data',iElectrode);
                            end
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index =  fSteepestNegativeSlope(oUnemap.TimeSeries, ...
                                oUnemap.Electrodes(iElectrode).Processed.Slope, ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                        case 'CentralDifference'
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index = fSteepestSlope(oUnemap.TimeSeries, ...
                                abs(oUnemap.Electrodes(iElectrode).Processed.CentralDifference), ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range);
                        case 'MaxSignalMagnitude'
                            %Loop through beats
                            for k = 1:size(oUnemap.Electrodes(iElectrode).Processed.BeatIndexes,1)
                                [C, oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index(k)] = ...
                                    max(oUnemap.Electrodes(iElectrode).Processed.Data(oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,1):...
                                    oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(k,2)));
                            end
                    end
                elseif size(varargin,2) >= 1
                    %Both a method and a beat number have been specified so
                    %only mark activation times for this beat
                    sMethod = oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Method;
                    iBeat = varargin{1};
                    %Choose the method to apply
                    switch (sMethod)
                        case 'SteepestPositiveSlope'
                            % Get slope data if this has not been done already
                            if isnan(oUnemap.Electrodes(iElectrode).Processed.Slope)
                                oUnemap.GetSlope('Data',iElectrode);
                            end
                            iIndex =  fSteepestSlope(oUnemap.TimeSeries, ...
                                oUnemap.Electrodes(iElectrode).Processed.Slope, ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oUnemap.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'SteepestNegativeSlope'
                            % Get slope data if this has not been done already
                            if isnan(oUnemap.Electrodes(iElectrode).Processed.Slope)
                                oUnemap.GetSlope('Data',iElectrode);
                            end
                            iIndex = fSteepestNegativeSlope(oUnemap.TimeSeries, ...
                                oUnemap.Electrodes(iElectrode).Processed.Slope, ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oUnemap.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'CentralDifference'
                            iIndex = fSteepestSlope(oUnemap.TimeSeries, ...
                                abs(oUnemap.Electrodes(iElectrode).Processed.CentralDifference), ...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,:));
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oUnemap.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                        case 'MaxSignalMagnitude'
                            [C, iIndex] = ...
                                max(oUnemap.Electrodes(iElectrode).Processed.Data(oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1):...
                                oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,2)));
                            oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Index(iBeat) = iIndex + oUnemap.Electrodes(iElectrode).SignalEvent(iEvent).Range(iBeat,1) - ...
                                oUnemap.Electrodes(iElectrode).Processed.BeatIndexes(iBeat,1);
                    end
                end
            end
        end
                
        function iIndex = GetIndexFromTime(oUnemap, iElectrodeNumber, iBeat, dTime)
            %Returns the index of the beat window corresponding to the
            %specified time
            iIndex = oUnemap.oDAL.oHelper.ConvertTimeToSeriesIndex(oUnemap.TimeSeries(...
                oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,1):...
                oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes(iBeat,2)), dTime);
        end
        
        function UpdateSignalEventMark(oUnemap, iElectrodeNumber, iEvent, iBeat, dTime)
            %Update the activation time index for the specified channel and
            %beat number
            
            %Convert the time into an index
            iIndex = oUnemap.oDAL.oHelper.ConvertTimeToSeriesIndex(oUnemap.TimeSeries(...
                oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Range(iBeat,1):...
                oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Range(iBeat,2)), dTime);
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent).Index(iBeat) = iIndex; 
        end

        function oMapData = PrepareEventMap(oUnemap,dInterpDim,iEventID,iSupportPoints)
            %If no eventID has been specified then default to 1
            if isempty(iEventID)
                iEventID = 1;
            end
            
            %get the accepted channels
            aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
            aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
            aFullCoords = cell2mat({oUnemap.Electrodes(:).Coords});
            aFullCoords = aFullCoords';
            aCoords = cell2mat({aElectrodes(:).Coords});
            aCoords = aCoords';
            rowlocs = aCoords(:,1);
            collocs = aCoords(:,2);
            %Get the interpolated points array
            [xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
                min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
            aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
            aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
            aMeshPoints = [aXArray,aYArray];
            %Find which points lie within the area of the array
            [V,ConcaveTri] = alphavol(aCoords,1);
            [FF BoundaryLocs] = freeBoundary(TriRep(ConcaveTri.tri,aCoords));
            aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),BoundaryLocs(:,1),BoundaryLocs(:,2));
            
            %Initialise the map data struct
            oMapData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints, 'CVx',aFullCoords(:,1),'CVy',aFullCoords(:,2));
            %Initialise the Beats struct
            aData = struct('FullActivationTimes',zeros(1, numel(oUnemap.Electrodes)),'ActivationTimes',...
                zeros(1, numel(aElectrodes)),'z',NaN(size(xlin)),'CVApprox',zeros(1, numel(oUnemap.Electrodes)),...
                'CVVectors',zeros(1, numel(oUnemap.Electrodes)),'ATgrad',zeros(1, numel(oUnemap.Electrodes)));
            oMapData.Beats = repmat(aData,1,size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1));
            %Get the activation indexes 
            aActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), numel(aElectrodes));
            aFullActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), numel(oUnemap.Electrodes));
            aFullActivationTimes = zeros(size(aFullActivationIndexes));
            %track the number of accepted electrodes
            m = 0;
            for p = 1:numel(oUnemap.Electrodes)
                if oUnemap.Electrodes(p).Accepted
                    m = m + 1;
                    aActivationIndexes(:,m) = aElectrodes(m).SignalEvent(iEventID).Index;
                    aFullActivationIndexes(:,p) =  aElectrodes(m).SignalEvent(iEventID).Index + oUnemap.Electrodes(p).Processed.BeatIndexes(:,1);
                    aFullActivationTimes(:,p) = oUnemap.TimeSeries(aFullActivationIndexes(:,p));
                else
                    %hold the unaccepted electrode places with inf
                    aFullActivationTimes(:,p) =  Inf;
                end
            end
            %initialise the activation times array
            aActivationTimes = zeros(size(aActivationIndexes));
            %do delaunay triangulation
            DT = DelaunayTri(aCoords);
            %set up wait bar
            oWaitbar = waitbar(0,'Please wait...');
            %Loop through the beats
            for k = 1:size(aActivationIndexes,1)
                %Get the activation time fields for all time points during this
                %beat
                waitbar(k/size(aActivationIndexes,1),oWaitbar,sprintf('Please wait... Processing Beat %d',k));
                aActivationIndexes(k,:) = aActivationIndexes(k,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(k,1);
                aTimesToUse = oUnemap.TimeSeries(aActivationIndexes(k,:));
                aActivationTimes(k,:) = aTimesToUse;
                %convert to ms
                aActivationTimes(k,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(k,:)) - min(aTimesToUse));
                aFullActivationTimes(k,:) = 1000*(aFullActivationTimes(k,:) - min(aFullActivationTimes(k,:)));
            
                %save to struct
                oMapData.Beats(k).FullActivationTimes = aFullActivationTimes(k,:).';
                oMapData.Beats(k).ActivationTimes = aActivationTimes(k,:).';

                %do interpolation
                %calculate interpolant
                oInterpolant = TriScatteredInterp(DT,oMapData.Beats(k).ActivationTimes);
                %evaluate interpolant
                oInterpolatedField = oInterpolant(xlin,ylin);
                %rearrange to be able to apply boundary
                aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                %apply boundary
                aQZArray(~aInBoundaryPoints) = NaN;
                %save result back in proper format
                oMapData.Beats(k).z  = reshape(aQZArray,size(xlin,1),size(xlin,2));
                
                %Calculate the CV and save the results
                [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oMapData.Beats(k).FullActivationTimes,iSupportPoints,0.1);
                oMapData.Beats(k).CVApprox = CVApprox;
                oMapData.Beats(k).CVVectors = CVVectors;
                oMapData.Beats(k).ATgrad = ATgrad;
            end
            close(oWaitbar);
        end
        
        function oMapData = PrepareActivationMap(oUnemap, dInterpDim, sPlotType, iEventID, iBeatIndex, oActivationData)
            %Get the inputs for a mapping call for activation times,
            %returning a struct containing the x and y locations of the
            %electrodes and the activation times for each. dInterpDim is
            %the number of interpolation points in each direction
                        
            %If no eventID has been specified then default to 1
            if isempty(iEventID)
                iEventID = 1;
            end
            
            switch (sPlotType)
                case 'Scatter'
                    oWaitbar = waitbar(0,'Please wait...');
                    %Get the electrode processed data
                    aActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), length(oUnemap.Electrodes));
                    for m = 1:length(oUnemap.Electrodes)
                        aActivationIndexes(:,m) = oUnemap.Electrodes(m).SignalEvent(iEventID).Index;
                    end
                    aActivationTimes = zeros(size(aActivationIndexes,1),size(aActivationIndexes,2));
                    %Make the activation indexes absolute, normalise them and
                    %convert to ms
                    aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
                    dMaxAcceptedTime = 0;
                    %dVals = [1];
                    for i = 1:size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1);%length(dVals)%
                        %i = dVals(k);
                        waitbar(i/size(oUnemap.Electrodes(1).SignalEvent.Index,1),oWaitbar,sprintf('Please wait... Processing Beat %d',i));
                        aActivationIndexes(i,:) = aActivationIndexes(i,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(i,1);
                        %Select accepted channels
                        aAcceptedActivations = aActivationIndexes(i,logical(aAcceptedChannels));
                        aAcceptedTimes = oUnemap.TimeSeries(aAcceptedActivations);
                        %Convert to ms
                        if isfield(oUnemap.Electrodes(1),'Pacing')
                            %this is a sequence of paced beats so express the
                            %activation time relative to the pacing stimulus
                            aActivationTimes(i,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(i,:)) - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(i)));
                        else
                            %this is a sequence of sinus beats so express the
                            %activation time relative to the earliest accepted
                            %activation
                            aActivationTimes(i,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(i,:)) - min(aAcceptedTimes));
                        end
                        
                        dMaxAcceptedTime = max(max(aActivationTimes(i,logical(aAcceptedChannels))),dMaxAcceptedTime);
                    end
                    aActivationTimes = transpose(aActivationTimes);
                    aCoords = cell2mat({oUnemap.Electrodes(:).Coords});
                    aCoords = aCoords';
                    aIndices = cell2mat({oUnemap.Electrodes(:).Accepted});
                    aActivationTimes(aIndices,:) = NaN;
                    
                    oMapData = struct();
                    oMapData.x = aCoords(:,1);
                    oMapData.y = aCoords(:,2);
                    oMapData.z = aActivationTimes;
                    oMapData.AcceptedActivationTimes = aAcceptedActivations;
                    oMapData.MaxActivationTime = dMaxAcceptedTime;
                    %compute CV
                    [CVApprox,CVVectors,ATgrad]=ReComputeCV([oMapData.x,oMapData.y],aActivationTimes,8,0.1);
                    oMapData.CVApprox = CVApprox;
                    oMapData.CVVectors = CVVectors;
                    oMapData.ATgrad = ATgrad;
                    close(oWaitbar);
                case 'Contour'
                    %get the accepted channels
                    aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
                    aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
                    %Get the points array that will be used to solve for the interpolation
                    %coefficients
                    %First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
                    % I.e x = A^-1 * b where x is ci.
                    aFullCoords = cell2mat({oUnemap.Electrodes(:).Coords});
                    aFullCoords = aFullCoords';
                    aCoords = cell2mat({aElectrodes(:).Coords});
                    aCoords = aCoords';
                    rowlocs = aCoords(:,1);
                    collocs = aCoords(:,2);
                    
                    %Get the interpolated points array
                    [xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
                        min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
                    aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
                    aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);

                    if isempty(oActivationData)
                        aMeshPoints = [aXArray,aYArray];
                        %Find which points lie within the area of the array
                        DT = DelaunayTri(aCoords);
                        aIndices = pointLocation(DT,aMeshPoints);
                        aIndices(isnan(aIndices)) = 0;
                        aInBoundaryPoints = logical(aIndices);
                        aMeshPoints = aMeshPoints(aInBoundaryPoints,:);
                        clear aIndices;
                        %Get the points array that will be used to solve for the interpolation
                        %coefficients
                        %First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
                        % I.e x = A^-1 * b where x is ci.
                        aPoints = (repmat(rowlocs,1,size(rowlocs,1)) - repmat(rowlocs',size(rowlocs,1),1)).^2 + ...
                            (repmat(collocs,1,size(collocs,1)) - repmat(collocs',size(collocs,1),1)).^2;
                        %Find the distance from each interpolation point to every data point
                        aInterpPoints = (repmat(aMeshPoints(:,1),1,size(rowlocs,1)) - repmat(rowlocs',size(aMeshPoints(:,1)),1)).^2 + ...
                            (repmat(aMeshPoints(:,2),1,size(collocs,1)) - repmat(collocs',size(aMeshPoints(:,2),1),1)).^2;
                        %Initialise the map data struct
                        oMapData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints, 'r2', 0.01,'CVx',aFullCoords(:,1),'CVy',aFullCoords(:,2));
                        %Finish calculating the points array
                        oMapData.Points = sqrt(aPoints + oMapData.r2);
                        %Finish calculating the interpolation points array
                        oMapData.InterpPoints = sqrt(aInterpPoints + oMapData.r2);
                        %Initialise the Beats struct
                        aData = struct('FullActivationTimes',zeros(1, length(oUnemap.Electrodes)),'ActivationTimes',...
                            zeros(1, length(oUnemap.Electrodes)),'Coefs',zeros(size(aInterpPoints,2),1),'Interpolated', ...
                            zeros(size(aInterpPoints,2),1),'z',NaN(size(aXArray,1),1),'RMS',0,'CVApprox',zeros(1, length(oUnemap.Electrodes)),...
                            'CVVectors',zeros(1, length(oUnemap.Electrodes)),'ATgrad',zeros(1, length(oUnemap.Electrodes)),...
                            'CVCoefs',zeros(size(aInterpPoints,2),1),'CVInterpolated',zeros(size(aInterpPoints,2),1),'CVz',NaN(size(aXArray,1),1));
                        oMapData.Beats = repmat(aData,1,size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1));
                        %Get the electrode processed data
                        aActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), length(aElectrodes));
                        aOutActivationIndexes = zeros(size(oUnemap.Electrodes(1).SignalEvent(iEventID).Index,1), length(oUnemap.Electrodes));
                        aOutActivationTimes = zeros(size(aOutActivationIndexes));
                        %track the number of accepted electrodes
                        m = 0;
                        for p = 1:length(oUnemap.Electrodes)
                            if oUnemap.Electrodes(p).Accepted
                                m = m + 1;
                                aActivationIndexes(:,m) = aElectrodes(m).SignalEvent(iEventID).Index;
                                aOutActivationIndexes(:,p) =  aElectrodes(m).SignalEvent(iEventID).Index + oUnemap.Electrodes(p).Processed.BeatIndexes(:,1);
                                aOutActivationTimes(:,p) = oUnemap.TimeSeries(aOutActivationIndexes(:,p));
                            else
                                %hold the unaccepted electrode places with inf
                                aOutActivationTimes(:,p) =  Inf;
                            end
                        end
                        aActivationTimes = zeros(size(aActivationIndexes));
                    end
                    if ~isempty(oActivationData) && ~isempty(iBeatIndex)
                        %a beat index has been specified so only refresh
                        %data for this beat
                        aTempData = oUnemap.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'SignalEvent','Index',iEventID);
                        aActivationIndexes = aTempData(iBeatIndex,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(iBeatIndex,1);
                        aTempData = oUnemap.oDAL.oHelper.MultiLevelSubsRef(oUnemap.Electrodes,'SignalEvent','Index',iEventID);
                        aOutActivationIndexes = aTempData(iBeatIndex,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(iBeatIndex,1);
                        clear aTempData;
                        aOutActivationTimes = oUnemap.TimeSeries(aOutActivationIndexes);
                        aOutActivationTimes(~logical(aAcceptedChannels)) = Inf;
                        aAcceptedTimes = oUnemap.TimeSeries(aActivationIndexes);
                        aActivationTimes = aAcceptedTimes;
                        %Convert to ms
                        if isfield(oUnemap.Electrodes(1),'Pacing')
                            %this is a sequence of paced beats so express the
                            %activation time relative to the pacing
                            %stimulus
                            aActivationTimes = 1000*(oUnemap.TimeSeries(aActivationIndexes) - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(iBeatIndex)));
                            aOutActivationTimes = 1000*(aOutActivationTimes - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(iBeatIndex)));
                        else
                            %this is a sequence of sinus beats so express
                            %the
                            %activation time relative to the earliest accepted
                            %activation
                            aActivationTimes = 1000*(oUnemap.TimeSeries(aActivationIndexes) - min(aAcceptedTimes));
                            aOutActivationTimes = 1000*(aOutActivationTimes - min(aOutActivationTimes));
                        end
                        %reinitialise z array
                        oActivationData.Beats(iBeatIndex).z = [];
                        oActivationData.Beats(iBeatIndex).z = NaN(size(aXArray,1),1); 
                        oActivationData.Beats(iBeatIndex).FullActivationTimes = aOutActivationTimes.';
                        oActivationData.Beats(iBeatIndex).ActivationTimes = aActivationTimes.';
                        oActivationData.Beats(iBeatIndex).Coefs = linsolve(oActivationData.Points,oActivationData.Beats(iBeatIndex).ActivationTimes);
                        %Get the interpolated data via matrix multiplication
                        oActivationData.Beats(iBeatIndex).Interpolated = oActivationData.InterpPoints * oActivationData.Beats(iBeatIndex).Coefs;
                        %Reconstruct field
                        oActivationData.Beats(iBeatIndex).z(oActivationData.Boundary) = oActivationData.Beats(iBeatIndex).Interpolated;
                        oActivationData.Beats(iBeatIndex).z = reshape(oActivationData.Beats(iBeatIndex).z,size(xlin,1),size(xlin,2));
                        %Find the indices of the closest interpolation points to each recording
                        %point
                        [Vals aMinIndices] = min(oActivationData.InterpPoints,[],1);
                        % %Calc the RMS error for this field
                        aExactPart = cell2mat({oActivationData.Beats(iBeatIndex).ActivationTimes});
                        aInterpPart = cell2mat({oActivationData.Beats(iBeatIndex).Interpolated});
                        aInterpPart = aInterpPart(aMinIndices,:);
                        oActivationData.Beats(iBeatIndex).RMS = sqrt(sum((aExactPart - aInterpPart).^2,1)/size(aExactPart,1));
                        
                        %Calculate the CV and save the results
                        [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oActivationData.Beats(iBeatIndex).FullActivationTimes,24,0.1);
                        oActivationData.Beats(iBeatIndex).CVApprox = CVApprox;
                        oActivationData.Beats(iBeatIndex).CVVectors = CVVectors;
                        oActivationData.Beats(iBeatIndex).ATgrad = ATgrad;
                        oMapData = oActivationData;
                        clear oActivationData;
                    else
                        oWaitbar = waitbar(0,'Please wait...');
                        %neither a beatindex or activationdata has been
                        %specified so refresh for all
                        %Loop through the beats
                        for k = 1:size(aActivationIndexes,1)
                            %Get the activation time fields for all time points during this
                            %beat
                            waitbar(k/size(aActivationIndexes,1),oWaitbar,sprintf('Please wait... Processing Beat %d',k));
                            aActivationIndexes(k,:) = aActivationIndexes(k,:) + oUnemap.Electrodes(1).Processed.BeatIndexes(k,1);
                            aAcceptedTimes = oUnemap.TimeSeries(aActivationIndexes(k,:));
                            aActivationTimes(k,:) = aAcceptedTimes;
                            %Convert to ms
                            if isfield(oUnemap.Electrodes(1),'Pacing')
                                %this is a sequence of paced beats so express the
                                %activation time relative to the pacing
                                %stimulus
                                aActivationTimes(k,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(k,:)) - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(k)));
                                aOutActivationTimes(k,:) = 1000*(aOutActivationTimes(k,:) - oUnemap.TimeSeries(oUnemap.Electrodes(1).Pacing.Index(k)));
                            else
                                %this is a sequence of sinus beats so express the
                                %activation time relative to the earliest accepted
                                %activation
                                aActivationTimes(k,:) = 1000*(oUnemap.TimeSeries(aActivationIndexes(k,:)) - min(aAcceptedTimes));
                                aOutActivationTimes(k,:) = 1000*(aOutActivationTimes(k,:) - min(aOutActivationTimes(k,:)));
                            end
                            oMapData.Beats(k).FullActivationTimes = aOutActivationTimes(k,:).';
                            oMapData.Beats(k).ActivationTimes = aActivationTimes(k,:).';
                            oMapData.Beats(k).Coefs = linsolve(oMapData.Points,oMapData.Beats(k).ActivationTimes);
                            %Get the interpolated data via matrix multiplication
                            oMapData.Beats(k).Interpolated = oMapData.InterpPoints * oMapData.Beats(k).Coefs;
                            %Reconstruct field
                            oMapData.Beats(k).z(oMapData.Boundary) = oMapData.Beats(k).Interpolated;
                            oMapData.Beats(k).z = reshape(oMapData.Beats(k).z,size(xlin,1),size(xlin,2));
                            %Find the indices of the closest interpolation points to each recording
                            %point
                            [Vals aMinIndices] = min(oMapData.InterpPoints,[],1);
                            % %Calc the RMS error for this field
                            aExactPart = cell2mat({oMapData.Beats(k).ActivationTimes});
                            aInterpPart = cell2mat({oMapData.Beats(k).Interpolated});
                            aInterpPart = aInterpPart(aMinIndices,:);
                            oMapData.Beats(k).RMS = sqrt(sum((aExactPart - aInterpPart).^2,1)/size(aExactPart,1));
                            
                            %Calculate the CV and save the results
                            
                            [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oMapData.Beats(k).FullActivationTimes,24,0.1);
                            oMapData.Beats(k).CVApprox = CVApprox;
                            oMapData.Beats(k).CVVectors = CVVectors;
                            oMapData.Beats(k).ATgrad = ATgrad;
                        end
                        close(oWaitbar);
                    end
            end
            
        end
        
        function oMapData = PreparePotentialMap(oUnemap, dInterpDim)
            %Get the inputs for a mapping call for potential fields,
            %returning a struct containing the x and y locations of the
            %electrodes and the potential fields for each time point in each beat.
            %This implements Hardy interpolation with an interpolation
            %array of dInterPoints x dInterpDim
            
            oWaitbar = waitbar(0,'Please wait...');
            
            %get the accepted channels
            aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
            aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
            
            %Get the points array that will be used to solve for the interpolation
            %coefficients
            %First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
            % I.e x = A^-1 * b where x is ci.
            aPoints = zeros(length(aElectrodes),length(aElectrodes));
            %...and turn the coords into a 2 column matrix
            aCoords = zeros(length(aElectrodes),2);
            
            for m = 1:length(aElectrodes);
                for i = 1:length(aElectrodes);
                    %Calc the euclidean distance between each point and every other
                    %point
                    aPoints(m,i) =  (aElectrodes(m).Coords(1) - aElectrodes(i).Coords(1))^2 + ...
                        (aElectrodes(m).Coords(2) - aElectrodes(i).Coords(2))^2;
                end
                %Save the coordinates
                aCoords(m,1) = aElectrodes(m).Coords(1);
                aCoords(m,2) = aElectrodes(m).Coords(2);
            end
            
            %Get the interpolated points array
            xlin = linspace(min(aCoords(:,1)), max(aCoords(:,1)), dInterpDim);
            ylin = linspace(min(aCoords(:,2)), max(aCoords(:,2)), dInterpDim);
            
            %Also the indexes in the interpolation array of the points that are closest to
            %the recording points - will use to calculate the error
            xIndices = zeros(length(aElectrodes),1);
            yIndices = zeros(length(aElectrodes),1);
            %Make an array of arbitrarily large numbers to be replaced with minimums
            aMinPoints = ones(1,length(aElectrodes))*2000;
            aInterpPoints = zeros(dInterpDim*dInterpDim,length(aElectrodes));
            
            for i = 1:length(aElectrodes);
                for m = 1:length(xlin)
                    for n = 1:length(ylin)
                        aInterpPoints((m-1)*length(ylin)+n,i) =  (xlin(m) - aElectrodes(i).Coords(1))^2 + ...
                            (ylin(n) - aElectrodes(i).Coords(2))^2;
                        if aInterpPoints((m-1)*length(xlin)+n,i) < aMinPoints(1,i)
                            aMinPoints(1,i) = aInterpPoints((m-1)*length(xlin)+n,i);
                            xIndices(i) = m;
                            yIndices(i) = n;
                        end
                    end
                end
            end
            
            %Initialise the map data struct
            oMapData = struct('x', xlin, 'y', ylin, 'r2', 0.005);
            %Finish calculating the points array
            oMapData.Points = sqrt(aPoints + oMapData.r2);
            %Finish calculating the interpolation points array
            oMapData.InterpPoints = sqrt(aInterpPoints + oMapData.r2);
            oMapData.Beats = struct();    
            %Get the potential data for all beats
            aAllBeatPotentials = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aElectrodes,'Processed','Beats');
            %initialise an RMS array
            aRMS = zeros(length(aElectrodes),1);
            %Loop through the beats
            for k = 1:size(aElectrodes(1).Processed.BeatIndexes,1)
                %Get the potential fields for all time points during this
                %beat
                waitbar(k/size(aElectrodes(1).Processed.BeatIndexes,1),oWaitbar,sprintf('Please wait... Processing Beat %d',k));
                aSingleBeatPotentials = aAllBeatPotentials(aElectrodes(1).Processed.BeatIndexes(k,1):aElectrodes(1).Processed.BeatIndexes(k,2),:);
                %initialise the struct to hold all the interpolated fields
                oFields = struct();
                %Loop through time points in beat
                for u = 1:size(aSingleBeatPotentials,1)
                    oFields(u).Potential = aSingleBeatPotentials(u,:).';
                    oFields(u).Coefs = linsolve(oMapData.Points,oFields(u).Potential);
                    %Get the interpolated potentials via matrix multiplication
                    oFields(u).Interpolated = oMapData.InterpPoints * oFields(u).Coefs;
                    %Reconstruct field
                    oFields(u).z = zeros(dInterpDim, dInterpDim);
                    for m = 1:dInterpDim
                        oFields(u).z(:,m) = oFields(u).Interpolated((m-1)*dInterpDim+1:m*dInterpDim,1);
                    end
                    %Calc the RMS error for this field
                    for i = 1:length(aRMS)
                        aRMS(i) =  (oFields(u).Potential(i) -  oFields(u).z(yIndices(i),xIndices(i)))^2;
                    end
                    oFields(u).RMS = sqrt(sum(aRMS)/length(aRMS));
                    %Save the fields struct
                    oMapData.Beats(k).Fields = oFields;
                end
            end
            close(oWaitbar);
        end
               
        function oMapData = CalculateAverageActivationMap(oUnemap,oActivationData)
            %Calculate average activation times over beats that at the
            %moment are hardcoded but could be user specified
            oMapData = struct();
            oMapData.x = oActivationData.x;
            oMapData.y = oActivationData.y;
            oMapData.PreStim.z =  mean(oActivationData.z(:,8:12),2);
            oMapData.Stim.z =  mean(oActivationData.z(:,20:24),2);
            oMapData.PostStim.z =  mean(oActivationData.z(:,46:50),2);
        end
        
        function CreateNewEvent(oUnemap, iElectrodeNumber, varargin)
            %Create a new event from the provided details
            
            if ~isfield(oUnemap.Electrodes(iElectrodeNumber), 'SignalEvent')
                %Initialise the SignalEvent field
                oUnemap.Electrodes(iElectrodeNumber).SignalEvent = [];
                iEvent = 1;
            elseif isfield(oUnemap.Electrodes(iElectrodeNumber).SignalEvent,'ID')
                %Check the event ID
                aEventIDs = {oUnemap.Electrodes(iElectrodeNumber).SignalEvent(:).ID};
                sThisEvent = oUnemap.MakeEventID(char(varargin{1}), char(varargin{2}), char(varargin{3}));
                [sLeftover iIndex iIsPresent] = setxor(aEventIDs, sThisEvent);
                if isempty(sLeftover)
                    %There is only one event and it is the current one
                    iEvent = 1;
                elseif ~isempty(iIsPresent)
                    %This event is not present in the EventID array
                    iEvent = length(oUnemap.Electrodes(iElectrodeNumber).SignalEvent) + 1;
                else
                    %This event has already been created for this
                    %electrode
                    iEvent = iIndex;
                end
            else
                iEvent = 1;
            end
            %Specify the processed beat indexes as the default range
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Range = oUnemap.Electrodes(iElectrodeNumber).Processed.BeatIndexes;
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Label.Colour = char(varargin{1});
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Type = char(varargin{2});
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Method = char(varargin{3});
            %initialise and build ID
            oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).ID = oUnemap.MakeEventID(char(varargin{1}), ...
                oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Type(1),oUnemap.Electrodes(iElectrodeNumber).SignalEvent(iEvent,1).Method);
            if size(varargin,2) == 4
                %A beat number has been specified so mark event just
                %for this beat (otherwise all beats)
                oUnemap.MarkEvent(iElectrodeNumber, iEvent,[varargin{5}]);
            else
                oUnemap.MarkEvent(iElectrodeNumber, iEvent);
            end
            
        end
        
        function sEventID = MakeEventID(oUnemap, sColour, sEventType, sMethod)
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
            end
            
        end
        
        function DeleteEvent(oUnemap, sEventID, aElectrodes)
            %Delete the specified event for the selected electrodes and all
            %beats
            if isempty(aElectrodes)
                %delete for all electrodes
                aElectrodes = 1:length(oUnemap.Electrodes);
            end
            for i = 1:length(aElectrodes)
                aEvents = oUnemap.Electrodes(aElectrodes(i)).SignalEvent;
                if length(aEvents) > 1
                    aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID), aEvents);
                    oUnemap.Electrodes(aElectrodes(i)).SignalEvent = oUnemap.Electrodes(aElectrodes(i)).SignalEvent(~aIndices);
                else
                    if strcmpi(aEvents.ID, sEventID)
                        oUnemap.Electrodes(aElectrodes(i)).SignalEvent = [];
                    end
                end
                
            end
        end
        
        function iIndex = GetEventIndex(oUnemap, iElectrodeNumber, sEventID)
            aEvents = oUnemap.Electrodes(iElectrodeNumber).SignalEvent;
            aIndices = arrayfun(@(x) strcmpi(x.ID,sEventID), aEvents);
            [row, iIndex] = find(aIndices);
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
        
        function oUnemap = GetUnemapAndUpdateExperiment(oUnemap,sFile,oNewExperiment)
            %   Get an entity by loading a mat file that has been saved
            %   previously and replace the Experiment entity
            
            %   Load the mat file into the workspace
            oData = oUnemap.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties
            oUnemap.TimeSeries = oData.oEntity.TimeSeries;
            oUnemap.oExperiment = oNewExperiment;
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
                oUnemap.oExperiment.Unemap.NumberOfChannels, char(aFileFull(1)), 0);
            oUnemap.RMS.Electrodes = [];
                             
            % Get the electrode data
            oUnemap.oDAL.GetDataFromSignalFile(oUnemap,sFile);
        end
        
        function oUnemap = GetSpecificElectrodeFromTXTFile(oUnemap, iElectrodeNumber, sFile, oExperiment)
            %   Get an entity by loading data from a txt file - only done the
            %   first time you are creating a Unemap entity
            
            %   Get the path
            [sPath] = fileparts(sFile);
            
            %   Look for an array config file in the same directory that will
            %   contain the electrode names/positions
            aFileFull = fGetFileNamesOnly(sPath,'*.cnfg');
            %Set the experiment
            oUnemap.oExperiment = oExperiment;
            % Get the electrodes
            oUnemap.Electrodes = oUnemap.oDAL.GetElectrodesFromConfigFile(...
                0, char(aFileFull(1)),iElectrodeNumber);
            % Get the electrode data
            oUnemap.oDAL.GetElectrodeFromSignalFile(oUnemap,iElectrodeNumber,sFile);
        end
    end
    
    
end

