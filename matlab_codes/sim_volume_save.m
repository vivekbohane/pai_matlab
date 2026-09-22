%% ============================================================
%  Make the 12 edges of a 3D volume have maximum fluence
% =============================================================
% clc; clearvars;
%%
% Original fluence volume
vol = H;

% -------------------------------------------------------------
% User-defined edge thickness
% -------------------------------------------------------------
edge_thick = 3;       % 1 = 1 voxel, 2 = 2x2, 3 = 3x3, etc.

% -------------------------------------------------------------
% Create adjusted volume
% -------------------------------------------------------------

vol_adj = vol;
% Maximum value in the original volume
max_val = max(vol(:))/1;

% max_val = mean(vol(:));
% max_val = 1;
% Get volume dimensions
[Nx, Ny, Nz] = size(vol);

% -------------------------------------------------------------
% X-direction edges
%
% At (Y,Z) = corners:
%   Y = 1       or Ny
%   Z = 1       or Nz
%
% Extend edge_thick voxels in Y and Z
% -------------------------------------------------------------

vol_adj( ...
    1:Nx, ...
    1:edge_thick, ...
    1:edge_thick) = max_val;

vol_adj( ...
    1:Nx, ...
    Ny-edge_thick+1:Ny, ...
    1:edge_thick) = max_val;

vol_adj( ...
    1:Nx, ...
    1:edge_thick, ...
    Nz-edge_thick+1:Nz) = max_val;

vol_adj( ...
    1:Nx, ...
    Ny-edge_thick+1:Ny, ...
    Nz-edge_thick+1:Nz) = max_val;


% -------------------------------------------------------------
% Y-direction edges
%
% At (X,Z) = corners:
%   X = 1       or Nx
%   Z = 1       or Nz
%
% Extend edge_thick voxels in X and Z
% -------------------------------------------------------------

vol_adj( ...
    1:edge_thick, ...
    1:Ny, ...
    1:edge_thick) = max_val;

vol_adj( ...
    Nx-edge_thick+1:Nx, ...
    1:Ny, ...
    1:edge_thick) = max_val;

vol_adj( ...
    1:edge_thick, ...
    1:Ny, ...
    Nz-edge_thick+1:Nz) = max_val;

vol_adj( ...
    Nx-edge_thick+1:Nx, ...
    1:Ny, ...
    Nz-edge_thick+1:Nz) = max_val;


% -------------------------------------------------------------
% Z-direction edges
%
% At (X,Y) = corners:
%   X = 1       or Nx
%   Y = 1       or Ny
%
% Extend edge_thick voxels in X and Y
% -------------------------------------------------------------

vol_adj( ...
    1:edge_thick, ...
    1:edge_thick, ...
    1:Nz) = max_val;

vol_adj( ...
    Nx-edge_thick+1:Nx, ...
    1:edge_thick, ...
    1:Nz) = max_val;

vol_adj( ...
    1:edge_thick, ...
    Ny-edge_thick+1:Ny, ...
    1:Nz) = max_val;

vol_adj( ...
    Nx-edge_thick+1:Nx, ...
    Ny-edge_thick+1:Ny, ...
    1:Nz) = max_val;


%% Display information
fprintf('Original maximum value = %g\n', max_val);
fprintf('Edge thickness         = %d voxel(s)\n', edge_thick);
fprintf('Adjusted volume size   = [%d %d %d]\n', Nx, Ny, Nz);