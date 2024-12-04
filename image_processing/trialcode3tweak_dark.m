clc; close all; clearvars;
% it is same code as trialcode 2, but it does not have any dependency on becoming equal dimension ref and test
% however shifting image like reference.jpg and test.jpg cannot be detected
% if positionally accurate, then it works.


% intensity_threshold changed for dark as chinu taken with his mobile


% Read the reference and test images
ref_img = imread('cinutaken_dark.jpg');
test_img = imread('dark_edited_2.jpg');

% Convert to HSV color space
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

% Extract intensity and Saturation channels
ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters for LED detection
intensity_threshold = 0.5;
saturation_threshold = 0.5;

% Create masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Clean up masks
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Get dimensions of both masks
[ref_height, ref_width] = size(ref_mask);
[test_height, test_width] = size(test_mask);

% LED grid parameters
grid_rows = 4;
grid_cols = 16;

% Calculate cell dimensions for both masks separately
ref_cell_height = floor(ref_height/grid_rows);
ref_cell_width = floor(ref_width/grid_cols);
test_cell_height = floor(test_height/grid_rows);
test_cell_width = floor(test_width/grid_cols);

% Initialize arrays to store white pixel ratios
ref_ratios = zeros(grid_rows, grid_cols);
test_ratios = zeros(grid_rows, grid_cols);
missing_leds = [];

% Analyze each grid cell
for row = 1:grid_rows
    for col = 1:grid_cols
        % Calculate cell boundaries for reference mask
        ref_row_start = (row-1)*ref_cell_height + 1;
        ref_row_end = min(row*ref_cell_height, ref_height);
        ref_col_start = (col-1)*ref_cell_width + 1;
        ref_col_end = min(col*ref_cell_width, ref_width);

        % Calculate cell boundaries for test mask
        test_row_start = (row-1)*test_cell_height + 1;
        test_row_end = min(row*test_cell_height, test_height);
        test_col_start = (col-1)*test_cell_width + 1;
        test_col_end = min(col*test_cell_width, test_width);

        % Extract cell regions from both masks
        ref_cell = ref_mask(ref_row_start:ref_row_end, ref_col_start:ref_col_end);
        test_cell = test_mask(test_row_start:test_row_end, test_col_start:test_col_end);

        % Calculate white pixel ratios
        ref_ratio = sum(ref_cell(:)) / numel(ref_cell);
        test_ratio = sum(test_cell(:)) / numel(test_cell);

        % Store ratios
        ref_ratios(row, col) = ref_ratio;
        test_ratios(row, col) = test_ratio;

        % Compare ratios to detect missing LEDs
        if ref_ratio > 0.1 && (ref_ratio - test_ratio) > 0.1
            missing_leds(end+1,:) = [row, col];
        end
    end
end

% Visualization code remains the same as before but using test_cell_height and test_cell_width
figure('Name', 'LED Detection Results', 'Position', [100 100 1200 800]);

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

% Draw grid using test image dimensions
for row = 1:grid_rows
    y = row*test_cell_height;
    line([1 test_width], [y y], 'Color', 'b', 'LineStyle', ':');
end
for col = 1:grid_cols
    x = col*test_cell_width;
    line([x x], [1 test_height], 'Color', 'b', 'LineStyle', ':');
end

% Mark missing LEDs
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    % Calculate center of the cell
    y = (row-0.5)*test_cell_height;
    x = (col-0.5)*test_cell_width;
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

% Print results
fprintf('\nMissing LEDs detected at positions:\n');
fprintf('--------------------------------\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

% Print analysis summary
fprintf('\nAnalysis Summary:\n');
fprintf('----------------\n');
fprintf('Reference image size: %dx%d\n', ref_height, ref_width);
fprintf('Test image size: %dx%d\n', test_height, test_width);
fprintf('Number of missing LEDs detected: %d\n', size(missing_leds, 1));
fprintf('Average intensity ratio in reference mask: %.3f\n', mean(ref_ratios(:)));
fprintf('Average intensity ratio in test mask: %.3f\n', mean(test_ratios(:)));