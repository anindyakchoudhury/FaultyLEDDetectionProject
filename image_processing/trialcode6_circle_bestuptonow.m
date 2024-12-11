clc; close all; clearvars;
%akc
% Read and prepare images (same as before)
ref_img = imread('cam_reference.jpg');
test_img = imread('cam_test.jpg');

% Convert to HSV and create masks (same as before)
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

ref_hue = ref_hsv(:,:,1);
test_hue = test_hsv(:,:,1);
ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters
hue_threshold_upper = 0.05;
hue_threshold_lower = 0.95;
intensity_threshold = 0.1;
saturation_threshold = 0.1;

% Create initial masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold) & ((ref_hue > hue_threshold_lower) | (ref_hue < hue_threshold_upper));
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold) & ((test_hue > hue_threshold_lower) | (test_hue < hue_threshold_upper));

% Clean up masks using circular structuring element 
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Get dimensions and calculate grid parameters
[ref_height, ref_width] = size(ref_mask);
[test_height, test_width] = size(test_mask);

grid_rows = 4;
grid_cols = 16;

ref_cell_height = floor(ref_height/grid_rows);
ref_cell_width = floor(ref_width/grid_cols);
test_cell_height = floor(test_height/grid_rows);
test_cell_width = floor(test_width/grid_cols);



% Initialize storage arrays
ref_ratios = zeros(grid_rows, grid_cols);
test_ratios = zeros(grid_rows, grid_cols);
missing_leds = [];

% Analyze each grid cell
for row = 1:grid_rows
    for col = 1:grid_cols
        % Calculate cell boundaries for both masks
        ref_row_start = (row-1)*ref_cell_height + 1;
        ref_row_end = min(row*ref_cell_height, ref_height);
        ref_col_start = (col-1)*ref_cell_width + 1;
        ref_col_end = min(col*ref_cell_width, ref_width);

        test_row_start = (row-1)*test_cell_height + 1;
        test_row_end = min(row*test_cell_height, test_height);
        test_col_start = (col-1)*test_cell_width + 1;
        test_col_end = min(col*test_cell_width, test_width);

        % Extract cell regions
        ref_cell = ref_mask(ref_row_start:ref_row_end, ref_col_start:ref_col_end);
        test_cell = test_mask(test_row_start:test_row_end, test_col_start:test_col_end);

        % Analyze circular LED regions
        [ref_ratio, ref_center] = analyzeCircularLED(ref_cell);
        [test_ratio, test_center] = analyzeCircularLED(test_cell);

        % Store ratios
        ref_ratios(row, col) = ref_ratio;
        test_ratios(row, col) = test_ratio;

        % Detect missing LEDs with improved threshold
        if ref_ratio > 0.15 && (ref_ratio - test_ratio) > 0.15
            missing_leds(end+1,:) = [row, col];
        end
    end
end

% Visualization (same as before but with added circle visualization)
figure('Name', 'LED Detection Results', 'Position', [100 100 1200 800]);

% Original visualizations
subplot(2,3,1); imshow(ref_img); title('Reference Image');
subplot(2,3,2); imshow(test_img); title('Test Image');
subplot(2,3,3); imshow(ref_mask); title('Reference LED Mask');
subplot(2,3,4); imshow(test_mask); title('Test LED Mask');

% Grid and missing LEDs visualization
subplot(2,3,5);
imshow(test_img);
hold on;

% Draw grid
for row = 1:grid_rows
    y = row*test_cell_height;
    line([1 test_width], [y y], 'Color', 'b', 'LineStyle', ':');
end
for col = 1:grid_cols
    x = col*test_cell_width;
    line([x x], [1 test_height], 'Color', 'b', 'LineStyle', ':');
end

% Mark missing LEDs with circles instead of X marks
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    y = (row-0.5)*test_cell_height;
    x = (col-0.5)*test_cell_width;

    % Draw circle marker
    radius = min(test_cell_height, test_cell_width)/4;
    theta = 0:0.1:2*pi;
    circle_x = x + radius*cos(theta);
    circle_y = y + radius*sin(theta);
    plot(circle_x, circle_y, 'y-', 'LineWidth', 2);
end
title('Grid and Missing LEDs (Circular)');

% Intensity ratios heatmap
subplot(2,3,6);
imagesc(test_ratios);
colormap('jet');
colorbar;
title('LED Intensity Ratios');
xlabel('Column');
ylabel('Row');
axis equal tight;

% Print results (same as before)
fprintf('\nMissing LEDs detected at positions:\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

fprintf('\nAnalysis Summary:\n');
fprintf('Reference image size: %dx%d\n', ref_height, ref_width);
fprintf('Test image size: %dx%d\n', test_height, test_width);
fprintf('Missing LEDs: %d\n', size(missing_leds, 1));
fprintf('Average reference ratio: %.3f\n', mean(ref_ratios(:)));
fprintf('Average test ratio: %.3f\n', mean(test_ratios(:)));

% Function to analyze circular LED region
function [ratio, center] = analyzeCircularLED(cell_mask)
    % Find the center of the potential LED in the cell
    [y, x] = find(cell_mask);
    if isempty(y)
        ratio = 0;
        center = [0, 0];
        return;
    end

    % Calculate center of mass
    center_x = mean(x);
    center_y = mean(y);

    % Create circular mask for analysis
    [XX, YY] = meshgrid(1:size(cell_mask,2), 1:size(cell_mask,1));
    radius = min(size(cell_mask))/4;  % Adjust radius based on LED size
    circular_region = ((XX-center_x).^2 + (YY-center_y).^2 <= radius^2);

    % Calculate ratio only within circular region
    ratio = sum(cell_mask(circular_region)) / sum(circular_region(:));
    center = [center_x, center_y];
end