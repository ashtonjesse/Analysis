function Dvec = ana_movingslope(vec,supportlength,modelorder,dt)
% movingslope: estimate local slope for a sequence of points, using a sliding window
% usage: Dvec = movingslope(vec)
% usage: Dvec = movingslope(vec,supportlength)
% usage: Dvec = movingslope(vec,supportlength,modelorder)
% usage: Dvec = movingslope(vec,supportlength,modelorder,dt)
%
%
% movingslope uses filter to determine the slope of a curve stored
% as an equally (unit) spaced sequence of points. A patch is applied
% at each end where filter will have problems. A non-unit spacing
% can be supplied.
%
% Note that with a 3 point window and equally spaced data sequence,
% this code should be similar to gradient. However, with wider
% windows this tool will be more robust to noisy data sequences.
%
%
% arguments: (input)
%  vec - row of column vector, to be differentiated. vec must be of
%        length at least 2.
%
%  supportlength - (OPTIONAL) scalar integer - defines the number of
%        points used for the moving window. supportlength may be no
%        more than the length of vec.
%
%        supportlength must be at least 2, but no more than length(vec)
%
%        If supportlength is an odd number, then the sliding window
%        will be central. If it is an even number, then the window
%        will be slid backwards by one element. Thus a 2 point window
%        will result in a backwards differences used, except at the
%        very first point, where a forward difference will be used.
%
%        DEFAULT: supportlength = 3
%
%  modelorder - (OPTIONAL) - scalar - Defines the order of the windowed
%        model used to estimate the slope. When model order is 1, the
%        model is a linear one. If modelorder is less than supportlength-1.
%        then the sliding window will be a regression one. If modelorder
%        is equal to supportlength-1, then the window will result in a
%        sliding Lagrange interpolant.
%
%        modelorder must be at least 1, but not exceeding
%        min(10,supportlength-1)
%
%        DEFAULT: modelorder = 1
%
%  dt - (OPTIONAL) - scalar - spacing for sequences which do not have
%        a unit spacing.
%
%        DEFAULT: dt = 1


% how long is vec? is it a vector?
if (nargin==0)
  help movingslope
  return
end
if ~isvector(vec)
  error('vec must be a row or column vector')
end
n = length(vec);

% supply defaults
if (nargin<4) || isempty(dt)
  dt = 1;
end
if (nargin<3) || isempty(modelorder)
  modelorder = 1;
end
if (nargin<2) || isempty(supportlength)
  supportlength = 3;
end

% check the parameters for problems
if (length(supportlength)~=1) || (supportlength<=1) || (supportlength>n) || (supportlength~=floor(supportlength))
  error('supportlength must be a scalar integer, >= 2, and no more than length(vec)')
end
if (length(modelorder)~=1) || (modelorder<1) || (modelorder>min(10,supportlength-1)) || (modelorder~=floor(modelorder))
  error('modelorder must be a scalar integer, >= 1, and no more than min(10,supportlength-1)')
end
if (length(dt)~=1) || (dt<0)
  error('dt must be a positive scalar numeric variable')
end

% now build the filter coefficients to estimate the slope
if mod(supportlength,2) == 1
  parity = 1; % odd parity
else
  parity = 0;
end
s = (supportlength-parity)/2;
t = ((-s+1-parity):s)';
coef = getcoef(t,supportlength,modelorder);

% Apply the filter to the entire vector
f = filter(-coef,1,vec);
Dvec = zeros(size(vec));
Dvec(s+(1:(n-supportlength+1))) = f(supportlength:end);

% patch each end
vec = vec(:);
for i = 1:s
  % patch the first few points
  t = (1:supportlength)' - i;
  coef = getcoef(t,supportlength,modelorder);
  
  Dvec(i) = coef*vec(1:supportlength);
  
  % patch the end points
  if i<(s + parity)
    t = (1:supportlength)' - supportlength + i - 1;
    coef = getcoef(t,supportlength,modelorder);
    Dvec(n - i + 1) = coef*vec(n + (0:(supportlength-1)) + 1 - supportlength);
  end
end

% scale by the supplied spacing
Dvec = Dvec/dt;
% all done

end % mainline end

% =========================================================
% subfunction, used to compute the filter coefficients
function coef = getcoef(t,supportlength,modelorder)
% Note: bsxfun would have worked here as well, but some people
% might not yet have that release of matlab.
A = repmat(t,1,modelorder+1).^repmat(0:modelorder,supportlength,1);
pinvA = pinv(A);
% we only need the linear term
coef = pinvA(2,:);
end % nested function end
