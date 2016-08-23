function [aLevels aPoints] = SplitContours(Cs)
%this function splits the contours from a contour function call into levels
%and point locations

%initialise variables
ii = 1; %array index
jj = 1; %contour count
aLevels = zeros(1,1);
aPoints = cell(1,1);

%get details of first contour
aLevels(jj) = Cs(1,1);
len = Cs(2,1);
aPoints{jj} = Cs(:,2:len+1);
ii = len + 2;
jj = jj + 1;

while ii < size(Cs,2)
    aLevels(jj) = Cs(1,ii);
    len = Cs(2,ii);
    aPoints{jj} = Cs(:,ii+1:ii+len);
    ii = ii + len + 1;
    jj = jj + 1;
end