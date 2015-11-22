close all;
% oOptical = GetOpticalFromMATFile(Optical, 'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\baro004_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');
aAxisData = cell2mat({oOptical.Electrodes(:).AxisPoint});
oAxesElectrodes = oOptical.Electrodes(aAxisData);
aAxesCoords = cell2mat({oAxesElectrodes(:).Coords});
figure();
plot(aAxesCoords(1,:),aAxesCoords(2,:));
xlim([-5 10]);
ylim([-5 , 10]);
hold on;
z = [0 1 2 3 4 5 6];
aPoints = [((aAxesCoords(1,1)-aAxesCoords(1,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(1,2) ; 
    ((aAxesCoords(2,1)-aAxesCoords(2,2))/norm(aAxesCoords(:,1)-aAxesCoords(:,2)))*z+aAxesCoords(2,2)];
scatter(aPoints(1,:),aPoints(2,:),'Marker','+',...
    'sizedata',144,'MarkerEdgeColor','k');
aNewPoints = TransformCoordinates(aAxesCoords(:,2),aAxesCoords(:,1),aPoints(:,1));
scatter(aNewPoints(1,:),aNewPoints(2,:),'Marker','+',...
    'sizedata',144,'MarkerEdgeColor','r');
aNewPoints = TransformCoordinates(aAxesCoords(:,2),aAxesCoords(:,1),aPoints(:,2));
scatter(aNewPoints(1,:),aNewPoints(2,:),'Marker','+',...
    'sizedata',144,'MarkerEdgeColor','r');
aNewPoints = TransformCoordinates(aAxesCoords(:,2),aAxesCoords(:,1),aPoints(:,3));
scatter(aNewPoints(1,:),aNewPoints(2,:),'Marker','+',...
    'sizedata',144,'MarkerEdgeColor','r');