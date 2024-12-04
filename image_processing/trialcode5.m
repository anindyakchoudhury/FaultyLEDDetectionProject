clc; close all; clearvars;

% Read the reference and test images
ref_img = imread('reference.jpg');
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
intensity_threshold = 0.7;
saturation_threshold = 0.5;

% Create initial masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Clean up masks
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Align test mask with reference mask using cross-correlation
c = normxcorr2(ref_mask, test_mask);
[ypeak, xpeak] = find(c==max(c(:)));
yoffset = ypeak - size(ref_mask,1);
xoffset = xpeak - size(ref_mask,2);

% Create aligned test mask
aligned_test_mask = zeros(size(ref_mask));
ybegin = max(1, yoffset + 1);
yend = min(size(ref_mask,1), yoffset + size(test_mask,1));
xbegin = max(1, xoffset + 1);
xend = min(size(ref_mask,2), xoffset + size(test_mask,2));

test_yrange = (ybegin - yoffset):(yend - yoffset);
test_xrange = (xbegin - xoffset):(xend - xoffset);
aligned_test_mask(ybegin:yend, xbegin:xend) = test_mask(test_yrange, test_xrange);

% Get dimensions
[height, width] = size(ref_mask);

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

% Function to calculate LED intensity in a cell considering circular shape
function ratio = calculateLEDRatio(cell_mask)
    % Find the center of mass of white pixels
    [y, x] = find(cell_mask);
    if isempty(y)
        ratio = 0;
        return;
    end
    center_y = mean(y);
    center_x = mean(x);
    
    % Create a circular mask around the center
    [XX, YY] = meshgrid(1:size(cell_mask,2), 1:size(cell_mask,1));
    radius = min(size(cell_mask))/4;  % Adjust radius as needed
    circle_mask = ((XX-center_x).^2 + (YY-center_y).^2 <= radius^2);
    
    % Calculate ratio only within the circular region
    white_pixels = sum(cell_mask(circle_mask));
    total_pixels = sum(circle_mask(:));
    ratio = white_pixels / total_pixels;
end

% Analyze each grid cell
for row = 1:grid_rows
    for col = 1:grid_cols
        % Calculate cell boundaries
        row_start = (row-1)*cell_height + 1;
        row_end = min(row*cell_height, height);
        col_start = (col-1)*cell_width + 1;
        col_end = min(col*cell_width, width);

        % Extract cell regions
        ref_cell = ref_mask(row_start:row_end, col_start:col_end);
        test_cell = aligned_test_mask(row_start:row_end, col_start:col_end);

        % Calculate LED ratios considering circular shape
        ref_ratio = calculateLEDRatio(ref_cell);
        test_ratio = calculateLEDRatio(test_cell);

        % Store ratios
        ref_ratios(row, col) = ref_ratio;
        test_ratios(row, col) = test_ratio;

        % Compare ratios to detect missing LEDs
        if ref_ratio > 0.1 && (ref_ratio - test_ratio) > 0.1
            missing_leds(end+1,:) = [row, col];
        end
    end
end

% Visualization
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
imshow(aligned_test_mask);
title('Aligned Test LED Mask');

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

% Print results
fprintf('\nImage Alignment Info:\n');
fprintf('-------------------\n');
fprintf('X offset: %d pixels\n', xoffset);
fprintf('Y offset: %d pixels\n', yoffset);

fprintf('\nMissing LEDs detected at positions:\n');
fprintf('--------------------------------\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

fprintf('\nAnalysis Summary:\n');
fprintf('----------------\n');
fprintf('Number of missing LEDs detected: %d\n', size(missing_leds, 1));
fprintf('Average intensity ratio in reference mask: %.3f\n', mean(ref_ratios(:)));
fprintf('Average intensity ratio in aligned test mask: %.3f\n', mean(test_ratios(:)));