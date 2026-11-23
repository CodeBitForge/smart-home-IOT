import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device.dart';
import '../mqtt/mqtt_service.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttService>();
    final status = mqtt.statuses[device.id];
    final active = status == device.onStatus;
    final busy = status == 'opening' || status == 'closing';
    final enabled = mqtt.hardwareOnline && !busy;
    final lit = active || busy;

    return Card(
      elevation: 0,
      color: lit
          ? device.color.withValues(alpha: 0.18)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: lit ? device.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(device.icon,
                size: 44, color: lit ? device.color : Colors.grey),
            Text(device.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              status == null
                  ? 'نامشخص'
                  : (device.statusLabels[status] ?? status),
              style: TextStyle(color: lit ? device.color : Colors.grey[600]),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: enabled ? () => mqtt.toggle(device) : null,
                child: Text(active ? device.offLabel : device.onLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
