# Firmware (ESP32)

Runs the whole scenario logic: LED control, the 5-second blinking garage state
machine, night mode, and status publishing.

## Build
1. Install [PlatformIO](https://platformio.org/).
2. `cp include/config.example.h include/config.h` and fill in Wi-Fi and broker details.
3. Adjust LED pins in `config.h` to match your wiring.
4. `pio run -t upload`

## Notes
- The garage scenario is non-blocking (`millis()`), so it keeps running if MQTT drops.
- Status messages are published retained; a Last Will reports `offline`.
- `config.h` is git-ignored. Never commit real credentials.
