
clear; close all; clc;

%% N Photons
cfg.nphoton = 1e6;              % 1 million photons

%% Define Volume
Nx = 256; Ny = 256; Nz = 256+2;
cfg.unitinmm = 0.1; % 0.1mm voxel dimention

vol = uint8(ones(Nx,Ny,Nz));

vol(30:33,10:246,25:28)   = 2;
vol(50:53,10:246,50:53)   = 2;
vol(80:83,10:246,75:78)   = 2;
vol(100:103,10:246,95:98)   = 2;
vol(150:153,10:246,140:143)   = 2;
vol(190:193,10:246,190:193)   = 2;
vol(230:233,10:246,230:233)   = 2;

vol(:,:,1:2) = 0; % For realism, reserve a few voxels at the top as air. keeping 5 voxels as air

cfg.vol = vol;

% 0 = air
% 1 = soft tissue
% 2 = blood vessel

% Optical Properties : 
% The exact values depend on wavelength. 
% A commonly used photoacoustic wavelength is around 800 nm because it lies in the biological optical window.

% Define Properties

% mua = absorption coefficient (mm⁻¹)
% mus = scattering coefficient (mm⁻¹)
% g = anisotropy
% n = refractive index

cfg.prop = [
    0      0      1.00   1.00   % label 0 air
    0.01   10     0.90   1.37   % label 1 soft tissue
    0.40   15     0.98   1.40   % label 2 blood
];

cfg.isreflect = 1; % Enable Fresnel reflection
cfg.isspecular = 1; 

cfg.outputtype = 'energy';

% 3D Plot
voxelPlot(double(vol));

%% See the specific cross section
% figure;
% imagesc(squeeze(vol(:,64,:))');
% axis image;
% colormap(gray);
% colorbar;

%% Define the source
cfg.srctype = 'planar';

% cfg.srcpos
% cfg.srcdir
% cfg.srcparam1
% cfg.srcparam2

cfg.srcpos    = [64 128 1];
cfg.srcparam1 = [128 0 0 0]; % x
cfg.srcparam2 = [0 1 0 0]; % y

cfg.srcdir    = [0 0 1];

%% Time
%% Time
cfg.tstart = 0;
cfg.tstep  = 1e-9;
cfg.tend   = 1e-9;

%%
diary('mcx_01_log.txt');
tic
fluence = mcxlab(cfg);
toc
diary off;

% Absorbed optical energy density
H = squeeze(fluence.data);

% Log visualization
Hlog = log10(H + 1e-12);

% save the complete workspace variables to a .mat file
save('mcx_01_workspace.mat');

%% Visualize the results
figure;
imagesc(squeeze(H(:,128,:))');
axis image;
colormap(hot);
