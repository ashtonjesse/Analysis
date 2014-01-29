function [CV,Vect] = ComputeCV(Locs,AT,ns)

  % This function computes a local CV estimate from scattered AT data at
  % x, y (and z) positions. The number of supporting points used to
  % calculate the CV estimate is given by ns. Support can be used to
  % provide a degree of smoothing, i.e. a larger value of support uses more
  % widely spread points to determine the gradient estimates. A typical
  % value of support for mostly grid-arranged electrodes might be 8 (3x3)
  % or 24 (5x5).
  %
  % Input:
  %   AT = Nx1 vector of N activation times
  %   Locs = Nx2(3) vector of physical locations of electrodes
  %   ns = number of electrodes (in addition to electrode of interest)
  %             used to calculate an activation time gradient estimate
  %
  % Output:
  %   CV = Nx1 vector of conduction velocities
  %   Vect = Nx2(3) array of conduction vectors (normalized)
  %
  % Reference:
  %   Trew ML, Smaill BH, Bullivant DP, Hunter PJ, Pullan AJ. A generalized 
  %   finite difference method for modeling cardiac electrical activation on
  %   arbitrary, irrecular computational meshes. Mathematical Biosciences, 
  %   198, 169-189, 2005.
  
  % Initialize
  CV = zeros(size(AT));
  Vect = zeros(size(Locs));
  N = length(AT);
  Tol = 1e-6;
  
  % Loop over the AT points
  for i=1:N
      %Check if the central point is an accepted electrode and skip if not
      %       if ~isinf(AT(i))
      
          % Find the relative distance vectors between point of interest and
          % all other points
          RelativeDistVectors = Locs-repmat(Locs(i,:),[N,1]);
          
          % Find nearest ns supporting points
          [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
          SupportPoints = sort(SupportPoints(1:(ns+1)),1,'ascend');
          % Only include supportpoints that are 
          SupportPoints = SupportPoints(~isinf(AT(SupportPoints)));
          % Calculate gradient approximation using a pseudoinverse of the
          % supporting relative distance vectors of points that actually
          % exist
          G = pinv(RelativeDistVectors(SupportPoints,:))*(AT(SupportPoints)-repmat(AT(i),[length(SupportPoints),1]));
          
          % Find the CV
          NG = norm(G);
          if NG >= Tol
              CV(i) = 1.0/NG;
              Vect(i,:) = G/NG;
          else
              CV(i) = NaN;
              Vect(i,:) = NaN*ones(size(G));
          end;
      
  end;

return;