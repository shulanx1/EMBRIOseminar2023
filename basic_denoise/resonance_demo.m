clear
clc
close all;


addpath([pwd,'\main']);
addpath([pwd,'\oasis']);
addpath([pwd,'\deconv_func']);
basefolder = pwd;
foldername = [pwd, '\demo_data'];

[filename, foldername] = uigetfile({fullfile(foldername, '*.tiff;*.tif')}, 'Pick a image linescan file');
[filename_meta, ~] = uigetfile({fullfile(foldername, '*.xml;*.xml')}, 'Pick a metadata file');
img = loadtiff(fullfile(foldername, filename)); % load image
meta_data = parseXML(fullfile(foldername, filename_meta));  % load metadata
img = double(img);    % change from uint to double for filtering

disp('')
img_filt = kalman_stack_filter(img);
dt = str2num(meta_data.Children(4).Children(12).Attributes(2).Value);  % read dwell time from metadata (s)
fs = 1/dt;
t = dt*[0:(size(img, 3)-1)];
%% manually extract ROI
N = inputdlg({'number of ROIs:'});
N_ROI = str2num(N{1});

[raw_f, A, Cn] = extract_raw_trace_video(img,N_ROI);
df = extract_df_video(raw_f);

figure, stackplot(t, df);

%% save
save(fullfile(foldername, sprintf('data%s', filename(1:end-3))), 'df', 'A', 'Cn', 'raw_f', 't', 'dt');