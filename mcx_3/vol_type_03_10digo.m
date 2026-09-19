%% Define Volume

Nx = 384-12;
Ny = 512-12;
Nz = 512-12;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 12;      % Diameter of the cylinder
radius = thickness / 2;

% --------------------------------------------------
% 10 uniformly spaced X and Y positions
% Starting position = (40,40)
% Rods are paired one-to-one to form a diagonal
% --------------------------------------------------

xpos = round(linspace(40, Nx-thickness-40, 10));
ypos = round(linspace(40, Ny-thickness-40, 10));

% --------------------------------------------------
% Create 2D circular cross-section
% Cross-section is in the X-Y plane
% --------------------------------------------------

[xx, yy] = ndgrid(1:thickness, 1:thickness);

xc = radius + 0.5;
yc = radius + 0.5;

circle_mask_2D = ((xx - xc).^2 + ...
                  (yy - yc).^2) <= radius^2;

% --------------------------------------------------
% Extend circular mask along the entire Z axis
% --------------------------------------------------

circle_mask_3D = reshape(circle_mask_2D, ...
                          [thickness, thickness, 1]);

circle_mask_3D = repmat(circle_mask_3D, ...
                        [1, 1, Nz]);

% --------------------------------------------------
% Create 10 diagonal rods
% Rods run along Z
% --------------------------------------------------

for k = 1:10
    
    % Corresponding X-Y position
    x = xpos(k);
    y = ypos(k);
    
    % Bounding box for the rod
    x_idx = x : x+thickness-1;
    y_idx = y : y+thickness-1;
    
    % Extract sub-volume across all Z
    sub_vol = vol(x_idx, y_idx, :);
    
    % Assign blood material = 2
    sub_vol(circle_mask_3D) = 2;
    
    % Put modified volume back
    vol(x_idx, y_idx, :) = sub_vol;
    
end

% --------------------------------------------------
% Assign volume to MCX
% --------------------------------------------------

cfg.vol = vol;