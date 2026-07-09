
clear;  clc;
% close all;

%% N Photons
cfg.nphoton = 1e6;              % 1 million photons

cfg.unitinmm = 0.1; % 0.1mm voxel dimention
cfg.isreflect = 1; cfg.isspecular = 1; cfg.outputtype = 'energy';
% Time
cfg.tstart = 0; cfg.tend   = 1e-7; cfg.tstep  = cfg.tend;
% --- Oxygenated blood (SO2 > 98%, e.g. arterial) ---
cfg.prop = [
%   mua      mus       g         n
    0.0000,  0.000,  1.0000,   1.000;  % 0: air
    0.0100,  10.000,  0.9000,   1.370;  % 1: soft tissue
    0.3800,  76.730,   0.9833,   1.380;  % 2: blood (arterial, compiled)
];


%% Define Volume

run('vol_type_01_54546.m');

% 3D Plot
% voxelPlot(double(vol));
% volshow(vol);

% figure;
% imagesc(squeeze(vol(:,:,1)));
% axis image;
% colormap(hot); colorbar;

%% Define the source
cfg.srctype = 'planar';
% cfg.srcpos ; cfg.srcdir ; cfg.srcparam1 ; cfg.srcparam2

% Starts at x=0, and centered on Y and Z
cfg.srcpos    = [0 58 248]; 
% Edge 1: Runs parallel to Z, length of 9
cfg.srcparam1 = [0 0 5 0];  
% Edge 2: Runs parallel to Y, length of 384
cfg.srcparam2 = [0 384 0 0]; 
% Fires straight into the volume along the X-axis
cfg.srcdir    = [1 0 0];

%%
run_name = "mcx_31_planarSlit";

diary(run_name + "_log.txt");
tic
fluence = mcxlab(cfg);
toc
diary off;

% Absorbed optical energy density
H = fluence.data;
fluence_stat = fluence.stat;

% Log visualization
Hlog = log10(H + 1e-12);

fprintf('Absorbed fraction = %.3f\n',sum(H(:)));

% save the complete workspace variables to a .mat file (except fluence)
save(run_name + "_workspace.mat", "-regexp", "^(?!fluence$).");

%% Visualize the results

% open Hlog in volume viewer
% volumeViewer(H);
% 
% figure;
% imagesc(squeeze(H(:,250,:)));
% axis image;
% colormap(hot); colorbar;
