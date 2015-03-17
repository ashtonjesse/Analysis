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
                case 'LowPass'
                    %Get nyquist frequency
                    wo = varargin{1}/2;
                    fc = varargin{2};
                    [z p k] = butter(3, fc/wo, 'low'); % 3rd order filter
                    %                     [z p k] = cheby1(5,0.5, fc/wo); % 5th order filter
                    [sos,g] = zp2sos(z,p,k); % Convert to 2nd order sections form
                    oFilter = dfilt.df2sos(sos,g); % Create filter object
                    %                     fvtool(oFilter);
                    %Check if this filter should be applied to processed or
                    %original data
                    OutData = filter(oFilter,aInData);
                    %reverse, repeat filter and reverse again
                    if isrow(OutData)
                        OutData = fliplr(OutData);
                        OutData = filter(oFilter,OutData);
                        OutData = fliplr(OutData);
                    else
                        OutData = flipud(OutData);
                        OutData = filter(oFilter,OutData);
                        OutData = flipud(OutData);
                    end
                case 'SovitzkyGolay'
                    iOrder = varargin{1};
                    iWindowSize = varargin{2};
                    %Apply filter
                    OutData = sgolayfilt(aInData,iOrder,iWindowSize);
                    
                case 'TukeyWindow'
                    iAlpha = varargin{1};
                    iWindowSize = varargin{2};
                    oWindow = tukeywin(iWindowSize,iAlpha);
                    OutData = filter(oWindow,sum(oWindow),aInData);
                    
                case 'BartlettWindow'
                    iWindowSize = varargin{1};
                    oWindow = bartlett(iWindowSize);
                    OutData = filter(oWindow,sum(oWindow),aInData);
                    
                case 'DWTFilterRemoveScales'
                    iScale = varargin{1};
                    OutData = oBaseSignal.ComputeDWTFilteredSignalsRemovingScales(aInData,iScale);
                    
                case 'DWTFilterKeepScales'
                    iScale = varargin{1};
                    OutData = oBaseSignal.ComputeDWTFilteredSignalsKeepingScales(aInData,iScale);
            end
        end
        
        function OutData = ComputeDWTFilteredSignalsKeepingScales(oBaseSignal, aInData, aScales)
            % Compute the DWT filtered signal keeping the scales specified
            % by iScales
            OutData = zeros(length(aInData),length(aScales));
            for i = 1:length(aScales)
                OutData(:,i) = DWTFilterKeepScales(aInData,aScales(i));
            end
        end
        
        function OutData = ComputeDWTFilteredSignalsRemovingScales(oBaseSignal, aInData, aScales)
            % Compute the DWT filtered signal removing the scales specified
            % by iScales
            OutData = zeros(length(aInData),length(aScales));
            for i = 1:length(aScales)
                OutData(:,i) = DWTFilterRemoveScales(aInData, aScales(i));
            end
        end
        
        function OutData = ResampleSignal(oBaseSignal, aInData, dNewSamplingRate, dOldSamplingRate)
            OutData = resample(aInData,dNewSamplingRate, dOldSamplingRate);
        end
        
        function OutData = ComputeRectifiedBinIntegral(oBaseSignal,aInData, iBinSize)
            %initialise variables
            OutData = zeros(length(aInData),1);
            dIntegrand = 0;
            iBinCount = 1;
            aInData = detrend(aInData);
            for i = 1:length(OutData)
                if (iBinCount * iBinSize) == i
                    %compute the integrand for the next bin
                    iStart = (iBinSize * (iBinCount-1) + 1);
                    iEnd = iStart + iBinSize;
                    %rectification through taking absolute value
                    dSum = sum(abs(aInData(iStart:iEnd)));
                    dIntegrand = dSum / iBinSize;
                    iBinCount = iBinCount + 1;
                end
                OutData(i) = dIntegrand;
            end
        end
    end
end

