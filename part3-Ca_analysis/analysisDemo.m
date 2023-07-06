%% NNT Calcium Pipeline
%% (1) Setting up the environment 
set(0,'DefaultFigureWindowStyle','docked')
format compact;
addpath(genpath('main'));
addpath(genpath('Pipelines'))
addpath(genpath('Plotting'))
params.caFr = 30.48;
params.ts = 1/params.caFr:1/params.caFr:size(DeltaFoverF,2)/params.caFr;
%% (2) Visualize Segmented Data
figure('Name','Calcium Segmentation'),
plot_contours(A,C,ops,1);

%% (3) Visualize Calcium Transience
figure('Name','Single Calcium Transience'), plot(DeltaFoverF(115,:)); % Single trace
figure('Name','Population Transience'), stack_plot(DeltaFoverF,1,5,1); % All traces
figure,imagesc(DeltaFoverF),axis xy, colormap(hot)
%% Spike detection from dF/F
std_threshold = 3;     
static_threshold = .01;
Spikes = rasterizeDFoF(DeltaFoverF,std_threshold,static_threshold);
figure('Name','Spiking Raster');Show_Spikes(Spikes);xlim([400 500])
%% define co-active frames
popCoactivity = sum(Spikes,1)/size(Spikes,1);
[coactive_cells,detected_spikes] = coactive_index(Spikes,5000);
%% Compute Sorenson-dice Correlation
pks = 1;
col = find(sum(Spikes,1)>pks);
coSpikes = Spikes(:,col);
corr = correlation_dice(coSpikes);
%% (4) Representing the data
% Mean similarity
% Connectivity
% Event related calcium fluorescence
figure,imagesc(corr),colormap("hot");

