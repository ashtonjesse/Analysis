% %Pressure processing test script
% close all;
% clear all;
% % load the pressure data
% sFile = 'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813CCh002\Pressure.mat';
% oPressure = GetPressureFromMATFile(Pressure,sFile,'Optical');
% fprintf('Got file %s\n',sFile);

%save pressure data for resuse
aPhrenicData = oPressure.oPhrenic.Electrodes(1).Processed.Data;

%plot the pressure data
oFigure = figure();
oAxes = axes();
plot(oAxes,oPressure.oPhrenic.TimeSeries,aPhrenicData,'k');

%compare to dwt filtered
aDWTData = oPressure.FilterData(aPhrenicData, 'DWTFilterRemoveScales', 5);
%plot on same plot
hold(oAxes,'on');
plot(oAxes,oPressure.oPhrenic.TimeSeries,aDWTData,'r');
hold(oAxes,'off');

aCurvatureData = oPressure.oPhrenic.CalculateCurvature(aDWTData,20,5);
figure();
oNewAxes = axes();
plot(oNewAxes,oPressure.oPhrenic.TimeSeries,aCurvatureData,'k');