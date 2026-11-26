# Hardware Wiring

## Parts
- NodeMCU (ESP8266, ESP-12E module)
- 4 LEDs (red, blue, green, yellow)
- 4 resistors, about 220 ohm
- Breadboard and jumper wires
- USB cable (micro-USB or USB-C, depending on your NodeMCU board)

## Pins
Use the labels printed on the board (D1, D2, ...). The firmware uses the GPIO numbers, which are listed here too. These values must match `firmware/include/config.h`.

| Device | LED | Board label | GPIO | Config constant |
|---|---|---|---|---|
| Garage | red | D1 | 5 | `PIN_GARAGE` |
| Cooler | blue | D2 | 4 | `PIN_COOLER` |
| TV | green | D5 | 14 | `PIN_TV` |
| House door | yellow | D6 | 12 | `PIN_DOOR` |

Do not use D0, D3, D4 or D8 for these devices. They have special roles at boot.

## Wiring
Wire each LED in series as follows:

`NodeMCU pin → resistor (~220 Ω) → LED anode (long leg) → LED cathode (short leg) → GND`

Connect all LED cathodes to a common GND pin on the NodeMCU.

## Before you power on
1. Check each wire against the table above.
2. Make sure every LED has its resistor. An LED without a resistor can be damaged.
3. Make sure the LED long leg (anode) is on the resistor side.

## Safety
This project uses low-voltage LEDs only, powered from the NodeMCU's USB port. Do not connect mains (220 V) loads without proper relays, isolation, and supervision by someone experienced.