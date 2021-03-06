function HRBaroFunction_GetPressureThreshold(aFiles,aPressureData,aRecordingIndex)
%this function plots a bunch of pressure vs HR plots and allows the user to
%check that the appropriate threshold has been chosen

%initialise arrays

for j = 1:numel(aFiles)
    sFile = char(aFiles{j});
    oPressure = aPressureData{j};
    % get the name for this line
    aIndices = regexp(sFile,'\');
    sName = sFile(aIndices(end-1)+1:aIndices(end)-1);
    %get rate data
    if isempty(oPressure.oRecording(aRecordingIndex(j)).Electrodes) || ~isfield(oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed,'BeatRates')
        aRates = oPressure.oPhrenic.Electrodes.Processed.BeatRates';
        aTimes = oPressure.oPhrenic.Electrodes.Processed.BeatRateTimes(2:end);
    else
        aRates = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRates';
        aTimes = oPressure.oRecording(aRecordingIndex(j)).Electrodes.Processed.BeatRateTimes(2:end);
    end
    %     find the rates that fall within the time range specified by the
    %     start of the increase section of the challenge to the start of
    %     the heart rate plateau section
    aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
        aTimes < oPressure.TimeSeries.Original(oPressure.Plateau.Range(1));
    aBeatRates = aRates(aTimePoints);
    if size(aTimePoints,1) > size(aTimePoints,2)
        aTimePoints = [false aTimePoints'];
    else
        aTimePoints = [false aTimePoints];
    end
    aBeatTimes = aTimes(aTimePoints);
    
    %get pressure data and filter
    if numel(oPressure.TimeSeries.Original) == numel(oPressure.Original.Data)
        aPressureProcessedData = oPressure.FilterData(oPressure.Original.Data, 'LowPass', oPressure.oExperiment.PerfusionPressure.SamplingRate, 1);
    else
        aPressureProcessedData = oPressure.Processed.Data;
    end
    
    %     get the corresponding pressures
    aPressures = zeros(size(aBeatTimes));
    for i = 1:numel(aBeatTimes)
        %         find the index that is closest to this time
        [MinVal MinIndex] = min(abs(oPressure.TimeSeries.Original - aBeatTimes(i)));
        aPressures(i) = aPressureProcessedData(MinIndex);
    end
    
    %fit cubic polynomial to data
    xx = linspace(aPressures(1), aPressures(end), 200);
    p = polyfit(aPressures,aBeatRates',3);
    yy = polyval(p,xx);
    %     yy = spline(aPressures,aBeatRates,xx);
    
    %compute curvature
    [aDerivative xbar] = EstimateDerivative(yy',xx,1,500,5);
    %find curvature minimum
    aPoints = diff(sign(aDerivative));
    indx_down = find(aPoints<0,1,'last');
    if isempty(indx_down)
        [C indx_down] = max(aDerivative);
    end
    oFigure = figure();
    % plotting
    aSubplotPanel = panel(oFigure,'no-manage-font');
    aSubplotPanel.pack(2,1);
    oAxes = cell(1,2);
    oAxes{1} = aSubplotPanel(1,1).select();
    [oFirstAxes H1 H2] = plotyy(aPressures,aBeatRates,xx,yy);
    oAxes{2} = aSubplotPanel(2,1).select();
    [oSecondAxes H1 H2] = plotyy(xx,yy,xbar,aDerivative);
    if ~isempty(indx_down)
        hold(oSecondAxes(2),'on');
        plot(oSecondAxes(2),xbar(indx_down),aDerivative(indx_down),'r+');
        fprintf('%1.0f,%4.0f\n',j,xbar(indx_down));
        hold(oSecondAxes(2),'off');
    end
    %set up figure
    %make sure data cursor displays the index aswell
    dcm_obj = datacursormode(oFigure);
    set(dcm_obj,'UpdateFcn',@NewCursorCallback);
    %create button
    oButton = uicontrol(oFigure,'style','pushbutton','string','Save Range','callback',@(src, event) ButtonCallback(src, event));
    set(oFigure,'toolbar','figure')
end

    function ButtonCallback(src, event)
        oFigure = get(src,'parent');
        hBrushLine = findall(oFigure,'tag','Brushing');
        % Get the Xdata and Ydata attitributes of this
        brushedData = get(hBrushLine, {'Xdata','Ydata'});
        % The data that has not been selected is labelled as NaN so get
        % rid of this
        % There are two axes on the plot so choose the second of these as
        % this corresponds to the pressure data
        brushedIdx = ~isnan(brushedData{2});
        brush(oFigure,'off');
        fprintf('%d,%d,%d\n',oFigure,find(brushedIdx,1,'first'),find(brushedIdx,1,'last'));
    end
end