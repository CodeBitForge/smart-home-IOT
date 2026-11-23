import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../mqtt/mqtt_service.dart';
import '../widgets/device_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('خانه هوشمند'),
        actions: [
          IconButton(
            tooltip: 'تنظیمات اتصال',
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context, mqtt),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _StatusBanner(mqtt: mqtt),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    for (final d in kDevices) DeviceCard(device: d),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'App & Software: Safari',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.4,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  icon: const Icon(Icons.nightlight_round),
                  label: const Text('حالت شب',
                      style: TextStyle(fontSize: 18)),
                  onPressed: mqtt.hardwareOnline ? mqtt.nightMode : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSettings(BuildContext context, MqttService mqtt) {
    final hostCtrl = TextEditingController(text: mqtt.host);
    final portCtrl = TextEditingController(text: mqtt.port.toString());

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تنظیمات بروکر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostCtrl,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                  labelText: 'آدرس (مثلاً 192.168.1.100)'),
            ),
            TextField(
              controller: portCtrl,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: 'پورت'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () {
              final port = int.tryParse(portCtrl.text.trim()) ?? 1883;
              mqtt.updateSettings(hostCtrl.text, port);
              Navigator.pop(ctx);
            },
            child: const Text('ذخیره و اتصال'),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.mqtt});

  final MqttService mqtt;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;
    late final IconData icon;

    if (mqtt.link == LinkState.connecting) {
      text = 'در حال اتصال به بروکر...';
      color = Colors.orange;
      icon = Icons.sync;
    } else if (mqtt.link == LinkState.disconnected) {
      text = 'اتصال به بروکر برقرار نیست';
      color = Colors.red;
      icon = Icons.cloud_off;
    } else if (mqtt.systemStatus != 'online') {
      text = 'سخت‌افزار متصل نیست';
      color = Colors.red;
      icon = Icons.developer_board_off;
    } else {
      text = 'سخت‌افزار متصل است';
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color))),
          if (mqtt.link == LinkState.disconnected)
            TextButton(
              onPressed: mqtt.connect,
              child: const Text('تلاش مجدد'),
            ),
        ],
      ),
    );
  }
}
