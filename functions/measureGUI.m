function varargout = measureGUI(varargin)
% MEASUREGUI MATLAB code for measureGUI.fig
%      MEASUREGUI, by itself, creates a new MEASUREGUI or raises the existing
%      singleton*.
%
%      H = MEASUREGUI returns the handle to a new MEASUREGUI or the handle to
%      the existing singleton*.
%
%      MEASUREGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEASUREGUI.M with the given input arguments.
%
%      MEASUREGUI('Property','Value',...) creates a new MEASUREGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before measureGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to measureGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help measureGUI

% Last Modified by GUIDE v2.5 25-May-2018 12:07:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @measureGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @measureGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before measureGUI is made visible.
function measureGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to measureGUI (see VARARGIN)

% Choose default command line output for measureGUI
handles.output = hObject;
handles.image = varargin{1};
handles.image_handle = imshow(handles.image);
handles.x = size(handles.image, 1);
handles.y = size(handles.image, 2);
handles.length = imdistline(gca, [0.1*handles.x, 0.1*handles.x], [0.1*handles.y, 0.8*handles.y]);
handles.diameter = imdistline(gca, [0.8*handles.x, 0.8*handles.x], [0.1*handles.y, 0.8*handles.y] );

fcn = makeConstrainToRectFcn('imline',...
                              get(gca,'XLim'),get(gca,'YLim'));
setLabelTextFormatter(handles.length, 'length = %02.0f px');
setLabelTextFormatter(handles.diameter, 'diameter = %02.0f px');
setDragConstraintFcn(handles.length, fcn);
setDragConstraintFcn(handles.diameter, fcn);
setColor(handles.diameter, 'green');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes measureGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = measureGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles.length.getDistance();
varargout{3} = handles.diameter.getDistance();
delete(handles.figure1);


% --- Executes on button press in pushbutton_enter.
function pushbutton_enter_Callback(hObject, eventdata, handles)
uiresume();
% hObject    handle to pushbutton_enter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
