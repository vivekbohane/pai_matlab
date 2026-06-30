
Nx = 384-12; Ny = 512-12; Nz = 512-12;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 12;      % Diameter of the cylinder
radius = thickness / 2;

% 5 uniformly spaced X positions (This defines our 5 columns)
xpos = round(linspace(30, Nx-thickness-30, 5));

% --- Calculate Y positions for staggered columns ---
% 1. Positions for the 5-rod columns
ypos5 = round(linspace(30, Ny-thickness-30, 5));

% 2. Calculate the distance between adjacent rods in the 5-rod column
dy = ypos5(2) - ypos5(1);

% 3. Positions for the 4-rod columns (shifted down by exactly half the distance)
ypos4 = round(ypos5(1:4) + dy/2);

% --- Create a 3D Cylindrical Mask ---
% 1. Create a 2D local grid for the cross-section (in X-Y plane)
[xx, yy] = ndgrid(1:thickness, 1:thickness);
xc = radius + 0.5; % X center
yc = radius + 0.5; % Y center

% 2. Create the 2D circular mask using the circle equation: (x-xc)^2 + (y-yc)^2 <= r^2
circle_mask_2D = ((xx - xc).^2 + (yy - yc).^2) <= radius^2;

% 3. Expand the 2D mask into a 3D cylinder that stretches across the entire Z axis
circle_mask_3D = reshape(circle_mask_2D, [thickness, thickness, 1]);
circle_mask_3D = repmat(circle_mask_3D, [1, 1, Nz]);
% -------------------------------------

%--------------------------------------------------
% 23 rods total (5+4+5+4+5) -> Circular Cylinders
% Rods run along Z
% Staggered layout along Y, Zig-zag ordering in Y
%--------------------------------------------------

for kx = 1:5
    
    x = xpos(kx);
    
    % Determine if this column has 5 rods (odd kx) or 4 rods (even kx)
    if mod(kx,2) == 1
        num_rods = 5;
        current_ypos = ypos5;
        yorder = 1:num_rods;      % top -> bottom
    else
        num_rods = 4;
        current_ypos = ypos4;
        yorder = num_rods:-1:1;   % bottom -> top
    end
    
    for ky = 1:num_rods
        
        % Pick the Y position from the correct array based on the column type
        y = current_ypos(yorder(ky));
        
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

% ========================================================
% --- 4. 3D VISUALIZATION ---
% ========================================================

figure('Color', 'white', 'Name', '3D Volume Viewer');
hold on;

% A. Extract the surface of the blood rods (where vol == 2)
% We use 1.5 as the threshold boundary between 1 (background) and 2 (blood)
disp('Extracting 3D geometry... this may take a few seconds.');
[faces, vertices] = isosurface(vol == 2, 0.5); 

% B. Render the rods in BLUE
p = patch('Faces', faces, 'Vertices', vertices);
p.FaceColor = '#0055A4';    % A nice, deep professional blue
p.EdgeColor = 'none';       % Remove the mesh lines for smooth rendering

% C. Add lighting and shading to make the rods look 3D and cylindrical
camlight; 
lighting gouraud;
material shiny;             % Adds a slight glossy highlight

% D. Draw the RED REFERENCE BOUNDARY at Z = 250
% This draws a rectangle around the outer edge (1 to Nx, 1 to Ny) at the Z=250 height
Z_ref = 250;
x_rect = [1, Nx, Nx, 1, 1];
y_rect = [1, 1, Ny, Ny, 1];
z_rect = [Z_ref, Z_ref, Z_ref, Z_ref, Z_ref];

plot3(x_rect, y_rect, z_rect, 'Color', 'red', 'LineWidth', 3);

% E. Format the View and Axes
view(3);                   % Set to default 3D isometric view
axis equal;                % Ensure the aspect ratio is correct (1 voxel = 1 unit)
grid on;
box on;                    % Show the outer bounding box of the whole space

% Set axis limits tightly around the volume
xlim([1 Nx]);
ylim([1 Ny]);
zlim([1 Nz]);

xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Blue Rods with Red Z=250 Reference Boundary');

hold off;
disp('Rendering complete.');