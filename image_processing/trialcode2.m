clc; close all; clearvars;
% this code perfectly works if the ref image and test image are matched pixel to pixel
% Read the reference and test images
ref_img = imread('reference.jpg');  % Your first image with complete pattern
test_img = imread('test2.jpg');      % Your second image with missing LEDs

% Convert to HSV color space for better handling of illumination
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

% Extract intensity (Value) and Saturation channels
ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters for LED detection
intensity_threshold = 0.7;  % Adjust based on your LED brightness
saturation_threshold = 0.5; % Adjust based on LED color saturation
min_blob_size = 20;        % Minimum size of LED blob in pixels

% Create masks for active LEDs in both images
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Clean up masks using morphological operations
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Get dimensions of the mask
[height, width] = size(test_mask);

% LED grid parameters
grid_rows = 4;
grid_cols = 16;

% Calculate cell dimensions
cell_height = floor(height/grid_rows);
cell_width = floor(width/grid_cols);

% Initialize arrays to store white pixel ratios
ref_ratios = zeros(grid_rows, grid_cols);
test_ratios = zeros(grid_rows, grid_cols);
missing_leds = [];

% Analyze each grid cell
for row = 1:grid_rows
    for col = 1:grid_cols
        % Calculate cell boundaries
        row_start = (row-1)*cell_height + 1;
        row_end = min(row*cell_height, height);
        col_start = (col-1)*cell_width + 1;
        col_end = min(col*cell_width, width);

        % Extract cell regions from both masks
        ref_cell = ref_mask(row_start:row_end, col_start:col_end);
        test_cell = test_mask(row_start:row_end, col_start:col_end);

        % Calculate white pixel ratios
        ref_ratio = sum(ref_cell(:)) / numel(ref_cell);
        test_ratio = sum(test_cell(:)) / numel(test_cell);

        % Store ratios
        ref_ratios(row, col) = ref_ratio;
        test_ratios(row, col) = test_ratio;

        % Compare ratios to detect missing LEDs
        % If reference has significant white pixels but test doesn't
        if ref_ratio > 0.1 && (ref_ratio - test_ratio) > 0.1
            missing_leds(end+1,:) = [row, col];
        end
    end
end

% Visualize results
figure('Name', 'LED Detection Results', 'Position', [100 100 1200 800]);

% Original Images and Masks
subplot(2,3,1);
imshow(ref_img);
title('Reference Image');

subplot(2,3,2);
imshow(test_img);
title('Test Image');

subplot(2,3,3);
imshow(ref_mask);
title('Reference LED Mask');

subplot(2,3,4);
imshow(test_mask);
title('Test LED Mask');

% Visualize the grid cells and missing LEDs
subplot(2,3,5);
imshow(test_img);
hold on;

% Draw grid
for row = 1:grid_rows
    y = row*cell_height;
    line([1 width], [y y], 'Color', 'b', 'LineStyle', ':');
end
for col = 1:grid_cols
    x = col*cell_width;
    line([x x], [1 height], 'Color', 'b', 'LineStyle', ':');
end

% Mark missing LEDs
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    % Calculate center of the cell
    y = (row-0.5)*cell_height;
    x = (col-0.5)*cell_width;
    plot(x, y, 'yx', 'MarkerSize', 20, 'LineWidth', 2);
end
title('Grid and Missing LEDs');

% Visualize intensity ratios
subplot(2,3,6);
imagesc(test_ratios);
colormap('jet');
colorbar;
title('LED Intensity Ratios');
xlabel('Column');
ylabel('Row');
axis equal tight;

% Print missing LED positions
fprintf('\nMissing LEDs detected at positions:\n');
fprintf('--------------------------------\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

% Add detailed analysis to command window
fprintf('\nAnalysis Summary:\n');
fprintf('----------------\n');
fprintf('Total LEDs in grid: %d\n', grid_rows * grid_cols);
fprintf('Number of missing LEDs detected: %d\n', size(missing_leds, 1));
fprintf('Average intensity ratio in reference mask: %.3f\n', mean(ref_ratios(:)));
fprintf('Average intensity ratio in test mask: %.3f\n', mean(test_ratios(:)));