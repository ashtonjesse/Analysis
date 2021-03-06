function wBaselineCorrection
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
    zoom on;
    
    uicontrol('style','text','units','pixels',...
        'position',[60 980 310 25],...
        'string','Select the order of the polynomial to fit',...
        'FontSize',10,'FontWeight','bold');
    
    pPolynomialOrder = uicontrol('style','popupmenu','units','pixels',...
        'position',[60 955 310 25],...
        'string',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14'},...
        'tag','pmPolynomialOrder','FontSize',11);
    
    uicontrol('style','text','units','pixels',...
        'position',[390 980 350 25],...
        'string','Select the order of the spline approximation',...
        'FontSize',10,'FontWeight','bold');
    
    pSplineOrder = uicontrol('style','popupmenu','units','pixels',...
        'position',[390 955 350 25],...
        'string',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14'},...
        'tag','pmSplineOrder','FontSize',11);
    
    uicontrol('style','text','units','pixels',...
        'position',[750 980 200 25],...
        'string','Select a channel',...
        'FontSize',10,'FontWeight','bold');
    
    pChannel = uicontrol('style','popupmenu','units','pixels',...
        'position',[750 955 200 25],'callback',@pChannelChange_Callback,...
        'string',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14'},...
        'tag','pmChannel','FontSize',11);
    
    oOriginalAxes = axes('units','pixels','position',[60 700 1000 210],...
        'nextplot','replacechildren','tag','OrginalAxes','Box','on'); 
    title('Original Signal');
    set(oOriginalAxes,'units','normalized');

    oCorrectedOriginal = axes('units','pixels','position',[60 375 1000 250],...
        'nextplot','replacechildren','tag','CorrectedOriginal','Box','on');
    title('Corrected Original Signal');
    set(oCorrectedOriginal,'units','normalized');

    oSmoothedSignal = axes('units','pixels','position',[60 50 1000 250],...
        'nextplot','replacechildren','tag','SmoothedSignal','Box','on'); 
    title('Smoothed Signal');
    set(oSmoothedSignal,'units','normalized');
    
    %Create a drop down menu at the top of the figure for choosing a file and
    %exiting
    h2menu=uimenu('Label','File');
    uimenu(h2menu,'label','Exit','callback',@Closeh2menu_Callback,'separator','on');
    oBaselineMenu=uimenu('Label','Baseline Correction');
    uimenu(oBaselineMenu,'label','Do Correction','callback',@pBaselineMenu_Callback,'separator','on');
    uimenu(oBaselineMenu,'label','Apply Spline Approximation','callback',@bApplySpline_Callback,'separator','on');
    uimenu(oBaselineMenu,'label','Apply to Data','callback',@bApplytoData_Callback,'separator','on');
    
    %Set the default signal
    iDefaultSignal = 1;
    set(oOriginalAxes,'UserData',[]);
    set(oOriginalAxes,'UserData',iDefaultSignal);

    %Plot the data of the default signal
    set(oBaselineMainFigure,'CurrentAxes',oOriginalAxes);
    plot(Data.Unemap.Time,Data.Unemap.Potential.Original(:,iDefaultSignal),'k');
    axis 'auto';

    %Clear the CorrectedOriginal axes
    set(oBaselineMainFigure,'CurrentAxes',oCorrectedOriginal);
    cla;
    axis 'auto';
    %If there a baseline correction has already been done and the data saved
    %then plot the baseline corrected original data too
    if(Data.Unemap.Potential.Baseline.Corrected)
        plot(Data.Unemap.Time,...
            Data.Unemap.Potential.Baseline.Corrected(:,iDefaultSignal),'k');
        sTitle = sprintf('Existing Baseline Corrected Signal');
        title(sTitle);
        set(oCorrectedOriginal,'UserData',[]);
        set(oCorrectedOriginal,'UserData',...
            Data.Unemap.Potential.Baseline.Corrected(:,iDefaultSignal));
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
    %control using this nested function
    iPolynomialOrder = GetPolynomialOrder();
                      
    %Remove baseline 
    aRemoveBaseline = fRemoveMedianAndPolynomialFit(...
        Data.Unemap.Potential.Original(:,iDefaultSignal), iPolynomialOrder);
            
    %Find the CorrectedOriginal axes and set them to be active
    oCorrectedOriginal = findobj('tag','CorrectedOriginal');
    set(oBaselineMainFigure,'CurrentAxes',oCorrectedOriginal);
    cla;
    %Store baseline corrected data
    set(oCorrectedOriginal,'UserData',[]);
    set(oCorrectedOriginal,'UserData',aRemoveBaseline);
    
    %Plot the data with the baseline and mean of it removed.
    plot(Data.Unemap.Time,aRemoveBaseline,'k');
    title('Baseline Corrected Signal');

function bApplySpline_Callback(handles,src,event)
    global Data;    
    %Find the main figure object
    oBaselineMainFigure = findobj('tag','BaselineMainFigure');
    %Find the CorrectedOriginal axes and get the data
    oCorrectedOriginal = findobj('tag','CorrectedOriginal');
    aRemoveBaseline = get(oCorrectedOriginal,'UserData');
    iSplineOrder = GetSplineOrder;
    
    %Smooth the data with a spline approximation
    aSplineApproximation = fSplineSmooth(aRemoveBaseline,iSplineOrder,'MaxIter',500);
    
    %Find the SmoothedSignal axes and set them to be active
    oSmoothedSignal = findobj('tag','SmoothedSignal');
    set(oBaselineMainFigure,'CurrentAxes',oSmoothedSignal);
    cla;
    %Store smoothed data
    set(oSmoothedSignal,'UserData',[]);
    set(oSmoothedSignal,'UserData',aSplineApproximation);
    
    %Plot the data with the baseline and mean of it removed.
    plot(Data.Unemap.Time,aSplineApproximation,'k');
    title('Smoothed Signal');
    
function bApplytoData_Callback(handles,src,event)
    %Handles the callback for the button to apply the baseline correction to
    %the data
    global Data Experiment;
    %Get the polynomial order from the selection made in the listbox
    %control
    iPolynomialOrder = GetPolynomialOrder();
    
    %Create a waitbar to indicate the stage of completion and initialise
    %the Baseline.Corrected structured array
    oWaitbar = waitbar(0,'Please wait...');
    Data.Unemap.Potential.Baseline.Corrected = ...
        zeros(size(Data.Unemap.Potential.Original,1),...
        Experiment.Unemap.NumberOfElectrodes);
    %Loop through all the electrodes creating a baseline polynomial for
    %each and removing this component from the data.
    for k = 1:Experiment.Unemap.NumberOfElectrodes;
        %Perform baseline correction
        aRemoveBaseline = fRemoveMedianAndPolynomialFit(...
        Data.Unemap.Potential.Original(:,k), iPolynomialOrder);
    
        Data.Unemap.Potential.Baseline.Order = iPolynomialOrder;
        Data.Unemap.Potential.Baseline.Corrected(:,k) = aRemoveBaseline;
        waitbar(k/Experiment.Unemap.NumberOfElectrodes,oWaitbar,sprintf(...
            'Please wait... Signal %d completed',k));
    end
    close(oWaitbar);

function pChannelChange_Callback(handles,src,event)
    iDefaultSignal = get(handles,'Value');
    set(oOriginalAxes,'UserData',[]);
    set(oOriginalAxes,'UserData',iDefaultSignal);

function iPolynomialOrder = GetPolynomialOrder()
    %Get the polynomial order from the selection made in the listbox
    %control
    oHandle = findobj('tag','pmPolynomialOrder');
    aString = get(oHandle,'String');
    iIndex = get(oHandle,'Value');
    iPolynomialOrder = aString(iIndex);
    % Make sure inputs are of type integer
    iPolynomialOrder = str2double(char(iPolynomialOrder));

function iSplineOrder = GetSplineOrder()
    %Get the polynomial order from the selection made in the listbox
    %control
    oHandle = findobj('tag','pmSplineOrder');
    aString = get(oHandle,'String');
    iIndex = get(oHandle,'Value');
    iSplineOrder = aString(iIndex);
    % Make sure output are of type double
    iSplineOrder = str2double(char(iSplineOrder));
  
function Closeh2menu_Callback(handles,src,event)
    closereq;
