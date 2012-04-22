function CalculateVrms(oUnemap, varargin)
% This function takes up to 3 inputs (not including the oBasePotential BasePotential class object). Depending on the
% inputs supplied it either calculates a straight RMS or calculates an RMS
% and smooths this over a iNumberofPoints point 
% window using either Savitzky-Golay FIR filtering or a moving average.
% aInData should be either a 1D or 2D array of doubles
% Example call:
%                 oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
%                 iPolynomialOrder, iWindowSize, 'MovingAverage')

% Get the dimensions
x = length(oUnemap.TimeSeries);
y = oUnemap.oExperiment.Unemap.NumberOfChannels;

% Initialise the aVrms array
aVrms = zeros(x,1);
%Check if there is Processed.Data
if isnan(oUnemap.Electrodes(1).Processed.Data(1))
    %Calculate Vrms of the original data
    aData = cell2mat({oUnemap.Electrodes(:).Potential});
    for k = 1:x;
        %Calculate the Vrms for signal k
        aVrms(k) = sqrt(sum(aData(k,:).^2) / y);
    end
else
    %Calculate Vrms of the processed data
    aData = MultiLevelSubsRef(DataHelper,oUnemap.Electrodes,'Processed','Data');
    
    for k = 1:x;
        %Calculate the Vrms for signal k
        aVrms(k) = sqrt(sum(aData(k,:).^2) / y);
    end
end

%Check the number of arguments and determine what to do
if ~isempty(varargin) && size(varargin,2) == 3
    iOrder = varargin{1,1};
    iNumberofPoints = varargin{1,2};
    sAlgorithm = char(varargin{1,3});
    
    switch (sAlgorithm) 
        case 'SavitzkyGolay'
            oUnemap.RMS.Smoothed = sgolayfilt(aVrms,iOrder,iNumberofPoints);
        case 'MovingAverage'
            oUnemap.RMS.Smoothed= fCalculateMovingAverage(aVrms,iNumberofPoints);
        otherwise
            error('BasePotential.CalculateVrms:unknowncase', ...
                'Wrong input to algorithm selection');
    end
    %Save the characteristics of the smoothing
    oUnemap.RMS.Smoothing = sAlgorithm;
    oUnemap.RMS.PolyOrder = iOrder;
    oUnemap.RMS.WindowSize = iNumberofPoints;
else
     oUnemap.RMS.Values = aVrms;
end

return