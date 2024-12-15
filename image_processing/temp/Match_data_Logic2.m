% MATLAB Code to Validate Real-Time Sensor Data Using New Mismatch Logic
serialPort = "COM9"; % Update with your Arduino's COM port
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
thresholdCornerHigh = 3; % Threshold for corners to terminate directly
thresholdCornerLow = 1; % Threshold for corners to check middle sensors
thresholdMiddle = 1; % Threshold for middle sensors
consecutiveMismatchLimit = 10; % Number of consecutive mismatches allowed
mismatchCounter = 0; % Counter for consecutive mismatches

try
    while true
        % Read a line of data from the Arduino
        line = readline(arduino);
        
        % Parse and extract sensor values
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        % Parse and extract sensor values
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");

        if ~isempty(matches)
            sensorID = str2double(matches{1}{1}); % Extract sensor ID (1-4)
            sensorValue = str2double(matches{1}{2}); % Extract sensor value
            sensorData(sensorID) = sensorValue; % Update sensor data for the specific sensor

            % Display the current sensor data
            fprintf("Sensor Data: Sensor 1: %d, Sensor 2: %d, Sensor 3: %d, Sensor 4: %d\n", ...
                    sensorData(1), sensorData(2), sensorData(3), sensorData(4));

            % Compute differences for verification
            differences = abs(sensorData - referenceValues);

            % Logic for corner sensors
            if differences(1) > thresholdCornerHigh || differences(4) > thresholdCornerHigh
                % Increment mismatch counter for high corner threshold
                mismatchCounter = mismatchCounter + 1;
                fprintf("Corner sensor mismatch detected (High)! Consecutive mismatches: %d\n", mismatchCounter);
            elseif differences(1) > thresholdCornerLow || differences(4) > thresholdCornerLow
                % Check middle sensors if corner sensors exceed low threshold
                if differences(2) > thresholdMiddle && differences(3) > thresholdMiddle
                    mismatchCounter = mismatchCounter + 1;
                    fprintf("Corner and middle sensor mismatch detected! Consecutive mismatches: %d\n", mismatchCounter);
                else
                    disp("Corner sensors exceeded low threshold, but middle sensors are within range.");
                end
            else
                disp("Sensor data matches reference values for corners and middle sensors.");
            end

            % Check if mismatch limit is reached
            if mismatchCounter >= consecutiveMismatchLimit
                disp("Consecutive mismatches exceeded the limit. Terminating process.");
                disp("Sensor Data: "), disp(sensorData);
                disp("Reference Values: "), disp(referenceValues);
                break;
            end
        else
            disp("Incomplete data received. Ignoring this set.");
        end

        % Optional: Manual termination mechanism
        if ~isempty(get(groot, 'CurrentFigure'))
            userInput = input('Do you want to terminate the process? (yes/no): ', 's');
            if strcmpi(userInput, 'yes')
                disp("Process terminated by user.");
                break;
            end
        end
    end
catch ME
    disp("An error occurred:");
    disp(ME.message);
end

% Clean up
clear arduino;
disp("Serial communication ended.");
