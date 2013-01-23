function [oZStack, oXStack, oYStack] = fSplitStackVolume(oStackVolume)
%Split an image volume into stacks in each dimension

%Create a new z stack
oZStack = GetZStackFromVolume(ImageStack,oStackVolume);
%Get image class
sStackClass = class(oZStack.oImages(1).Data);
%Resample Z stack in x
oXStack = oZStack.ResampleStack('x',sStackClass);
%Resample Z stack in y
oYStack = oZStack.ResampleStack('y',sStackClass);

end