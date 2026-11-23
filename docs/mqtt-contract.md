# MQTT Contract

Shared agreement between the app and the ESP32 firmware. Any change here must
be made in the same Pull Request as the code that uses it.

## Conventions
- Command topics: `home/<device>/cmd` (app publishes, ESP32 subscribes)
- Status topics: `home/<device>/status` (ESP32 publishes, app subscribes)
- Lowercase English names, single-word plain-text payloads
- All `status` messages are published **retained**
- Commands are **not** retained

## Devices

| Device | LED | Command topic | Status topic |
|---|---|---|---|
| Garage | red | `home/garage/cmd` | `home/garage/status` |
| Cooler | blue | `home/cooler/cmd` | `home/cooler/status` |
| TV | green | `home/tv/cmd` | `home/tv/status` |
| House door | yellow | `home/door/cmd` | `home/door/status` |
| All (group) | - | `home/all/cmd` | - |
| System | - | - | `home/system/status` |

## Payloads

| Topic | Values | Direction |
|---|---|---|
| `home/garage/cmd` | `open`, `close` | app to ESP32 |
| `home/garage/status` | `closed`, `opening`, `open`, `closing` | ESP32 to app |
| `home/cooler/cmd` | `on`, `off` | app to ESP32 |
| `home/cooler/status` | `on`, `off` | ESP32 to app |
| `home/tv/cmd` | `on`, `off` | app to ESP32 |
| `home/tv/status` | `on`, `off` | ESP32 to app |
| `home/door/cmd` | `open`, `close` | app to ESP32 |
| `home/door/status` | `open`, `closed` | ESP32 to app |
| `home/all/cmd` | `night` | app to ESP32 |
| `home/system/status` | `online`, `offline` | ESP32 to app |

## Behavior

### Garage
- `open`: status `opening`, red LED blinks 5 s, status `open`, red LED steady.
- `close`: status `closing`, red LED blinks 5 s, status `closed`, red LED off.
- Commands received during a transition are ignored.

### Night mode (`home/all/cmd` = `night`)
Closes the garage (with the usual blinking), closes the door, turns off the TV
and the cooler. Each device publishes its own new status.

### Connection status
The ESP32 registers a Last Will of `offline` (retained) on
`home/system/status` and publishes `online` after connecting. The app shows
"hardware not connected" when the value is `offline`.

### Voice announcements (app side)

| Received status | Voice |
|---|---|
| `garage/status = opening` | "Garage door is opening" |
| `garage/status = open` | "Garage door is open" |
| `garage/status = closing` | "Garage door is closing" |
| `garage/status = closed` | "Garage door is closed" |
| night mode completed | "Night mode activated" |

Voices are driven by status messages, not button presses, so voice and LEDs
always stay in sync.

## Delivery settings
- QoS 1 for commands and status
- Retained: status and system topics only
