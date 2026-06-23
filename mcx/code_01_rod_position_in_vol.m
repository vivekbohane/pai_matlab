Nx = 256;
Ny = 256;
Nz = 256;

vol = uint8(ones(Nx,Ny,Nz));

thickness = 4;

% 8 uniformly spaced Y and Z positions
ypos = round(linspace(20,236,8));
zpos = round(linspace(20,236,8));

%--------------------------------------------------
% Create 64 rods running along X
% Zig-zag arrangement in Y as Z increases
%--------------------------------------------------

for kz = 1:8

    % Alternate Y ordering for each Z plane
    if mod(kz,2)==1
        yorder = 1:8;      % left -> right
    else
        yorder = 8:-1:1;   % right -> left
    end

    z = zpos(kz);

    for ky = 1:8

        y = ypos(yorder(ky));

        % Rod extending through entire X dimension
        vol(:, ...
            y:y+thickness-1, ...
            z:z+thickness-1) = 2;

    end
end

cfg.vol = vol;

volshow(vol);

%% vol2

Nx = 256;
Ny = 256;
Nz = 256;

vol = uint8(ones(Nx,Ny,Nz));

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

volshow(vol);

%%

Nx = 512;
Ny = 512;
Nz = 384;

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

% Visualize
figure;
volshow(vol);

