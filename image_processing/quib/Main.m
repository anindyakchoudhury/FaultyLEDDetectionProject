close all;


% MATLAB Code to Validate Real-Time Sensor Data
serialPort = "COM5"; % Update with your Arduino's COM port
baudRate = 9600; % Match the Arduino baud rate

cam = webcam();
cam.Resolution='1280x720';
pause(3);
ref_img = snapshot(cam);
cropRect = [21, 330, 1250, 400]; % x=0, y=, width=, height=
croppedImg = imcrop(ref_img, cropRect);
ref_img = croppedImg;
imwrite(ref_img,"ref1.jpg");

% Load reference values
if exist('referenceValues.mat', 'file')
    load('referenceValues.mat', 'referenceValues');
    if length(referenceValues) ~= 4
        error("The reference values file must contain data for 4 sensors.");
    end
else
    error("Reference values file not found. Run the first script to generate it.");
end

% Initialize serial communication
arduino = serialport(serialPort, baudRate);
configureTerminator(arduino, "LF");

disp("Checking real-time sensor data against reference values...");
sensorData = zeros(1, 4); % Initialize sensor data array for 4 sensors
threshold = 1; % Tolerance for matching each sensor value
consecutiveMismatchLimit = 10; % Number of consecutive mismatches allowed
mismatchCounter = 0; % Counter for consecutive mismatches

try
    while true
        % Read a line of data from the Arduino
        line = readline(arduino);
        
        % Parse and extract sensor values
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        if ~isempty(matches)
            sensorID = str2double(matches{1}{1}); % Extract sensor ID (1-4)
            sensorValue = str2double(matches{1}{2}); % Extract sensor value
            sensorData(sensorID) = sensorValue; % Update sensor data for the specific sensor

            % Check if all 4 sensors have valid data
            if all(sensorData > 0) % Assuming valid sensor data is non-zero
                % Compare each sensor value to the corresponding reference
                differences = abs(sensorData - referenceValues);
                if any(differences > threshold)
                    mismatchCounter = mismatchCounter + 1; % Increment mismatch counter
                    fprintf("Mismatch detected! Consecutive mismatches: %d\n", mismatchCounter);
                    
                    % Check if mismatch limit is reached
                    if mismatchCounter >= consecutiveMismatchLimit
                        disp("Consecutive mismatches exceeded the limit. Terminating process.");
                        disp("Sensor Data: "), disp(sensorData);
                        disp("Reference Values: "), disp(referenceValues);
                        
                        

                        %initiate_image_processing_v3(ref_img,cam); 
                        initiate_image_processing_v4(ref_img,cam); 
                        clear cam;
                        break; % Terminate the process
                        
                    end
                else
                    % Reset mismatch counter if data matches
                    mismatchCounter = 0;
                    disp("Sensor data matches reference values.");
                end
            end
        end

% %         Optional: Manual termination mechanism
% %         if ~isempty(get(groot, 'CurrentFigure'))
% %             userInput = input('Do you want to terminate the process? (yes/no): ', 's');
% %             if strcmpi(userInput, 'yes')
% %                 disp("Process terminated by user.");
% %                 break;
% %             end
% %         end
    end
catch ME
    disp("An error occurred:");
    disp(ME.message);
end

% Clean up
clear arduino;
disp("Serial communication ended.");


