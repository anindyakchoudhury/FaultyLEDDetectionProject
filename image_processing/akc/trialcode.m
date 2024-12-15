clc; close all; clearvars;
% Read the reference and test images
ref_img = imread('reference.jpg');  % Your first image with complete pattern
test_img = imread('test.jpg');      % Your second image with missing LEDs

% Convert to HSV color space for better handling of illumination
ref_hsv = rgb2hsv(ref_img);
test_hsv = rgb2hsv(test_img);

% Extract intensity (Value) and Saturation channels
ref_intensity = ref_hsv(:,:,3);
test_intensity = test_hsv(:,:,3);
ref_saturation = ref_hsv(:,:,2);
test_saturation = test_hsv(:,:,2);

% Parameters for LED detection
%intensity_threshold = 0.7;  % Adjust based on your LED brightness
intensity_threshold = 0.7;  % Adjust based on your LED brightness
%saturation_threshold = 0.5; % Adjust based on LED color saturation
saturation_threshold = 0.5; % Adjust based on LED color saturation
min_blob_size = 20;        % Minimum size of LED blob in pixels

% Create masks for active LEDs in both images
ref_mask = (ref_intensity > intensity_threshold) & (ref_saturation > saturation_threshold);
test_mask = (test_intensity > intensity_threshold) & (test_saturation > saturation_threshold);

% Clean up masks using morphological operations
se = strel('disk', 2);
ref_mask = imopen(ref_mask, se);
test_mask = imopen(test_mask, se);

% Label connected components (LED regions)
[ref_labeled, ref_num] = bwlabel(ref_mask);
[test_labeled, test_num] = bwlabel(test_mask);

% Get properties of LED regions
ref_props = regionprops(ref_labeled, 'Centroid', 'Area', 'BoundingBox');
test_props = regionprops(test_labeled, 'Centroid', 'Area', 'BoundingBox');

% Filter out small blobs
ref_valid_idx = find([ref_props.Area] >= min_blob_size);
test_valid_idx = find([test_props.Area] >= min_blob_size);

% Create structured arrays for LED positions
ref_leds = struct('row', {}, 'col', {}, 'centroid', {}, 'intensity', {});
test_leds = struct('row', {}, 'col', {}, 'centroid', {}, 'intensity', {});

% LED grid parameters
grid_rows = 4;
grid_cols = 16;
img_height = size(ref_img, 1);
img_width = size(ref_img, 2);

% Map LED positions to grid coordinates
for i = 1:length(ref_valid_idx)
    centroid = ref_props(ref_valid_idx(i)).Centroid;
    row = round(centroid(2) * grid_rows / img_height);
    col = round(centroid(1) * grid_cols / img_width);
    intensity = mean(ref_intensity(ref_labeled == ref_valid_idx(i)));

    ref_leds(end+1) = struct('row', row, 'col', col, ...
        'centroid', centroid, 'intensity', intensity);
end

for i = 1:length(test_valid_idx)
    centroid = test_props(test_valid_idx(i)).Centroid;
    row = round(centroid(2) * grid_rows / img_height);
    col = round(centroid(1) * grid_cols / img_width);
    intensity = mean(test_intensity(test_labeled == test_valid_idx(i)));

    test_leds(end+1) = struct('row', row, 'col', col, ...
        'centroid', centroid, 'intensity', intensity);
end

% Find missing LEDs
% missing_leds = [];
% for i = 1:length(ref_leds)
%     ref_led = ref_leds(i);
%     found = false;

%     for j = 1:length(test_leds)
%         test_led = test_leds(j);
%         if ref_led.row == test_led.row && ref_led.col == test_led.col
%             % Compare intensity and spectral characteristics
%             intensity_diff = abs(ref_led.intensity - test_led.intensity);
%             if intensity_diff < 0.2  % Threshold for intensity difference
%                 found = true;
%                 break;
%             end
%         end
%     end

%     if ~found
%         missing_leds(end+1,:) = [ref_led.row, ref_led.col];
%     end
% end

% Find missing LEDs
missing_leds = [];
seen_positions = containers.Map('KeyType', 'char', 'ValueType', 'logical');

for i = 1:length(ref_leds)
    ref_led = ref_leds(i);
    found = false;

    for j = 1:length(test_leds)
        test_led = test_leds(j);
        if ref_led.row == test_led.row && ref_led.col == test_led.col
            % Compare intensity and spectral characteristics
            intensity_diff = abs(ref_led.intensity - test_led.intensity);
            if intensity_diff < 0.2  % Threshold for intensity difference
                found = true;
                break;
            end
        end
    end

    if ~found
        % Create a unique key for this position
        position_key = sprintf('%d_%d', ref_led.row, ref_led.col);

        % Only add if we haven't seen this position before
        if ~isKey(seen_positions, position_key)
            missing_leds(end+1,:) = [ref_led.row, ref_led.col];
            seen_positions(position_key) = true;
        end
    end
end

% Visualize results
figure;
subplot(2,2,1); imshow(ref_img); title('Reference Image');
subplot(2,2,2); imshow(test_img); title('Test Image');
subplot(2,2,3); imshow(ref_mask); title('Reference LED Mask');
subplot(2,2,4); imshow(test_mask); title('Test LED Mask');

% Display results
figure;
imshow(test_img);
hold on;
for i = 1:size(missing_leds, 1)
    row = missing_leds(i,1);
    col = missing_leds(i,2);
    % Convert grid coordinates back to image coordinates
    y = row * img_height / grid_rows;
    x = col * img_width / grid_cols;
    plot(x, y, 'yx', 'MarkerSize', 20, 'LineWidth', 2);
end
title('Missing LEDs Highlighted');

% Print missing LED positions
fprintf('Missing LEDs detected at positions:\n');
for i = 1:size(missing_leds, 1)
    fprintf('Row: %d, Column: %d\n', missing_leds(i,1), missing_leds(i,2));
end