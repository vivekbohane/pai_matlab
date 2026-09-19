%% Define Volume

Nx = 384-12; Ny = 512-12; Nz = 512-12;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 12;      % Diameter of the cylinder
radius = thickness / 2;

% 5 uniformly spaced X positions (This defines our 5 columns)
xpos = round(linspace(30, Nx-thickness-30, 5));

% --- Calculate Z positions for staggered columns ---
% 1. Positions for the 5-rod columns
zpos5 = round(linspace(30, Nz-thickness-30, 5));

% 2. Calculate the distance between adjacent rods in the 5-rod column
dz = zpos5(2) - zpos5(1);

% 3. Positions for the 4-rod columns (shifted by half the distance)
zpos4 = round(zpos5(1:4) + dz/2);

% --- Create a 3D Cylindrical Mask ---
% Rods now run along Y
% Cross-section is therefore in the X-Z plane

[xx, zz] = ndgrid(1:thickness, 1:thickness);

xc = radius + 0.5; % X center
zc = radius + 0.5; % Z center

% Circular cross-section in X-Z plane
circle_mask_2D = ((xx - xc).^2 + (zz - zc).^2) <= radius^2;

% Expand the 2D mask along Y
circle_mask_3D = reshape(circle_mask_2D, [thickness, 1, thickness]);
circle_mask_3D = repmat(circle_mask_3D, [1, Ny, 1]);

%--------------------------------------------------
% 23 rods total (5+4+5+4+5)
% Circular Cylinders
%
% Rods run along Y
% Staggered layout along Z
% Zig-zag ordering in Z
% X remains unchanged
%--------------------------------------------------

for kx = 1:5
    
    x = xpos(kx);
    
    % Determine if this column has 5 rods (odd kx) or 4 rods (even kx)
    if mod(kx,2) == 1
        num_rods = 5;
        current_zpos = zpos5;
        zorder = 1:num_rods;      % top -> bottom
    else
        num_rods = 4;
        current_zpos = zpos4;
        zorder = num_rods:-1:1;   % bottom -> top
    end
    
    for kz = 1:num_rods
        
        % Pick the Z position
        z = current_zpos(zorder(kz));
        
        % Define bounding box
        x_idx = x : x+thickness-1;
        z_idx = z : z+thickness-1;
        
        % Grab all Y slices
        sub_vol = vol(x_idx, :, z_idx);
        
        % Apply blood material (2) only where cylindrical mask is true
        sub_vol(circle_mask_3D) = 2;
        
        % Place updated subvolume back
        vol(x_idx, :, z_idx) = sub_vol;
        
    end
end

cfg.vol = vol;