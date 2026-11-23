import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';


class VoiceService {
  final AudioPlayer _player = AudioPlayer();

  static const Map<String, Map<String, String>> _clips = {
  'garage': {
    'opening': 'garage_opening',
    'open': 'garage_open',
    'closing': 'garage_closing',
    'closed': 'garage_closed',
  },
  'cooler': {
    'on': 'cooler_on',
    'off': 'cooler_off',
  },
  'tv': {
    'on': 'tv_on',
    'off': 'tv_off',
  },
  'door': {
    'open': 'door_open',
    'closed': 'door_closed',
  },
};

  Future<void> onStatus(String deviceId, String status) async {
    final clip = _clips[deviceId]?[status];
    debugPrint('VOICE: status $deviceId=$status -> clip=$clip');
    if (clip != null) await play(clip);
  }

  Future<void> play(String clip) async {
    debugPrint('VOICE: playing $clip');
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$clip.mp3'));
    } catch (e) {
      debugPrint('VOICE ERROR ($clip): $e');
    }
  }
}