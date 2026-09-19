%% Define Volume

Nx = 384-12; Ny = 512-12; Nz = 512-12;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 12;      % Diameter of the cylinder
radius = thickness / 2;

% 5 uniformly spaced X positions
xpos = round(linspace(40, Nx-thickness-40, 5));

% 5 uniformly spaced Z positions
% (Y and Z have been interchanged)
zpos = round(linspace(30, Nz-thickness-30, 5));

% --- Create a 3D Cylindrical Mask ---
% Cross-section is now in the X-Z plane
% because rods will run along Y

[xx, zz] = ndgrid(1:thickness, 1:thickness);

xc = radius + 0.5; % X center
zc = radius + 0.5; % Z center

% Circular mask in X-Z plane
circle_mask_2D = ((xx - xc).^2 + (zz - zc).^2) <= radius^2;

% Expand the mask along the Y axis
% Reshape to [thickness in X, 1 in Y, thickness in Z]
circle_mask_3D = reshape(circle_mask_2D, [thickness, 1, thickness]);

% Repeat along the Y axis
circle_mask_3D = repmat(circle_mask_3D, [1, Ny, 1]);

%--------------------------------------------------
% 25 rods (5 × 5) -> Circular Cylinders
% Rods run along Y
% Zig-zag ordering in X as Z increases
%--------------------------------------------------

for kz = 1:5
    
    if mod(kz,2) == 1
        xorder = 1:5;      % left -> right
    else
        xorder = 5:-1:1;   % right -> left
    end
    
    z = zpos(kz);
    
    for kx = 1:5
        
        x = xpos(xorder(kx));
        
        % Define bounding box indices
        x_idx = x : x+thickness-1;
        z_idx = z : z+thickness-1;
        
        % Extract current background subvolume
        % Grabbing all Y positions
        sub_vol = vol(x_idx, :, z_idx);
        
        % Apply blood material (2) only where cylindrical mask is true
        sub_vol(circle_mask_3D) = 2;
        
        % Place updated subvolume back into main volume
        vol(x_idx, :, z_idx) = sub_vol;
        
    end
end

cfg.vol = vol;