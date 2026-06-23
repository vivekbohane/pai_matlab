
clear;  clc;
% close all;

%% N Photons
cfg.nphoton = 1e9;              % 1 million photons

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
Nx = 512; Ny = 512; Nz = 384;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 8;

% 8 uniformly spaced X positions
xpos = round(linspace(20, Nx-thickness-20, 8));

% 6 uniformly spaced Z positions
zpos = round(linspace(20, Nz-thickness-20, 6));

%--------------------------------------------------
% 48 rods (8 × 6)
% Rods run along Y
% Zig-zag ordering in X as Z increases
%--------------------------------------------------

for kz = 1:6

    if mod(kz,2)==1
        xorder = 1:8;      % left -> right
    else
        xorder = 8:-1:1;   % right -> left
    end

    z = zpos(kz);

    for kx = 1:8

        x = xpos(xorder(kx));

        % Rod extends through entire Y dimension
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

%% Define the source
cfg.srctype = 'planar';

% cfg.srcpos ; cfg.srcdir ; cfg.srcparam1 ; cfg.srcparam2

cfg.srcpos    = [128 256 0];
cfg.srcparam1 = [256 0 0 0]; % x
cfg.srcparam2 = [0 1 0 0]; % y

cfg.srcdir    = [0 0 1];

%%
diary('mcx_04_log.txt');
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
save('mcx_04_workspace.mat','-regexp','^(?!fluence$).')

%% Visualize the results

% open Hlog in volume viewer
volumeViewer(Hlog);

% figure;
% imagesc(squeeze(H(:,57,:)));
% axis image;
% colormap(hot); colorbar;
