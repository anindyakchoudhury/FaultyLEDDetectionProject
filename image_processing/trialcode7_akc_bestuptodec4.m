clc; close all; clearvars;

% requires comp vision toolbox


% Read and prepare images
ref_img = imread('cam_reference.jpg');
test_img = imread('cam_test.jpg');

% Convert images to grayscale for feature detection
ref_gray = rgb2gray(ref_img);
test_gray = rgb2gray(test_img);

% Detect features using SURF
ref_points = detectSURFFeatures(ref_gray);
test_points = detectSURFFeatures(test_gray);

% Extract features
[ref_features, ref_valid_points] = extractFeatures(ref_gray, ref_points);
[test_features, test_valid_points] = extractFeatures(test_gray, test_points);

% Match features
index_pairs = matchFeatures(ref_features, test_features);
matched_ref_points = ref_valid_points(index_pairs(:, 1));
matched_test_points = test_valid_points(index_pairs(:, 2));

% Estimate homography
[tform, inlier_ref_points, inlier_test_points] = estimateGeometricTransform2D(...
    matched_ref_points, matched_test_points, 'projective');

% Warp reference mask to test image space
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

ref_intensity = ref_hsv(:, :, 3);
ref_saturation = ref_hsv(:, :, 3);
test_intensity = test_hsv(:, :, 3);
test_saturation = test_hsv(:, :, 3);

intensity_threshold = 0.9;
saturation_threshold = 0.9 ;

% Create initial masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Transform reference mask to align with test image
output_view = imref2d(size(test_gray));
aligned_ref_mask = imwarp(ref_mask, tform, 'OutputView', output_view);

% Calculate grid parameters
[ref_height, ref_width] = size(ref_mask);
grid_rows = 4;
grid_cols = 16;

% Generate grid in reference image
ref_grid_x = linspace(1, ref_width, grid_cols + 1);
ref_grid_y = linspace(1, ref_height, grid_rows + 1);

% Map grid to test image
[test_grid_x, test_grid_y] = transformPointsForward(tform, ...
    repmat(ref_grid_x, grid_rows + 1, 1), ...
    repmat(ref_grid_y', 1, grid_cols + 1));

% Initialize missing LED list
missing_leds = [];

% Analyze each grid cell
for row = 1:grid_rows
    for col = 1:grid_cols
        % Get cell boundaries in the test image
        x_min = round(min(test_grid_x(row:row+1, col:col+1), [], 'all'));
        x_max = round(max(test_grid_x(row:row+1, col:col+1), [], 'all'));
        y_min = round(min(test_grid_y(row:row+1, col:col+1), [], 'all'));
        y_max = round(max(test_grid_y(row:row+1, col:col+1), [], 'all'));

        % Extract corresponding regions
        test_cell = test_mask(max(1, y_min):min(size(test_mask, 1), y_max), ...
                              max(1, x_min):min(size(test_mask, 2), x_max));
        ref_cell = aligned_ref_mask(max(1, y_min):min(size(aligned_ref_mask, 1), y_max), ...
                                    max(1, x_min):min(size(aligned_ref_mask, 2), x_max));

        % Analyze LED region
        [ref_ratio, ~] = analyzeCircularLED(ref_cell);
        [test_ratio, ~] = analyzeCircularLED(test_cell);

        % Detect missing LEDs
        if ref_ratio > 0.15 && (ref_ratio - test_ratio) > 0.15
            missing_leds(end+1, :) = [row, col];
        end
    end
end


% Visualization and Results (similar to before)
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

% Draw grid on the test image
for row = 1:grid_rows+1
    plot(test_grid_x(row, :), test_grid_y(row, :), 'b:', 'LineWidth', 1);
end
for col = 1:grid_cols+1
    plot(test_grid_x(:, col), test_grid_y(:, col), 'b:', 'LineWidth', 1);
end

% Mark missing LEDs with circles
for i = 1:size(missing_leds, 1)
    row = missing_leds(i, 1);
    col = missing_leds(i, 2);

    x_center = mean(test_grid_x(row:row+1, col:col+1), 'all');
    y_center = mean(test_grid_y(row:row+1, col:col+1), 'all');

    radius = min(diff(test_grid_x(row, col:col+1)), diff(test_grid_y(row:row+1, col)))/4;
    theta = linspace(0, 2*pi, 100);
    plot(x_center + radius*cos(theta), y_center + radius*sin(theta), 'y-', 'LineWidth', 2);
end
title('Aligned Grid and Missing LEDs');

fprintf('\nMissing LEDs detected at positions:\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i, 1), missing_leds(i, 2));
end

function [ratio, center] = analyzeCircularLED(cell_mask)
    % Analyze circular LED region within a cell
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