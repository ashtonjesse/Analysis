function th = fBOSauvolaThreshold3D(im,n1,n2,k,R)

%% Setup - fill in unset optional values.
switch nargin
    case 1
        n = 15; n1 = n; n2 = n;
        k = 0.5;
        R = 128;        
    case 2
        k = 0.5;
        R = 128;        
    case 3
        R = 128;        
end
%% Convert To Gray Scale Image
disp('Converting image to uint8')
im2 = double(im2uint8(im));
%% Kernel
disp('Creating spherical kernel')
se = strel('ball',n1,n2);
h = double(getnhood(se));
%% Local Mean
% m = sum(x)/n
disp('Creating filter')
m  = imfilter(im2,h,'symmetric') / sum(h(:)); 
%% Local Variance
% v = sum(x-m)^2/n = sum(x^2-2xm+m^2)/n = (sum(x^2)-2msum(x)+m^2)/n = 
%   = (sum(x^2)-2m^2+m^2)/n = sum(x^2)/n-m^2 
disp('Calculating local variance')
v  = imfilter(im2.^2,h,'symmetric') / sum(h(:)) - m.^2; 
%% Local Std
% s = sqrt(v)
disp('Sqrt of local variance')
s = sqrt(v);
%% Level
disp('Calculating level')
level = m .* (1.0 + k * (s / R - 1.0));
%% Threshold
disp('Binarizing image > level')
th = im2 > level;

end