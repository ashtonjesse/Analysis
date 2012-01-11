global  Data

%% Unemap
Data.Unemap.Potential.Original = [];
Data.Unemap.Potential.BaselineCorrected = [];
Data.Unemap.Time = [];
Data.Unemap.RejectedElectrodes = [];


%% Environment
Data.Environment.Temperature = input('Temperature (degC): ');
Data.Environment.PumpRPM = input('Pump RPM: ');
Data.Environment.PerfusionPressure = input('Prefusion Pressure (mmHg): ');
Data.Environment.Drugs = input('Most recent drugs (time, concentration, volume): ');

%% Protocols
Data.Protocols.Pacing.Electrodes = [];
Data.Protocols.Pacing.Current = input('Pacing Current: ');
Data.Protocols.Pacing.Frequency = input('Pacing Frequency: ');
