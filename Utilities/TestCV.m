% example code for using compute CV
%clear all;

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

% disp('loading unemap...');
% oUnemap = ...
% GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130904\baro001\pabaro001_unemap.mat');
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));
%Get the activation times for beat 45
aOutActivationIndexes = zeros(length(oUnemap.Electrodes),1);
aOutActivationTimes = zeros(size(aOutActivationIndexes));
% %track the number of accepted electrodes
m = 0;
for p = 1:length(oUnemap.Electrodes)
    if oUnemap.Electrodes(p).Accepted
         m = m + 1;
        aOutActivationIndexes(p) =  aElectrodes(m).SignalEvent(1).Index(42) + oUnemap.Electrodes(p).Processed.BeatIndexes(42,1);
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
% F = TriScatteredInterp(x,y,AT);
% [xx,yy]=ndgrid(min(x):0.2:max(x),min(y):0.2:max(y));
% ATI = F(xx,yy);
% figure(1); clf; subplot(1,3,1); mesh(xx,yy,ATI); hold on; 
% scatter3(x,y,AT,40,AT,'filled'); hold off; axis tight; colorbar;
% xlabel('x'); ylabel('y'); zlabel('AT'); title('Input AT samples and function');

% Approximate AT
[CVApprox,ConductionVector]=ComputeCV([x,y],AT,8);


% Plot conduction direction
figure(1); axes(); 
quiver(x,y,ConductionVector(:,1),ConductionVector(:,2)); 
axis equal; axis tight;
xlabel('x'); ylabel('y'); title('Conduction direction');

%Plot conduction velocity
%get the accepted channels
aAcceptedChannels = MultiLevelSubsRef(oUnemap.oDAL.oHelper,oUnemap.Electrodes,'Accepted');
aElectrodes = oUnemap.Electrodes(logical(aAcceptedChannels));

%Get the points array that will be used to solve for the interpolation
%coefficients
%First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% I.e x = A^-1 * b where x is ci.
aPoints = zeros(length(aElectrodes),length(aElectrodes));
%...and turn the coords into a 2 column matrix
aCoords = zeros(length(aElectrodes),2);

for m = 1:length(aElectrodes);
    for i = 1:length(aElectrodes);
        %Calc the euclidean distance between each point and every other
        %point
        aPoints(m,i) =  (aElectrodes(m).Coords(1) - aElectrodes(i).Coords(1))^2 + ...
            (aElectrodes(m).Coords(2) - aElectrodes(i).Coords(2))^2;
    end
    %Save the coordinates
    aCoords(m,1) = aElectrodes(m).Coords(1);
    aCoords(m,2) = aElectrodes(m).Coords(2);
end
dInterpDim = 50;
%Get the interpolated points array
xlin = linspace(min(aCoords(:,1)), max(aCoords(:,1)), dInterpDim);
ylin = linspace(min(aCoords(:,2)), max(aCoords(:,2)), dInterpDim);

%Also the indexes in the interpolation array of the points that are closest to
%the recording points - will use to calculate the error
xIndices = zeros(length(aElectrodes),1);
yIndices = zeros(length(aElectrodes),1);
%Make an array of arbitrarily large numbers to be replaced with minimums
aMinPoints = ones(1,length(aElectrodes))*2000;
aInterpPoints = zeros(dInterpDim*dInterpDim,length(aElectrodes));

for i = 1:length(aElectrodes);
    for m = 1:length(xlin)
        for n = 1:length(ylin)
            aInterpPoints((m-1)*length(ylin)+n,i) =  (xlin(m) - aElectrodes(i).Coords(1))^2 + ...
                (ylin(n) - aElectrodes(i).Coords(2))^2;
            if aInterpPoints((m-1)*length(xlin)+n,i) < aMinPoints(1,i)
                aMinPoints(1,i) = aInterpPoints((m-1)*length(xlin)+n,i);
                xIndices(i) = m;
                yIndices(i) = n;
            end
        end
    end
end

%Initialise the map data struct
oMapData = struct('x', xlin, 'y', ylin, 'r2', 0.005);
%Finish calculating the points array
oMapData.Points = sqrt(aPoints + oMapData.r2);
%Finish calculating the interpolation points array
oMapData.InterpPoints = sqrt(aInterpPoints + oMapData.r2);
oMapData.Beats = struct();

%initialise an RMS array
aRMS = zeros(length(aElectrodes),1);

%Loop through the beats

%Get the activation time fields for all time points during this
%beat
k = 1;
oMapData.Beats(k).CVApprox = CVApprox(logical(aAcceptedChannels));
oMapData.Beats(k).Coefs = linsolve(oMapData.Points,oMapData.Beats(k).CVApprox);
%Get the interpolated data via matrix multiplication
oMapData.Beats(k).Interpolated = oMapData.InterpPoints * oMapData.Beats(k).Coefs;
%Reconstruct field
oMapData.Beats(k).z = zeros(dInterpDim, dInterpDim);
for m = 1:dInterpDim
    oMapData.Beats(k).z(:,m) = oMapData.Beats(k).Interpolated((m-1)*dInterpDim+1:m*dInterpDim,1);
end
%Calc the RMS error for this field
for i = 1:length(aRMS)
    aRMS(i) =  (oMapData.Beats(k).CVApprox(i) -  oMapData.Beats(k).z(yIndices(i),xIndices(i)))^2;
end
oMapData.Beats(k).RMS = sqrt(sum(aRMS)/length(aRMS));


%check if there is an existing colour bar
%get figure children
    %Get a new min and max
cbarmax = 0;
cbarmin = 2000; %arbitrary
ibmax = 0;
ibmin = 0;
i = 1;
%Loop through the beats to find max and min
dMin = min(min(oMapData.Beats(i).z));
dMax = max(max(oMapData.Beats(i).z));
if dMin < cbarmin
    cbarmin = dMin;
    ibmin = i;
end
if dMax > cbarmax
    cbarmax = dMax;
    ibmax = i;
end

figure(2); oMapAxes = axes();
iBeat = 1;
%Assuming the potential field has been normalised.
[C, oContour] = contourf(oMapAxes,oMapData.x,oMapData.y,oMapData.Beats(iBeat).z,floor(cbarmin):0.2:ceil(cbarmax));
colormap(oMapAxes, colormap(flipud(colormap(jet))));

%if the colour bar should be visible then make
%a new one
oColorBar = cbarf([cbarmin cbarmax], floor(cbarmin):0.2:ceil(cbarmax));
oTitle = get(oColorBar, 'title');
set(oTitle,'units','normalized');
set(oTitle,'string','Time (ms)','position',[0.5 1.02]);
axis(oMapAxes, 'equal');
PlotLimits = oUnemap.GetSpatialLimits();
set(oMapAxes,'xlim',PlotLimits(1,:),'ylim',PlotLimits(2,:));
