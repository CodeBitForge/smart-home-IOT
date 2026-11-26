#pragma once

#define WIFI_SSID   "your-wifi-name"
#define WIFI_PASS   "your-wifi-password"

#define MQTT_HOST   "broker.example.com"
#define MQTT_PORT   1883
#define MQTT_USER   ""
#define MQTT_PASS   ""
#define MQTT_CLIENT_ID "smart-home-esp32"

// LED pins (each LED needs a ~220 ohm resistor in series)
#define PIN_GARAGE  5    // D1, red
#define PIN_COOLER  4    // D2, blue
#define PIN_TV      14   // D5, green
#define PIN_DOOR    12   // D6, yellow
