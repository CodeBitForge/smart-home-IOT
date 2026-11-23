# Hardware Wiring

## Parts
- ESP32 dev board
- 4 LEDs (red, blue, green, yellow)
- 4 resistors, about 220 ohm
- Breadboard and jumper wires

## Default pins (change in `firmware/include/config.h`)

| Device | LED | ESP32 pin |
|---|---|---|
| Garage | red | GPIO 25 |
| Cooler | blue | GPIO 26 |
| TV | green | GPIO 27 |
| Door | yellow | GPIO 14 |

Wire each LED as: GPIO pin, resistor, LED anode, LED cathode, GND.

## Safety
This demo uses low-voltage LEDs only. Do not connect mains (220 V) loads
without proper relays, isolation, and supervision by someone experienced.

Add a wiring photo or diagram to `docs/images/`.
