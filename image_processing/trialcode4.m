clc; close all; clearvars;

% this code is working fine for the reference and test(shifted picture)
% but getting messed up with the glow surrounding my own made up picture white doodled

% Read the reference and test images
ref_img = imread('ref2.jpg');
test_img = imread('test5.jpg');

% Convert to HSV color space
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

% Extract intensity and Saturation channels
ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters for LED detection
intensity_threshold = 0.6;
saturation_threshold = 0.5;

% Create masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Clean up masks
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Get dimensions
[ref_height, ref_width] = size(ref_mask);
[test_height, test_width] = size(test_mask);

% LED grid parameters
grid_rows = 4;
grid_cols = 16;

% Function to detect LED centers in a mask
function centers = detectLEDCenters(mask)
    % Label connected components
    [labeled, num] = bwlabel(mask);
    stats = regionprops(labeled, 'Centroid');
    centers = zeros(num, 2);
    for i = 1:num
        centers(i,:) = stats(i).Centroid;
    end
    % Sort centers by x coordinate, then by y
    [~, idx] = sortrows(centers, [2 1]);
    centers = centers(idx,:);
end

% Get LED centers for both masks
ref_centers = detectLEDCenters(ref_mask);
test_centers = detectLEDCenters(test_mask);

% Calculate average spacing between LEDs in reference
ref_x_spacing = median(diff(ref_centers(:,1)));
ref_y_spacing = median(diff(ref_centers(:,2)));

% Initialize grid for both masks
ref_grid = zeros(grid_rows, grid_cols);
test_grid = zeros(grid_rows, grid_cols);

% Function to assign LEDs to grid positions
function grid = assignToGrid(centers, grid_rows, grid_cols)
    grid = zeros(grid_rows, grid_cols);
    num_leds = size(centers, 1);
    
    % Find minimum and maximum x,y coordinates
    min_x = min(centers(:,1));
    max_x = max(centers(:,1));
    min_y = min(centers(:,2));
    max_y = max(centers(:,2));
    
    % Calculate cell sizes
    cell_width = (max_x - min_x) / (grid_cols - 1);
    cell_height = (max_y - min_y) / (grid_rows - 1);
    
    % Assign LEDs to grid positions
    for i = 1:num_leds
        col = round((centers(i,1) - min_x) / cell_width) + 1;
        row = round((centers(i,2) - min_y) / cell_height) + 1;
        
        % Ensure indices are within bounds
        col = max(1, min(col, grid_cols));
        row = max(1, min(row, grid_rows));
        
        grid(row, col) = 1;
    end
end

% Create grids
ref_grid = assignToGrid(ref_centers, grid_rows, grid_cols);
test_grid = assignToGrid(test_centers, grid_rows, grid_cols);

% Find missing LEDs by comparing grids
missing_leds = [];
for row = 1:grid_rows
    for col = 1:grid_cols
        if ref_grid(row, col) == 1 && test_grid(row, col) == 0
            missing_leds(end+1,:) = [row, col];
        end
    end
end

% Visualization
figure('Name', 'LED Detection Results', 'Position', [100 100 1200 800]);

subplot(2,3,1);
imshow(ref_img);
title('Reference Image');
hold on;
plot(ref_centers(:,1), ref_centers(:,2), 'r+');

subplot(2,3,2);
imshow(test_img);
title('Test Image');
hold on;
plot(test_centers(:,1), test_centers(:,2), 'r+');

subplot(2,3,3);
imshow(ref_mask);
title('Reference LED Mask');

subplot(2,3,4);
imshow(test_mask);
title('Test LED Mask');

% Visualize grids
subplot(2,3,5);
imagesc(ref_grid);
title('Reference Grid');
colormap('gray');
axis equal tight;
grid on;

subplot(2,3,6);
imagesc(test_grid);
title('Test Grid with Missing LEDs');
hold on;
% Mark missing LEDs
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    plot(col, row, 'rx', 'MarkerSize', 15, 'LineWidth', 2);
end
axis equal tight;
grid on;

% Print results
fprintf('\nMissing LEDs detected at positions:\n');
fprintf('--------------------------------\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

fprintf('\nAnalysis Summary:\n');
fprintf('----------------\n');
fprintf('Number of LEDs detected in reference: %d\n', size(ref_centers, 1));
fprintf('Number of LEDs detected in test: %d\n', size(test_centers, 1));
fprintf('Number of missing LEDs: %d\n', size(missing_leds, 1));