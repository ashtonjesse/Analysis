function wDetectBeats
%     This gui allows the user to complete processing the signals by
%     calculating a VRMS signal, which is then smoothed and fitted
%     with a spline approximation. The curvature of this signal is 
%     calculated and used to mark a time window of activation for
%     each beat. The isoelectric point is found preceeding each beat and
%     a 2nd order polynomial approximation is fitted to this to normalise 
%     each beat. 

    %Add paths
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Utilities/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Signal/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Gui/'));

    global Data Experiment;

    %Create the main figure window and set up three axes for original signal,
    %baseline mean and baseline corrected.
    oDetectBeatsMainFigure=figure('Visible','on',...
        'units','pixels','position',[260 50 1295 1000],...
        'tag','DetectBeatsMainFigure','name','DetectBeats',...
        'menubar','none','numbertitle','off',...
        'Color',[.95 .99 .95]);
    
    uicontrol('style','text','units','pixels',...
        'position',[60 980 290 25],...
        'string','Select the window size for filtering',...
        'FontSize',10,'FontWeight','bold');
    
    pFilterWindowSize = uicontrol('style','popupmenu','units','pixels',...
        'callback',@pFilterWindowSize_Callback,'position',[60 955 290 25],...
        'string',{'1','3','5','7','9','11','13','15','17','19','21'},...
        'tag','pmFilterWindowSize','FontSize',11);
    
    uicontrol('style','text','units','pixels',...
        'position',[360 980 350 25],...
        'string','Select the order of the polynomial for fitting',...
        'FontSize',10,'FontWeight','bold');
    
    pPolynomialOrder = uicontrol('style','popupmenu','units','pixels',...
        'callback',@pPolynomialOrder_Callback,'position',[360 955 350 25],...
        'string',{'3','5','6','7','8','9','10','11','12','13','14'},...
        'tag','pmPolynomialOrder','FontSize',11);
    
    oVrmsAxes = axes('units','pixels','position',[60 700 1000 200],...
        'nextplot','replacechildren','tag','VrmsAxes','Box','on'); 
    title('V_R_M_S');
    set(oVrmsAxes,'units','normalized');
 
    oCurvatureAxes = axes('units','pixels','position',[60 375 1000 250],...
        'nextplot','replacechildren','tag','CurvatureAxes','Box','on'); 
    title('Curvature');
    set(oCurvatureAxes,'units','normalized');

    oRepSignalAxes = axes('units','pixels','position',[60 50 1000 250],...
        'nextplot','replacechildren','tag','RepSignalAxes','Box','on');
    title('Representative signal');
    set(oRepSignalAxes,'units','normalized');

    %Create a drop down menu at the top of the figure for control options
    oFileMenu=uimenu('Label','File');
    uimenu(oFileMenu,'label','Exit','callback',@CloseWindow_Callback,'separator','on');
    oVrmsMenu=uimenu('Label','Vrms');
    uimenu(oVrmsMenu,'label','Calculate Vrms','callback',@bCalculateVrms_Callback,'separator','on');
    uimenu(oVrmsMenu,'label','Calculate Smooth Vrms','callback',@bCalculateSmoothVrms_Callback,'separator','on');

    %Set the default signal
    iDefaultSignal = 1;
    set(oVrmsAxes,'UserData',[]);
    set(oVrmsAxes,'UserData',iDefaultSignal);
   

function bCalculateVrms_Callback(handles,src,event)
    %Handles the callback for the calculate Vrms button
    
    global Data Experiment;
    %Find the main figure object
    oDetectBeatsMainFigure = findobj('tag','DetectBeatsMainFigure');
                           
    %Calculate Vrms and smooth
    aVrms = fCalculateVrms(Data.Unemap.Potential.Baseline.Corrected);
            
    %Find the VrmsAxes axes and set them to be active
    oVrmsAxes = findobj('tag','VrmsAxes');
    set(oDetectBeatsMainFigure,'CurrentAxes',oVrmsAxes);
    cla;
    %Plot the computed Vrms
    plot(Data.Unemap.Time,aVrms,'k');
    title('V_R_M_S');
                

function bCalculateSmoothVrms_Callback(handles,src,event)
    %Handles the callback for the calculate smooth Vrms button
    global Data Experiment;
    %Find the main figure object
    oDetectBeatsMainFigure = findobj('tag','DetectBeatsMainFigure');
    %Find the drop down objects to get the values
%     oHandle = findobj('tag','pmFilterWindowSize');
%     iFilterWindowSize = get(oHandle,'Value');
%     oHandle = findobj('tag','pmPolynomialOrder');
%     iPolynomialOrder = get(oHandle,'Value');
    iFilterWindowSize = get(handles,'FilterWindowSize');
    %Calculate Vrms and smooth
    aVrms = fCalculateSmoothVrms(Data.Unemap.Potential.Baseline.Corrected,...
        iPolynomialOrder,iFilterWindowSize);
            
    %Find the VrmsAxes axes and set them to be active
    oVrmsAxes = findobj('tag','VrmsAxes');
    set(oDetectBeatsMainFigure,'CurrentAxes',oVrmsAxes);
    cla;
    %Plot the computed Vrms
    plot(Data.Unemap.Time,aVrms,'k');
    title('Smooth V_R_M_S');

function pFilterWindowSize_Callback(handles,src,event)
    iFilterWindowSize = get(handles,'Value');
    set(handles,'FilterWindowSize',iFilterWindowSize);
        
function pPolynomialOrder_Callback(handles,src,event)
    iPolynomialOrder = get(handles,'Value');
    set(handles,'PolynomialOrder',iPolynomialOrder);
    
function CloseWindow_Callback(handles,src,event)
    closereq;