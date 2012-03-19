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
        end
    end
    
    methods (Access = public)
        %% Public methods that are inherited
        function OutData = ProcessData(oBasePotential, aInData, varargin)
            % This function processes data depending on the specified procedure 
            %  to be performed. 
            % After aInData (the input data to be processed) the arguments should be listed:
            % - sProcedure: a string specifying the procedure to run:
            %       *RemoveMedianAndFitPolynomial - computes the overall median of the signal data (aInData)
            %           and subtracts this constant from the data. A polynomial fit of order iOrder is then computed 
            %           and subtracted from the data.
            %           For this the second input should be iOrder, the
            %           order of the polynomial to fit and a third input,
            %           iIndex can be specified
            %       *SplineSmoothData - Apply a spline approximation of a specified order.
            %           For this the second input should be iOrder, the
            %           order of the spline to apply and a third input,
            %           iIndex can be specified
            
            %Initialise the output array
            sProcedure = varargin{1,1}{1,1};
            OutData = zeros(size(aInData,1),size(aInData,2));
            %Check the number of arguments and determine what to do
            switch size(varargin{1,1},2)
                case 2 %Only the spline order has been specified so apply to whole array
                    iOrder = varargin{1,1}{1,2};
                    oWaitbar = waitbar(0,'Please wait...');
                    switch sProcedure
                        case 'RemoveMedianAndFitPolynomial'
                            %Loop through all the columns
                            for k = 1:size(aInData,2);
                                %Remove the polynomial approximation to the baseline from the data
                                OutData(:,k) =  oBasePotential.PerformCorrection(aInData(:,k),iOrder);
                                %Update the waitbar
                                waitbar(k/size(aInData,2),oWaitbar,sprintf(...
                                    'Please wait... Baseline Correcting Signal %d',k));
                            end
                        case 'SplineSmoothData'
                            %Loop through all the columns
                            for k = 1:size(aInData,2);
                                %Apply a spline approximation to smooth the data
                                OutData(:,k) = fSplineSmooth(aInData(:,k),iOrder,'MaxIter',500);
                                %Update the waitbar
                                waitbar(k/size(aInData,2),oWaitbar,sprintf(...
                                    'Please wait... Smoothing signal %d',k));
                            end
                   end
                    close(oWaitbar);
                case 3 %A column number has been specified so only apply to this column
                    iOrder = varargin{1,1}{1,2};
                    iIndex = varargin{1,1}{1,3};
                    switch sProcedure
                        case 'RemoveMedianAndFitPolynomial'
                            %Remove the polynomial approximation to the baseline from the data
                            OutData(:,iIndex) =  oBasePotential.PerformCorrection(aInData(:,iIndex),iOrder);
                        case 'SplineSmoothData'
                            %Apply a spline approximation to smooth the data
                            OutData(:,iIndex) = fSplineSmooth(aInData(:,iIndex),iOrder,'MaxIter',500);
                    end
                    
                otherwise %The wrong number of inputs have been specified
                    error('BasePotential.ProcessData:unknowncase', ...
                        'Wrong number of inputs');
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

