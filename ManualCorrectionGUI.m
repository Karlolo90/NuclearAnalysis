function varargout = ManualCorrectionGUI(varargin)
% MANUALCORRECTIONGUI MATLAB code for ManualCorrectionGUI.fig
%      MANUALCORRECTIONGUI, by itself, creates a new MANUALCORRECTIONGUI or raises the existing
%      singleton*.
%
%      H = MANUALCORRECTIONGUI returns the handle to a new MANUALCORRECTIONGUI or the handle to
%      the existing singleton*.
%
%      MANUALCORRECTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALCORRECTIONGUI.M with the given input arguments.
%
%      MANUALCORRECTIONGUI('Property','Value',...) creates a new MANUALCORRECTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ManualCorrectionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ManualCorrectionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ManualCorrectionGUI

% Last Modified by GUIDE v2.5 27-Sep-2019 14:41:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ManualCorrectionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ManualCorrectionGUI_OutputFcn, ...
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
end

% --- Executes just before ManualCorrectionGUI is made visible.
function ManualCorrectionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManualCorrectionGUI (see VARARGIN)

% Choose default command line output for ManualCorrectionGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0, 'hManualCorrectionGUI'   , gca);
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');

ResSpheroid = varargin{1};
%ResSpheroid = evalin('base', 'ResSpheroid');
setappdata(hManualCorrectionGUI, 'numClusters',      length(ResSpheroid.labelsForManualInspection))
setappdata(hManualCorrectionGUI, 'currentCluster',   1)
setappdata(hManualCorrectionGUI, 'numCell',          [])
setappdata(hManualCorrectionGUI, 'numAllCluster',    [])
setappdata(hManualCorrectionGUI, 'numSpheroids',     1)
setappdata(hManualCorrectionGUI, 'currentSlice',     1)
setappdata(hManualCorrectionGUI, 'ResSpheroid',      ResSpheroid);
setappdata(hManualCorrectionGUI, 'clusterLabels',    ResSpheroid.labelsForManualInspection)
setappdata(hManualCorrectionGUI, 'topSlice',         size(ResSpheroid.waterShed,3))
setappdata(hManualCorrectionGUI, 'showCircle',       0)
setappdata(hManualCorrectionGUI, 'circleRadius',     5)
setappdata(hManualCorrectionGUI, 'sphereMask',       logical(zeros(size(ResSpheroid.waterShed))))
setappdata(hManualCorrectionGUI, 'imageSize',        size(ResSpheroid.waterShed))

set(handles.slider1, 'Value', 1)
set(handles.slider1, 'Min',   1)
set(handles.slider1, 'Max',   size(ResSpheroid.waterShed,3))

set(gcf, 'PointerShapeHotSpot', [16 16]);

hCountAxes    = findobj('Tag', 'countImage');
axes(hCountAxes)
set(hCountAxes, 'ButtonDownFcn', @Count_Axes_ButtonDownFcn);
setappdata(hManualCorrectionGUI, 'hCountAxes', hCountAxes);

hNumClusterToCount = findobj('Tag', 'NumClusters');
set(hNumClusterToCount, 'string', length(ResSpheroid.labelsForManualInspection));

updateText()
updateCluster(0)
hImage = imshow(zeros(512,512));
set(hImage, 'ButtonDownFcn', @Count_Axes_ButtonDownFcn);
setappdata(hManualCorrectionGUI, 'hImage', hImage);

updateImage()

% UIWAIT makes ManualCorrectionGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = ManualCorrectionGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end
% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hManualCorrectionGUI = getappdata(0,'hManualCorrectionGUI');
currentCluster       = getappdata(hManualCorrectionGUI, 'currentCluster');
numAllCluster        = getappdata(hManualCorrectionGUI, 'numAllCluster');
clusterLabels        = getappdata(hManualCorrectionGUI, 'clusterLabels');
numCell              = getappdata(hManualCorrectionGUI, 'numCell');
imageSize            = getappdata(hManualCorrectionGUI, 'imageSize');
label                = ones(size(numCell, 1),1).*clusterLabels(currentCluster);
newEntry             = [label numCell];
numAllCluster        = [numAllCluster; newEntry];

if currentCluster < length(clusterLabels)
    setappdata(hManualCorrectionGUI, 'numCell', [])
    setappdata(hManualCorrectionGUI, 'numAllCluster',  numAllCluster)
    setappdata(hManualCorrectionGUI, 'currentCluster', currentCluster + 1)
    setappdata(hManualCorrectionGUI, 'sphereMask',     logical(zeros(imageSize)));
    updateCluster(1)
    updateImage()
    updateText()
else
    setappdata(hManualCorrectionGUI, 'numAllCluster', numAllCluster)
    ResSpheroid = getappdata(hManualCorrectionGUI, 'ResSpheroid');
    ResSpheroid.pixelsBigClusters = numAllCluster;
    ResSpheroid.manuallyControlled = 1;
    choice = questdlg('Done correcting?', 'ARE YOU DONE?!?!?', 'Yes, export my stuff', 'Not done yet', 'Yes, export my stuff');
    switch choice
        case 'Yes, export my stuff'
            ResSpheroid = getappdata(hManualCorrectionGUI, 'ResSpheroid');
            %ResSpheroid.pixelsBigClusters = numAllCluster;
            %ResSpheroid.manuallyControlled = 1;
            assignin('base', 'correctedPixels', numAllCluster);
            %vargout{1} = numAllCluster;
        case 'Not done yet'
    end
end
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

hManualCorrectionGUI = getappdata(0,'hManualCorrectionGUI');
setappdata(hManualCorrectionGUI,'currentSlice',round(get(hObject,'Value')));



updateImage();

end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hManualCorrectionGUI = getappdata(0,'hManualCorrectionGUI');
currentCluster       = getappdata(hManualCorrectionGUI, 'currentCluster');
numAllCluster        = getappdata(hManualCorrectionGUI, 'numAllCluster');
clusterLabels        = getappdata(hManualCorrectionGUI, 'clusterLabels');
imageSize            = getappdata(hManualCorrectionGUI, 'imageSize');
if currentCluster > 1
    label                = clusterLabels(currentCluster-1);
    deleteEntry          = find(numAllCluster(:,1) == label);
    
    numAllCluster(deleteEntry,:) = [];

    setappdata(hManualCorrectionGUI, 'numCell', [])
    setappdata(hManualCorrectionGUI, 'numAllCluster', numAllCluster)
    setappdata(hManualCorrectionGUI, 'currentCluster', currentCluster - 1)
    setappdata(hManualCorrectionGUI, 'sphereMask',     logical(zeros(imageSize)));
    
    updateCluster(1)
    updateImage()
    updateText()
else 
   msgbox('Not possible to correct what does not exist') 
end
end

% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hManualCorrectionGUI = getappdata(0,'hManualCorrectionGUI');
imageSize            = getappdata(hManualCorrectionGUI, 'imageSize');
setappdata(hManualCorrectionGUI, 'numCell',    [])
setappdata(hManualCorrectionGUI, 'sphereMask', logical(zeros(imageSize)));
updateText()
end

function numClusters_Callback(hObject, eventdata, handles)
% hObject    handle to numClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numClusters as text
%        str2double(get(hObject,'String')) returns contents of numClusters as a double
end

% --- Executes during object creation, after setting all properties.
function numClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function countedClusters_Callback(hObject, eventdata, handles)
% hObject    handle to countedClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of countedClusters as text
%        str2double(get(hObject,'String')) returns contents of countedClusters as a double
end

% --- Executes during object creation, after setting all properties.
function countedClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to countedClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function numCells_Callback(hObject, eventdata, handles)
% hObject    handle to numCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numCells as text
%        str2double(get(hObject,'String')) returns contents of numCells as a double
end

% --- Executes during object creation, after setting all properties.
function numCells_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function numberOfSpheroids_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfSpheroids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfSpheroids as text
%        str2double(get(hObject,'String')) returns contents of numberOfSpheroids as a double
end

% --- Executes during object creation, after setting all properties.
function numberOfSpheroids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfSpheroids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end




% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
hManualCorrectionGUI = getappdata(0,                    'hManualCorrectionGUI');
currentSlice         = getappdata(hManualCorrectionGUI, 'currentSlice');
topSlice             = getappdata(hManualCorrectionGUI, 'topSlice');
if eventdata.VerticalScrollCount > 0 && currentSlice+3 < topSlice
    set(handles.slider1,             'Value',        currentSlice+3)
    setappdata(hManualCorrectionGUI, 'currentSlice', currentSlice +3)
elseif eventdata.VerticalScrollCount < 0 && currentSlice-3 > 1
    set(handles.slider1,             'Value',        currentSlice -3)
    setappdata(hManualCorrectionGUI, 'currentSlice', currentSlice -3)
else
   
end
updateImage()
end
    


% --- Executes on slider movement.
function circleRadiusSlider_Callback(hObject, eventdata, handles)
% hObject    handle to circleRadiusSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
hManualCorrectionGUI = getappdata(0,'hManualCorrectionGUI');
set(hObject, 'Value', round(get(hObject,'Value')))
setappdata(hManualCorrectionGUI,'circleRadius',round(get(hObject,'Value')));

updateText()
updatePointer()
end

% --- Executes during object creation, after setting all properties.
function circleRadiusSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to circleRadiusSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on button press in showCircle.
function showCircle_Callback(hObject, eventdata, handles)
% hObject    handle to showCircle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showCircle
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');

setappdata(hManualCorrectionGUI, 'showCircles', get(hObject,'Value'))

updatePointer();
end


function circleRadiusText_Callback(hObject, eventdata, handles)
% hObject    handle to circleRadiusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of circleRadiusText as text
%        str2double(get(hObject,'String')) returns contents of circleRadiusText as a double


end

% --- Executes during object creation, after setting all properties.
function circleRadiusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to circleRadiusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on mouse press over axes background.
function Count_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Count_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');
numCell              = getappdata(hManualCorrectionGUI, 'numCell');
currentSlice         = getappdata(hManualCorrectionGUI, 'currentSlice');
sphereMask           = getappdata(hManualCorrectionGUI, 'sphereMask');
circleRadius         = getappdata(hManualCorrectionGUI, 'circleRadius');

hCountAxes           = get(hObject   , 'Parent');
cellCoordinates      = get(hCountAxes, 'CurrentPoint');
cellCoordinates      = round(cellCoordinates(1,1:2));
numCell              = [numCell; [cellCoordinates currentSlice circleRadius]];

sphere               = strel('sphere', circleRadius);
xSpace               = (cellCoordinates(2)-circleRadius):1:(cellCoordinates(2)+circleRadius);
ySpace               = (cellCoordinates(1)-circleRadius):1:(cellCoordinates(1)+circleRadius);
zSpace               = (currentSlice-circleRadius):1:(currentSlice+circleRadius);
sphereMask(xSpace,ySpace,zSpace) = logical(sphere.Neighborhood);

setappdata(hManualCorrectionGUI, 'sphereMask', sphereMask)
setappdata(hManualCorrectionGUI, 'numCell', numCell);

assignin('base', 'sphereMask', sphereMask);

updateCluster(0)
updateText()
updateImage()
end

function updateText()
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');
clusterLabels        = getappdata(hManualCorrectionGUI, 'clusterLabels');
currentCluster       = getappdata(hManualCorrectionGUI, 'currentCluster');
numCells             = getappdata(hManualCorrectionGUI, 'numCell');
numClusters          = getappdata(hManualCorrectionGUI, 'numClusters');
numSpheroids         = getappdata(hManualCorrectionGUI, 'numSpheroids');
circleRadius         = getappdata(hManualCorrectionGUI, 'circleRadius');
hCurrent             = findobj('Tag', 'numCells');
hCountedCluster      = findobj('Tag', 'countedClusters');
hNumClusters         = findobj('Tag', 'numClusters');
hNumSpheroids        = findobj('Tag', 'numberOfSpheroids'); 
hCircleRadiusText    = findobj('Tag', 'circleRadiusText');
hCurrentIndexText    = findobj('Tag', 'currentIndex');

if isempty(numCells)
    set(hCurrent, 'string', 0)
else
    set(hCurrent, 'string', size(numCells, 1))
end
set(hCountedCluster, 'string', currentCluster-1)
set(hNumClusters, 'string', numClusters)
set(hNumSpheroids , 'string', numSpheroids)
set(hCircleRadiusText, 'string', circleRadius)
set(hCurrentIndexText, 'string', clusterLabels(currentCluster))

end

function updateImage()
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');
hImage               = getappdata(hManualCorrectionGUI, 'hImage');
currentClusterImage  = getappdata(hManualCorrectionGUI, 'currentClusterImage');
currentSlice         = getappdata(hManualCorrectionGUI, 'currentSlice');

set(hImage, 'CData', currentClusterImage(:,:,currentSlice));
end

function updateCluster(changeSlice)
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');
ResSpheroid          = getappdata(hManualCorrectionGUI, 'ResSpheroid');
currentCluster       = getappdata(hManualCorrectionGUI, 'currentCluster');
sphereMask           = getappdata(hManualCorrectionGUI, 'sphereMask');

clusterIndex         = ResSpheroid.labelsForManualInspection(currentCluster);
maskCurrentCluster   = ResSpheroid.waterShed == clusterIndex;
imageCurrentCluster  = maskCurrentCluster.*ResSpheroid.interpolatedImage;
imageCurrentCluster(sphereMask) = 1;
if changeSlice == 1
    nonZeroZAxis         = sum(sum(imageCurrentCluster));
    nonZeroZAxis         = find(nonZeroZAxis);
    midZ                 = nonZeroZAxis(round(length(nonZeroZAxis)/2));
    setappdata(hManualCorrectionGUI, 'currentSlice', midZ)
end
setappdata(hManualCorrectionGUI, 'currentClusterImage', imageCurrentCluster)
end

function updatePointer()
hManualCorrectionGUI = getappdata(0, 'hManualCorrectionGUI');
showCircles          = getappdata(hManualCorrectionGUI, 'showCirlcle');
circleRadius         = getappdata(hManualCorrectionGUI, 'circleRadius');
if showCircles == 0
    set(hManualCorrectionGUI, 'Pointer', 'arrow')
else
    pointerDisk = strel('disk', circleRadius);
    pointerDisk = pointerDisk.Neighborhood;
    pointerDisk = padarray(pointerDisk, [16-circleRadius 16-circleRadius]);
    pointerDisk = [pointerDisk zeros(1,31)'; zeros(1,32)];
    pointerDisk(pointerDisk == 1) = 2;
    pointerDisk(pointerDisk == 0) = NaN;
    set(gcf, 'PointerShapeCData', pointerDisk)
    set(gcf, 'Pointer', 'custom')
    
end


end



function currentIndex_Callback(hObject, eventdata, handles)
% hObject    handle to currentIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of currentIndex as text
%        str2double(get(hObject,'String')) returns contents of currentIndex as a double
end

% --- Executes during object creation, after setting all properties.
function currentIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to currentIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end