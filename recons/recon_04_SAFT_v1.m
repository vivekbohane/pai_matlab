%% SAFT Reconstruction

clear;
clc;
close all;

%% Load workspace

load('C:\Users\vsb27\Downloads\IIT_H_Files\PAI\Matlab_Codes\kwave_codes\PAI_workspace.mat');

%% Parameters

c = medium.sound_speed;

[num_sensors, Nt] = size(sensor_data);
dt = kgrid.dt;

sensor_x = zeros(1, num_sensors);
sensor_y = (0:num_sensors-1) * dy;

x_img = (0:Nx-1) * dx;
y_img = (0:Ny-1) * dy;

recon = zeros(Nx, Ny);

%% Apodization Window

window = hanning(num_sensors);

%% SAFT Reconstruction

disp('Starting SAFT Reconstruction...');
tic


for ix = 1:Nx

    for iy = 1:Ny

        pixel_value = 0;

        px = x_img(ix);
        py = y_img(iy);

        for s = 1:num_sensors

            %% Distance

            dist = sqrt( ...
                (px - sensor_x(s))^2 + ...
                (py - sensor_y(s))^2 );

            %% Time-of-flight

            tof = dist / c;

            %% Fractional sample index

            sample_pos = tof/dt + 1;

            %% Linear interpolation

            if sample_pos >= 1 && sample_pos <= Nt

                signal_value = interp1( ...
                    1:Nt, ...
                    sensor_data(s,:), ...
                    sample_pos, ...
                    'linear', ...
                    0);

                %% Weighted summation

                pixel_value = pixel_value + ...
                              window(s) * signal_value;

            end

        end

        recon(ix,iy) = pixel_value;

    end

end

% delete(gcp('nocreate')); 

toc
disp('SAFT Reconstruction Complete.');

%% Normalize

recon_norm = recon - min(recon(:));

if max(recon_norm(:)) > 0
    recon_norm = recon_norm ./ max(recon_norm(:));
end

%% Display

figure;

imagesc(y_img*1e3, x_img*1e3, recon_norm);

axis image;
colormap gray;
colorbar;


xlabel('Y (mm) - Sensor Line Across Top');
ylabel('X (mm) - Depth');

title(' Synthetic Aperture Focusing Technique (SAFT)', 'FontSize', 14);
