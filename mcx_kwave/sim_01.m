%% 
clear; clc;
close all;

%% load the data of mcx simulation

load('C:\Users\Partha\Documents\vivekbohane\pai_matlab\mcx\mcx_04_workspace.mat'); 

% clear unnesseary variables 
clear cfg fluence_stat Hlog kx kz x xorder z zpos thickness;

%% Initial pressure distribution (PA Source)
Gamma = 0.12 * ones(Nx,Ny,Nz);

Gamma(vol==1)=0.12; % tissue
Gamma(vol==2)=0.20; % blood

normalization_factor = 1e7; % normalization factor for initial pressure

source.p0 = normalization_factor *( Gamma.*H);
clear Gamma;

% volshow(source.p0);
% voxelPlot(source.p0);
%% 1. Create Computational Grid 

% Nx = Nx; Ny = Ny; Nz = Nz;       
dx = 0.1e-3; dy = 0.1e-3; dz = 0.1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

%% 2. Define Medium Properties

medium.sound_speed = 1540 * ones(Nx,Ny,Nz);
medium.density     = 1025 * ones(Nx,Ny,Nz);

medium.sound_speed(vol==1) = 1540; % tissue
medium.sound_speed(vol==2) = 1575; % blood

medium.density(vol==1) = 1025; % tissue
medium.density(vol==2) = 1060; % blood

medium.alpha_coeff = 0.75;
medium.alpha_power = 1.5;

%% 4. Define Sensor Array

sensor.mask = zeros(Nx,Ny,Nz);
% Sensors on top boundary
sensor.mask(:,:,end) = 1;

% voxelPlot(sensor.mask);
% title('Sensor Mask', 'FontSize', 15);

%% 5. Create Time Array

kgrid.makeTime(medium.sound_speed);

%% 6. Run Forward Simulation

arg_pml = {'PMLInside',false,'PlotPML',false,'PMLAlpha',2,'PMLSize',20 };
% arg_plot = {'PlotSim',true,'PlotFreq', 10,'PlotLayout',true};
arg_plot = {'PlotLayout',true};
arg_movie = {'RecordMovie', false,'MovieProfile', 'MPEG-4', 'MovieName','PAI_sim_001'};
%  source.p0, medium.sound_speed, and medium.density (default = [true, false, false])
arg_input = {'Smooth', [true,true,true], 'DataCast', 'gpuArray-single', 'CartInterp', 'linear'};
%  'CartInterp', 'nearest' 

diary('sim_01_log.txt')
% kspaceFirstOrder2D(kgrid, medium, source, sensor, 'SaveToDisk', 'PAI_init_001');
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, ...
                         arg_pml{:},arg_plot{:},arg_movie{:},arg_input{:});
% sensor_data(sensor_point_index, time_index)
diary off

sensor_data = gather(sensor_data);

% save the recorded sensor data as .mat file
save('sim_01_sensor_data.mat','sensor_data');

