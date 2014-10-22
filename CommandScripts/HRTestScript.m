close all;
% clear all;
% %open all the files 
% aPressureData = cell(1,6);
% aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat', ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat' ...
%     };
% for i = 1:numel(aFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aFiles{i}));
% end

%plot all the HR traces
oFigure = figure();
aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(2,1);
oAxes = cell(1,2);
oAxes{1} = aSubplotPanel(1,1).select();
oAxes{2} = aSubplotPanel(2,1).select();
oColors = distinguishable_colors(numel(aFiles));
for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
   
    switch (j)
        case {1,2}
            aRates = oPressure.oRecording(2).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(2).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = floor(numel(aRates)/2);
        case 3
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = 41;
        otherwise
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = floor(numel(aRates)/2);
    end
    %normalise rates
    aRates = (-1 + aRates./mean(aRates(1:4)))*100;
    % get pressure time and data
    aPressureTime = oPressure.TimeSeries.Processed;
    aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    aPressureTime = aPressureTime(aSeriesPoints);
    aPressureProcessedData = oPressure.Processed.Data(aSeriesPoints);
    %normalise times to start of stimulus
    %     aSlope = fCalculateMovingSlope(aPressureProcessedData,5,3);
    aSlope = fCalculateMovingSlope(aRates,5,3);
    aCurvature = fCalculateMovingSlope(aSlope,5,3);
    aSlope(1:4) = 0;
    aSlope(end-3:end) = 0;
    aCurvature(1:4) = 0;
    aCurvature(end-3:end) = 0;
    %     [C I] = max(aCurvature(1:iCurvatureLimit));
    %     aTimes = aTimes - aPressureTime(I);
    %     aPressureTime = aPressureTime -  aPressureTime(I);
    [C I] = min(aCurvature(1:iCurvatureLimit));
    aPressureTime = aPressureTime -  aTimes(I);
    aTimes = aTimes - aTimes(I);
    oHRLine = plot(oAxes{1}, aTimes , aRates, 'Color',oColors(j,:));
    set(oHRLine,'DisplayName',sName, 'LineWidth', 1.5);
    oPressureLine = plot(oAxes{2}, aPressureTime, aPressureProcessedData, 'Color',oColors(j,:));
    set(oPressureLine,'DisplayName',sName, 'LineWidth', 1.5);
    hold(oAxes{1}, 'on');
    hold(oAxes{2}, 'on');
end
hold(oAxes{1}, 'off');
legend(oAxes{1},'show');
hold(oAxes{2}, 'off');
legend(oAxes{2},'show');
%set up labels
set(get(oAxes{2},'xlabel'),'string','Time relative to rate change onset (s)');
set(get(oAxes{1},'ylabel'),'string','% atrial rate change (bpm)');
set(get(oAxes{2},'ylabel'),'string','Pressure (mmHg)');