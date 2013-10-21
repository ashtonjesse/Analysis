% example code for using compute CV
clear all;

% % set up some scattered points
% load('RandNumState.mat');
% defaultStream.State = savedState;
% [x,y]=ndgrid(0:5,0:5);
% Offsetx = rand(size(x))*0.4-0.2;
% Offsety = rand(size(y))*0.4-0.2;
% x = x+Offsetx; y = y+Offsety;
% x = reshape(x,[prod(size(x)),1]);
% y = reshape(y,[prod(size(y)),1]);

% define an AT function so that actual CV can be calculated and compared
% with approximate CV from ComputeCV function

% The following function is trivial and approximated almost exactly by the
% approximate CV calculations
%AT = 2*(x+0.2);
%dAdx = 2*ones(size(x)); dAdy = zeros(size(y));

% The following functions are more complex and the approximation (on this 
% coarsely sampled data) is worst where the gradient is smallest
%AT = 2*(x+0.2).^(2)+(y+0.2).^(2);
%dAdx = 4*(x+0.2); dAdy = 2*(y+0.2);
% AT = (x+1) + (x+1).*(y+1) + (y+1);
% dAdx = ones(size(x)) + (y+1); dAdy = (x+1) + ones(size(y));

% The following function is trivial and approximated almost exactly by the
% approximate CV calculations
%AT = (x+1) + (y+1);
%dAdx = ones(size(x)); dAdy = ones(size(y));

disp('loading unemap...');
oUnemap = ...
GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130904\baro001\pabaro001_unemap.mat');
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
%Get the activation times for beat 45
aOutActivationIndexes = zeros(length(oUnemap.Electrodes),1);
aOutActivationTimes = zeros(size(aOutActivationIndexes));
%track the number of accepted electrodes
m = 0;
for p = 1:length(oUnemap.Electrodes)
    if oUnemap.Electrodes(p).Accepted
         m = m + 1;
        aOutActivationIndexes(p) =  aElectrodes(m).SignalEvent(1).Index(45) + oUnemap.Electrodes(p).Processed.BeatIndexes(45,1);
        aOutActivationTimes(p) = oUnemap.TimeSeries(aOutActivationIndexes(p));
    else
        %hold the unaccepted electrode places with inf
        aOutActivationTimes(p) =  Inf;
    end
end
aOutActivationTimes = 1000*(aOutActivationTimes - min(aOutActivationTimes));

%CVActual = 1.0./sqrt(dAdx.^2 + dAdy.^2);
AT = aOutActivationTimes;

%Get electrode coords
aCoords = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Coords');
x = aCoords(1,:)';
y = aCoords(2,:)';
% visualize AT
F = TriScatteredInterp(x,y,AT);
[xx,yy]=ndgrid(min(x):0.2:max(x),min(y):0.2:max(y));
ATI = F(xx,yy);
figure(1); clf; subplot(1,3,1); mesh(xx,yy,ATI); hold on; 
scatter3(x,y,AT,40,AT,'filled'); hold off; axis tight; colorbar;
xlabel('x'); ylabel('y'); zlabel('AT'); title('Input AT samples and function');

% Approximate AT
[CVApprox,ConductionVector]=ComputeCV([x,y],AT,8);


% Plot conduction direction
figure(1); subplot(1,3,3); 
quiver(x,y,ConductionVector(:,1),ConductionVector(:,2)); 
axis equal; axis tight;
xlabel('x'); ylabel('y'); title('Conduction direction');
