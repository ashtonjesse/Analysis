function aOutData = fSteepestSlope(varargin)
% This function loops through the intervals provided and returns an array
% of values from the aXData array that correspond with the maximum values
% in the aYData array within these intervals

%check the inputs
if nargin > 3
    %apply threshold
    aXData = varargin{1};
    aYData = varargin{2};
    aIntervals = varargin{3};
    dThreshold = varargin{4};
    
    [a b] = size(aIntervals);
    aOutData = zeros(a,1);
    for i = 1:a;
        [dMax, iMaxIndex] = max(aYData(aIntervals(i,1):aIntervals(i,2)));
        if dMax > dThreshold
            aOutData(i) = iMaxIndex;
        else
            aOutData(i) = 0;
        end
    end
elseif nargin > 2
    %No threshold has been specified
    aXData = varargin{1};
    aYData = varargin{2};
    aIntervals = varargin{3};
    [a b] = size(aIntervals);
    aOutData = zeros(a,1);
    for i = 1:a;
        [dMax, iMaxIndex] = max(aYData(aIntervals(i,1):aIntervals(i,2)));
        aOutData(i) = iMaxIndex;
    end
    
else
    error('fSteepestSlope:InputCheck','Entered the wrong number of inputs.');
end

end


