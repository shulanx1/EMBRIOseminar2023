clear
clc
close all;


addpath([pwd,'\main']); % add custom functions to the path
basefolder = pwd;
foldername = [pwd, '\demo_data']; % data folder

[filename, foldername] = uigetfile({fullfile(foldername, '*.tiff;*.tif')}, 'Pick a image linescan file');
[filename_meta, ~] = uigetfile({fullfile(foldername, '*.xml;*.xml')}, 'Pick a metadata file');
[img,~] = imread(fullfile(foldername, filename)); % load image
meta_data = parseXML(fullfile(foldername, filename_meta));  % load metadata
img = double(img); % reformat data from uint to double for FFT

denoise_img = custom_fft(img); % custom FFT filter
denoise_img = imrotate(denoise_img,90); % rotate image in 90 degree 
img = imrotate(img,90); % rotate image in 90 degree 

dwell_time = str2num(meta_data.Children(4).Children(10).Attributes(2).Value)*1e-6;  % read dwell time from metadata (s)
% read dwell time from metadata (s), might differ from image aquisition tools
dt = dwell_time*size(img, 1);   % line rate (Hz)
t = dt*[0:(size(img, 2)-1)]; 

close all
figure(1), imshow(stretch(denoise_img)); % plot the denoised linescan file
title('denoised linescan')
%% extrace branch Ca signal
b_raw_f = extract_raw_trace(img, 'branch');
b_raw_df = extract_df(b_raw_f, dt);
b_raw_f_denoise = extract_raw_trace(denoise_img, 'branch');
b_raw_df_denoise = extract_df(b_raw_f_denoise, dt);
b_filt_df_denoise = sgolayfilt(b_raw_df_denoise,2,61);


figure(2), 
plot(t, b_raw_df, 'Color', [0.5,0.5,0.5])
hold on, plot(t, b_raw_df_denoise, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1)
hold on, plot(t, b_filt_df_denoise, 'r', 'LineWidth', 2)
legend('raw', 'denoised', 'filtered')
title('branch Ca signal')
xlabel('T [s]')
ylabel('dF/F [A.U.]')
xlim([min(t), max(t)])
%% extrace spine Ca signal
s_raw_f = extract_raw_trace(img, 'spine');
s_raw_df = extract_df(s_raw_f, dt);
s_raw_f_denoise = extract_raw_trace(denoise_img, 'spine');
s_raw_df_denoise = extract_df(s_raw_f_denoise, dt);
s_filt_df_denoise = sgolayfilt(s_raw_df_denoise,2,61);


figure(3), 
plot(t, s_raw_df, 'Color', [0.5,0.5,0.5])
hold on, plot(t, s_raw_df_denoise, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1)
hold on, plot(t, s_filt_df_denoise, 'r', 'LineWidth', 2)
legend('raw', 'denoised', 'filtered')
title('spine Ca signal')
xlabel('T [s]')
ylabel('dF/F [A.U.]')
xlim([min(t), max(t)])

%% save data
save_linescan;



