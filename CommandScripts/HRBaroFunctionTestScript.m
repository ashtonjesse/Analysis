close all;
clear all;
% open all the files 
aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro010\Pressure.mat' ...
    };
aPressureData = cell(1,numel(aFiles));
for i = 1:numel(aFiles)
    aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
    fprintf('Got file %s\n',char(aFiles{i}));
end

% %plot all the HR traces
% oFigure = figure();
% aSubplotPanel = panel(oFigure,'no-manage-font');
% aSubplotPanel.pack(3,1);
% oAxes = cell(1,3);
% oAxes{1} = aSubplotPanel(1,1).select();
% oAxes{2} = aSubplotPanel(2,1).select();
% oAxes{3} = aSubplotPanel(3,1).select();
% oColors = distinguishable_colors(numel(aFiles));
%initialise arrays
aHRSlope = zeros(numel(aFiles),2);
aPressureSlope = zeros(numel(aFiles),2);
for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
    
    aPhrenicRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
    aPhrenicTime = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
    aSeriesPoints = find(aPhrenicTime >= aTimes(1) & aPhrenicTime <= aTimes(end));
    aPhrenicTime = aPhrenicTime(aSeriesPoints);
    aPhrenicRates = aPhrenicRates(aSeriesPoints);
    
    % get pressure time
    aPressureTime = oPressure.TimeSeries.Original;
    aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    aPressureTime = aPressureTime(aSeriesPoints);
    %get pressure data and filter
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    aPressureProcessedData = aPressureProcessedData(aSeriesPoints);
    
    % %     normalise rates
    %     aRates = (-1 + aRates./mean(aRates(1:4)))*100;
    %     get rate slope values
    aSlope = fCalculateMovingSlope(aRates,5,3);
    aSmoothSlope = fCalculateMovingSlope(aRates,19,3);
    
    %get pressure slope values
    aPressureSlope = fCalculateMovingSlope(aPressureProcessedData,15,3);
    aPressureCurvature = fCalculateMovingSlope(aPressureSlope,15,3);
    
    %for aligning data
    %     aPhrenicTime = aPhrenicTime - aTimes(ThresholdInd);
    %     aPressureTime = aPressureTime -  aTimes(ThresholdInd);
    %     aTimes = aTimes - aTimes(ThresholdInd);
    
    %for plotting all data
    %     sColor = oColors(j,:);
    %     oHRLine = plot(oAxes{1}, aTimes , aRates, 'Color',sColor);
    %     set(oHRLine,'DisplayName',sName, 'LineWidth', 1.5);
    %     oPressureLine = plot(oAxes{2}, aPressureTime, aPressureProcessedData, 'Color',sColor);
    %     set(oPressureLine,'DisplayName',sName, 'LineWidth', 1.5);
    %     oPhrenicLine = plot(oAxes{3}, aPhrenicTime, aPhrenicRates, 'Color',sColor);
    %     set(oPhrenicLine,'DisplayName',sName, 'LineWidth', 1.5);
    %     hold(oAxes{1}, 'on');
    %     hold(oAxes{2}, 'on');
    %     hold(oAxes{3}, 'on');
    
    %     %HR plotting
    %     oFigure = figure();
    %     [AX H1 H2] = plotyy(aTimes,aRates,aTimes,aSlope);
    %     dcm_obj = datacursormode(oFigure);
    %     set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    %     hold(AX(2),'on');
    %     plot(AX(2),aTimes,aSmoothSlope,'g');
    %     hold(AX(2),'off');
    
        %pressure plotting
        oFigure = figure();
        [AX H1 H2] = plotyy(aPressureTime,aPressureProcessedData,aPressureTime,aPressureCurvature);
        dcm_obj = datacursormode(oFigure);
        set(dcm_obj,'UpdateFcn',@NewCursorCallback);
end
% hold(oAxes{1}, 'off');
% legend(oAxes{1},'show');
% hold(oAxes{2}, 'off');
% legend(oAxes{2},'show');
% hold(oAxes{3}, 'off');
% legend(oAxes{3},'show');
% %set up labels
% set(get(oAxes{3},'xlabel'),'string','Time relative to rate change onset (s)');
% set(get(oAxes{1},'ylabel'),'string','% atrial rate change (bpm)');
% set(get(oAxes{2},'ylabel'),'string','Pressure (mmHg)');
% set(get(oAxes{3},'ylabel'),'string','Phrenic burst rate (bpm)');
% set(oAxes{2},'xlim',get(oAxes{1},'xlim'));
% set(oAxes{2},'ylim',[60 155]);
% set(oAxes{2},'YMinorTick','on');
% set(oAxes{3},'xlim',get(oAxes{1},'xlim'));