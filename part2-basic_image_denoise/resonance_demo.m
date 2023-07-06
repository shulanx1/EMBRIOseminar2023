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

img_filt = kalman_stack_filter(img);
dt = str2num(meta_data.Children(4).Children(12).Attributes(2).Value);  % read dwell time from metadata (s)
fs = 1/dt;
t = dt*[0:(size(img, 3)-1)];


%% auto-segmentation based on thresholding

[df, raw_f, A, Cn] = extract_raw_trace_video(img);
figure, stackplot(t, df, 0.5), xlabel('Time [s]')

%% save
[~,name,~] = fileparts(filename);
save(fullfile(foldername, sprintf('data_%s.mat', name)), 'df', 'A', 'Cn', 'raw_f', 't', 'dt');