
% oPressure = GetPressureFromMATFile(Pressure,'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat','Optical');
aData = oPressure.oPhrenic.Electrodes.Processed.Data;
aTimes = oPressure.oPhrenic.TimeSeries;

%get dimension variables
iNumDataPoints = numel(aData);
oWindow = tukeywin(iNumDataPoints,0.5);
iSamplingFreq = 10000;

[aPSDXTukey Fxx] = periodogram(aData,oWindow,iNumDataPoints,iSamplingFreq);

oFigure = figure();oPowerAxes = axes();
% plot(oPowerAxes,Fxx, aPSDXTukey);

aOutData = oPressure.oPhrenic.FilterData(aData,'LowPass',iSamplingFreq,100);
plot(oPowerAxes,aTimes,aOutData);