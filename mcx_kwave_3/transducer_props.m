% DEFINE THE ULTRASOUND TRANSDUCER

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