classdef BasePotential < BaseEntity
    %   BasePotential 
    %   This is the base class for all entities that hold experimental data
    %   of the potential type. 
    
    properties
    end
    
    methods
        %% Constructor
        function oBasePotential = BasePotential()
            oBasePotential = oBasePotential@BaseEntity();
            oBasePotential.oDAL = PotentialDAL();
        end
    end
        
    methods (Access = public)
        %% Public methods that are inherited
        function [OutData, aBaselinePolynomial] = RemoveMedianAndFitPolynomial(oBasePotential, aInData, iOrder)
            %       *RemoveMedianAndFitPolynomial - computes the overall median of the signal data (Electrodes)
            %           and subtracts this constant from the data. A polynomial fit of order iOrder is then computed 
            %           and subtracted from the data.
            %           For this the second input should be iOrder, the
            %           order of the polynomial to fit.
            OutData = zeros(size(aInData,1),size(aInData,2));
            %Loop through all the columns
            for k = 1:size(aInData,2);
                %Remove the polynomial approximation to the baseline from the data
                %Compute the median
                dMedian = median(aInData(:,k));
                %Subtract this from the input data
                aRemoveMedian = aInData(:,k) - dMedian;
                %Compute the polynomial fit of order iOrder
                aBaselinePolynomial = fPolynomialFitEvaluation(aRemoveMedian,iOrder);
                %Remove the polynomial approximation to the baseline from the
                %data
                OutData(:,k) = aRemoveMedian-aBaselinePolynomial;
            end
        end
        
        function OutData = SplineSmoothData(oBasePotential, aInData, iOrder)
            %       *SplineSmoothData - Apply a spline approximation of a specified order.
            %           For this the second input should be iOrder, the
            %           order of the spline to apply.
            OutData = zeros(size(aInData,1),size(aInData,2));
            %Loop through all the columns
            for k = 1:size(aInData,2);
                %Apply a spline approximation to smooth the data
                OutData(:,k) = fSplineSmooth(aInData(:,k),iOrder,'MaxIter',500);
            end
        end
        
        function OutData = FilterData(oBasePotential, aInData, sFilterType, varargin)
            %             Apply a filter - either 50Hz notch or
            %             SovitzkyGolay
            
            %Determine filter type
            switch(sFilterType)
                case '50HzNotch'
                    %Get nyquist frequency
                    wo = cell2mat(varargin{1}(1))/2;
                    [z p k] = butter(3, [49 51]./wo, 'stop'); % 10th order filter
                    [sos,g] = zp2sos(z,p,k); % Convert to 2nd order sections form
                    oFilter = dfilt.df2sos(sos,g); % Create filter object
                    %Check if this filter should be applied to processed or
                    %original data
                    OutData = filter(oFilter,aInData);
                case 'SovitzkyGolay'
                    iOrder = cell2mat(varargin{1}(1));
                    iWindowSize = cell2mat(varargin{1}(2));
                    %Apply filter
                    OutData = sgolayfilt(aInData,iOrder,iWindowSize);
            end
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
        
% % %         function OutData = ProcessData(oBasePotential, aInData, sProcedure, varargin)
% % %             % This function processes data depending on the specified procedure 
% % %             %  to be performed. 
% % %             % After aInData the arguments should be listed:
% % %             % - sProcedure: a string specifying the procedure to run:
% % %             
% % %             
% % %             
% % %             
% % %             
% % %                     
% % %                     'NeighbourhoodAverage'
% % %                     oImage = mat2gray(aInData);
% % %                     iBlockDim = cell2mat(varargin{1,1});
% % %                     OutData = colfilt(oImage,[iBlockDim iBlockDim],'sliding',@(oBasePotential) SubtractNeighbourhoodAverage(oBasePotential));
% % %         end
        
    end
    
    methods (Access = private)
        %% Private methods
        function aOut = SubtractNeighbourhoodAverage(oBasePotential)
            x = 1;
        end
    end
    
end

