#include <Q2HX711.h>  // HX711 library
#include <HX711.h>

// Constants for Torque Sensor (or Load Cell)
float Q_raw = 0;
float Q = 0;
float Q_cal = (-6.7969 / 10000);
float Z_off = 0;

char Command;
String string;

// Torque
const byte hx711_data_pin = 2;
const byte hx711_clock_pin = 3;

HX711 hx711(hx711_data_pin, hx711_clock_pin);

// timers
unsigned long loop_micros = 0;
unsigned long loop_millis = 0;
unsigned long loop_exec = 0;
unsigned long timer1_old = 0;
unsigned long timer1_delay = 100;
unsigned long timer1_exec = 0;

// reporting
boolean output_data = false;

void setup() {
  Serial.begin(115200);
}

void loop() {
  loop_micros = micros();
  loop_millis = millis();
  loop_exec = millis() - loop_millis;
  timer1_exec = millis() - timer1_old;

  if (Serial.available() > 0)
  {
    string = "";
  }
  while (Serial.available() > 0)
  {
    Command = ((byte)Serial.read());
    if (Command == ':')
    {
      break;
    }
    else
    {
      string += Command;
    }
    delay(1);
  }

  if (string == "ON")
  {
    TorqueON();
  }
  if (string == "OFF")
  {
    TorqueOFF();
  }
}

// Function to execute when "ON" string is detected and writes load cell values to serial monitor
void TorqueON()
{
  if (timer1_exec > timer1_delay)
  {
    timer1_old = millis();

    // Raw Data Import
    Q_raw = hx711.read();

    // Scaling factor (Calibration Factor and Zero Offset)
    Q = Q_raw * Q_cal + Z_off; 

    // Print Data to Serial Monitor
    Serial.println(Q); // Torque Sensor Output
  }
}
// Function to execute when STOP button in LabVIEW is toggled
void TorqueOFF()
{
  string = "";
}
