#include <Wire.h>

#define BH1750_ADDR_LOW 0x23 // Address when ADDR = LOW
#define BH1750_ADDR_HIGH 0x5C // Address when ADDR = HIGH

// GPIO pins connected to the ADDR pins of each sensor
uint8_t addrControlPins[4] = {7, 8, 9, 10};

// Buffer for reading sensor data
byte buff[2];

void setup() {
  Wire.begin();            // Initialize I2C communication
  Serial.begin(9600);      // Initialize Serial communication

  // Set up ADDR control pins
  for (int i = 0; i < 4; i++) {
    pinMode(addrControlPins[i], OUTPUT);
    digitalWrite(addrControlPins[i], HIGH); // Default to HIGH (address 0x5C)
  }

  // Initialize each sensor
  for (int i = 0; i < 4; i++) {
    setSensorAddrPin(i, LOW);          // Set sensor to address 0x23
    BH1750_Init(BH1750_ADDR_LOW);      // Initialize sensor
    setSensorAddrPin(i, HIGH);         // Reset to default address
    delay(200);
  }
}

void loop() {
  for (int i = 0; i < 4; i++) {
    setSensorAddrPin(i, LOW);              // Set sensor to address 0x23
    uint16_t val = readSensor(BH1750_ADDR_LOW); // Read data
    setSensorAddrPin(i, HIGH);             // Reset address to default
    
    // Send sensor data to Serial in the format "SensorX:value"
    Serial.print("Sensor");
    Serial.print(i + 1);
    Serial.print(":");
    Serial.print(val);
    Serial.print(" lux");
    Serial.println();
    delay(100); // Allow time for MATLAB to process
  }
}

// Function to control the ADDR pin of a sensor
void setSensorAddrPin(uint8_t sensorIndex, uint8_t state) {
  digitalWrite(addrControlPins[sensorIndex], state);
  delay(10); // Allow time for the sensor to register the change
}

// Function to initialize BH1750 sensor
void BH1750_Init(uint8_t address) {
  Wire.beginTransmission(address);
  Wire.write(0x10);        // Continuous High-Resolution Mode
  Wire.endTransmission();  // End transmission
}

// Function to read data from a BH1750 sensor
uint16_t readSensor(uint8_t address) {
  uint16_t val = 0;
  Wire.beginTransmission(address);
  Wire.requestFrom(address, 2);

  if (Wire.available() == 2) {
    buff[0] = Wire.read();
    buff[1] = Wire.read();
    val = ((buff[0] << 8) | buff[1]) / 1.2; // Convert to lux
  }

  Wire.endTransmission();
  return val;
}
