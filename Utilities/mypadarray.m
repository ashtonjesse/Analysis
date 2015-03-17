function b = mypadarray(varargin)
[a, method, padSize, padVal, direction] = ParseInputs(varargin{:});
b = SymmetricPad(a, padSize, direction);

function b = SymmetricPad(a, padSize, direction)

numDims = numel(padSize);

% Form index vectors to subsasgn input array into output array.
% Also compute the size of the output array.
idx   = cell(1,numDims);
for k = 1:numDims
  M = size(a,k);
  dimNums = [1:M M:-1:1];
  p = padSize(k);
    
  switch direction
    case 'pre'
      idx{k}   = dimNums(mod(-p:M-1, 2*M) + 1);
            
    case 'post'
      idx{k}   = dimNums(mod(0:M+p-1, 2*M) + 1);
            
    case 'both'
      idx{k}   = dimNums(mod(-p:M+p-1, 2*M) + 1);
  end
end
b = a(idx{:});

function [a, method, padSize, padVal, direction] = ParseInputs(varargin)

% default values
a         = [];
method    = 'constant';
padSize   = [];
padVal    = 0;
direction = 'both';

iptchecknargin(2,4,nargin,mfilename);

a = varargin{1};

padSize = varargin{2};
iptcheckinput(padSize, {'double'}, {'real' 'vector' 'nonnan' 'nonnegative' ...
                    'integer'}, mfilename, 'PADSIZE', 2);

% Preprocess the padding size
if (numel(padSize) < ndims(a))
    padSize           = padSize(:);
    padSize(ndims(a)) = 0;
end

if nargin > 2

    firstStringToProcess = 3;
    
    if ~ischar(varargin{3})
        % Third input must be pad value.
        padVal = varargin{3};
        iptcheckinput(padVal, {'numeric' 'logical'}, {'scalar'}, ...
                      mfilename, 'PADVAL', 3);
        
        firstStringToProcess = 4;
        
    end
    
    for k = firstStringToProcess:nargin
        validStrings = {'circular' 'replicate' 'symmetric' 'pre' ...
                        'post' 'both'};
        string = iptcheckstrs(varargin{k}, validStrings, mfilename, ...
                              'METHOD or DIRECTION', k);
        switch string
         case {'circular' 'replicate' 'symmetric'}
          method = string;
          
         case {'pre' 'post' 'both'}
          direction = string;
          
         otherwise
          error('Images:padarray:unexpectedError', '%s', ...
                'Unexpected logic error.')
        end
    end
end
    
% Check the input array type
if strcmp(method,'constant') && ~(isnumeric(a) || islogical(a))
    id = sprintf('Images:%s:badTypeForConstantPadding', mfilename);
    msg1 = sprintf('Function %s expected A (argument 1)',mfilename);
    msg2 = 'to be numeric or logical for constant padding.';
    error(id,'%s\n%s',msg1,msg2);
end