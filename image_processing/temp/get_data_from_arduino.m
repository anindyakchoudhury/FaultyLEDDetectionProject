% MATLAB Code to Read Real-Time Data from Arduino
serialPort = "COM5"; % Update with your Arduino's COM port
baudRate = 9600; % Match the Arduino baud rate

% Initialize serial communication
arduino = serialport(serialPort, baudRate);

% Set the terminator for reading the lines
configureTerminator(arduino, "LF");

disp("Reading real-time sensor data...");
sensorData = [];

count = 0;
% Read data indefinitely (or for a fixed duration)
while true
    try
        % Read a line of data from the Arduino
        line = readline(arduino);
        
        % Parse and display the data
        % disp(line);
        
        % Optional: Extract numerical values and store them
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        if ~isempty(matches)
            sensorID = str2double(matches{1}{1});
            sensorValue = str2double(matches{1}{2});
            sensorData(sensorID) = sensorValue; % Store data for each sensor

            % Display the parsed data
            % fprintf("Sensor %d: %d lux\n", sensorID, sensorValue);
        end

        sensorData
    catch ME
        % Stop if the user interrupts or there's an error
        disp("Error or user stopped the process.");
        disp(ME.message);
        break;
    end
end

% Clean up
clear arduino;
disp("Serial communication ended.");
