
clear;  clc;
% close all;

%% N Photons
cfg.nphoton = 1e8;              % 1 million photons

cfg.isreflect = 1; % Accounts for reflection/refraction at all material boundaries
cfg.isspecular = 1; % Accounts for specular reflection at the surface (Fresnel reflection)
cfg.outputtype = 'energy'; % Output type can be 'fluence', 'energy', or 'pathlength'.
%  Here, we choose 'energy' to get the absorbed optical energy density.

% Time
cfg.tstart = 0;
cfg.tend   = 1e-8;
cfg.tstep  = cfg.tend;

% Optical Properties : 
% The exact values depend on wavelength. 
% A commonly used photoacoustic wavelength is around 800 nm because it lies in the biological optical window.

% Define Properties : 
% mua = absorption coefficient (mm⁻¹)
% mus = scattering coefficient (mm⁻¹)
% g = anisotropy
% n = refractive index

cfg.prop = [
    0      0      1.00   1.00   % label 0 air
    0.01   10     0.90   1.37   % label 1 soft tissue
    0.40   15     0.95   1.40   % label 2 blood vessel
];

%% Define Volume
Nx = 256; Ny = 256; Nz = 256;
cfg.unitinmm = 0.1; % 0.1mm voxel dimention

vol = uint8(ones(Nx,Ny,Nz));

%-------------------------------------------------
% vol(30:33,10:246,25:28)   = 2;
% vol(50:53,10:246,50:53)   = 2;
% vol(80:83,10:246,75:78)   = 2;
% vol(100:103,10:246,95:98)   = 2;
% vol(150:153,10:246,140:143)   = 2;
% vol(190:193,10:246,190:193)   = 2;
% vol(230:233,10:246,230:233)   = 2;
% vol(10:246,40:43,35:38)   = 2;
% vol(10:246,90:93,90:93)   = 2;
% vol(10:246,140:143,135:138)   = 2;
% vol(10:246,240:243,235:238)   = 2;
%-------------------------------------------------

% Vessel thickness
thickness = 4;

% 8 uniformly spaced z-levels
zpos = round(linspace(25,230,8));

% 8 uniformly spaced x positions
xpos = round(linspace(20,236,8));

% 8 uniformly spaced y positions
ypos = round(linspace(20,236,8));

% Bars parallel to Y direction
for k = 1:8
    vol(xpos(k):xpos(k)+thickness-1, ...
        10:246, ...
        zpos(k):zpos(k)+thickness-1) = 2;
end

% Bars parallel to X direction
for k = 1:8
    vol(10:246, ...
        ypos(k):ypos(k)+thickness-1, ...
        zpos(k):zpos(k)+thickness-1) = 2;
end
%-------------------------------------------------

cfg.vol = vol;
% 3D Plot
voxelPlot(double(vol));


%% See the specific cross section
% figure;
% imagesc(squeeze(vol(:,128,:)));
% axis image; colormap(gray); colorbar;

%% Define the source
cfg.srctype = 'planar';

% cfg.srcpos ; cfg.srcdir ; cfg.srcparam1 ; cfg.srcparam2

cfg.srcpos    = [64 128 0];
cfg.srcparam1 = [128 0 0 0]; % x
cfg.srcparam2 = [0 1 0 0]; % y

cfg.srcdir    = [0 0 1];

%%
% diary('mcx_02_log.txt');
tic
fluence = mcxlab(cfg);
toc
% diary off;

% Absorbed optical energy density
H = fluence.data;
fluence_stat = fluence.stat;

% Log visualization
Hlog = log10(H + 1e-12);

fprintf('Absorbed fraction = %.3f\n',sum(H(:)));

% save the complete workspace variables to a .mat file (except fluence)
% save('mcx_02_workspace.mat','-regexp','^(?!fluence$).')

%% Visualize the results

% % open Hlog in volume viewer
% volumeViewer(Hlog);

% figure;
imagesc(squeeze(H(64+127,124:132,1:10)));
axis image;
colormap(hot); colorbar;
