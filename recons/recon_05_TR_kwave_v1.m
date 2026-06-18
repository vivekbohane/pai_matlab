%% Time Reversal (TR) Reconstruction
clear;
clc;
close all;

%% Load workspace
load('C:\Users\vsb27\Downloads\IIT_H_Files\PAI\Matlab_Codes\kwave_codes\PAI_workspace.mat');

%% 1. Setup Time Reversal Parameters

% Clear the original initial pressure source. 
% In TR, the "source" is the sensor data acting as a boundary condition.
source = struct(); 

% Assign the recorded sensor data to the time reversal boundary.
% k-Wave will automatically reverse this matrix in time internally.
sensor.time_reversal_boundary_data = sensor_data;

%% 2. Run Time Reversal Simulation
disp('Starting Time Reversal Reconstruction using k-Wave...');
tic;

% Optional simulation arguments:
% Setting 'PlotSim' to true is actually very instructive here—you can watch 
% the waves propagate backwards and converge! We'll set it to false for speed.
input_args = {'PlotSim', true,'PlotFreq', 10, 'PMLInside', false, 'PlotPML', false, 'Smooth', false};
arg_movie = {'RecordMovie', false,'MovieProfile', 'MPEG-4', 'MovieName','PAI_sim_TVrecon_001', ...
                       'MeshPlot', false};

% Run the forward solver. When time_reversal_boundary_data is present, 
% the output is the reconstructed initial pressure field (p0).
recon_tr = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:},arg_movie{:});

toc;
disp('Reconstruction Complete.');

%% 3. Process and Display Results

% Positivity Constraint:
% Because a flat linear array only captures a "limited view" (waves traveling upwards),
% TR reconstructions often contain negative pressure ringing artifacts. 
% We apply a max(0, recon) constraint to isolate the true positive sources.
recon_tr_pos = max(0, recon_tr);

% Normalize the reconstruction
recon_norm = recon_tr_pos / max(recon_tr_pos(:));

% Reconstruction grid axes for plotting
x_img = (0:Nx-1) * dx;
y_img = (0:Ny-1) * dy;

figure;
imagesc(y_img*1e3, x_img*1e3, recon_norm);
axis image;
colorbar;
colormap gray;
xlabel('Y (mm) - Sensor Line Across Top');
ylabel('X (mm) - Depth');
title('Time Reversal (TR) Reconstruction', 'FontSize', 14);