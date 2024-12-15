clc; close all; clearvars;

% Read and prepare images
ref_img = imread('final.jpg');
test_img = imread('final_f.jpg');

% Convert to HSV and create masks
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters
intensity_threshold = 0.7;
saturation_threshold = 0.2;

% Create initial masks
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation < saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation < saturation_threshold);

% Clean up masks using circular structuring element
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Create black and white masks (255 for white, 0 for black)
ref_mask_display = uint8(ref_mask) * 255;
test_mask_display = uint8(test_mask) * 255;

% Set figure background to black
set(0, 'defaultfigurecolor', [1 1 1]);

% Get bounding boxes for reference mask
ref_stats = regionprops(ref_mask, 'BoundingBox', 'Area', 'PixelIdxList');
ref_boxes = cat(1, ref_stats.BoundingBox);
ref_areas = cat(1, ref_stats.Area);

% Get bounding boxes for test mask
test_stats = regionprops(test_mask, 'BoundingBox', 'Area');
test_boxes = cat(1, test_stats.BoundingBox);
test_areas = cat(1, test_stats.Area);

% Sort reference boxes by y then x to create 4x16 grid
[~, ref_order] = sortrows(ref_boxes, [2 1]);  % Sort by y then x
ref_boxes = ref_boxes(ref_order,:);
ref_areas = ref_areas(ref_order);

% Reshape into 4x16 grid
grid_rows = 4;
grid_cols = 16;
ref_boxes_grid = reshape(ref_boxes, [grid_cols, grid_rows, 4]);
ref_boxes_grid = permute(ref_boxes_grid, [2 1 3]);  % Make it rows x cols

% Function to analyze LED region
function ratio = analyzeLEDIntensity(box, intensity_img, mask_img)
    % Get the region within the bounding box
    x1 = max(1, round(box(1)));
    y1 = max(1, round(box(2)));
    x2 = min(size(intensity_img,2), round(box(1) + box(3)));
    y2 = min(size(intensity_img,1), round(box(2) + box(4)));

    % Extract the region
    region_mask = logical(mask_img(y1:y2, x1:x2));
    region_intensity = intensity_img(y1:y2, x1:x2);

    % If no LED detected, return 0
    if sum(region_mask(:)) == 0
        ratio = 0;
        return;
    end

    % Calculate average intensity where the mask is true
    ratio = mean(region_intensity(region_mask));
end

% Initialize intensity ratio grids
test_ratios = zeros(grid_rows, grid_cols);

% Calculate intensity ratios for test image
for row = 1:grid_rows
    for col = 1:grid_cols
        box = ref_boxes_grid(row, col, :);
        test_ratios(row, col) = analyzeLEDIntensity(box, test_intensity, test_mask);
    end
end

% Initialize array to store missing LEDs
missing_leds = [];

% Function to check if a box exists at similar position
function found = findMatchingBox(ref_box, test_boxes)
    if isempty(test_boxes)
        found = false;
        return;
    end

    ref_center = [ref_box(1) + ref_box(3)/2, ref_box(2) + ref_box(4)/2];
    for i = 1:size(test_boxes, 1)
        test_center = [test_boxes(i,1) + test_boxes(i,3)/2, ...
                      test_boxes(i,2) + test_boxes(i,4)/2];
        if norm(ref_center - test_center) < max(ref_box(3), ref_box(4))
            found = true;
            return;
        end
    end
    found = false;
end

% Check each position in reference grid
for row = 1:grid_rows
    for col = 1:grid_cols
        ref_box = ref_boxes_grid(row, col, :);
        if ~findMatchingBox(ref_box, test_boxes)
            missing_leds(end+1,:) = [row, col];
            % Set intensity ratio to 0 for missing LEDs
            test_ratios(row, col) = 0;
        end
    end
end

% Create figure with 5 subplots
figure('Name', 'LED Detection Results', 'Position', [100 100 1500 800]);

% Show original masks with black background
subplot(2,3,1);
imshow(ref_mask_display, [0 255]);
set(gca, 'Color', 'k');  % Set axes background to black
title('Reference LED Mask', 'Color', 'k');

subplot(2,3,2);
imshow(test_mask_display, [0 255]);
set(gca, 'Color', 'k');  % Set axes background to black
title('Test LED Mask', 'Color', 'k');

% Show reference mask with all bounding boxes
subplot(2,3,3);
imshow(ref_mask_display, [0 255]);
set(gca, 'Color', 'k');  % Set axes background to black
hold on;
for row = 1:grid_rows
    for col = 1:grid_cols
        box = ref_boxes_grid(row, col, :);
        rectangle('Position', box, 'EdgeColor', 'b', 'LineWidth', 1);
    end
end
title('Reference Mask with Bounding Boxes', 'Color', 'k');

% Show test image with reference boxes and missing LEDs highlighted
subplot(2,3,4);
imshow(test_mask_display, [0 255]);
set(gca, 'Color', 'k');  % Set axes background to black
hold on;

% Draw all reference boxes in blue
for row = 1:grid_rows
    for col = 1:grid_cols
        box = ref_boxes_grid(row, col, :);
        rectangle('Position', box, 'EdgeColor', 'b', 'LineWidth', 1);
    end
end

% Highlight missing LEDs in red
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    box = ref_boxes_grid(row, col, :);
    rectangle('Position', box, 'EdgeColor', 'r', 'LineWidth', 2);
end
title('Missing LEDs Highlighted', 'Color', 'k');

% Add LED intensity ratio plot
subplot(2,3,5);
imagesc(test_ratios);
colormap('jet');
c = colorbar;
c.Label.String = 'Intensity Ratio';
title('LED Intensity Ratios');
xlabel('Column');
ylabel('Row');
yticks(1:grid_rows);
yticklabels(1:grid_rows);
axis equal tight;

% Print results
fprintf('\nMissing LEDs detected at positions:\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end

fprintf('\nAnalysis Summary:\n');
fprintf('Total LEDs in reference: %d\n', grid_rows * grid_cols);
fprintf('Total LEDs in test: %d\n', size(test_boxes, 1));
fprintf('Missing LEDs: %d\n', size(missing_leds, 1));