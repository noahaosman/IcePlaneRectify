clear all, clc, close all

params = struct;

% Intrinsic camera params
params.fx =  4231.87732;
params.fy =  4227.55014;
params.cx = 2674.03114;
params.cy = 1449.75072;

% translation distance between frames (meters)
params.tau = [0.0,0.042];

% Camera rotation [roll, yaw, pitch] (degrees)
params.camera_rotation = [1,-18,1.5];

% initial guess for feature locations (meters)
% tune this parameter if triangulation fails to converge.
params.X0_init = [0.0;     0.0;      0.15]; 

% Calculate 3D position of features in camera coordinates
triang = multi_view_triangulation(params, false);

[rectifiedImage, scale_mm_per_pixel] = rectify_image(params, triang, 'field_data/frame_000_rect.tif',true);

imwrite(rectifiedImage, 'output/frame_000_rect2.tif');  % Save to file

fprintf('Scale = %.3f mm/pixel\n', scale_mm_per_pixel);

