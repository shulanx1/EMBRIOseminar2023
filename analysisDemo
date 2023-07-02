%% NNT Calcium Pipeline
%% (1) Setting up the environment 
set(0,'DefaultFigureWindowStyle','normal')
format compact;
addpath(genpath('main'));
addpath(genpath('Pipelines'))
addpath(genpath('Plotting'))

%% (2) Visualize Segmented Data
figure('Name','Calcium Segmentation'),
plot_contours(A_throw,Cn,options,0)

%% (3) Visualize Calcium Transience
figure('Name','Single Calcium Transience'), plot(params.ts,DeltaFoverF(1,:)); % Single trace
figure('Name','Population Transience'), stack_plot(DeltaFoverF,3,1,params.caFR); % All traces
figure,imagesc(DeltaFoverF),axis xy, colormap(hot)
%% Spike detection from dF/F
std_threshold = 3;     
static_threshold = .01;
Spikes = rasterizeDFoF(DeltaFoverF,std_threshold,static_threshold);
figure('Name','Spiking Raster');Show_Spikes(Spikes);
%% define co-active frames
pks = 1;
col = find(sum(Spikes,1)>pks);
coSpikes = Spikes(col);
corr = correlation_dice(coSpikes);