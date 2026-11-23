import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/device.dart';
import '../voice/voice_service.dart';

enum LinkState { disconnected, connecting, connected }


class MqttService extends ChangeNotifier {
  MqttService(this._voice);

  final VoiceService _voice;
  MqttServerClient? _client;
  StreamSubscription? _sub;
  Timer? _nightTimer;
  bool _nightPending = false;

  String host = '192.168.1.100';
  int port = 1883;

  LinkState link = LinkState.disconnected;

  /// 'online' / 'offline' / null (unknown), from home/system/status
  String? systemStatus;

  /// device id -> last status value
  final Map<String, String> statuses = {};

  bool get hardwareOnline =>
      link == LinkState.connected && systemStatus == 'online';

  // ---------- settings ----------
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    host = prefs.getString('host') ?? host;
    port = prefs.getInt('port') ?? port;
  }

  Future<void> updateSettings(String newHost, int newPort) async {
    host = newHost.trim();
    port = newPort;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', host);
    await prefs.setInt('port', port);
    await connect();
  }

  // ---------- connection ----------
  Future<void> connect() async {
    await _sub?.cancel();
    _client?.disconnect();

    link = LinkState.connecting;
    systemStatus = null;
    notifyListeners();

    final id = 'smart_home_app_${DateTime.now().millisecondsSinceEpoch}';
    final c = MqttServerClient(host, id)
      ..port = port
      ..keepAlivePeriod = 20
      ..connectTimeoutPeriod = 5000
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..logging(on: false);

    c.connectionMessage =
        MqttConnectMessage().withClientIdentifier(id).startClean();

    c.onConnected = () {
      link = LinkState.connected;
      notifyListeners();
    };
    c.onAutoReconnect = () {
      link = LinkState.connecting;
      notifyListeners();
    };
    c.onAutoReconnected = () {
      link = LinkState.connected;
      notifyListeners();
    };
    c.onDisconnected = () {
      if (identical(_client, c) && link != LinkState.connecting) {
        link = LinkState.disconnected;
        systemStatus = null;
        notifyListeners();
      }
    };

    _client = c;

    try {
      await c.connect();
    } catch (_) {
      c.disconnect();
      link = LinkState.disconnected;
      notifyListeners();
      return;
    }

    if (c.connectionStatus?.state != MqttConnectionState.connected) {
      c.disconnect();
      link = LinkState.disconnected;
      notifyListeners();
      return;
    }

    // all device statuses + home/system/status
    c.subscribe('home/+/status', MqttQos.atLeastOnce);
    _sub = c.updates!.listen((events) => _onMessages(events));
  }

  // ---------- incoming ----------
  void _onMessages(List<dynamic> events) {
    for (final e in events) {
      final msg = e.payload as MqttPublishMessage;
      final value =
          MqttPublishPayload.bytesToStringAsString(msg.payload.message).trim();
      _handle(e.topic as String, value);
    }
    _checkNight();
    notifyListeners();
  }

  void _handle(String topic, String value) {
  final parts = topic.split('/');
  if (parts.length != 3 || parts[0] != 'home' || parts[2] != 'status') {
    return;
  }
  final id = parts[1];

  if (id == 'system') {
    systemStatus = value;
    return;
  }

  final previous = statuses[id];
  statuses[id] = value;

  // Voice only on real changes, and NOT while night mode is running
  if (previous != null && previous != value && !_nightPending) {
    _voice.onStatus(id, value);
  }
}

  // ---------- outgoing ----------
  void _send(String topic, String payload) {
    final c = _client;
    if (c == null ||
        c.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(payload);
    c.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void toggle(Device d) {
    final active = statuses[d.id] == d.onStatus;
    _send(d.cmdTopic, active ? d.offCmd : d.onCmd);
  }

  void nightMode() {
    _send('home/all/cmd', 'night');
    _nightPending = true;
    _nightTimer?.cancel();
    _nightTimer = Timer(const Duration(seconds: 20), () => _nightPending = false);
  }

  /// Announce "night mode" only after the hardware reports everything secured.
  void _checkNight() {
    if (!_nightPending) return;
    final done = statuses['garage'] == 'closed' &&
        statuses['door'] == 'closed' &&
        statuses['tv'] == 'off' &&
        statuses['cooler'] == 'off';
    if (done) {
      _nightPending = false;
      _nightTimer?.cancel();
      _voice.play('night_mode');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _nightTimer?.cancel();
    _client?.disconnect();
    super.dispose();
  }
}
