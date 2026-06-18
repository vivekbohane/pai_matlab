% %% UBP Reconstruction
% 
% clear;
% clc;
% close all;
% 
% %% Load workspace
% 
% load('C:\Users\vsb27\Downloads\IIT_H_Files\PAI\Matlab_Codes\kwave_codes\PAI_workspace.mat');

%% Parameters

c = medium.sound_speed;

[num_sensors, Nt] = size(sensor_data);
dt = kgrid.dt;

sensor_x = zeros(1, Nx);
sensor_y = (0:Ny-1) * dy;

x_img = (0:Nx-1) * dx;
y_img = (0:Ny-1) * dy;

recon = zeros(Nx, Ny);

%% Time derivative of pressure

dpdt = gradient(sensor_data, dt);

%% UBP Reconstruction

disp('Starting UBP Reconstruction...');
tic

for ix = 2:Nx

    for iy = 1:Ny

        pixel_value = 0;

        px = x_img(ix);
        py = y_img(iy);

        for s = 1:num_sensors

            % Distance from pixel to sensor
            dist = sqrt( (px - sensor_x(s))^2 + (py - sensor_y(s))^2 );
                         
            % Time of flight
            t = dist / c;

            % Sample index
            idx = round(t/dt) + 1;

            if idx >= 1 && idx <= Nt

                % Universal Back Projection
                pixel_value = pixel_value + ...
                              dpdt(s,idx) / (dist + eps);

            end

        end

        recon(ix,iy) = pixel_value;

    end

end

toc
disp('UBP Reconstruction Complete.');

recon_norm = recon - min(recon(:));
recon_norm = recon_norm / max(recon_norm(:));

%% Display

figure;
imagesc(y_img*1e3, x_img*1e3, recon_norm);

axis image;
colormap gray;
colorbar;

xlabel('Y (mm) - Sensor Line Across Top');
ylabel('X (mm) - Depth');

title('Universal Back Projection (UBP)', 'FontSize', 14);
