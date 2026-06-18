%% Clear workspace

clear; clc; close all;

%% 1. Create Computational Grid 

Nx = 128; Ny = 128; Nz = 128;       
dx = 0.1e-3; dy = 0.1e-3; dz = 0.1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

%% 2. Define Medium Properties

medium.sound_speed = 1500;   % m/s
medium.density     = 1000;   % kg/m^3
% medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]
% medium.alpha_power = 1.5;

%% 3. Define Initial Pressure Distribution (PA Source)

source.p0 = zeros(Nx,Ny,Nz);

source.p0(30:100,30:32,30:32) = 3 ;
source.p0(30:100,60:62,30:32) = 3 ;
source.p0(30:100,90:92,30:32) = 3 ;

source.p0(30:100,30:32,60:62) = 3 ;
source.p0(30:100,60:62,60:62) = 3 ;
source.p0(30:100,90:92,60:62) = 3 ;

source.p0(30:100,30:32,90:92) = 3 ;
source.p0(30:100,60:62,90:92) = 3 ;
source.p0(30:100,90:92,90:92) = 3 ;

% source.p0(60,60,60) = 3 ;
% source.p0(90,90,90) = 1 ;
% source.p0(90,66,66) = 1 ;

voxelPlot(source.p0);
title('Initial Pressure Distribution (Pa)', 'FontSize', 15);
%% 4. Define Sensor Array

sensor.mask = zeros(Nx,Ny,Nz);
% Sensors on top boundary
sensor.mask(:,:,1) = 1;

voxelPlot(sensor.mask);
title('Sensor Mask', 'FontSize', 15);

%% Plot Source and Sensor in Same Voxel Plot

% plot the simulation layout using voxelplot
voxelPlot(double(source.p0 |  sensor.mask));
title("Sensor and Source",  'FontSize', 15);
view([50, 20]);

%% 5. Create Time Array

kgrid.makeTime(medium.sound_speed);

%% 6. Run Forward Simulation

arg_pml = {'PMLInside',false,'PlotPML',false,'PMLAlpha',2,'PMLSize',20 };
% arg_plot = {'PlotSim',true,'PlotFreq', 10,'PlotLayout',true};
arg_plot = {'PlotLayout',true};
arg_movie = {'RecordMovie', false,'MovieProfile', 'MPEG-4', 'MovieName','PAI_sim_001'};
%  source.p0, medium.sound_speed, and medium.density (default = [true, false, false])
arg_input = {'Smooth', [true,true,true], 'DataCast', 'single', 'CartInterp', 'linear'};
%  'CartInterp', 'nearest' 

% kspaceFirstOrder2D(kgrid, medium, source, sensor, 'SaveToDisk', 'PAI_init_001');
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, ...
                         arg_pml{:},arg_plot{:},arg_movie{:},arg_input{:});
% sensor_data(sensor_point_index, time_index)

% save the recorded sensor data as .mat file
% save('sensor_data.mat','sensor_data');

%% 7. Display Sensor Data

% define the figure size to be 600x800 pixels
figure;
set(gcf, 'Position', [00, 00, 600, 800]);
imagesc(sensor_data');
ylabel('Time Step');
xlabel('Sensor Position');
title('Recorded PA Signals');
colorbar;
colormap(getColorMap);
% colormap jet;

% saveas(gcf,'PAI_sensorData_001.svg');

%%
% 1. Get the number of time steps (your 740)
Nt = size(sensor_data, 2);

% 2. Define your grid dimensions (adjust if your Nx/Ny are different)
Nx = 128; 
Ny = 128; 

% 3. Reshape the 2D matrix back into a 3D matrix (X, Y, Time)
sensor_data_3D = reshape(sensor_data, Nx, Ny, Nt);

%%
% Extract the 2D plane at time step 300
pressure_at_t300 = sensor_data_3D(:, :, 3);

% Plot it
figure;
imagesc(pressure_at_t300);
colormap(getColorMap); % k-Wave's default colormap
colorbar;
title('Pressure at Top Sensor Boundary (Time Step 300)');

%% select the specific 

sensor_data = squeeze(sensor_data_3D(:,31,:));

%% Create MP4 showing sensor data accumulation
% 
% [num_sensors, Nt] = size(sensor_data);
% 
% v = VideoWriter('PAI_sensor_sim_001.mp4', 'MPEG-4');
% v.FrameRate = 30;
% v.Quality = 100;
% 
% open(v);
% 
% figure('Position',[00 00 600 800]);
% 
% % Fix color scale for all frames
% clims = [min(sensor_data(:)), max(sensor_data(:))];
% 
% for t = 1:Nt
% 
%     % Create partially-filled image
%     temp = nan(size(sensor_data'));
%     temp(1:t,:) = sensor_data(:,1:t)';
% 
%     imagesc(temp);
%     caxis(clims);
% 
%     ylabel('Time Samples', 'FontSize', 14);
%     xlabel('Sensor Number', 'FontSize', 14);
% 
%     title(sprintf('Recorded PA Signals (Unit Pa) (%d/%d)', t, Nt), 'FontSize', 16);
% 
%     colorbar;
%     colormap(getColorMap);
%     drawnow;
% 
%     frame = getframe(gcf);
%     writeVideo(v, frame);
% 
% end
% 
% close(v);
% close(gcf);
% 
% disp('MP4 saved successfully.');


%% Save the worksapce
save('PAI_workspace_002.mat');


%% Show the 10 pixel values of highest intensity in the sensor_data matrix and also show this points in matrix as mask
% % Find the 10 highest intensity values in sensor_data
% [num_sensors, Nt] = size(sensor_data);
% [max_values, max_indices] = maxk(sensor_data(:), 10);
% disp('Top 10 pixel values in sensor_data:');
% disp(max_values);
% 
% % Create a mask showing the locations of the highest intensity values
% mask = zeros(size(sensor_data));
% for i = 1:10
%     [row, col] = ind2sub(size(sensor_data), max_indices(i));
%     mask(row, col) = 1;
% end
% 
% % Display the mask
% figure;
% imagesc(mask);
% axis image;
% colormap hot;
% colorbar;
% title('Locations of Highest Intensity Values');


%% Create MP4 for a single sensor signal accumulation

% k = 32;   % <-- Sensor number to visualize
% 
% [num_sensors, Nt] = size(sensor_data);
% 
% % Check validity
% if k < 1 || k > num_sensors
%     error('Sensor number must be between 1 and %d', num_sensors);
% end
% 
% signal = sensor_data(k,:);
% 
% % Create video writer
% v = VideoWriter(sprintf('Sensor_%03d_Data.mp4',k),'MPEG-4');
% v.FrameRate = 30;
% v.Quality = 100;
% 
% open(v);
% 
% figure('Position',[100 100 1000 500]);
% 
% % Fixed axis limits for smooth movie
% ymin = min(signal);
% ymax = max(signal);
% 
% if ymin == ymax
%     ymin = ymin - 1;
%     ymax = ymax + 1;
% end
% 
% for t = 1:2:Nt
% 
%     clf
% 
%     % Plot signal up to current time
%     plot(1:t, signal(1:t), 'LineWidth', 2);
% 
%     hold on
% 
%     % Current sample marker
%     plot(t, signal(t), 'ro', ...
%         'MarkerFaceColor','r', ...
%         'MarkerSize',8);
% 
%     hold off
% 
%     xlim([1 Nt]);
%     ylim([ymin ymax]);
% 
%     xlabel('Time Sample','FontSize', 16);
%     ylabel('Pressure (Pa)', 'FontSize', 16);
%     title(sprintf('Sensor %d Signal (%d/%d)', k, t, Nt), 'FontSize', 20);
% 
%     grid on
% 
%     drawnow
% 
%     frame = getframe(gcf);
%     writeVideo(v, frame);
% 
% end
% 
% close(v);
% close(gcf);
% 
% disp(['Movie saved as Sensor_' sprintf('%03d',k) '_Data.mp4']);


%%
% filename = 'PAI_init_001.h5';
% 
% % Check structure first
% h5disp(filename)
% 
% % Read p0
% p0 = h5read(filename,'/p0_source_input');
% 
% % Plot
% figure;
% imagesc(p0);
% axis image;
% colormap(gray);
% colorbar;
% title('Initial Pressure Distribution (Pa)', 'FontSize', 15);
