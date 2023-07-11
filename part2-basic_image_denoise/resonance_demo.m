clear
clc
close all;


addpath([pwd,'\main']); % add custom functions to the path
basefolder = pwd;
foldername = [pwd, '\demo_data']; % define the data folder

[filename, foldername] = uigetfile({fullfile(foldername, '*.tiff;*.tif')}, 'Pick a image linescan file');
[filename_meta, ~] = uigetfile({fullfile(foldername, '*.xml;*.xml')}, 'Pick a metadata file');
img = loadtiff(fullfile(foldername, filename)); % load image
meta_data = parseXML(fullfile(foldername, filename_meta));  % load metadata
img = double(img);    % change from uint to double for filtering

%% filter
img_filt = kalman_stack_filter(img); % custom kalman filter
dt = str2num(meta_data.Children(4).Children(12).Attributes(2).Value);  
% read dwell time from metadata (s), might differ from image aquisition tools
fs = 1/dt; % sampling frequency (Hz)
t = dt*[0:(size(img, 3)-1)]; % time trace

%% auto-segmentation based on thresholding

[df, raw_f, A, Cn] = extract_raw_trace_video(img); % custom auto segementation based on thresholding of SD projection
figure, stackplot(t, df, 0.5), xlabel('Time [s]'); % plot the traces

%% save
[~,name,~] = fileparts(filename);
save(fullfile(foldername, sprintf('data_%s.mat', name)), 'df', 'A', 'Cn', 'raw_f', 't', 'dt');