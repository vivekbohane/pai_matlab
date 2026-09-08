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