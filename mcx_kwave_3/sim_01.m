%% 
clear; clc;
close all;

%% load the data of mcx simulation

load("D:\vivekbohane\pai_matlab\mcx_3\mcx_31_planarSlit_workspace.mat"); 

%% Initial pressure distribution (PA Source)
Gamma = 0.12 * ones(Nx,Ny,Nz);

Gamma(vol==1)=0.12; % tissue
Gamma(vol==2)=0.20; % blood

normalization_factor = 1/max(H(:)); % normalization factor for initial pressure

source.p0 = normalization_factor *( Gamma.*H);
clear Gamma;

% volshow(source.p0);
% voxelPlot(source.p0);
%% 1a. Create Computational Grid 

% Nx = Nx; Ny = Ny; Nz = Nz;       
dx = 0.1e-3; dy = 0.1e-3; dz = 0.1e-3;
kgrid = kWaveGrid(Nx, dx, Ny, dy, Nz, dz);

%% 1b. Create Time Array

kgrid.makeTime(1540);
% kgrid.makeTime(medium.sound_speed);
% kgrid.Nt = 2400;

%% 2. Define Medium Properties

% 1. Initialize matrices for properties that can be heterogeneous
medium.sound_speed = 1540 * ones(Nx, Ny, Nz);
medium.density     = 1050 * ones(Nx, Ny, Nz);
medium.alpha_coeff = 0.50 * ones(Nx, Ny, Nz); 

% 2. Define alpha_power as a SCALAR (k-Wave limitation)
% y = 1.0 to 1.1 is standard for most biological tissues
medium.alpha_power = 1.2; 

% 3. Assign properties for Soft Tissue (vol == 1)
medium.sound_speed(vol == 1) = 1540; % m/s
medium.density(vol == 1)     = 1050; % kg/m^3 (1025 to 1050 is typical)
medium.alpha_coeff(vol == 1) = 0.50; % dB/(MHz^y cm) 

% 4. Assign properties for Blood (vol == 2)
medium.sound_speed(vol == 2) = 1575; % m/s
medium.density(vol == 2)     = 1060; % kg/m^3
medium.alpha_coeff(vol == 2) = 0.15; % dB/(MHz^y cm)

%% 4. Define Sensor Array

run('transducer_props.m');

% --- POSITIONING THE TRANSDUCER ---
% 1. Set X-position: Placed at voxel index 64, looking down the +x direction
transducer_pos_x = Nx-2;
% 2. Set Y-position: Center the array across your 500-voxel Y-axis
transducer_pos_y = round((Ny - transducer_width) / 2);
% 3. Set Z-position: Center the 40-voxel element length across your 52-voxel Z-axis
transducer_pos_z = round((Nz - transducer.element_length) / 2);

% Assign the calculated corner position to the object
transducer.position = [transducer_pos_x, transducer_pos_y, transducer_pos_z];

% create the transducer using the defined settings
transducer = kWaveTransducer(kgrid, transducer);

%% 5. Run Forward Simulation

run_name = "sim_01_planarSlit";

arg_pml = {'PMLInside',false,'PlotPML',false,'PMLAlpha',10,'PMLSize',6 };
arg_plot = {'PlotSim',false,'PlotFreq', 10,'PlotLayout',false};
% arg_plot = {'PlotLayout',false};
arg_movie = {'RecordMovie', false,'MovieProfile', 'MPEG-4', 'MovieName','movie'};
%  source.p0, medium.sound_speed, and medium.density (default = [true, false, false])
arg_input = {'Smooth', [true,true,true], 'DataCast', 'gpuArray-single', 'CartInterp', 'linear'};
%  'CartInterp', 'nearest' 

diary(run_name + "_log.txt");

% sensor_data_savetodisk = kspaceFirstOrder3D(kgrid, medium, source, transducer, ...
%                          arg_pml{:},arg_plot{:},arg_movie{:},arg_input{:}, ...
%                          'SaveToDisk', run_name + "_SaveToDisk.h5");
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, transducer, ...
                         arg_pml{:},arg_plot{:},arg_movie{:},arg_input{:});
% sensor_data(sensor_point_index, time_index)
diary off

sensor_data = gather(sensor_data);

% save the recorded sensor data as .mat file
save(run_name + "_sensor_data.mat","sensor_data");

%% Save the worksapce
save(run_name + "_workspace.mat");
