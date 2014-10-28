close all;
% clear all;
% % open all the files 
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
% aPressureData = cell(1,numel(aFiles));
% for i = 1:numel(aFiles)
%     aPressureData{i} = GetPressureFromMATFile(Pressure,char(aFiles{i}),'Optical');
%     fprintf('Got file %s\n',char(aFiles{i}));
% end

%plot all the HR traces
oFigure = figure();
aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(3,1);
oAxes = cell(1,3);
oAxes{1} = aSubplotPanel(1,1).select();
oAxes{2} = aSubplotPanel(2,1).select();
oAxes{3} = aSubplotPanel(3,1).select();
oColors = distinguishable_colors(numel(aFiles));
for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    
    switch (j)
        case 4
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = 28;
        case 1
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = 26;
        case 8
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = 24;
        otherwise
            aRates = oPressure.oRecording(1).Electrodes.Processed.BeatRates;
            aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
            iCurvatureLimit = 40;
    end
    
    
    aPhrenicRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates;
    aPhrenicTime = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
    aSeriesPoints = find(aPhrenicTime >= aTimes(1) & aPhrenicTime <= aTimes(end));
    aPhrenicTime = aPhrenicTime(aSeriesPoints);
    aPhrenicRates = aPhrenicRates(aSeriesPoints);
    %normalise rates
    aRates = (-1 + aRates./mean(aRates(1:4)))*100;
    % get pressure time and data
    aPressureTime = oPressure.TimeSeries.Processed;
    aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    aPressureTime = aPressureTime(aSeriesPoints);
    aPressureProcessedData = oPressure.Processed.Data(aSeriesPoints);
    %normalise times to start of stimulus
    %     aSlope = fCalculateMovingSlope(aPressureProcessedData,5,3);
    aSlope = fCalculateMovingSlope(aRates,7,3);
    aCurvature = fCalculateMovingSlope(aSlope,7,3);
    aSlope(1:4) = 0;
    aSlope(end-3:end) = 0;
    aCurvature(1:4) = 0;
    aCurvature(end-3:end) = 0;
    %     [C I] = max(aCurvature(1:iCurvatureLimit));
    %     aTimes = aTimes - aPressureTime(I);
    %     aPressureTime = aPressureTime -  aPressureTime(I);
    
    sColor = oColors(j,:);
    
    
    [C I] = min(aCurvature(1:iCurvatureLimit));
    aPressureTime = aPressureTime -  aTimes(I);
    aPhrenicTime = aPhrenicTime - aTimes(I);
    aTimes = aTimes - aTimes(I);
    oHRLine = plot(oAxes{1}, aTimes , aRates, 'Color',sColor);
    set(oHRLine,'DisplayName',sName, 'LineWidth', 1.5);
    oPressureLine = plot(oAxes{2}, aPressureTime, aPressureProcessedData, 'Color',sColor);
    set(oPressureLine,'DisplayName',sName, 'LineWidth', 1.5);
    oPhrenicLine = plot(oAxes{3}, aPhrenicTime, aPhrenicRates, 'Color',sColor);
    set(oPhrenicLine,'DisplayName',sName, 'LineWidth', 1.5);
    hold(oAxes{1}, 'on');
    hold(oAxes{2}, 'on');
    hold(oAxes{3}, 'on');
%     figure();
%     plotyy(aTimes,aRates,aTimes,aCurvature);
%     hold on;
%     plot(aTimes(I),aRates(I),'r+');
end
hold(oAxes{1}, 'off');
legend(oAxes{1},'show');
hold(oAxes{2}, 'off');
legend(oAxes{2},'show');
hold(oAxes{3}, 'off');
legend(oAxes{3},'show');
%set up labels
set(get(oAxes{3},'xlabel'),'string','Time relative to rate change onset (s)');
set(get(oAxes{1},'ylabel'),'string','% atrial rate change (bpm)');
set(get(oAxes{2},'ylabel'),'string','Pressure (mmHg)');
set(get(oAxes{3},'ylabel'),'string','Phrenic burst rate (bpm)');
set(oAxes{2},'xlim',get(oAxes{1},'xlim'));
set(oAxes{2},'ylim',[50 155]);
set(oAxes{2},'YMinorTick','on');
set(oAxes{3},'xlim',get(oAxes{1},'xlim'));