
%% Gaussian

cfg.srctype = 'gaussian';
% cfg.srcparam1(1) is Beam waist radius
% Applications: Most lasers; DPSS; Fiber lasers; Diode lasers

%% Disk

cfg.srctype = 'disk';
% A uniform circular beam.
% All photons are launched from random positions inside a circle.
cfg.srcparam1 = [radius 0 0 0];

%% Planar

cfg.srctype = 'planar';
% This is simply a flat rectangular emitting surface.

%% Slit

cfg.srctype = 'slit';
% Gaussian broadening
% You can give the slit a finite width: cfg.srcparam2 = [2 0 0 0];
% This broadens the slit perpendicular to its length with a Gaussian profile.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Hyperboloid

% This is the physically correct propagating Gaussian beam.
% Instead of being perfectly collimated,
% the beam
% converges
% reaches waist
% diverges
% just like a real focused Gaussian beam.

%% Pencil

cfg.srctype = 'pencil';
cfg.srcpos  = [x y z];
cfg.srcdir  = [dx dy dz];
% Photon launches from one single point
% All photons travel in the same direction
% Applications : Optical fiber ; Very tightly focused laser; Point illumination