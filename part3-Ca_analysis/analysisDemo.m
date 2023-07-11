%% NNT Calcium Pipeline
%% (1) Setting up the environment 
set(0,'DefaultFigureWindowStyle','docked')
format compact;
addpath(genpath('scripts'));
%% (2) Visualize Segmented Data
figure('Name','Calcium Segmentation'),
plot_contours(A,C,ops,0);
%% (3) Visualize Calcium Transience
figure('Name','Single Calcium Transience'), plot(DeltaFoverF(1,:)); % Single trace
figure('Name','Population Transience'), stack_plot(DeltaFoverF,1,5,0); % All traces
figure('Name','Population Heatmap'),imagesc(DeltaFoverF),axis xy, colormap(hot),caxis([0 5])
%% Spike detection from dF/F
std_threshold = 3;     
static_threshold = .01;
Spikes = rasterizeDFoF(DeltaFoverF,std_threshold,static_threshold);
figure('Name','Spiking Raster');Show_Spikes(Spikes);
%% Calculate coactivity across binary matrix (2 different ways)
popCoactivity = sum(Spikes,1)/size(Spikes,1); % No binning
[coactivityIndex,detectedSpikes] = coactive_index(Spikes,ceil(size(Spikes,2)/2)); %With binning
figure('Name','Coactivity (no binning)'),bar(popCoactivity)
figure('Name', 'Coactivity (binning)'),bar(coactivityIndex)
%% Compute Sorenson-dice Correlation
pks = 1;
col = find(sum(Spikes(:,1:2000,1))>pks); % To save computation time
coSpikes = Spikes(:,col);
corr = correlation_dice(coSpikes);
figure('Name','Similarity'),imagesc(corr),colormap("jet");caxis([0 1]),colorbar
% Plot non-zero correlation 
figure('Name','Similarity'),histogram(corr(corr>0),'Normalization','probability'),xlabel('Similar`ity Index'),ylabel('Probability')
%% (4) Representing the data
% Mean similarity
% Connectivity
% Event related calcium fluorescence
Connected_ROI = Connectivity_dice(corr);

figure('Name','Network Map'); NodeSize = 5;EdgeSize = 1;Cell_Map_Dice(AverageImage,Connected_ROI,ROI,NodeSize,EdgeSize)
%% (5) Graph Theory Analysis
% Number of edges formed 
numEdges = size(Connected_ROI,1);
% list of all nodes (neurons) that formed at least one connection
nodeList = vertcat(Connected_ROI(:,1),Connected_ROI(:,2));
[nodeList,~,ix] = unique(nodeList);
% Find which neuron has the most connection
nodeList(:,2) = accumarray(ix,1);

