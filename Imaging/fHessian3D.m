function F = fHessian3D(Volume,Sigma)

    if nargin < 2, Sigma = 1; end

    if(Sigma>0)
        F=imgaussian(Volume,Sigma);
        disp('Finished executing imgaussian mex function');
    else
        F=Volume;
    end

    disp('Completed Hessian3D matlab function')
    
end