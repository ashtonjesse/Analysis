function  [Grad,Vect] = ComputeSpatialGrad(Locs,Fxy,ns,BandProportion)
% This function computes a local spatial gradient estimate from scattered data at
% x and y positions. The number of supporting points used to
% calculate the gradient estimate is given by ns. Support can be used to
% provide a degree of smoothing, i.e. a larger value of support uses more
% widely spread points to determine the gradient estimates. A typical
% value of support for mostly grid-arranged electrodes might be 8 (3x3)
% or 24 (5x5).
%
% Input:
%   Fxy = Nx1 vector of N data points
%   Locs = Nx2 vector of physical locations of electrodes
%   ns = number of electrodes (in addition to electrode of interest)
%             used to calculate gradient estimate
%
% Output:
%   Grad = Nx1 vector of gradient values
%   Vect = Nx2 array of conduction vectors (normalized)
%
% Reference:
%   Trew ML, Smaill BH, Bullivant DP, Hunter PJ, Pullan AJ. A generalized
%   finite difference method for modeling cardiac electrical activation on
%   arbitrary, irrecular computational meshes. Mathematical Biosciences,
%   198, 169-189, 2005.

% Initialize
Grad = zeros(size(Fxy));
Vect = zeros(size(Locs));
N = length(Fxy);
Tol = 1e-6;

% Loop over the Fxy points
for i=1:N
    %Check if the central point is an accepted electrode and skip if not
    if isfinite(Fxy(i))
        
        % Find the relative distance vectors between point of interest and
        % all other points
        RelativeDistVectors = Locs-repmat(Locs(i,:),[N,1]);
        
        % Find nearest ns supporting points
        [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
        SupportPoints = sort(SupportPoints(1:(ns+1)),1,'ascend');
        % Only include support points that have a non-infinite Fxy
        SupportPoints = SupportPoints(isfinite(Fxy(SupportPoints)));
        % Find significant quadrants of support points around point of
        % interest - only works in 2D
        XBand = BandProportion*(max(RelativeDistVectors(SupportPoints,1))-min(RelativeDistVectors(SupportPoints,1)));
        YBand = BandProportion*(max(RelativeDistVectors(SupportPoints,2))-min(RelativeDistVectors(SupportPoints,2)));
        quadrant = [(RelativeDistVectors(SupportPoints,1) >  XBand & RelativeDistVectors(SupportPoints,2) >  YBand),...
            (RelativeDistVectors(SupportPoints,1) < -XBand & RelativeDistVectors(SupportPoints,2) >  YBand),...
            (RelativeDistVectors(SupportPoints,1) >  XBand & RelativeDistVectors(SupportPoints,2) < -YBand),...
            (RelativeDistVectors(SupportPoints,1) < -XBand & RelativeDistVectors(SupportPoints,2) < -YBand)];
        
        % Calculate gradient approximation using a pseudoinverse of the
        % supporting relative distance vectors of points that actually
        % exist
        G = pinv(RelativeDistVectors(SupportPoints,:))*(Fxy(SupportPoints)-repmat(Fxy(i),[length(SupportPoints),1]));
        
        % Find the gradient
        NG = norm(G);
        if NG >= Tol && (min(sum(quadrant,1)) >= 1) % points must exist in all four quadrants
            Vect(i,:) = G/NG;
            Grad(i) = NG;
        else
            Vect(i,:) = NaN*ones(size(G));
            Grad(i) = NaN;
        end;
    else
        Vect(i,:) = NaN*ones(1,size(Locs,2));
        Grad(i) = NaN;
    end
end;

return;