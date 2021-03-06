function y = fCalculateMovingAverage(aData,iFilterWindowSize)
% will compute moving averages of order n (best taken as odd)
%
%Usage: y=moving(x,n[,fun])
%where x 	is the input vector (or matrix) to be smoothed. 
%      m 	is number of points to average over (best odd, but even works)
%      y 	is output vector of same length as x
%      fun  (optional) is a custom function rather than moving averages
%
% Note:if x is a matrix then the smoothing will be done 'vertically'.
%
% Example:
%
% x=randn(300,1);
% plot(x,'g.'); 
% hold on;
% plot(moving(x,7),'k'); 
% plot(moving(x,7,'median'),'r');
% plot(moving(x,7,@(x)max(x)),'b'); 
% legend('x','7pt moving mean','7pt moving median','7pt moving max','location','best')
%
% optimized Aslak Grinsted jan2004
% enhanced Aslak Grinsted Apr2007

if iFilterWindowSize == 1
    y = aData;
    return
end

if size(aData,1) == 1
    aData = aData';
end

f = zeros(iFilterWindowSize,1) + 1/iFilterWindowSize;
n = size(aData,1);
isodd = bitand(iFilterWindowSize,1);
iHalfWindowSize = floor(iFilterWindowSize/2);

if (size(aData,2) == 1)
    y = filter(f,1,aData);
    y = y([zeros(1,iHalfWindowSize - 1 + isodd) + iFilterWindowSize,...
        iFilterWindowSize:n,zeros(1,iHalfWindowSize) + n]);
else
    y = filter2(f,aData);
    y(1:(iHalfWindowSize-~isodd),:) = y(iHalfWindowSize + isodd + ...
        zeros(iHalfWindowSize-~isodd,1),:);
    y((n-iHalfWindowSize+1):end,:) = y(n - iHalfWindowSize + ...
        zeros(iHalfWindowSize,1),:);
end

return
