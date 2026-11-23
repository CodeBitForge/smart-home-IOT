#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include "config.h"

enum GarageState { G_CLOSED, G_OPENING, G_OPEN, G_CLOSING };

static const unsigned long GARAGE_TRANSITION_MS = 5000;
static const unsigned long BLINK_INTERVAL_MS = 250;
static const unsigned long RECONNECT_INTERVAL_MS = 5000;

WiFiClient wifiClient;
PubSubClient mqtt(wifiClient);

GarageState garage = G_CLOSED;
unsigned long garageStarted = 0;
unsigned long lastBlink = 0;
bool pendingGarageClose = false;   
bool coolerOn = false, tvOn = false, doorOpen = false;
unsigned long lastReconnect = 0;

// ---------- helpers ----------
void publishStatus(const char *topic, const char *value) {
  mqtt.publish(topic, value, true);  // retained
}

const char *garageName(GarageState s) {
  switch (s) {
    case G_CLOSED:  return "closed";
    case G_OPENING: return "opening";
    case G_OPEN:    return "open";
    default:        return "closing";
  }
}

void publishGarage()  { publishStatus("home/garage/status", garageName(garage)); }
void publishCooler()  { publishStatus("home/cooler/status", coolerOn ? "on" : "off"); }
void publishTv()      { publishStatus("home/tv/status", tvOn ? "on" : "off"); }
void publishDoor()    { publishStatus("home/door/status", doorOpen ? "open" : "closed"); }

void publishAll() {
  publishGarage(); publishCooler(); publishTv(); publishDoor();
}

// ---------- device actions ----------
void startGarage(bool opening) {
  garage = opening ? G_OPENING : G_CLOSING;
  garageStarted = millis();
  lastBlink = millis();
  publishGarage();
}

void setCooler(bool on) { coolerOn = on; digitalWrite(PIN_COOLER, on); publishCooler(); }
void setTv(bool on)     { tvOn = on;     digitalWrite(PIN_TV, on);     publishTv(); }
void setDoor(bool open) { doorOpen = open; digitalWrite(PIN_DOOR, open); publishDoor(); }

void nightMode() {
  if (garage == G_OPEN) startGarage(false);
  else if (garage == G_OPENING) pendingGarageClose = true;
  setDoor(false);
  setTv(false);
  setCooler(false);
}

// ---------- MQTT ----------
void onMessage(char *topicRaw, byte *payload, unsigned int len) {
  String topic(topicRaw);
  String msg;
  for (unsigned int i = 0; i < len; i++) msg += (char)payload[i];
  msg.trim();

  if (topic == "home/garage/cmd") {
    // ignore commands while a transition is running
    if (msg == "open" && garage == G_CLOSED) startGarage(true);
    else if (msg == "close" && garage == G_OPEN) startGarage(false);
  } else if (topic == "home/cooler/cmd") {
    if (msg == "on") setCooler(true); else if (msg == "off") setCooler(false);
  } else if (topic == "home/tv/cmd") {
    if (msg == "on") setTv(true); else if (msg == "off") setTv(false);
  } else if (topic == "home/door/cmd") {
    if (msg == "open") setDoor(true); else if (msg == "close") setDoor(false);
  } else if (topic == "home/all/cmd") {
    if (msg == "night") nightMode();
  }
}

void connectWifi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.print("WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println(" connected");
}

bool connectMqtt() {
  // Last Will: broker publishes "offline" if we vanish
  bool ok = mqtt.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_PASS,
                         "home/system/status", 1, true, "offline");
  if (!ok) return false;
  mqtt.subscribe("home/garage/cmd", 1);
  mqtt.subscribe("home/cooler/cmd", 1);
  mqtt.subscribe("home/tv/cmd", 1);
  mqtt.subscribe("home/door/cmd", 1);
  mqtt.subscribe("home/all/cmd", 1);
  publishStatus("home/system/status", "online");
  publishAll();
  return true;
}

// ---------- garage state machine (non-blocking) ----------
void updateGarage() {
  unsigned long now = millis();
  switch (garage) {
    case G_OPENING:
    case G_CLOSING:
      if (now - lastBlink >= BLINK_INTERVAL_MS) {
        lastBlink = now;
        digitalWrite(PIN_GARAGE, !digitalRead(PIN_GARAGE));
      }
      if (now - garageStarted >= GARAGE_TRANSITION_MS) {
        if (garage == G_OPENING) {
          garage = G_OPEN;
          digitalWrite(PIN_GARAGE, HIGH);   // steady red
          publishGarage();
          if (pendingGarageClose) {
            pendingGarageClose = false;
            startGarage(false);
          }
        } else {
          garage = G_CLOSED;
          digitalWrite(PIN_GARAGE, LOW);    // off
          publishGarage();
        }
      }
      break;
    default:
      break;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(PIN_GARAGE, OUTPUT);
  pinMode(PIN_COOLER, OUTPUT);
  pinMode(PIN_TV, OUTPUT);
  pinMode(PIN_DOOR, OUTPUT);
  digitalWrite(PIN_GARAGE, LOW);
  digitalWrite(PIN_COOLER, LOW);
  digitalWrite(PIN_TV, LOW);
  digitalWrite(PIN_DOOR, LOW);

  connectWifi();
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(onMessage);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) connectWifi();

  if (!mqtt.connected()) {
    unsigned long now = millis();
    if (now - lastReconnect >= RECONNECT_INTERVAL_MS) {
      lastReconnect = now;
      connectMqtt();
    }
  } else {
    mqtt.loop();
  }

  updateGarage();   
}
