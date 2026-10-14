%%
clearvars; clc;
close all;

% also rotate each imge 180 degrees before plotting
% normalize each slice to 0 to 1 before plotting
vol = (vol - min(vol(:))) / (max(vol(:)) - min(vol(:)));

%%  init_001

% figure;
% % normalize each slice to 0 to 1 before plotting
% vol_norm = (vol - min(vol(:))) / (max(vol(:)) - min(vol(:)));
% % also rotate each imge 180 degrees before plotting
% vol_norm = rot90(vol_norm, 2);
% imagesc(squeeze(vol_norm(:,:,250)));
% axis image;
% colormap(hot);
% colorbar;
% % remove the x and y ticks
% set(gca, 'XTick', [], 'YTick', []);


figure;

% Normalize each slice to 0 to 1 before plotting
vol_norm = (vol - min(vol(:))) / (max(vol(:)) - min(vol(:)));

% Rotate each image 180 degrees before plotting
vol_norm = rot90(vol_norm, 2);

imagesc(squeeze(vol_norm(:,:,250)));
axis image;

% Inverted hot colormap (black = max, white = min)
colormap(flipud(gray));

colorbar;

% Remove the x and y ticks
set(gca, 'XTick', [], 'YTick', []);


%%  fluence_002

figure;
% normalize each slice to 0 to 1 before plotting
H_norm = (H - min(H(:))) / (max(H(:)) - min(H(:)));
imagesc(squeeze(H_norm(:,:,250)));
axis image;
colormap(flipud(gray));
colorbar;
% remove the x and y ticks
set(gca, 'XTick', [], 'YTick', []);

%% 

figure;
% normalize each slice to 0 to 1 before plotting
source_p0_norm = (source.p0 - min(source.p0(:))) / (max(source.p0(:)) - min(source.p0(:)));
% also rotate each image 180 degrees before plotting
source_p0_norm = rot90(source_p0_norm, 2);
imagesc(squeeze(source_p0_norm(:,:,250)));
axis image;
colormap(flipud(gray));
% only show 5 ticks on the colorbar
% colorbar('Ticks', linspace(0, 1, 5));
% remove the x and y ticks
set(gca, 'XTick', [], 'YTick', []);

%%
figure('Color','w');

% Normalize
source_p0_norm = (source.p0 - min(source.p0(:))) / ...
                 (max(source.p0(:)) - min(source.p0(:)));

% Rotate 180 degrees
source_p0_norm = rot90(source_p0_norm,2);

% Extract image
img = squeeze(source_p0_norm(:,:,250));

% vol_norm = (vol - min(vol(:))) / (max(vol(:)) - min(vol(:)));
% 
% % Rotate each image 180 degrees before plotting
% vol_norm = rot90(vol_norm, 2);
% 
% img = squeeze(vol_norm(:,:,250));

% H_norm = (H - min(H(:))) / (max(H(:)) - min(H(:)));
% 
% vol_norm = rot90(H_norm, 2);
% 
% img = squeeze(vol_norm(:,:,250));

% Display image
imagesc(img);
axis image;
axis off;
colormap(flipud(gray));

% Get image size
[H, W] = size(img);

% Set figure size to match image size
set(gcf, 'Units', 'pixels', 'Position', [100 100 W H]);

% Fill the figure while preserving aspect ratio
set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);

% Save
% exportgraphics(gca, 'img_001.jpg', 'Resolution', 300);

%% Here we will plot the a line fluence 

figure;
% normalize each slice to 0 to 1 before plotting
H_norm = (H - min(H(:))) / (max(H(:)) - min(H(:)));
% plot(squeeze(H_norm(44,:,252)));
plot(squeeze(H_norm(:,252,252)), 'LineWidth', 2.5, 'Color', [0.13 0.55 0.13]);
% make the color green and incrse the thickness of the line

% axis image;
% colormap(hot);
% colorbar;
% remove the x and y ticks
set(gca, 'XTick', [], 'YTick', []);


%% plot the signal present in sensor data 
figure;
sd = sensor_data;
sd_norm = (sd - min(sd(:))) / (max(sd(:)) - min(sd(:)));
imagesc(sd_norm');
% axis image;
colormap(gray);

% axis image;
axis off;
% colormap(flipud(gray));

% Get image size
[H, W] = size(img);

% Set figure size to match image size
set(gcf, 'Units', 'pixels', 'Position', [100 100 W H]);

% Fill the figure while preserving aspect ratio
set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);

