% MATLAB Code to Read Real-Time Data from Arduino and Plot in Subplots
serialPort = "COM5"; % Update with your Arduino's COM port
baudRate = 9600; % Match the Arduino baud rate

% Initialize serial communication
arduino = serialport(serialPort, baudRate);

% Set the terminator for reading the lines
configureTerminator(arduino, "LF");

disp("Reading real-time sensor data...");
sensorData = zeros(4, 1); % Initialize sensor data array
timeData = []; % To store time values
sensorHistory = zeros(4, 0); % To store sensor values over time

% Create a figure with 4 subplots
figure;
for i = 1:4
    subplot(4, 1, i);
    grid on;
    title(sprintf("Sensor %d", i));
    xlabel("Time (s)");
    ylabel("Lux");
end

timeStart = tic; % Start a timer for time axis

% Main loop to read and display data
while true
    try
        % Read a line of data from the Arduino
        line = readline(arduino);
        
        % Extract numerical values and update the sensor data
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        if ~isempty(matches)
            sensorID = str2double(matches{1}{1});
            sensorValue = str2double(matches{1}{2});
            sensorData(sensorID) = sensorValue; % Update data for the corresponding sensor
            
            % Record data for plotting
            timeElapsed = toc(timeStart); % Get elapsed time
            if isempty(timeData) || length(timeData) < size(sensorHistory, 2) + 1
                timeData(end+1) = timeElapsed; % Update time axis
                sensorHistory(:, end+1) = sensorData; % Update sensor history
            else
                sensorHistory(:, end) = sensorData; % Update latest sensor data
            end
            
            % Update each subplot
            for i = 1:4
                subplot(4, 1, i);
                plot(timeData, sensorHistory(i, :), '-b');
                xlim([max(0, timeElapsed - 10), timeElapsed]); % Show last 10 seconds
                
                % Adjust Y-axis limits safely
                if all(sensorHistory(i, :) == 0)
                    ylim([0, 1000]); % Default range when no data
                else
                    ylim([0, max(max(sensorHistory(i, :)), 1000)]); % Adjust dynamically
                end
                
                drawnow; % Update the plots
            end
        end
    catch ME
        % Stop if the user interrupts or an error occurs
        disp("Error or user stopped the process.");
        disp(ME.message);
        break;
    end
end

% Clean up
clear arduino;
disp("Serial communication ended.");
