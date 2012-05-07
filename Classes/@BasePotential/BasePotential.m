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
        function OutData = ProcessData(oBasePotential, aInData, sProcedure, iOrder)
            % This function processes data depending on the specified procedure 
            %  to be performed. 
            % After aInData the arguments should be listed:
            % - sProcedure: a string specifying the procedure to run:
            %       *RemoveMedianAndFitPolynomial - computes the overall median of the signal data (Electrodes)
            %           and subtracts this constant from the data. A polynomial fit of order iOrder is then computed 
            %           and subtracted from the data.
            %           For this the second input should be iOrder, the
            %           order of the polynomial to fit.
            %       *SplineSmoothData - Apply a spline approximation of a specified order.
            %           For this the second input should be iOrder, the
            %           order of the spline to apply.
            %       *RemoveSplineInterpolation - Using cubic spline
            %       interpolation between isoelectric points to remove this
            %       variation between beats
            OutData = zeros(size(aInData,1),size(aInData,2));
            
            switch sProcedure
                case 'RemoveMedianAndFitPolynomial'
                    %Loop through all the columns
                    for k = 1:size(aInData,2);
                        %Remove the polynomial approximation to the baseline from the data
                        OutData(:,k) =  oBasePotential.PerformCorrection(aInData(:,k),iOrder);
                    end
                case 'SplineSmoothData'
                    %Loop through all the columns
                    for k = 1:size(aInData,2);
                        %Apply a spline approximation to smooth the data
                        OutData(:,k) = fSplineSmooth(aInData(:,k),iOrder,'MaxIter',500);
                    end
                case 'RemoveSplineInterpolation'
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
                    %Loop through channels
                    for j = 1:y;
                        OutData(:,j) = fInterpolate({aAverages(:,1),aAverages(:,j+1)},iOrder,x);
                    end

            end

        end
        
    end
    
    methods (Access = private)
        %% Private methods
        function aOut = PerformCorrection(oBasePotential,aIn,iOrder)
            %Perform baseline correction
            
            %Compute the median
            dMedian = median(aIn);
            %Subtract this from the input data
            aRemoveMedian = aIn - dMedian;
            %Compute the polynomial fit of order iOrder
            aBaselinePolynomial = fPolynomialFitEvaluation(aRemoveMedian,iOrder);
            %Remove the polynomial approximation to the baseline from the
            %data
            aOut = aRemoveMedian-aBaselinePolynomial;
        end
    end
    
end

