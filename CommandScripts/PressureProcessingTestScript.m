%Pressure processing test script
close all;
clear all;
% load the pressure data
sFile = 'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Test.mat';
oPressure = GetPressureFromMATFile(Pressure,sFile,'Optical');
fprintf('Got file %s\n',sFile);

%save pressure data for resuse
aPressureData = oPressure.Processed.Data;

%plot the pressure data
oFigure = figure();
oAxes = axes();
plot(oAxes,oPressure.TimeSeries.Original,aPressureData);

%filter the pressure data
aFilteredData = oPressure.FilterData(aPressureData, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
%plot on same plot
hold(oAxes, 'on');
iOffset = 12000;
plot(oAxes,oPressure.TimeSeries.Original(iOffset:(end-iOffset)),aFilteredData(iOffset:(end-iOffset)),'r');

%compare to dwt filtered
% aDWTData = oPressure.FilterData(aPressureData, 'DWTFilterRemoveScales', 12);
%plot on same plot
% plot(oAxes,oPressure.TimeSeries.Processed,aDWTData,'k');
hold(oAxes,'off');
