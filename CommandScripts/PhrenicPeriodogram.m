% clear all;
% 
% % % % %Read in the file containing the data
% oExperiment = GetExperimentFromTxtFile(Experiment, 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718_experiment.txt');
aFileContents = LoadFromFile(BaseDAL, 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\lb172921_test.txt');
oPhrenic = Phrenic(oExperiment, aFileContents(:,oExperiment.Phrenic.StorageColumn),aFileContents(:,1));

%get dimension variables
iNumDataPoints = length(oPhrenic.Electrodes.Potential.Data);

%initialise variables
aPSDXTukey = zeros(iNumDataPoints/2+1,1);
aMeanPSDX = zeros(iNumDataPoints/2+1,1);
oWindow = tukeywin(iNumDataPoints,0.5);
oMeanWindow = tukeywin(45,0.5);
iSamplingFreq = 10000;

[aPSDXTukey Fxx] = periodogram(oPhrenic.Electrodes.Potential.Data,oWindow,iNumDataPoints,iSamplingFreq);
% aMean = filter(oMeanWindow,1,mean(aPSDXTukey,2));
% aMeanPSDX = aMean;
% aNoiseIndices = find(Fxx > 250);
% dPower = mean(aMean(aNoiseIndices));
% 
% aMeanPSDX(:,i) = aMean/dPower;

oFigure = figure();oPowerAxes = axes();
set(oPowerAxes,'NextPlot','replacechildren');
oPowerLines = plot(oPowerAxes,Fxx,aPSDXTukey); 
set(get(oPowerAxes,'xlabel'),'string','Frequency (Hz)');
set(get(oPowerAxes,'ylabel'),'string','Normalised Power (P/P_n)');
axis([0 max(Fxx)+50 0 2.5]);
% % % %print figure
% set(oFigure,'paperunits','centimeters');
% set(oFigure,'paperposition',[0 0 10 10])
% set(oFigure,'papersize',[10 10])
% sSaveFilePath = fullfile(sPathName,'Periodgram.bmp');
% print(oFigure,'-dbmp','-r300',sSaveFilePath);
