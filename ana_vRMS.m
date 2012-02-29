function [vrms, slopes1, slopes2, curvature] = ana_vRMS
% [vrms, slopes1, slopes2, curvature] = ana_vRMS(d)
global DATA

[sd1 sd2] = size(DATA.Unemap.Pot.OrigBase);
vrms = zeros(sd1,1);
curvature = zeros(sd1,1);

for k = 1:sd1
    vrms(k) = sqrt(sum(DATA.Unemap.Pot.OrigBase(k,:).^2) / sd2);
end
order = 20;
slopes1 = ana_movingslope(vrms,20,5); 
slopes2 = ana_movingslope(slopes1,20,5);

for k = 1:sd1
    curvature(k) = abs(slopes2(k)) / ((1 + slopes1(k)^2))^(3/2);
end

%thresh = mean(curvature(1:50)) + 3*std(curvature(1:50));

%[curvepeaksy, curvepeaksx] = findpeaks(curvature, 'minpeakheight', thresh);
%a = DATA.Unemap.Analysis{1}.peaks.loc(1,:);
%aa = find(a>0);
%ATs = a(aa);
%[n, xout] = hist(ATs,[1:1:sd1]);

%numcurvepeaks = length(curvepeaksx);

%figure; subplot(2,1,1); plot(vrms); title('vrms');   
%hold on;  bar(xout,n); lineA = line([curvepeaksx(1) curvepeaksx(1)],[0 max(vrms)+2]);
%lineB = line([curvepeaksx(numcurvepeaks) curvepeaksx(numcurvepeaks)],[0 max(vrms)+2]);
%subplot(2,1,2); plot(curvature); title('curvature'); hold on; 
%plot(curvepeaksx,curvepeaksy,'*');
%figure; plot(slopes1); title('vrms slope1');
%figure; plot(slopes2); title('vrms slope2');




