function varargout = Main(varargin)
% MAIN M-file for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 09-Mar-2012 13:43:07


gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename, 'gui_Singleton',  gui_Singleton, 'gui_OpeningFcn', @Main_OpeningFcn, 'gui_OutputFcn',  @Main_OutputFcn, 'gui_LayoutFcn',  [] , 'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

addpath(genpath('D:/Users/jash042/Documents/PhD/Analysis/'));

% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function ePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ePath_Callback(hObject, eventdata, handles)
% hObject    handle to ePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ePath as text
%        str2double(get(hObject,'String')) returns contents of ePath as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new ePath value
handles.metricdata.volume = volume;
guidata(hObject,handles)

% --- Executes on button press in bBaselineCorrection.
function bBaselineCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to bBaselineCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in bDetectBeats.
function bDetectBeats_Callback(hObject, eventdata, handles)
% hObject    handle to bDetectBeats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the bDetectBeats flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to bDetectBeats the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

handles.Experiment.Path = 'H:/Data/Database';

set(handles.ePath,  'String', handles.Experiment.Path);

% Update handles structure
guidata(handles.figure1, handles);


% --------------------------------------------------------------------
function oFileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oFileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function oOpenMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oOpenMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%This function opens a file dialog, loads a text file,
%(containing the signal) and plots the data
        
%Call built-in file dialog to select filename
[sDataFileName,sDataPathName]=uigetfile('*.mat','Select .mat containing a Data structured array');
%[sExpFileName,sExpPathName]=uigetfile('*.mat','Select .mat containing an Experiment structured array');
%Make sure the dialogs return char objects
% if (~ischar(sDataFileName) && ~ischar(sExpFileName))
%     return
% end

%Change the string on the datatext label
oHandle = findobj('tag','ePath');

%Get the full file name and save it to string attribute of oHandle
sLongDataFileName=strcat(sDataPathName,sDataFileName);
%sLongExpFileName=strcat(sExpPathName,sExpFileName);
set(oHandle,'String',sLongDataFileName);

%Load the selected file
datacursormode off
oPotentialModel = PotentialModel.LoadEntityFromFile(sLongDataFileName);

% load(sLongDataFileName);
% load(sLongExpFileName);
datacursormode on
%Check the data loaded and make appropriate buttons visible
%fCheckData;
set(oHandle,'string','Data Loaded','BackgroundColor',[1 0 0],'ForegroundColor',[1 1 1]);
    
    
% --------------------------------------------------------------------
function oSaveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oSaveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function oExitMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oExitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closereq;


% --------------------------------------------------------------------
function oViewMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oViewMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function oUpdateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to oUpdateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
