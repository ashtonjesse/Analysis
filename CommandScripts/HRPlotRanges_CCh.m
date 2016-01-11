close all;
clear all;
% % % open all the files 
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh007\Pressure.mat' ...
    };
aPressureData = cell(1,numel(aFiles));
for i = 1:numel(aFiles)
    aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aFiles{i}));
end

% %plot all the HR traces
for j = 1:numel(aFiles)
    oPressure = aPressureData{j};
    %create figure and subplot
    oFigure = figure();
    aSubplotPanel = panel(oFigure,'no-manage-font');
    aSubplotPanel.pack(2,1);
    oAxes = cell(1,2);
    
    aRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates';
    aTimes = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
    [aRateCurvature xbar] = EstimateDerivative(aRates,aTimes,2,500,5);
    
    %get pressure data and filter
    if isfield(oPressure.TimeSeries,'Processed')
        aPressureTime = oPressure.TimeSeries.Processed;
    else
        aPressureTime = oPressure.TimeSeries.Original;
    end
    aPressureProcessedData = oPressure.Processed.Data;
    %get pressure slope values
    aPressureSlope = fCalculateMovingSlope(aPressureProcessedData,15,3);
    aPressureCurvature = fCalculateMovingSlope(aPressureSlope,15,3);
    
    %for plotting all data
    oAxes{1} = aSubplotPanel(1,1).select();
    [oFirstAxes H1 H2] = plotyy(aTimes, aRates, NaN, NaN);
    oAxes{2} = aSubplotPanel(2,1).select();
    [oSecondAxes H1 H2] = plotyy(aPressureTime, aPressureProcessedData,aPressureTime,aPressureCurvature);
     %plot the ranges
    hold(oFirstAxes(1),'on');
    hold(oSecondAxes(1),'on');
    sRanges = {{'HeartRate','Decrease'},{'HeartRate','Plateau'}};
    oColors = {'ro','b+','gx','mo'};
    for m = 1:numel(sRanges)
        if iscell(sRanges{m})
            if oPressure.HeartRate.Decrease.Range(1) > 0
                aTimePoints = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end) > aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1)) & ...
                    oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end) < aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2));
                if size(aTimePoints,1) > size(aTimePoints,2)
                    aTimePoints = aTimePoints';
                end
                aBeats = oPressure.oPhrenic.Electrodes.Processed.BeatRates(aTimePoints);
                aTimePoints = [false aTimePoints];
                aBeatTimes = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(aTimePoints);
                plot(oAxes{1},aBeatTimes,aBeats,char(oColors{m}));
                plot(oAxes{2},aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1):oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2)),...
                    aPressureProcessedData(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1):oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2)),char(oColors{m}));
            end
        end
    end
    hold(oFirstAxes(1),'off');
    hold(oSecondAxes(1),'off');
    dcm_obj = datacursormode(oFigure);
    set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    set(oSecondAxes(1),'xlim',get(oFirstAxes(1),'xlim'));
    set(oSecondAxes(2),'xlim',get(oFirstAxes(1),'xlim'));
    set(oSecondAxes(2),'ylim',[-1*10^-6,1*10^-6]);
end

