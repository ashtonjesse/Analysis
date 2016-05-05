function SEM = stderror(X,dim)
%this function computes the standard error of the mean of this data
SEM = std(X,[],dim)/sqrt(size(X,dim));
end