
clear;  clc;
% close all;

%% N Photons
cfg.nphoton = 1e7;              % 1 million photons
cfg.unitinmm = 0.1; % 0.1mm voxel dimention

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

% --- Oxygenated blood (SO2 > 98%, e.g. arterial) ---
cfg.prop = [
%   mua      mus       g         n
    0.0000,  0.000,  1.0000,   1.000;  % 0: air
    0.0100,  10.000,  0.9000,   1.370;  % 1: soft tissue
    0.3800,  76.730,   0.9833,   1.380;  % 2: blood (arterial, compiled)
];

%% Define Volume
Nx = 256; Ny = 256; Nz = 256;

vol = uint8(ones(Nx,Ny,Nz));

% Vessel thickness
thickness = 4;

% 8 uniformly spaced X and Z positions
xpos = round(linspace(20,236,8));
zpos = round(linspace(20,236,8));

%--------------------------------------------------
% Create 64 rods running along Y
% Zig-zag arrangement in X as Z increases
%--------------------------------------------------

for kz = 1:8

    % Alternate X ordering for each Z plane
    if mod(kz,2)==1
        xorder = 1:8;      % left -> right
    else
        xorder = 8:-1:1;   % right -> left
    end

    z = zpos(kz);

    for kx = 1:8

        x = xpos(xorder(kx));

        % Rod extending through entire Y dimension
        vol( ...
            x:x+thickness-1, ...
            :, ...
            z:z+thickness-1) = 2;

    end
end

cfg.vol = vol;

% 3D Plot
% voxelPlot(double(vol));
% volshow(vol);

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
diary('mcx_03_log.txt');
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
save('mcx_03_workspace.mat','-regexp','^(?!fluence$).')

%% Visualize the results

% open Hlog in volume viewer
volumeViewer(Hlog);

% figure;
imagesc(squeeze(H(:,124,:)));
axis image;
colormap(hot); colorbar;
