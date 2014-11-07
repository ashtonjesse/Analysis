function aRange = HRBaroFunction_GetPressureRange(aFiles,aPressureData)
%this function plots a bunch of pressure plots and allows the user to
%select a range for each and save this to a variable called aRange
%initialise arrays
aRange = zeros(numel(aFiles),2);
for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
    
    % get pressure time
    aPressureTime = oPressure.TimeSeries.Original;
    aSeriesPoints = find(aPressureTime >= aTimes(1) & aPressureTime <= aTimes(end));
    aPressureTime = aPressureTime(aSeriesPoints);
    %get pressure data and filter
    aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    aPressureProcessedData = aPressureProcessedData(aSeriesPoints);
        
    %get pressure slope values
    aPressureSlope = fCalculateMovingSlope(aPressureProcessedData,15,3);
    aPressureCurvature = fCalculateMovingSlope(aPressureSlope,15,3);
    
    %pressure plotting
    oFigure = figure();
    [AX H1 H2] = plotyy(aPressureTime,aPressureProcessedData,aPressureTime,aPressureCurvature);
    %set up figure
    %make sure data cursor displays the index aswell
    dcm_obj = datacursormode(oFigure);
    set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    %create button
    oButton = uicontrol(oFigure,'style','pushbutton','string','Save Range','callback',@(src, event) ButtonCallback(src, event));
end

    function ButtonCallback(src, event)
        oFigure = get(src,'parent');
        hBrushLine = findall(oFigure,'tag','Brushing');
        % Get the Xdata and Ydata attitributes of this
        brushedData = get(hBrushLine, {'Xdata','Ydata'});
        % The data that has not been selected is labelled as NaN so get
        % rid of this
        brushedIdx = ~isnan(brushedData{1});
    end
end