classdef BaseSignal < BaseEntity
    %BaseSignal 
    %   This is the base class for any signal acquired so contains signal
    %   processing methods.
    
    properties
    end
    
    methods
         %% Constructor
        function oBaseSignal = BaseSignal()
            oBaseSignal = oBaseSignal@BaseEntity();
        end
    end
    
    methods (Access = public)
        %% Public methods that are inherited
        function [OutData, aBaselinePolynomial] = RemoveMedianAndFitPolynomial(oBaseSignal, aInData, iOrder)
            %       *RemoveMedianAndFitPolynomial - computes the overall median of the signal data (e.g Electrodes)
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
        
        function OutData = SplineSmoothData(oBaseSignal, aInData, varargin)
            %       *SplineSmoothData - Apply a spline approximation of a specified order.
            %           For this the second input should be iOrder, the
            %           order of the spline to apply.
            OutData = zeros(size(aInData,1),size(aInData,2));
            %Do some checks
            if length(varargin{1}) > 1 
                iOrder = cell2mat(varargin{1}(1));
                sType = char(varargin{1}(2));
                %Loop through all the columns
                for k = 1:size(aInData,2);
                    %Apply a spline approximation to smooth the data
                    OutData(:,k) = fSplineSmooth(aInData(:,k),iOrder,'MaxIter',500,sType);
                end
            elseif length(varargin{1}) > 0
                iOrder = cell2mat(varargin{1}(1));
                %Loop through all the columns
                for k = 1:size(aInData,2);
                    %Apply a spline approximation to smooth the data
                    OutData(:,k) = fSplineSmooth(aInData(:,k),iOrder,'MaxIter',500);
                end
            else
                error('BasePotential.SplineSmoothData.VerifyInput:Incorrect', 'Wrong number of inputs.')
            end
            
        end
        
        function OutData = FilterData(oBaseSignal, aInData, sFilterType, varargin)
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
    end
end

