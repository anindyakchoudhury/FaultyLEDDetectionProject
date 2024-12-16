function initiate_image_processing_v5(cam, led_num, intensity_increase_status)

try
    
    %Caputure Test Image
    img = snapshot(cam);
    cropRect = [21, 330, 1250, 400]; % x, y, width, height
    croppedImg = imcrop(img, cropRect);
    
    %disp("Test Image Captured");
    test_img = croppedImg;
    imwrite(test_img,"test1.jpg");
    
    % Set the base directory %be careful about this
    base_dir = pwd;

    % Create output directory if it doesn't exist
    report_dir = fullfile(base_dir, 'test_reports');
    if ~exist(report_dir, 'dir')
        mkdir(report_dir);
    end

    % Generate unique filename based on timestamp
    timestamp = datestr(now, 'HH_MM_SS');
    report_filename = fullfile(report_dir, ['LED_Test_Report_for_sample_' num2str(led_num) '_at_' timestamp]);

    % Create temporary directory for intermediate files
    temp_dir = fullfile(base_dir, 'temp');
    if ~exist(temp_dir, 'dir')
        mkdir(temp_dir);
    end

    % Create report generator object
    import mlreportgen.report.*;
    import mlreportgen.dom.*;

    rpt = Report(report_filename, 'pdf');

    % Add title page with correct properties
    tp = TitlePage;
    tp.Title = 'LED Array Test Report';
    tp.Author = 'Automated Test System';
    % Add date and time as subtitle instead
    tp.Subtitle = ['Test Date: ' datestr(now, 'dd-mmm-yyyy') newline ...
                  'Test Time: ' datestr(now, 'HH:MM:SS') newline ...
                  'Report For: LED Matrix # ' num2str(led_num)];
    add(rpt, tp);

    % Read and prepare images
    ref_img = imread(fullfile(base_dir, 'ref1.jpg'));
    test_img = imread(fullfile(base_dir, 'test1.jpg'));

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

    % Get bounding boxes for reference mask
    ref_stats = regionprops(ref_mask, 'BoundingBox', 'Area', 'PixelIdxList');
    ref_boxes = cat(1, ref_stats.BoundingBox);
    ref_areas = cat(1, ref_stats.Area);

    % Get bounding boxes for test mask
    test_stats = regionprops(test_mask, 'BoundingBox', 'Area');
    test_boxes = cat(1, test_stats.BoundingBox);
    test_areas = cat(1, test_stats.Area);

    % Sort reference boxes by y then x to create 4x16 grid
    [~, ref_order] = sortrows(ref_boxes, [2 1]);
    ref_boxes = ref_boxes(ref_order,:);
    ref_areas = ref_areas(ref_order);

    % Reshape into 4x16 grid
    grid_rows = 4;
    grid_cols = 16;
    ref_boxes_grid = reshape(ref_boxes, [grid_cols, grid_rows, 4]);
    ref_boxes_grid = permute(ref_boxes_grid, [2 1 3]);

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

    % Check each position in reference grid
    for row = 1:grid_rows
        for col = 1:grid_cols
            ref_box = ref_boxes_grid(row, col, :);
            if ~findMatchingBox(ref_box, test_boxes)
                missing_leds(end+1,:) = [row, col];
                test_ratios(row, col) = 0;
            end
        end
    end

    % Create visualization figure
    fig = figure('Name', 'LED Detection Results', 'Position', [100 100 1800 1000]); % Adjust figure size for larger subplots
    
    % Show original masks with black background
    subplot(2,3,1);
    imshow(ref_mask_display, [0 255]);
    set(gca, 'Color', 'k', 'Position', [0.05, 0.55, 0.25, 0.35]); % Adjust position and size
    title('Reference LED Mask', 'Color', 'k');
    
    subplot(2,3,2);
    imshow(test_mask_display, [0 255]);
    set(gca, 'Color', 'k', 'Position', [0.35, 0.55, 0.25, 0.35]); % Adjust position and size
    title('Test LED Mask', 'Color', 'k');
    
    % Show reference mask with all bounding boxes
    subplot(2,3,3);
    imshow(ref_mask_display, [0 255]);
    set(gca, 'Color', 'k', 'Position', [0.65, 0.55, 0.25, 0.35]); % Adjust position and size
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
    set(gca, 'Color', 'k', 'Position', [0.05, 0.1, 0.25, 0.35]); % Adjust position and size
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
    clim([0, 1]); % Set static colormap limits
    c = colorbar;
    c.Label.String = 'Intensity Ratio';
    title('LED Intensity Ratios');
    xlabel('Column');
    ylabel('Row');
    yticks(1:grid_rows);
    yticklabels(1:grid_rows);
    axis equal tight;
    set(gca, 'Position', [0.35, 0.1, 0.25, 0.35]); % Adjust position and size


    % Save figure for report with full path
    temp_figure_path = fullfile(temp_dir, 'temp_figure.png');
    print(fig, temp_figure_path, '-dpng', '-r300');
    close(fig);

    % Add content to report
    chapter = Chapter('Test Results');

    % Add test parameters
    sec = Section('Test Parameters');
    para = Paragraph(['Test conducted on: ' datestr(now, 'dd-mmm-yyyy HH:MM:SS')]);
    add(sec, para);

    paraParams = Paragraph(sprintf(['Intensity Threshold: %.2f\n' ...
        'Saturation Threshold: %.2f\n' ...
        'Grid Size: %dx%d'], ...
        intensity_threshold, saturation_threshold, grid_rows, grid_cols));
    add(sec, paraParams);
    add(chapter, sec);

    % Add results section
    sec = Section('Test Results');

    % Add test summary
    para = Paragraph('Test Summary:');
    add(sec, para);

    % Create summary table
    summary_data = {...
        'Description', 'Value'; ...
        'Total LEDs', num2str(grid_rows * grid_cols); ...
        'Working LEDs', num2str(size(test_boxes, 1)); ...
        'Missing LEDs', num2str(size(missing_leds, 1))};

    table = FormalTable(summary_data);
    table.Style = {Border('solid'), Width('100%')};
    add(sec, table);
    

    % Add pass/fail status
    if(intensity_increase_status) 
        status = Paragraph('TEST STATUS: FAIL, INTENSITY NOT WITHIN LIMIT');
    elseif isempty(missing_leds)
        status = Paragraph('TEST STATUS: PASS');
        status.Style = {Color('green'), Bold(true)};
    else
        status = Paragraph('TEST STATUS: FAIL, MISSING LEDs');
        status.Style = {Color('red'), Bold(true)};

        % Add failed LED positions
        para = Paragraph('Failed LED Positions:');
        add(sec, para);

        failed_positions = cell(size(missing_leds, 1) + 1, 2);
        failed_positions(1,:) = {'Row', 'Column'};
        for i = 1:size(missing_leds, 1)
            failed_positions(i+1,:) = {num2str(missing_leds(i,1)), ...
                num2str(missing_leds(i,2))};
        end

        table = FormalTable(failed_positions);
        table.Style = {Border('solid'), Width('50%')};
        add(sec, table);
    end
    add(sec, status);

    % Add visualization
    img = Image(temp_figure_path);
    img.Style = {Width('6in')};
    add(sec, img);

    add(chapter, sec);
    add(rpt, chapter);

    % Close and generate the report
    close(rpt);

    % Clean up temporary files
    delete(temp_figure_path);

    % Remove temporary directory if empty
    if exist(temp_dir, 'dir')
        rmdir(temp_dir);
    end

    fprintf('Report generated successfully: %s.pdf\n', report_filename);

catch ME
    fprintf('Error generating report: %s\n', ME.message);
    fprintf('Error details: %s\n', getReport(ME, 'extended'));
end

% Helper functions
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
end