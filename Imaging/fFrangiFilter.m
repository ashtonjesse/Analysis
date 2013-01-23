 function [OutImageData, OutScales] = fFrangiFilter(oImageData, aInputs)
     %Carry out frangi filtering in 3D

     dSigmas = aInputs.FrangiScaleRange(1):aInputs.FrangiScaleRatio:aInputs.FrangiScaleRange(2);
     dSigmas = sort(dSigmas, 'ascend');

     % Frangi filter for all sigmas
     for i = 1:length(dSigmas),
         % Show progress
         disp(['Current Frangi Filter Sigma: ' num2str(dSigmas(i)) ]);

         % Calculate 3D hessian
         disp(['Calculating 3D Hessian for Sigma: ' num2str(dSigmas(i)) ]);
         oFilteredImageVolume = fHessian3D(oImageData,dSigmas(i));    %FilteredImageVolume = double(reshape([0:59],[3 4 5]))

         disp('Starting to correct for scaling');

         if(dSigmas(i)>0)
             % Correct for scaling
             c = (dSigmas(i)^2);
         end

         % Calculate eigen values
         disp(['Calculating Eigenvalues for Sigma: ' num2str(dSigmas(i)) ]);

         iAlpha = 2*aInputs.FrangiAlpha^2;
         iBeta = 2*aInputs.FrangiBeta^2;
         iFrangiC = aInputs.FrangiC;
         bBlackWhite = aInputs.BlackWhite;

         aVoxelData = eig3volume(oFilteredImageVolume,c,iAlpha,iBeta,iFrangiC,bBlackWhite);

         %clean up
         clear oFilteredImageVolume;
         %update the user
         disp(['Completed eig3volume for sigma ' num2str(i)]);

         % Remove NaN values
         aVoxelData(~isfinite(aVoxelData)) = 0;

         % Add result of this scale to output
         if(i==1)
             OutImageData = aVoxelData;
             OutScales = ones(size(oImageData,1),class(OutImageData));
         else
             OutScales(aVoxelData > OutImageData) = dSigmas(i);
             % Keep maximum filter response
             OutImageData = max(OutImageData,aVoxelData);
         end
         clear aVoxelData;
     end

     disp('Completed filtering all sigmas');
 end