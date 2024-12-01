// Fully Tested and Working Codes
// Turns on Half of the LED Present in the Panel by Default in the Same intensity
// rowcol, rowoff, coloff, colon, indon, indoff added as commands for serial Monitor


#include <MD_MAX72xx.h>
#include <SPI.h>

// Define hardware type for MAX7219 displays
#define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// Define display parameters
#define MAX_DEVICES 4     // 4 modules for 32 columns
#define CLK_PIN   13      // SPI CLK pin
#define DATA_PIN  11      // SPI MOSI pin
#define CS_PIN    3       // SPI CS pin

// Create display object
MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// Array to store override positions
bool overridePositions[8][32] = {{false}};  // Initialize all to false

// Function to flip row index (0->7, 1->6, 2->5, etc.)
int flipRow(int row) {
    return 7 - row;
}

// Function to check if an LED should be on in the original pattern
bool isLEDPartOfPattern(int row, int col) {
    int flippedRow = flipRow(row);
    return (flippedRow % 2 == 0 && col % 2 == 0);  // Top-left LED in each 2x2 block
}

void setup() {
    // Initialize Serial communication
    Serial.begin(9600);
    Serial.println("Commands:");
    Serial.println("indoff - Enter row,column to override LED (e.g., '7,0')");
    Serial.println("rowoff - Enter row to turn off (e.g., '7')");
    Serial.println("coloff - Enter column to turn off (e.g., '0')");
    Serial.println("indon - Enter row,column to turn LED on if off (e.g., '7,0')");
    Serial.println("rowon - Enter row to turn all LEDs on (e.g., '7')");
    Serial.println("colon - Enter column to turn all LEDs on (e.g., '0')");
    Serial.println("Valid ranges - Row: 0-7 (7 is top), Column: 0-31");

    // Initialize the display
    mx.begin();
    mx.control(MD_MAX72XX::INTENSITY, 2);
    mx.control(MD_MAX72XX::SHUTDOWN, 0);

    updateDisplay();  // Initial display update
}

void updateDisplay() {
    mx.clear();

    // Update all LEDs based on pattern and overrides
    for(int row = 0; row < 8; row++) {
        for(int col = 0; col < MAX_DEVICES * 8; col++) {
            if(isLEDPartOfPattern(row, col) && !overridePositions[row][col]) {
                mx.setPoint(flipRow(row), col, true);
            }
        }
    }
}

void turnOffRow(int row) {
    for (int col = 0; col < MAX_DEVICES * 8; col++) {
        if (isLEDPartOfPattern(row, col)) {
            overridePositions[row][col] = true;
        }
    }
    updateDisplay();
    Serial.print("Turned off row: ");
    Serial.println(row);
}

void turnOffColumn(int col) {
    for (int row = 0; row < 8; row++) {
        if (isLEDPartOfPattern(row, col)) {
            overridePositions[row][col] = true;
        }
    }
    updateDisplay();
    Serial.print("Turned off column: ");
    Serial.println(col);
}

void turnOnRow(int row) {
    for (int col = 0; col < MAX_DEVICES * 8; col++) {
        if (isLEDPartOfPattern(row, col)) {
            overridePositions[row][col] = false;
        }
    }
    updateDisplay();
    Serial.print("Turned on row: ");
    Serial.println(row);
}

void turnOnColumn(int col) {
    for (int row = 0; row < 8; row++) {
        if (isLEDPartOfPattern(row, col)) {
            overridePositions[row][col] = false;
        }
    }
    updateDisplay();
    Serial.print("Turned on column: ");
    Serial.println(col);
}

void turnOnLED(int row, int col) {
    if (isLEDPartOfPattern(row, col)) {
        overridePositions[row][col] = false;
        updateDisplay();

        Serial.print("Turned on LED at position (");
        Serial.print(row);
        Serial.print(",");
        Serial.print(col);
        Serial.println(")");
    } else {
        Serial.println("This LED is not part of the pattern or already on!");
    }
}

void loop() {
    static String command;

    if (Serial.available() > 0) {
        String input = Serial.readStringUntil('\n');
        input.trim();

        if (input == "indoff" || input == "rowoff" || input == "coloff" || input == "indon" || input == "rowon" || input == "colon") {
            command = input;
            Serial.println("Enter index (e.g., '7,0' for indoff/indon, '7' for rowoff/rowon, '0' for coloff/colon)");
            return;
        }

        if (command == "indoff") {
            int commaIndex = input.indexOf(',');
            if (commaIndex != -1) {
                int row = input.substring(0, commaIndex).toInt();
                int col = input.substring(commaIndex + 1).toInt();

                if (row >= 0 && row < 8 && col >= 0 && col < (MAX_DEVICES * 8)) {
                    if (isLEDPartOfPattern(row, col)) {
                        overridePositions[row][col] = true;
                        updateDisplay();

                        Serial.print("Overrode LED at position (");
                        Serial.print(row);
                        Serial.print(",");
                        Serial.print(col);
                        Serial.println(")");
                    } else {
                        Serial.println("This LED is already off in the pattern!");
                    }
                } else {
                    Serial.println("Invalid position! Row should be 0-7 (7 is top), Column should be 0-31");
                }
            } else {
                Serial.println("Invalid format! Use 'row,column' (e.g., '7,0')");
            }
        } else if (command == "rowoff") {
            int row = input.toInt();
            if (row >= 0 && row < 8) {
                turnOffRow(row);
            } else {
                Serial.println("Invalid row! Row should be 0-7 (7 is top)");
            }
        } else if (command == "coloff") {
            int col = input.toInt();
            if (col >= 0 && col < (MAX_DEVICES * 8)) {
                turnOffColumn(col);
            } else {
                Serial.println("Invalid column! Column should be 0-31");
            }
        } else if (command == "indon") {
            int commaIndex = input.indexOf(',');
            if (commaIndex != -1) {
                int row = input.substring(0, commaIndex).toInt();
                int col = input.substring(commaIndex + 1).toInt();

                if (row >= 0 && row < 8 && col >= 0 && col < (MAX_DEVICES * 8)) {
                    turnOnLED(row, col);
                } else {
                    Serial.println("Invalid position! Row should be 0-7 (7 is top), Column should be 0-31");
                }
            } else {
                Serial.println("Invalid format! Use 'row,column' (e.g., '7,0')");
            }
        } else if (command == "rowon") {
            int row = input.toInt();
            if (row >= 0 && row < 8) {
                turnOnRow(row);
            } else {
                Serial.println("Invalid row! Row should be 0-7 (7 is top)");
            }
        } else if (command == "colon") {
            int col = input.toInt();
            if (col >= 0 && col < (MAX_DEVICES * 8)) {
                turnOnColumn(col);
            } else {
                Serial.println("Invalid column! Column should be 0-31");
            }

            } else {
            Serial.println("Unknown command! Use 'indoff', 'rowoff', or 'coloff'");
        }

        command = "";  // Clear command after processing
    }
}