function CalculateVrms(oBasePotential, varargin)
% This function takes up to 3 inputs (not including the oBasePotential BasePotential class object). Depending on the
% inputs supplied it either calculates a straight RMS or calculates an RMS
% and smooths this over a iNumberofPoints point 
% window using either Savitzky-Golay FIR filtering or a moving average.
% aInData should be either a 1D or 2D array of doubles
% Example call:
%                 oFigure.oParentFigure.oGuiHandle.oUnemap.CalculateVrms(...
%                 iPolynomialOrder, iWindowSize, 'MovingAverage')


%Check if there is Processed.Data
if isnan(oBasePotential.Electrodes(1).Processed.Data(1))

    %Calculate Vrms of the original data
    %aData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Potential');
    aData = cell2mat({oBasePotential.Electrodes(oBasePotential.RMS.Electrodes).Potential});
    % Get the dimensions
    x = length(oBasePotential.TimeSeries);
    y = size(aData,2);
    
    % Initialise the aVrms array
    aVrms = zeros(x,1);
    
    for k = 1:x;
        %Calculate the Vrms for signal k
        aVrms(k) = sqrt(sum(aData(k,:).^2) / y);
    end
else
    %Calculate Vrms of the processed data
    aData = MultiLevelSubsRef(DataHelper,oBasePotential.Electrodes(oBasePotential.RMS.Electrodes),'Processed','Data');
    %aData = oUnemap.SelectAcceptedChannelData(oUnemap.Electrodes,'Processed','Data');
    
    % Get the dimensions
    x = length(oBasePotential.TimeSeries);
    y = size(aData,2);
    
    % Initialise the aVrms array
    aVrms = zeros(x,1);
    
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
            oBasePotential.RMS.Smoothed = sgolayfilt(aVrms,iOrder,iNumberofPoints);
        case 'MovingAverage'
            oBasePotential.RMS.Smoothed= fCalculateMovingAverage(aVrms,iNumberofPoints);
        otherwise
            error('BasePotential.CalculateVrms:unknowncase', ...
                'Wrong input to algorithm selection');
    end
    %Save the characteristics of the smoothing
    oBasePotential.RMS.Smoothing = sAlgorithm;
    oBasePotential.RMS.PolyOrder = iOrder;
    oBasePotential.RMS.WindowSize = iNumberofPoints;
else
     oBasePotential.RMS.Values = aVrms;
end

return