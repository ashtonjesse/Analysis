%this script loads a bunch of pressure files and compares heart rates,
%phrenic burst rates and durations
close all;
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134350\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134621\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\134852\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135123\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135354\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135625\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\135856\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140522\140127\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\162847\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163118\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163349\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163620\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\163911\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171221\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171452\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171723\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\171954\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172224\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172455\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172726\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\172957\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140526\173324\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163208\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163439\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163710\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\163941\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164212\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164605\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\164836\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\165107\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140527\165338\Pressure.mat' ...
    };
aTimes = [...
    0
151
302
453
604
755
906
1057
0
151
302
453
604
2614
2765
2916
3067
3218
3369
3520
3671
3822
0
151
302
453
604
755
906
1057
1208
];

aTimes = aTimes ./ 60;
%loop through files and get data
%initialise variables
% aHeartBeatRates = cell(numel(aFiles),1);
% aBurstRates = cell(numel(aFiles),1);
% aBurstDurations = cell(numel(aFiles),1);
aMeanHeartRates = zeros(numel(aFiles),1);
aMeanBurstRates = zeros(numel(aFiles),1);
aMeanBurstDurations = zeros(numel(aFiles),1);
aSEMHeartRates = zeros(numel(aFiles),1);
aSEMBurstRates = zeros(numel(aFiles),1);
aSEMBurstDurations = zeros(numel(aFiles),1);
for i =1:numel(aFiles)
    %     oPressure = GetPressureFromMATFile(Pressure, aFiles{i}, 'Optical');
    %     aHeartBeatRates{i} = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
    %     aBurstRates{i} = oPressure.oPhrenic.Electrodes.Processed.BurstRates;
    %     aBurstDurations{i} = oPressure.oPhrenic.Electrodes.Processed.BurstDurations;
    %     fprintf('Got data from %s\n',aFiles{i});
    aMeanHeartRates(i) = mean(aHeartBeatRates{i});
    aMeanBurstRates(i) = mean(aBurstRates{i});
    aMeanBurstDurations(i) = mean(aBurstDurations{i});
    aSEMHeartRates(i) = stderror(aHeartBeatRates{i});
    aSEMBurstRates(i) = stderror(aBurstRates{i});
    aSEMBurstDurations(i) = stderror(aBurstDurations{i});
end

figure();
oAxes = axes();
errorbar(aTimes(1:8),aMeanBurstRates(1:8),aSEMBurstRates(1:8),'k','parent',oAxes);
hold(oAxes,'on');
errorbar(aTimes(9:13),aMeanBurstRates(9:13),aSEMBurstRates(9:13),'r','parent',oAxes);
plot(oAxes,[aTimes(13) aTimes(14)],[aMeanBurstRates(13) aMeanBurstRates(14)],'r--');
errorbar(aTimes(14:22),aMeanBurstRates(14:22),aSEMBurstRates(14:22),'r','parent',oAxes);
errorbar(aTimes(23:end),aMeanBurstRates(23:end),aSEMBurstRates(23:end),'b','parent',oAxes);

figure();
oAxes = axes();
errorbar(aTimes(1:8),aMeanBurstDurations(1:8),aSEMBurstDurations(1:8),'k','parent',oAxes);
hold(oAxes,'on');
errorbar(aTimes(9:13),aMeanBurstDurations(9:13),aSEMBurstDurations(9:13),'r','parent',oAxes);
plot(oAxes,[aTimes(13) aTimes(14)],[aMeanBurstDurations(13) aMeanBurstDurations(14)],'r--');
errorbar(aTimes(14:22),aMeanBurstDurations(14:22),aSEMBurstDurations(14:22),'r','parent',oAxes);
errorbar(aTimes(23:end),aMeanBurstDurations(23:end),aSEMBurstDurations(23:end),'b','parent',oAxes);
