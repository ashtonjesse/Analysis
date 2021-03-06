% This file sets up the gViewPotentials gui. Currently this gui has the
% following functionality:
% *View potential traces
% *Do baseline correction
% *Mark activation times
function gViewPotentials
    close all; 
    clear all;

    global Data Experiment;
       
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Utilities/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Signal/'));
    addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/Gui/'));

    %Set up the the main figure and the objects on that figure
    oMainFigure=figure('Visible','on',...
        'units','pixels','position',[250 100 500 600],...
        'tag','MainFigure','name','View Potentials',...
        'menubar','none','numbertitle','off',...
        'Color',[1 1 1]);

    sDataText = uicontrol('style','text','units','pixels',...
        'position',[120 560 260 25],'BackgroundColor',[1 1 1 ],...
        'FontSize',[14],'FontWeight','bold','String',...
        'Data not yet loaded','tag','strDataText');

    bBaseline = uicontrol('style','pushbutton','units','pixels','position',[20 425 460 25],...
        'FontSize',[10],'FontWeight','bold','String','Baseline Correct',...
        'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0],'callback',@bBaseline_Callback,...
        'visible','off','tag','btnBaseline');
    
    bDetectBeats = uicontrol('style','pushbutton','units','pixels','position',[20 375 460 25],...
        'FontSize',[10],'FontWeight','bold','String','Detect Beats',...
        'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0],'callback',@bDetectBeats_Callback,...
        'visible','off','tag','btnDetectBeats');
    
    bSignalAnalysis = uicontrol('style','pushbutton','units','pixels','position',[20 300 460 25],...
        'FontSize',[10],'FontWeight','bold','String','Select Beat(s)',...
        'BackgroundColor',[0 1 0],'ForegroundColor',[0 0 0],'callback',@bSignalAnalysis_Callback,...
        'visible','off','tag','btnSignalAnalysis');

    bActivationAnalysis = uicontrol('style','pushbutton','units','pixels','position',[20 225 460 25],...
        'FontSize',[10],'FontWeight','bold','String','Analyse Activation',...
        'BackgroundColor',[0 .5 1],'ForegroundColor',[0 0 0],'callback',@bActivationAnalysis_Callback,...
        'visible','off','tag','btnActivationAnalysis');

    eData = uicontrol('style','edit','units','pixels','position',[20 150 460 25],...
        'FontSize',[10],'FontWeight','bold','String','H:/Data/Database',...
        'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],'HorizontalAlignment','left',...
        'visible','on','tag','edtData');

    %Set up drop down menu
    hmenu=uimenu('label','File');
    uimenu(hmenu,'label','Open Data','callback',@LoadData_Callback,'tag','OpenDataMenu');
    uimenu(hmenu,'label','Exit','callback','closereq','separator','on');
    hmenu=uimenu('label','Data');
    uimenu(hmenu,'label','Save Data','callback',@SaveData_Callback,'tag','OpenDataMenu');
    uimenu(hmenu,'label','Update Menu','callback',@UpdateMenu_Callback,'tag','OpenDataMenu');

    %Get the string components of the path to this file
    oViewPotentials = which('gViewPotentials.m');
    [sViewPotentialsPath sViewPotentialsName sViewPotentialsType] = fileparts(oViewPotentials);
    
function LoadData_Callback(src, eventdata)
    %This function opens a file dialog, loads a text file,
    %(containing the signal) and plots the data
    clear Data;
    global Data Experiment;

    %Call built-in file dialog to select filename
    [sDataFileName,sDataPathName]=uigetfile('*.mat','Select .mat containing a Data structured array');
    [sExpFileName,sExpPathName]=uigetfile('*.mat','Select .mat containing an Experiment structured array');
    %Make sure the dialogs return char objects
    if (~ischar(sDataFileName) && ~ischar(sExpFileName))
        return
    end

    %Change the string on the datatext label
    oHandle = findobj('tag','strDataText'); 
    set(oHandle,'string','Loading Data','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1]);

    %Get the full file name and save it to UserData attribute of oHandle
    sLongDataFileName=strcat(sDataPathName,sDataFileName);
    sLongExpFileName=strcat(sExpPathName,sExpFileName);
    set(oHandle,'UserData',sLongDataFileName);

    %Load the selected file
    load(sLongDataFileName);
    load(sLongExpFileName);
    %Check the data loaded and make appropriate buttons visible
    fCheckData;
    set(oHandle,'string','Data Loaded','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1]);

function fCheckData
    %This function checks the data currently loaded into Data and makes the
    %appropriate buttons visible on the mainfigure.
    
    global Data Experiment;
    %If there is anything in the Unemap Potentials make the baseline
    %correction button visible.
    if(size(Data.Unemap.Potential.Original,1))
        oHandle = findobj('tag','btnBaseline');
        set(oHandle,'visible','on');
    else
        temp = findobj('tag','btnBaseline'); 
        set(temp,'visible','off');
    end
    
    %If the Unemap potentials have been baseline corrected make the Single
    %channel button and Unemap signals button visible.
    if(size(Data.Unemap.Potential.Baseline.Corrected,1))
        oHandle = findobj('tag','btnDetectBeats'); 
        set(oHandle,'visible','on');
%         oHandle = findobj('tag','btnSingle'); 
%         set(oHandle,'visible','on');
%         oHandle = findobj('tag','btnUnemap'); 
%         set(oHandle,'visible','on');
    end

% function LoadMRI(src, eventdata)
% %This function opens a file dialog, loads a text file,
% %(containing the signal) and plots the data
% global GEO;
% global fileDirect
% a = pwd;
% 
% cd(fileDirect.GEO);
% %call built-in file dialog to select filename
% [filename,pathname]=uigetfile('*.mat','Select MRI mat file');
% fileDirect.GEO  = pathname;
% save(fileDirect.fileDfullpath,'fileDirect')
% 
% if ~ischar(filename),return,end
% 
% temp = findobj('tag','mritext');
% set(temp,'string','Patients, loading MRI.','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1]);
% %load file
% longfilename=strcat(pathname,filename);
% load(longfilename);
% newtext = sprintf('%s',GEO.Info.Exp);
% set(temp,'string',newtext,'BackgroundColor',[1 .1 0],'ForegroundColor',[1 1 1]);
% cd(a);


function bBaseline_Callback(src,eventdata)
    %Do a baseline correction
    wBaselineCorrection;
    fCheckData;

function bDetectBeats_Callback(src,eventdata)
    wDetectBeats;
        
function UpdateMenu_Callback(src,eventdata)
    %Updates the main figure
    fCheckData;

function bActivationAnalysis_Callback(src,eventdata)
    %Load up the Unemap figure and run the activation marking code
    fActivationTimeAnalysis;

function bSignalAnalysis_Callback(src, eventdata)
    %Look at beat(s)
    fSignalAnalysis;
    fCheckData;

function SaveData_Callback(src,eventdata)
    %Save the data file
    global Data;
    %Open a help dialog to explain the need to wait
    oHelp = helpdlg('Saving Data, please wait for this window to close itself','Saving Data');
    %Find the strDataText object to retrieve the UserData string
    oHandle = findobj('tag','strDataText');
    sLongFileName = get(oHandle,'UserData');
    %Save
    save(sLongFileName, 'Data');
    %Close the helpdialog
    close(oHelp);
    set(oHandle,'String','Data saved');