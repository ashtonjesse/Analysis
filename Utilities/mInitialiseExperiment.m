global  Experiment

Experiment.Date = '20111124';

%% Material
Experiment.Material.Gender = 'M';
Experiment.Material.Weight = 120;
Experiment.Material.DOB = '20111101';
Experiment.Material.Strain = 'SD';

%% Unemap
Experiment.Unemap.ADConversion.SamplingRate = 1024;
Experiment.Unemap.ADConversion.BitDepth = 256;
Experiment.Unemap.ADConversion.Gain = 256;
Experiment.Unemap.ADConversion.DynamicRange = 256;
Experiment.Unemap.NumberOfElectrodes = 288;

%% Recordings
Experiment.Recordings.PerfusionPressure.Gain = 256;
Experiment.Recordings.PerfusionPressure.HighFilter = 10000;
Experiment.Recordings.PerfusionPressure.LowFilter = 50;
Experiment.Recordings.PerfusionPressure.LineFilter = 50;

Experiment.Recordings.Phrenic.InGain = 10;
Experiment.Recordings.Phrenic.OutGain = 10;

Experiment.Recordings.ECG.AcCouplingFrequency = 10;
Experiment.Recordings.ECG.HighFilter = 10000;
Experiment.Recordings.ECG.LowFilter = 50;
Experiment.Recordings.ECG.LineFilter = 50;

