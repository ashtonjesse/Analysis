function varargout = StartFigure(varargin)
% StartFigure M-file for StartFigure.fig
%      StartFigure, by itself, creates a new StartFigure or raises the existing
%      singleton*.
%
%      H = StartFigure returns the handle to a new StartFigure or the handle to
%      the existing singleton*.
%
%      StartFigure('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in StartFigure.M with the given input arguments.
%
%      StartFigure('Property','Value',...) creates a new StartFigure or raises
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

% Last Modified by GUIDE v2.5 13-Mar-2012 15:31:23


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

%initialize_gui(hObject, handles, false);

% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
% function initialize_gui(fig_handle, handles, isreset)
% % If the metricdata field is present and the bDetectBeats flag is false, it means
% % we are we are just re-initializing a GUI by calling it from the cmd line
% % while it is up. So, bail out as we dont want to bDetectBeats the data.
% if isfield(handles, 'metricdata') && ~isreset
%     return;
% end
% 
% set(handles.ePath,  'String', 'H:/Data/Database');
% 
% % Update handles structure
% guidata(handles.Figure1, handles);
% Put this in the control CrtFcn attribute: Main('ePath_CreateFcn',hObject,eventdata,guidata(hObject))
% --- Executes during object creation, after setting all properties.
% function ePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
