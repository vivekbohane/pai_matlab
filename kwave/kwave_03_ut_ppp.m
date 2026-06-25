%% Clear workspace

clear; clc; close all;

%% 1. Create Computational Grid 
% simulation settings
DATA_CAST = 'gpuArray-single';
Nx = 500; Ny = 500; Nz = 52;       
dx = 0.1e-3; dy = 0.1e-3; dz = 0.1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

%% 2. Define Medium Properties

medium.sound_speed = 1500;   % m/s
medium.density     = 1000;   % kg/m^3
medium.alpha_coeff = 0.75;  % [dB/(MHz^y cm)]
medium.alpha_power = 1.5;

%% 3. Define Initial Pressure Distribution (PA Source)

source.p0 = zeros(Nx,Ny,Nz);

source.p0(330:350,230:240,30:40) = 3 ;

% voxelPlot(source.p0);
% title('Initial Pressure Distribution (Pa)', 'FontSize', 15);
% volshow(source.p0);

%%

kgrid.makeTime(medium.sound_speed);

%% 4. Define Sensor Array
% =========================================================================
% DEFINE THE ULTRASOUND TRANSDUCER
% =========================================================================

% physical properties of the transducer
transducer.number_elements = 128;    % total number of transducer elements
transducer.element_width = 2;       % width of each element [grid points/voxels]
transducer.element_spacing = 1;     % spacing (kerf  width) between the elements [grid points/voxels]
transducer.element_length = 40;     % length of each element [grid points/voxels]
transducer.radius = inf;            % radius of curvature of the transducer [m]

% calculate the width of the transducer in grid points
transducer_width = transducer.number_elements * transducer.element_width ...
    + (transducer.number_elements - 1) * transducer.element_spacing;

% properties used to derive the beamforming delays
transducer.sound_speed = 1500;                  % sound speed [m/s]
transducer.focus_distance = inf;              % focus distance [m]
% transducer.elevation_focus_distance = 19e-3;    % focus distance in the elevation plane [m]
transducer.steering_angle = 0;                  % steering angle [degrees]

% use this to position the transducer in the middle of the computational grid
% transducer.position = round([Nx/2 - transducer_width/2, Ny/2 - transducer.element_length/2,52]);
transducer.position = [ ...
    round(Nx/2 - transducer.element_length/2), ...
    round(Ny/2 - transducer_width/2), ...
    51];

% create the transducer using the defined settings
transducer = kWaveTransducer(kgrid, transducer);

% set the input settings
input_args = {'DisplayMask', transducer.active_elements_mask, ...
    'PMLInside', false, 'PlotPML', false, 'PMLSize',20,  ...
    'DataCast', DATA_CAST};

%%
% run the simulation
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, transducer, input_args{:});

%% GPU to CPU
sensor_data = gather(sensor_data);

%%
figure;
voxelPlot(double(transducer.active_elements_mask));
title('Transducer Mask');


