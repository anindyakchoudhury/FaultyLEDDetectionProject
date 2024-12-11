//Will create a good pattern

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

void setup() {
    Serial.begin(9600);  // For debugging

    // Initialize the display
    mx.begin();

    // Set medium intensity
    mx.control(MD_MAX72XX::INTENSITY, 8);

    // Wake up display
    mx.control(MD_MAX72XX::SHUTDOWN, 0);  // 0 = normal operation, 1 = shutdown

    // Clear everything
    mx.clear();

    // Fill all LEDs as a first test
    fillAll();
    delay(2000);

    // Start the moving patterns
    mx.clear();
}

void fillAll() {
    for(int module = 0; module < MAX_DEVICES; module++) {
        for(int col = 0; col < 8; col++) {
            mx.setColumn(module, col, 0xFF);
        }
    }
}

void loop() {
    // Pattern 1: Moving single LED across all modules
    for(int row = 0; row < 8; row++) {
        for(int col = 0; col < MAX_DEVICES * 8; col++) {
            mx.clear();
            mx.setPoint(row, col, true);
            delay(50);
        }
    }
    delay(10000);

    // Pattern 2: Fill one module at a time
    for(int module = 0; module < MAX_DEVICES; module++) {
        mx.clear();
        for(int col = 0; col < 8; col++) {
            mx.setColumn(module, col, 0xFF);
        }
        delay(5000);
    }
    delay(10000);

    // Pattern 3: Fill all modules gradually
    mx.clear();
    for(int col = 0; col < MAX_DEVICES * 8; col++) {
        for(int row = 0; row < 8; row++) {
            mx.setPoint(row, col, true);
        }
        delay(500);
    }
    delay(10000);

    // Fill everything
    fillAll();
    delay(10000);
}