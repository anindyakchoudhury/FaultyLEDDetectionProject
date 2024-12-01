// // Including the required Arduino libraries
// #include <MD_Parola.h>
// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Uncomment according to your hardware type
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW
// //#define HARDWARE_TYPE MD_MAX72XX::GENERIC_HW

// // Defining size, and output pins
// #define MAX_DEVICES 4
// #define CS_PIN 3

// // Create a new instance of the MD_Parola class with hardware SPI connection
// MD_Parola myDisplay = MD_Parola(HARDWARE_TYPE, CS_PIN, MAX_DEVICES);

// void setup() {
// 	// Intialize the object
// 	myDisplay.begin();

// 	// Set the intensity (brightness) of the display (0-15)
// 	myDisplay.setIntensity(5);

// 	// Clear the display
// 	myDisplay.displayClear();
// }

// void loop() {
// 	myDisplay.setTextAlignment(PA_LEFT);
// 	myDisplay.print("Left");
// 	delay(2000);
	
// 	myDisplay.setTextAlignment(PA_CENTER);
// 	myDisplay.print("Center");
// 	delay(2000);

// 	myDisplay.setTextAlignment(PA_RIGHT);
// 	myDisplay.print("Right");
// 	delay(2000);

// 	myDisplay.setTextAlignment(PA_CENTER);
// 	myDisplay.setInvert(true);
// 	myDisplay.print("Invert");
// 	delay(2000);

// 	myDisplay.setInvert(false);
// 	myDisplay.print(1234);
// 	delay(2000);
// }


// // Including the required Arduino libraries
// #include <MD_Parola.h>
// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Uncomment according to your hardware type
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW
// //#define HARDWARE_TYPE MD_MAX72XX::GENERIC_HW

// // Defining size, and output pins
// #define MAX_DEVICES 4
// #define CS_PIN 3

// // Create a new instance of the MD_Parola class with hardware SPI connection
// MD_Parola myDisplay = MD_Parola(HARDWARE_TYPE, CS_PIN, MAX_DEVICES);

// void setup() {
// 	// Intialize the object
// 	myDisplay.begin();

// 	// Set the intensity (brightness) of the display (0-15)
// 	myDisplay.setIntensity(0);

// 	// Clear the display
// 	myDisplay.displayClear();

// 	myDisplay.displayScroll("Hello", PA_CENTER, PA_SCROLL_LEFT, 100);
// }

// void loop() {
// 	if (myDisplay.displayAnimate()) {
// 		myDisplay.displayReset();
// 	}
// }

// // Including the required Arduino libraries
// #include <MD_Parola.h>
// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Uncomment according to your hardware type
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW
// //#define HARDWARE_TYPE MD_MAX72XX::GENERIC_HW

// // Defining size, and output pins
// #define MAX_DEVICES 4
// #define CS_PIN 3

// // Create a new instance of the MD_Parola class with hardware SPI connection
// MD_Parola myDisplay = MD_Parola(HARDWARE_TYPE, CS_PIN, MAX_DEVICES);

// void setup() {
//   // Intialize the object
//   myDisplay.begin();

//   // Set the brightness of the display (0-15)
//   myDisplay.setIntensity(2);

//   // Clear the display
//   myDisplay.displayClear();
// }

// void loop() {
//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("C");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("I");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("R");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("C");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("U");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("I");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("T");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("D");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("I");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("G");
//   delay(650);

//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("E");
//   delay(650);


//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("S");
//   delay(650);


//   myDisplay.setTextAlignment(PA_LEFT);
//   myDisplay.print("T");
//   delay(1500);
// }

// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type - try PAROLA_HW if FC16_HW doesn't work
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW
// //#define HARDWARE_TYPE MD_MAX72XX::PAROLA_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// void setup() {
//     Serial.begin(9600);  // Start serial for debugging
    
//     // Initialize the display
//     mx.begin();
    
//     // Set medium intensity to not overwhelm power supply
//     mx.control(MD_MAX72XX::INTENSITY, 8);
    
//     // Make sure display is on
//     mx.control(MD_MAX72XX::SHUTDOWN, false);
    
//     // Clear everything
//     mx.clear();
// }

// void loop() {
//     // Test 1: Light up one column at a time
//     for (int col = 0; col < MAX_DEVICES * 8; col++) {
//         mx.clear();
//         for (int row = 0; row < 8; row++) {
//             mx.setPoint(row, col, true);
//         }
//         delay(100);  // Wait to see the effect
//     }
//     delay(1000);

//     // Test 2: Light up one row at a time
//     for (int row = 0; row < 8; row++) {
//         mx.clear();
//         for (int col = 0; col < MAX_DEVICES * 8; col++) {
//             mx.setPoint(row, col, true);
//         }
//         delay(100);  // Wait to see the effect
//     }
//     delay(1000);

//     // Test 3: Fill entire display using matrix transformation
//     mx.clear();
//     for (int dev = 0; dev < MAX_DEVICES; dev++) {
//         for (int row = 0; row < 8; row++) {
//             mx.setRow(dev, row, 0xFF);  // Set all columns in this row
//         }
//     }
//     delay(1000);

//     // Test 4: Alternative fill method
//     mx.clear();
//     for (int dev = 0; dev < MAX_DEVICES; dev++) {
//         for (int col = 0; col < 8; col++) {
//             mx.setColumn(dev, col, 0xFF);  // Set all rows in this column
//         }
//     }
//     delay(1000);
// }




//working code is below, it is creating good pattern

// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// void setup() {
//     Serial.begin(9600);  // For debugging
    
//     // Initialize the display
//     mx.begin();
    
//     // Set medium intensity
//     mx.control(MD_MAX72XX::INTENSITY, 8);
    
//     // Wake up display
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);  // 0 = normal operation, 1 = shutdown
    
//     // Clear everything
//     mx.clear();
    
//     // Fill all LEDs as a first test
//     fillAll();
//     delay(2000);
    
//     // Start the moving patterns
//     mx.clear();
// }

// void fillAll() {
//     for(int module = 0; module < MAX_DEVICES; module++) {
//         for(int col = 0; col < 8; col++) {
//             mx.setColumn(module, col, 0xFF);
//         }
//     }
// }

// void loop() {
//     // Pattern 1: Moving single LED across all modules
//     for(int row = 0; row < 8; row++) {
//         for(int col = 0; col < MAX_DEVICES * 8; col++) {
//             mx.clear();
//             mx.setPoint(row, col, true);
//             delay(50);
//         }
//     }
//     delay(10000);
    
//     // Pattern 2: Fill one module at a time
//     for(int module = 0; module < MAX_DEVICES; module++) {
//         mx.clear();
//         for(int col = 0; col < 8; col++) {
//             mx.setColumn(module, col, 0xFF);
//         }
//         delay(5000);
//     }
//     delay(10000);
    
//     // Pattern 3: Fill all modules gradually
//     mx.clear();
//     for(int col = 0; col < MAX_DEVICES * 8; col++) {
//         for(int row = 0; row < 8; row++) {
//             mx.setPoint(row, col, true);
//         }
//         delay(500);
//     }
//     delay(10000);
    
//     // Fill everything
//     fillAll();
//     delay(10000);
// }






// //Every ODD columns are lit up

// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// void setup() {
//     // Initialize the display
//     mx.begin();
    
//     // Set medium intensity
//     mx.control(MD_MAX72XX::INTENSITY, 8);
    
//     // Wake up display
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);
    
//     // Clear everything first
//     mx.clear();
    
//     // Create alternating pattern
//     for(int col = 0; col < MAX_DEVICES * 8; col++) {
//         if(col % 2 == 0) {  // If column number is even
//             // Turn on all LEDs in this column
//             for(int row = 0; row < 8; row++) {
//                 mx.setPoint(row, col, true);
//             }
//         }
//     }
// }

// void loop() {
//     // Nothing needed in loop as pattern stays static
// }





//Only one LED is lit up in every 2by2 LED

// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// void setup() {
//     // Initialize the display
//     mx.begin();
    
//     // Set medium intensity
//     mx.control(MD_MAX72XX::INTENSITY, 13);
    
//     // Wake up display
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);
    
//     // Clear everything first
//     mx.clear();
    
//     // Create 2x2 pattern with one LED lit
//     for(int row = 0; row < 8; row += 2) {
//         for(int col = 0; col < MAX_DEVICES * 8; col += 2) {
//             // In each 2x2 block, light up the top-left LED
//             mx.setPoint(row, col, true);
//         }
//     }
// }

// void loop() {
//     // Nothing needed in loop as pattern stays static
// }



//This code can turn on the led in 2by2 pattern, then from the serial monitor input, I can turn off a specific LED
//if DIN is on the left side, then most below row is indexed at 0.


// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// // Array to store override positions
// bool overridePositions[8][32] = {{false}};  // Initialize all to false

// // Function to check if an LED should be on in the original pattern
// bool isLEDPartOfPattern(int row, int col) {
//     return (row % 2 == 0 && col % 2 == 0);  // Top-left LED in each 2x2 block
// }

// void setup() {
//     // Initialize Serial communication
//     Serial.begin(9600);
//     Serial.println("Enter row,column to override LED (e.g., '0,0')");
//     Serial.println("Valid ranges - Row: 0-7, Column: 0-31");
    
//     // Initialize the display
//     mx.begin();
//     mx.control(MD_MAX72XX::INTENSITY, 8);
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);
    
//     updateDisplay();  // Initial display update
// }

// void updateDisplay() {
//     mx.clear();
    
//     // Update all LEDs based on pattern and overrides
//     for(int row = 0; row < 8; row++) {
//         for(int col = 0; col < MAX_DEVICES * 8; col++) {
//             if(isLEDPartOfPattern(row, col) && !overridePositions[row][col]) {
//                 mx.setPoint(row, col, true);
//             }
//         }
//     }
// }

// void loop() {
//     if (Serial.available() > 0) {
//         String input = Serial.readStringUntil('\n');
        
//         // Parse row and column
//         int commaIndex = input.indexOf(',');
//         if (commaIndex != -1) {
//             int row = input.substring(0, commaIndex).toInt();
//             int col = input.substring(commaIndex + 1).toInt();
            
//             // Validate input
//             if (row >= 0 && row < 8 && col >= 0 && col < (MAX_DEVICES * 8)) {
//                 // Only process if this LED would normally be on in the pattern
//                 if(isLEDPartOfPattern(row, col)) {
//                     overridePositions[row][col] = true;
//                     updateDisplay();
                    
//                     Serial.print("Overrode LED at position (");
//                     Serial.print(row);
//                     Serial.print(",");
//                     Serial.print(col);
//                     Serial.println(")");
//                 } else {
//                     Serial.println("This LED is already off in the pattern!");
//                 }
//             } else {
//                 Serial.println("Invalid position! Row should be 0-7, Column should be 0-31");
//             }
//         } else {
//             Serial.println("Invalid format! Use 'row,column' (e.g., '0,0')");
//         }
//     }
// }




//Index Reversed than Before.

// #include <MD_MAX72xx.h>
// #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// // Array to store override positions
// bool overridePositions[8][32] = {{false}};  // Initialize all to false

// // Function to flip row index (0->7, 1->6, 2->5, etc.)
// int flipRow(int row) {
//     return 7 - row;
// }

// // Function to check if an LED should be on in the original pattern
// bool isLEDPartOfPattern(int row, int col) {
//     int flippedRow = flipRow(row);
//     return (flippedRow % 2 == 0 && col % 2 == 0);  // Top-left LED in each 2x2 block
// }

// void setup() {
//     // Initialize Serial communication
//     Serial.begin(9600);
//     Serial.println("Enter row,column to override LED (e.g., '7,0')");
//     Serial.println("Valid ranges - Row: 0-7 (7 is top), Column: 0-31");
    
//     // Initialize the display
//     mx.begin();
//     mx.control(MD_MAX72XX::INTENSITY, 2);
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);
    
//     updateDisplay();  // Initial display update
// }

// void updateDisplay() {
//     mx.clear();
    
//     // Update all LEDs based on pattern and overrides
//     for(int row = 0; row < 8; row++) {
//         for(int col = 0; col < MAX_DEVICES * 8; col++) {
//             if(isLEDPartOfPattern(row, col) && !overridePositions[row][col]) {
//                 mx.setPoint(flipRow(row), col, true);
//             }
//         }
//     }
// }

// void loop() {
//     if (Serial.available() > 0) {
//         String input = Serial.readStringUntil('\n');
        
//         // Parse row and column
//         int commaIndex = input.indexOf(',');
//         if (commaIndex != -1) {
//             int row = input.substring(0, commaIndex).toInt();
//             int col = input.substring(commaIndex + 1).toInt();
            
//             // Validate input
//             if (row >= 0 && row < 8 && col >= 0 && col < (MAX_DEVICES * 8)) {
//                 // Only process if this LED would normally be on in the pattern
//                 if(isLEDPartOfPattern(row, col)) {
//                     overridePositions[row][col] = true;
//                     updateDisplay();
                    
//                     Serial.print("Overrode LED at position (");
//                     Serial.print(row);
//                     Serial.print(",");
//                     Serial.print(col);
//                     Serial.println(")");
//                 } else {
//                     Serial.println("This LED is already off in the pattern!");
//                 }
//             } else {
//                 Serial.println("Invalid position! Row should be 0-7 (7 is top), Column should be 0-31");
//             }
//         } else {
//             Serial.println("Invalid format! Use 'row,column' (e.g., '7,0')");
//         }
//     }
// }



//can do the rowoff and coloff and indoff

//  #include <MD_MAX72xx.h>
//  #include <SPI.h>

// // Define hardware type for MAX7219 displays
// #define HARDWARE_TYPE MD_MAX72XX::FC16_HW

// // Define display parameters
// #define MAX_DEVICES 4     // 4 modules for 32 columns
// #define CLK_PIN   13      // SPI CLK pin
// #define DATA_PIN  11      // SPI MOSI pin
// #define CS_PIN    3       // SPI CS pin

// // Create display object
// MD_MAX72XX mx = MD_MAX72XX(HARDWARE_TYPE, DATA_PIN, CLK_PIN, CS_PIN, MAX_DEVICES);

// // Array to store override positions
// bool overridePositions[8][32] = {{false}};  // Initialize all to false

// // Function to flip row index (0->7, 1->6, 2->5, etc.)
// int flipRow(int row) {
//     return 7 - row;
// }

// // Function to check if an LED should be on in the original pattern
// bool isLEDPartOfPattern(int row, int col) {
//     int flippedRow = flipRow(row);
//     return (flippedRow % 2 == 0 && col % 2 == 0);  // Top-left LED in each 2x2 block
// }

// void setup() {
//     // Initialize Serial communication
//     Serial.begin(9600);
//     Serial.println("Commands:");
//     Serial.println("indoff - Enter row,column to override LED (e.g., '7,0')");
//     Serial.println("rowoff - Enter row to turn off (e.g., '7')");
//     Serial.println("coloff - Enter column to turn off (e.g., '0')");
//     Serial.println("Valid ranges - Row: 0-7 (7 is top), Column: 0-31");

//     // Initialize the display
//     mx.begin();
//     mx.control(MD_MAX72XX::INTENSITY, 2);
//     mx.control(MD_MAX72XX::SHUTDOWN, 0);

//     updateDisplay();  // Initial display update
// }

// void updateDisplay() {
//     mx.clear();

//     // Update all LEDs based on pattern and overrides
//     for(int row = 0; row < 8; row++) {
//         for(int col = 0; col < MAX_DEVICES * 8; col++) {
//             if(isLEDPartOfPattern(row, col) && !overridePositions[row][col]) {
//                 mx.setPoint(flipRow(row), col, true);
//             }
//         }
//     }
// }

// void turnOffRow(int row) {
//     for (int col = 0; col < MAX_DEVICES * 8; col++) {
//         if (isLEDPartOfPattern(row, col)) {
//             overridePositions[row][col] = true;
//         }
//     }
//     updateDisplay();
//     Serial.print("Turned off row: ");
//     Serial.println(row);
// }

// void turnOffColumn(int col) {
//     for (int row = 0; row < 8; row++) {
//         if (isLEDPartOfPattern(row, col)) {
//             overridePositions[row][col] = true;
//         }
//     }
//     updateDisplay();
//     Serial.print("Turned off column: ");
//     Serial.println(col);
// }

// void loop() {
//     static String command;

//     if (Serial.available() > 0) {
//         String input = Serial.readStringUntil('\n');
//         input.trim();

//         if (input == "indoff" || input == "rowoff" || input == "coloff") {
//             command = input;
//             Serial.println("Enter index (e.g., '7,0' for indoff, '7' for rowoff, '0' for coloff)");
//             return;
//         }

//         if (command == "indoff") {
//             int commaIndex = input.indexOf(',');
//             if (commaIndex != -1) {
//                 int row = input.substring(0, commaIndex).toInt();
//                 int col = input.substring(commaIndex + 1).toInt();

//                 if (row >= 0 && row < 8 && col >= 0 && col < (MAX_DEVICES * 8)) {
//                     if (isLEDPartOfPattern(row, col)) {
//                         overridePositions[row][col] = true;
//                         updateDisplay();

//                         Serial.print("Overrode LED at position (");
//                         Serial.print(row);
//                         Serial.print(",");
//                         Serial.print(col);
//                         Serial.println(")");
//                     } else {
//                         Serial.println("This LED is already off in the pattern!");
//                     }
//                 } else {
//                     Serial.println("Invalid position! Row should be 0-7 (7 is top), Column should be 0-31");
//                 }
//             } else {
//                 Serial.println("Invalid format! Use 'row,column' (e.g., '7,0')");
//             }
//         } else if (command == "rowoff") {
//             int row = input.toInt();
//             if (row >= 0 && row < 8) {
//                 turnOffRow(row);
//             } else {
//                 Serial.println("Invalid row! Row should be 0-7 (7 is top)");
//             }
//         } else if (command == "coloff") {
//             int col = input.toInt();
//             if (col >= 0 && col < (MAX_DEVICES * 8)) {
//                 turnOffColumn(col);
//             } else {
//                 Serial.println("Invalid column! Column should be 0-31");
//             }
//         } else {
//             Serial.println("Unknown command! Use 'indoff', 'rowoff', or 'coloff'");
//         }

//         command = "";  // Clear command after processing
//     }
// }




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

