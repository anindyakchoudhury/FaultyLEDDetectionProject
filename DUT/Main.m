clc
close all;


cam = webcam();
cam.Resolution='1280x720';

% MATLAB Code to Validate Real-Time Sensor Data
serialPort = "COM5"; % Update with your Arduino's COM port
baudRate = 9600; % Match the Arduino baud rate

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

real_time_clock = 1;
led_num = 1;
time_period = 20;

% % % try
    while true
        % Read a line of data from the Arduino
        line = readline(arduino);
        %disp(sensorData)
        % Parse and extract sensor values
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        if ~isempty(matches)
            sensorID = str2double(matches{1}{1}); % Extract sensor ID (1-4)
            sensorValue = str2double(matches{1}{2}); % Extract sensor value
            sensorData(sensorID) = sensorValue; % Update sensor data for the specific sensor
            
            timestamp = datestr(now, 'HH_MM_SS');

            if mod(real_time_clock, time_period) == 0
                fprintf("LED Matrix # %d passed at time = %s. Moving on to another LED Matrix\n", led_num, timestamp)
                led_num = led_num + 1;
            end

            % Check if all 4 sensors have valid data
            if all(sensorData > 0) % Assuming valid sensor data is non-zero
                % Compare each sensor value to the corresponding reference
                differences = abs(sensorData - referenceValues);
                if any(differences > threshold)
                    mismatchCounter = mismatchCounter + 1; % Increment mismatch counter
                    %fprintf("Mismatch detected! Consecutive mismatches: %d\n", mismatchCounter);
                    
                    % Check if mismatch limit is reached
                    if mismatchCounter >= consecutiveMismatchLimit
                        % disp("Consecutive mismatches exceeded the limit. Terminating process.");
                        % disp("Sensor Data: "), disp(sensorData);
                        % disp("Reference Values: "), disp(referenceValues);
                        
                        fprintf("LED Matrix # %d failed in sensor. Moving to Image Processing...\n", led_num);
                        
                        intensity_increase_status = 0;
                        check_intensity = sensorData./referenceValues;
                        if(all(check_intensity > 1)) % Intensity has increased
                            intensity_increase_status = 1;
                        end

                        %initiate_image_processing_v3(ref_img,cam); 
                        initiate_image_processing_v5(cam, led_num, intensity_increase_status); 
                        %clear cam;
                        %break; % Terminate the process

                        % Ask user if they want to continue or terminate
                        while true
                            userInput = input('Do you want to continue the process? (Y/N): ', 's');
                            if strcmpi(userInput, 'N')
                                disp("Process terminated by user.");
                                break; % Exit the loop
                            elseif strcmpi(userInput, 'Y')
                                % Reset mismatch counter and continue
                                mismatchCounter = 0;
                                real_time_clock = 0;
                                led_num = led_num+1;
                                sensorData = zeros(1, 4);
                                clear arduino
                                arduino = serialport(serialPort, baudRate);
                                configureTerminator(arduino, "LF");
                                %pause(3);
                                disp("Continuing the process...");
                                break; % Exit the input loop
                            else
                                disp("Invalid input. Please enter 'Y' to continue or 'N' to terminate.");
                            end
                        end
                        
                        if strcmpi(userInput, 'N')
                            break; % Exit the main loop
                        end
                        
                        
                    end
                else
                    % Reset mismatch counter if data matches
                    mismatchCounter = 0;
                    % disp("Sensor data matches reference values.");
                end
            end
        end
        real_time_clock = real_time_clock + 1;

% %         Optional: Manual termination mechanism
% %         if ~isempty(get(groot, 'CurrentFigure'))
% %             userInput = input('Do you want to terminate the process? (yes/no): ', 's');
% %             if strcmpi(userInput, 'yes')
% %                 disp("Process terminated by user.");
% %                 break;
% %             end
% %         end
    end
% % % catch ME
% % %     disp("An error occurred:");
% % %     disp(ME.message);
% % % end

% Clean up
clear arduino;
disp("Serial communication ended.");

