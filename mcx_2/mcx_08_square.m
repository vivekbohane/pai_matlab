
clear;  clc;
% close all;

%% N Photons
cfg.nphoton = 1e8;              % 1 million photons

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

Nx = 384-12; Ny = 512-12; Nz = 512-12;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 12;      % Diameter of the cylinder
radius = thickness / 2;

% 5 uniformly spaced X positions
xpos = round(linspace(40, Nx-thickness-40, 5));

% 5 uniformly spaced Y positions (shifted from Z)
ypos = round(linspace(30, Ny-thickness-30, 5));

% --- Create a 3D Cylindrical Mask ---
% 1. Create a 2D local grid for the cross-section (now in X-Y plane)
[xx, yy] = ndgrid(1:thickness, 1:thickness);
xc = radius + 0.5; % X center
yc = radius + 0.5; % Y center

% 2. Create the 2D circular mask using the circle equation: (x-xc)^2 + (y-yc)^2 <= r^2
circle_mask_2D = ((xx - xc).^2 + (yy - yc).^2) <= radius^2;

% 3. Expand the 2D mask into a 3D cylinder that stretches across the entire Z axis
% Reshape to [thickness in X, thickness in Y, 1 in Z]
circle_mask_3D = reshape(circle_mask_2D, [thickness, thickness, 1]);
% Repeat along the Z axis
circle_mask_3D = repmat(circle_mask_3D, [1, 1, Nz]);
% -------------------------------------

%--------------------------------------------------
% 25 rods (5 × 5) -> Circular Cylinders
% Rods run along Z
% Zig-zag ordering in X as Y increases
%--------------------------------------------------

for ky = 1:5
    
    if mod(ky,2) == 1
        xorder = 1:5;      % left -> right
    else
        xorder = 5:-1:1;   % right -> left
    end
    
    y = ypos(ky);
    
    for kx = 1:5
        
        x = xpos(xorder(kx));
        
        % Define the bounding box indices for this specific rod
        x_idx = x : x+thickness-1;
        y_idx = y : y+thickness-1;
        
        % Extract the current background subvolume (grabbing all Z slices)
        sub_vol = vol(x_idx, y_idx, :);
        
        % Apply the blood material (2) only where the cylindrical mask is true
        sub_vol(circle_mask_3D) = 2;
        
        % Place the updated subvolume back into the main volume
        vol(x_idx, y_idx, :) = sub_vol;
        
    end
end

cfg.vol = vol;

% 3D Plot
% voxelPlot(double(vol));
% volshow(vol);

% figure;
% imagesc(squeeze(vol(:,:,1)));
% axis image;
% colormap(hot); colorbar;

%% Define the source
cfg.srctype = 'planar';

% Bottom-left corner of the square on the x = 0 face
cfg.srcpos = [0 58 58];
% First edge: 384 voxels along Y
cfg.srcparam1 = [0 384 0 0];
% Second edge: 384 voxels along Z
cfg.srcparam2 = [0 0 384 0];
% Propagate along +X
cfg.srcdir = [1 0 0];

%%
diary('mcx_08_square_log.txt');
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
save('mcx_08_square_workspace.mat','-regexp','^(?!fluence$).')

%% Visualize the results

% open Hlog in volume viewer
% volumeViewer(H);
% 
% figure;
% imagesc(squeeze(H(:,250,:)));
% axis image;
% colormap(hot); colorbar;
