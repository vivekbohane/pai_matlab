
clear; close all; clc;

%% N Photons
cfg.nphoton = 1e8;              % 1 million photons

%% Define Volume
Nx = 256; Ny = 256; Nz = 256+2;
cfg.unitinmm = 0.1; % 0.1mm voxel dimention

vol = uint8(ones(Nx,Ny,Nz));

vol(30:34,20:70,25:28)   = 2;
vol(40:43,40:62,50:53)   = 2;
vol(60:63,60:85,75:78)   = 2;
vol(80:83,55:90,95:100)   = 2;
% vol(95:98, 94:98,20:80)   = 2;

vol(:,:,1:5) = 0; % For realism, reserve a few voxels at the top as air. keeping 5 voxels as air

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


% 3D Plot
% voxelPlot(double(vol));

%% See the specific cross section
% figure;
% imagesc(squeeze(vol(:,45,:))');
% axis image;
% colormap(gray);
% colorbar;

%% Define the source
cfg.srctype = 'planar';

% cfg.srcpos
% cfg.srcdir
% cfg.srcparam1
% cfg.srcparam2

cfg.srcpos    = [20 63 1];

cfg.srcparam1 = [80 0 0 0];
cfg.srcparam2 = [0 2 0 0];

cfg.srcdir    = [0 0 1];

%%
cfg.tstart = 0;
cfg.tstep  = 1e-10;
cfg.tend   = 1e-8;
%%
tic
fluence = mcxlab(cfg);
tac

cwfluence = sum(fluence.data,4);
log_cwf = log10(cwfluence);
