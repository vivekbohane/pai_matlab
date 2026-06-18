% %% DAS Reconstruction
% 
% clear;
% clc;
% close all;
% 
% %% Load workspace
% 
% load('C:\Users\vsb27\Downloads\IIT_H_Files\PAI\Matlab_Codes\kwave_3d\PAI_workspace_001.mat');

%% Parameters

c = medium.sound_speed;

[num_sensors, Nt] = size(sensor_data);
dt = kgrid.dt;

% Sensor positions (top boundary)
sensor_x = zeros(1, Nx);
sensor_y = (0:Ny-1) * dy;

% Reconstruction grid
x_img = (0:Nx-1) * dx;
y_img = (0:Ny-1) * dy;

recon = zeros(Nx, Ny);

%% DAS
disp('Starting DAS Reconstruction');
tic

for ix = 1:Nx

    for iy = 1:Ny

        pixel_value = 0;

        px = x_img(ix);
        py = y_img(iy);

        for s = 1:num_sensors

            % Distance from pixel to sensor
            dist = sqrt( (px - sensor_x(s))^2 + (py - sensor_y(s))^2 );

            % Time-of-flight
            t = dist / c;

            % Sample index
            idx = round(t / dt) + 1;

            if idx >= 1 && idx <= Nt
                pixel_value = pixel_value + sensor_data(s, idx);
            end

        end

        recon(ix,iy) = pixel_value;

    end

end

recon_norm = (recon - min(recon(:))) / (max(recon(:)) - min(recon(:)));

toc
disp('Reconstruction Complete.');
%% Display 

figure;
imagesc(y_img*1e3, x_img*1e3, recon_norm);
axis image;
colorbar;
colormap gray;
% colormap(getColorMap);
xlabel('Y (mm) - Sensor Line Across Top');
ylabel('X (mm) - Depth');
title('DAS Reconstruction', 'FontSize', 14);
