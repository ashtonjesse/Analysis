close all;
clear all;
% % % open all the files 
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'...
%     };
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro009\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro010\Pressure.mat' ...
%     };
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro006\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro007\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro009\Pressure.mat' ...
% };
aFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat' ...
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
    
    switch (j)
        case {1}
            iRecording = 2;
        otherwise
            iRecording = 1;
    end
    aRates = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRates;
    aTimes = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(2:end);
    [aRateCurvature xbar] = EstimateDerivative(aRates',aTimes,2,500,5);
    [aRateSlope xbar] = EstimateDerivative(aRates',aTimes,1,500,5);
    
    %get pressure data and filter
     if numel(oPressure.TimeSeries.Original) == numel(oPressure.Original.Data)
        aPressureTime = oPressure.TimeSeries.Original;
        aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    else
        aPressureTime = oPressure.TimeSeries.Original;
        aPressureProcessedData = oPressure.Processed.Data;
    end
    %get pressure slope values
    aPressureSlope = fCalculateMovingSlope(aPressureProcessedData,15,3);
    aPressureCurvature = fCalculateMovingSlope(aPressureSlope,15,3);
    
    %for plotting all data
    oAxes{1} = aSubplotPanel(1,1).select();
    [oFirstAxes H1 H2] = plotyy(aTimes, aRates, xbar, aRateCurvature);
    hold(oFirstAxes(1),'on');
    hold(oFirstAxes(2),'on');
    oSlopeLine = plot(oFirstAxes(2),xbar, aRateSlope,'-');
    set(oSlopeLine,'Color','k');
    oAxes{2} = aSubplotPanel(2,1).select();
    [oSecondAxes H1 H2] = plotyy(aPressureTime, aPressureProcessedData,aPressureTime,aPressureCurvature);
    hold(oSecondAxes(1),'on');
     %plot the ranges
    sRanges = {'Baseline','Increase','Plateau',{'HeartRate','Plateau'}};
    oColors = {'ro','b+','gx','mo'};
    for m = 1:numel(sRanges)
        if iscell(sRanges{m})
            if oPressure.HeartRate.Plateau.Range(1) > 0
                aTimePoints = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(2:end) > aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1)) & ...
                    oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(2:end) < aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2));
                aBeats = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRates(aTimePoints);
                aTimePoints = [false aTimePoints];
                aBeatTimes = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(aTimePoints);
                plot(oAxes{1},aBeatTimes,aBeats,char(oColors{m}));
                plot(oAxes{2},aPressureTime(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1):oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2)),...
                    aPressureProcessedData(oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(1):oPressure.(char(sRanges{m}{1})).(char(sRanges{m}{2})).Range(2)),char(oColors{m}));
            end
        else
            aTimePoints = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(2:end) > aPressureTime(oPressure.(char(sRanges{m})).Range(1)) & ...
                oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(2:end) < aPressureTime(oPressure.(char(sRanges{m})).Range(2));
            aBeats = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRates(aTimePoints);
            aTimePoints = [false aTimePoints];
            aBeatTimes = oPressure.oRecording(iRecording).Electrodes.Processed.BeatRateTimes(aTimePoints);
            plot(oAxes{1},aBeatTimes,aBeats,char(oColors{m}));
            plot(oAxes{2},aPressureTime(oPressure.(char(sRanges{m})).Range(1):oPressure.(char(sRanges{m})).Range(2)),...
                aPressureProcessedData(oPressure.(char(sRanges{m})).Range(1):oPressure.(char(sRanges{m})).Range(2)),char(oColors{m}));
        end
        
    end
    xDatum = plot(oFirstAxes(2),aPressureTime, zeros(1,numel(aPressureTime)),'-');
    set(xDatum,'Color',get(H2,'Color'));
    hold(oFirstAxes(1),'off');
    hold(oSecondAxes(1),'off');
    dcm_obj = datacursormode(oFigure);
    set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    set(oSecondAxes(1),'xlim',get(oFirstAxes(1),'xlim'));
    set(oSecondAxes(2),'xlim',get(oFirstAxes(1),'xlim'));
    set(oSecondAxes(2),'ylim',[-1*10^-6,1*10^-6]);
end

