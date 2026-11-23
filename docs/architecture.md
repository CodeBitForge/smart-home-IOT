# Architecture

```mermaid
flowchart LR
    A[Mobile app] -- "home/*/cmd" --> B[(MQTT broker)]
    B -- "home/*/cmd" --> C[ESP32]
    C -- "home/*/status" --> B
    B -- "home/*/status" --> A
    C --> L1[Red LED: garage]
    C --> L2[Blue LED: cooler]
    C --> L3[Green LED: TV]
    C --> L4[Yellow LED: door]
```

## Responsibilities
- **App**: sends one command, displays status, plays voice from status messages.
- **ESP32**: executes the whole scenario (blinking, timing, state machine) and reports status.
- **Broker**: relays messages and stores retained status.

Timing logic lives on the ESP32 rather than the app, so a lost connection
mid-scenario cannot leave a device in an unknown state.

## Garage state machine

```mermaid
stateDiagram-v2
    [*] --> closed
    closed --> opening: cmd open
    opening --> open: after 5 s
    open --> closing: cmd close / night
    closing --> closed: after 5 s
```
