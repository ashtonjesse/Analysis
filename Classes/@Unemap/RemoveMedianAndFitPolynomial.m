function oPotential = RemoveMedianAndFitPolynomial(oPotential, varargin)
% This function computes the overall median of the signal data (aInData)
% and subtracts this constant from the data. A polynomial fit of order 
% iOrder is then computed and subtracted from the data.
% It accepts between 2 and 3 input variables (incl the object handle) and
% the order of the polynomial iOrder should be specified first, then a
% selected channel if needed.

addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/'));
%Check the number of arguments and determine what to do
switch nargin
    case 2 %Only the polynomial order has been specified so apply to whole struct
        iOrder = varargin{1};
     
        %Initialise the Baseline.Corrected array
        oWaitbar = waitbar(0,'Please wait...');
        oPotential.Baseline.Corrected = zeros(size(oPotential.Original,1),...
            oPotential.Experiment.Unemap.NumberOfElectrodes);
        
        %Loop through all the electrodes creating a baseline polynomial for
        %each and removing this component from the data.
        for k = 1:oPotential.Experiment.Unemap.NumberOfElectrodes;
            %Remove the polynomial approximation to the baseline from the
            %data and the load this back into baseline.corrected
            oPotential.Baseline.Corrected(:,k) =  PerformCorrection(oPotential.Original(:,k),iOrder);
            %Update the waitbar
            waitbar(k/Experiment.Unemap.NumberOfElectrodes,oWaitbar,sprintf(...
                'Please wait... Signal %d completed',k));
        end
        oPotential.Baseline.Order = iPolynomialOrder;
        close(oWaitbar);
    case 3 %A channel number has been specified so only apply to this channel
        iOrder = varargin{1};
        iChannel = varargin{2};
        oPotential.Baseline.Corrected = zeros(size(oPotential.Original,1),...
            oPotential.Experiment.Unemap.NumberOfElectrodes);
        
        %Remove the polynomial approximation to the baseline from the
        %data and the load this back into baseline.corrected
        oPotential.Baseline.Corrected(:,iChannel) =  PerformCorrection(oPotential.Original(:,iChannel),iOrder);
                
    otherwise %The wrong number of inputs have been specified
        error('Potential.RemoveMedianAndFitPolynomial:unknowncase', ...
            'This methods accepts up to 2 or 3 inputs including the object handle');
end
  
return