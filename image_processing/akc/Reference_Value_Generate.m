% MATLAB Code to Read Real-Time Data and Save Reference Values
serialPort = "COM5"; % Update with your Arduino's COM port
baudRate = 9600; % Match the Arduino baud rate

% Initialize serial communication
arduino = serialport(serialPort, baudRate);
configureTerminator(arduino, "LF");

disp("Reading real-time sensor data...");
sensorData = zeros(1,4);
dataBuffer = [];
count = 0;
excludedDataCount = 10;
maxDataPoints = 50;
threshold = 2;

try
    while true
        line = readline(arduino);
        matches = regexp(line, "Sensor(\d+):(\d+)\s*lux", "tokens");
        if ~isempty(matches)
            sensorID = str2double(matches{1}{1});
            sensorValue = str2double(matches{1}{2});
            sensorData(sensorID) = sensorValue;
            
            if count >= excludedDataCount
                if size(dataBuffer, 1) < maxDataPoints
                    dataBuffer = [dataBuffer; sensorData];
                    if size(dataBuffer, 1) > 1
                        change = abs(sensorData - dataBuffer(end-1, :));
                        if any(change > threshold)
                            disp("Sensor value changed significantly. Operation stopped.");
                            break;
                        end
                    end
                else
                    break;
                end
            end
            count = count + 1;
        end
        sensorData
    end
    
    if ~isempty(dataBuffer)
        referenceValues = mean(dataBuffer, 1);
        disp("Reference values calculated and saved.");
        disp(referenceValues)
        save('referenceValues.mat', 'referenceValues');
    else
        disp("No data collected for averaging.");
    end
    
catch ME
    disp("An error occurred:");
    disp(ME.message);
end

clear arduino;
disp("Serial communication ended.");
