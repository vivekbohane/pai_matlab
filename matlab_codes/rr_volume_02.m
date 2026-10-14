clc; clearvars;
load("config_mip_jet.mat"); load("config_vr.mat");
load("config_mip_jet_r.mat"); load("config_vr_r.mat");
load("config_mip_jet_3.mat"); load("config_vr_3.mat");
load("config_mip_jet_all.mat"); load("config_vr_all.mat");
%% 

load("D:\IITH_Files\PAI\comb_data\other\mcx_34_gaussian_side_rotate\03_10digo_radius_156_focus_250_trans_1y\mcx_34_gaussian_side_rotate_03_10digo_radius_156_focus_250_workspace.mat");
H_p3f250 = H; Hlog_p3f250 = Hlog;  

%% 
run('sim_volume_save.m');
H_p3f250_b = vol_adj;


v = volshow(H_p3f250_b);

config_mip = config_vr;

v.CameraPosition = config_mip.CameraPosition;
v.CameraUpVector = config_mip.CameraUpVector;
v.CameraTarget = config_mip.CameraTarget;
v.CameraViewAngle = config_mip.CameraViewAngle;

v.BackgroundColor = config_mip.BackgroundColor;
v.Renderer = config_mip.Renderer;
v.Colormap = config_mip.Colormap;
v.Alphamap = config_mip.Alphamap;
v.Lighting = config_mip.Lighting;
%% 
run('Copy_of_sim_volume_save.m');
Hlog_p3f250_b = vol_adj;


v = volshow(Hlog_p3f250_b);

config_mip = config_mip_jet;

v.CameraPosition = config_mip.CameraPosition;
v.CameraUpVector = config_mip.CameraUpVector;
v.CameraTarget = config_mip.CameraTarget;
v.CameraViewAngle = config_mip.CameraViewAngle;

v.BackgroundColor = config_mip.BackgroundColor;
v.Renderer = config_mip.Renderer;
v.Colormap = config_mip.Colormap;
v.Alphamap = config_mip.Alphamap;
v.Lighting = config_mip.Lighting;

