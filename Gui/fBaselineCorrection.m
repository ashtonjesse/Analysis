function fBaselineCorrection
    %Carry out a baseline correction on the data loaded into Data

    %Add paths
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Utilities/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Signal/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Gui/'));

    global Data Experiment;

    %Create the main figure window and set up three axes for original signal,
    %baseline mean and baseline corrected.
    oBaselineMainFigure=figure('Visible','on',...
        'units','pixels','position',[260 50 1295 1000],...
        'tag','BaselineMainFigure','name','BaselineCorrection',...
        'menubar','none','numbertitle','off',...
        'Color',[.95 .99 .95]);

    oOriginalAxes = axes('units','pixels','position',[60 700 1000 250],...
        'nextplot','replacechildren','tag','OrginalAxes','Box','on'); 
    title('Original Signal');
    set(oOriginalAxes,'units','normalized');

    oBaselineMean = axes('units','pixels','position',[60 375 1000 250],...
        'nextplot','replacechildren','tag','BaselineMean','Box','on'); 
    title('Baseline and Mean of Original Signal');
    set(oBaselineMean,'units','normalized');

    oCorrectedOriginal = axes('units','pixels','position',[60 50 1000 250],...
        'nextplot','replacechildren','tag','CorrectedOriginal','Box','on');
    title('Corrected Original Signal');
    set(oCorrectedOriginal,'units','normalized');

    %Create controls, a menu to choose the polynomial order and a button to
    %apply the baseline correction to the data
    pBaselineMenu = uicontrol('style','popupmenu','units','pixels',...
        'position',[1080 300 200 200],...
        'string',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14'},...
        'tag','pmBaselineMenu','callback',@pBaselineMenu_Callback,'FontSize',14);

    bApplytoData = uicontrol('style','pushbutton','units',...
        'pixels','position',[1080 70 200 200],...
        'string','Apply to Data',...
        'tag','btnApplytoData','callback',@bApplytoData_Callback,'FontSize',14);

    %Create a drop down menu at the top of the figure for choosing a file and
    %exiting
    h2menu=uimenu('Label','File');
    uimenu(h2menu,'label','Exit','callback',@Closeh2menu_Callback,'separator','on');

    %Set the default signal
    iDefaultSignal = 1;
    set(oOriginalAxes,'UserData',[]);
    set(oOriginalAxes,'UserData',iDefaultSignal);

    %Plot the data of the default signal
    set(oBaselineMainFigure,'CurrentAxes',oOriginalAxes);
    plot(Data.Unemap.Time,Data.Unemap.Potential.Original(:,iDefaultSignal),'k');
    %Hold the axis handle
    oCurrentAxis = axis;

    %Clear the BaselineMean axes
    set(oBaselineMainFigure,'CurrentAxes',oBaselineMean);
    cla;
    axis(oCurrentAxis);

    %Clear the CorrectedOriginal axes
    set(oBaselineMainFigure,'CurrentAxes',oCorrectedOriginal);
    cla;
    axis(oCurrentAxis);

    %If there a baseline correction has already been done and the data saved
    %then plot the baseline corrected original data too
    if(Data.Unemap.Potential.Baseline.Corrected)
        plot(Data.Unemap.Time,Data.Unemap.Potential.Baseline.Corrected(:,iDefaultSignal),'k');
        sTitle = sprintf('Existing Baseline Corrected Signal');
        title(sTitle);
    end


function pBaselineMenu_Callback(handles,src,event)
    %Handles the callback for the popupmenu that specifies the order of the
    %polynomial to fit
    global Data Experiment;
    %Find the main figure object
    oBaselineMainFigure = findobj('tag','BaselineMainFigure');
    %Find the OriginalAxes object
    oHandle = findobj('tag','OrginalAxes');
    iDefaultSignal = get(oHandle,'UserData');
    %Get the polynomial order from the selection made in the listbox
    %control
    iPolynomialOrder = get(handles,'Value');
    
    %Set the Original axes as the active axes 
    set(oBaselineMainFigure,'CurrentAxes',oHandle);
    %Hold on to the axis information
    oOriginalAxis = axis;
    %Get the polynomial fit for this signal
    [aBaselinePolynomial] = fPolynomialFitEvaluation(iPolynomialOrder,iDefaultSignal);
    %Find the BaselineMean axes and set them to be active
    oBaselineMean = findobj('tag','BaselineMean');
    set(oBaselineMainFigure,'CurrentAxes',oBaselineMean);
    cla;
    %Plot the polynomial that was computed
    plot(Data.Unemap.Time,aBaselinePolynomial,'k');
    sTitle = sprintf('Baseline Poly Order: %d',iPolynomialOrder);
    title(sTitle);
    %Remove the polynomial approximation to the baseline from the data
    aRemoveBaseline = Data.Unemap.Potential.Original(:,iDefaultSignal)-aBaselinePolynomial;
    %Take away the mean of this data
    aRemoveBaselineMean = aRemoveBaseline - mean(aRemoveBaseline);
    axis(oOriginalAxis);
    %Find the CorrectedOriginal axes and set them to be active
    oCorrectedOriginal = findobj('tag','CorrectedOriginal');
    set(oBaselineMainFigure,'CurrentAxes',oCorrectedOriginal);
    cla;
    %Plot the data with the baseline and mean of it removed.
    plot(Data.Unemap.Time,aRemoveBaselineMean,'k');
    axis(oOriginalAxis);
    title('Baseline Corrected Signal');

    function bApplytoData_Callback(handles,src,event)
    %Handles the callback for the button to apply the baseline correction to
    %the data
    global Data Experiment;
    %Create a waitbar to indicate the stage of completion and initialise
    %the Baseline.Corrected structured array
    oWaitbar = waitbar(0,'Please wait...');
    Data.Unemap.Potential.Baseline.Corrected = ...
        zeros(size(Data.Unemap.Potential.Original,1),...
        Experiment.Unemap.NumberOfElectrodes);
    %Loop through all the electrodes creating a baseline polynomial for
    %each and removing this component from the data.
    for k = 1:Experiment.Unemap.NumberOfElectrodes;
        oBaselineMenu = findobj('tag','pmBaselineMenu');
        iPolynomialOrder = get(oBaselineMenu,'Value');
        [aBaselinePolynomial] = fPolynomialFitEvaluation(iPolynomialOrder,k);
        aRemoveBaseline = Data.Unemap.Potential.Original(:,k)-aBaselinePolynomial;
        aRemoveBaselineMean = aRemoveBaseline - mean(aRemoveBaseline);

        Data.Unemap.Potential.Baseline.Order = iPolynomialOrder;
        Data.Unemap.Potential.Baseline.Corrected(:,k) = aRemoveBaselineMean;
        waitbar(k/Experiment.Unemap.NumberOfElectrodes,oWaitbar,sprintf(...
            'Please wait... Signal %d completed',k));
    end
    close(oWaitbar);

function Closeh2menu_Callback(handles,src,event)
    closereq;
