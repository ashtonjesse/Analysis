function aOutData = CalculateVrms(oBasePotential, aInData, varargin)
% This function takes up to 4 inputs including an array of input data (but
% not including the oBasePotential BasePotential class object). Depending on the
% inputs supplied it either calculates a straight RMS or calculates an RMS
% and smooths this over a iNumberofPoints point 
% window using either Savitzky-Golay FIR filtering or a moving average.
% aInData should be either a 1D or 2D array of doubles
% Example call:
%             oFigure.oParentFigure.oGuiHandle.oUnemap.RMS.Smoothed = ...
%                 oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
%                 oFigure.oParentFigure.oGuiHandle.oUnemap.Baseline.Corrected, ...
%                 iPolynomialOrder, iWindowSize, 'MovingAverage')

% Get the size of the input data array
[x y] = size(aInData);
% Initialise the aVrms array
aVrms = zeros(x,1);
%Calculate aVrms
for k = 1:x;
    %Calculate the Vrms for signal k
    aVrms(k) = sqrt(sum(aInData(k,:).^2) / y);
end

%Check the number of arguments and determine what to do
if size(varargin{1,1},2) == 3
    iOrder = varargin{1,1}{1,1};
    iNumberofPoints = varargin{1,1}{1,2};
    sAlgorithm = char(varargin{1,1}{1,3});
    
    switch (sAlgorithm) 
        case 'SavitzkyGolay'
            aOutData = sgolayfilt(aVrms,iOrder,iNumberofPoints);
        case 'MovingAverage'
            aOutData = fCalculateMovingAverage(aVrms,iNumberofPoints);
        otherwise
            error('BasePotential.CalculateVrms:unknowncase', ...
                'Wrong input to algorithm selection');
    end
else
     aOutData = aVrms;
end

return