clear all
% This script is used for running a test to determine the optimum r2
% parameter for Hardy Interpolation for a given problem geometry.

% r2 parameter depends on geometry of the dataset but not the geometry of the
% interpolation field.
disp('loading unemap...');
oUnemap = ...
GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130904\baro001\pabaro001_unemap.mat');
disp('done loading');
%
oMapData = oUnemap.PrepareActivationMap(50, 'Contour',1);
%
r2 = 0:0.001:0.02;

Data = struct();
aKeep = logical(length(oUnemap.Electrodes));
aAccepted = logical(length(oUnemap.Electrodes));

for i = 1:length(oUnemap.Electrodes)
    if oUnemap.Electrodes(i).Accepted
        aAccepted(i) = 1;
%         if rem(i,3) == 0
%             aKeep(i) = 0;
%         else
            aKeep(i) = 1;
%         end
    else
        aAccepted(i) = 0;
        aKeep(i) = 0;
    end
end

aElectrodes = oUnemap.Electrodes(aKeep);
%Get the points array that will be used to solve for the interpolation
%coefficients
%First solve the inverse problem of ActTimes(p) = sum(ci * sqrt((p-pi)^2 + r2))
% I.e x = A^-1 * b where x is ci.
aPoints = zeros(length(aElectrodes),length(aElectrodes));
for m = 1:length(aElectrodes);
    for i = 1:length(aElectrodes);
        %Calc the euclidean distance between each point and every other
        %point
        aPoints(m,i) =  (aElectrodes(m).Coords(1) - aElectrodes(i).Coords(1))^2 + ...
            (aElectrodes(m).Coords(2) - aElectrodes(i).Coords(2))^2;
    end
end

%Get the interpolated points array that will be used to assess the accuracy
%of the interpolation
xlin = linspace(min(oMapData.x(~isnan(oMapData.Beats(1).z(:,1)))), ...
    max(oMapData.x(~isnan(oMapData.Beats(1).z(:,1)))),50);
ylin = linspace(min(oMapData.y(~isnan(oMapData.Beats(1).z(:,1)))), ...
    max(oMapData.y(~isnan(oMapData.Beats(1).z(:,1)))),50);

%Also the indexes in the interpolation array of the points that are closest to
%the recording points - will use to calculate the error
xIndices = zeros(length(aElectrodes),1);
yIndices = zeros(length(aElectrodes),1);
%Make an array of arbitrarily large numbers to be replaced with minimums
aMinPoints = ones(1,length(aElectrodes))*2000;
aInterpPoints = zeros(length(xlin)*length(ylin),length(aElectrodes));
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
aPotentialData = MultiLevelSubsRef(oUnemap.oDAL.oHelper,aElectrodes,'Processed','Beats');
aPotentialData = aPotentialData(aElectrodes(1).Processed.BeatIndexes(1,1):aElectrodes(1).Processed.BeatIndexes(1,2),:);
%Loop through all the r2 values
for j = 1:length(r2);
    %save the r2 value
    Data(j).r2 = r2(j);
    %Finish calculating the points array
    Data(j).Points = sqrt(aPoints + r2(j));
    %Get the activation times at these points
    Data(j).Activation = aPotentialData(60,:).';
    %Solve the linear system to get the array of coefficients
    Data(j).cArray = linsolve(Data(j).Points,Data(j).Activation);

    %Finish calculating the interpolation points array
    Data(j).InterpPoints = sqrt(aInterpPoints + r2(j));
    %Get the interpolated activation times via matrix multiplication
    Data(j).InterpActTimes = Data(j).InterpPoints * Data(j).cArray;
    %Reconstruct field
    Data(j).InterpField = zeros(length(ylin), length(xlin));
    for m = 1:length(xlin)
        Data(j).InterpField(:,m) = Data(j).InterpActTimes((m-1)*length(ylin)+1:m*length(ylin),1);
    end

%     fprintf('Completed r %d\n',j);
end


RMS = zeros(length(aElectrodes),1);
for j = 1:length(r2);
    for i = 1:length(RMS)
        RMS(i) =  (Data(j).Activation(i) -  Data(j).InterpField(yIndices(i),xIndices(i)))^2;
    end
    Data(j).RMS = sqrt(sum(RMS)/length(RMS));

    fprintf('Completed RMS calc %d\n',j);
end
aDataToPlot = cell2mat({Data(:).RMS});
[C iMinIndex] = min(aDataToPlot);
figure();
plot(r2,aDataToPlot);
figure();
contourf(xlin,ylin,Data(iMinIndex).InterpField);
colormap(flipud(colormap(jet)));
axis equal;
colorbar('location','EastOutside');



























