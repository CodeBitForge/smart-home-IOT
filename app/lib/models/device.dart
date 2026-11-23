import 'package:flutter/material.dart';


class Device {
  const Device({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.onCmd,
    required this.offCmd,
    required this.onStatus,
    required this.onLabel,
    required this.offLabel,
    required this.statusLabels,
  });

  final String id;
  final String title;
  final Color color;
  final IconData icon;

  
  final String onCmd;
  final String offCmd;

  
  final String onStatus;

  
  final String onLabel;
  final String offLabel;

  final Map<String, String> statusLabels;

  String get cmdTopic => 'home/$id/cmd';
  String get statusTopic => 'home/$id/status';
}

const List<Device> kDevices = [
  Device(
    id: 'garage',
    title: 'پارکینگ',
    color: Colors.red,
    icon: Icons.garage,
    onCmd: 'open',
    offCmd: 'close',
    onStatus: 'open',
    onLabel: 'باز کردن',
    offLabel: 'بستن',
    statusLabels: {
      'closed': 'بسته',
      'opening': 'در حال باز شدن',
      'open': 'باز',
      'closing': 'در حال بسته شدن',
    },
  ),
  Device(
    id: 'cooler',
    title: 'کولر',
    color: Colors.blue,
    icon: Icons.ac_unit,
    onCmd: 'on',
    offCmd: 'off',
    onStatus: 'on',
    onLabel: 'روشن کردن',
    offLabel: 'خاموش کردن',
    statusLabels: {'on': 'روشن', 'off': 'خاموش'},
  ),
  Device(
    id: 'tv',
    title: 'تلویزیون',
    color: Colors.green,
    icon: Icons.tv,
    onCmd: 'on',
    offCmd: 'off',
    onStatus: 'on',
    onLabel: 'روشن کردن',
    offLabel: 'خاموش کردن',
    statusLabels: {'on': 'روشن', 'off': 'خاموش'},
  ),
  Device(
    id: 'door',
    title: 'درب خانه',
    color: Colors.amber,
    icon: Icons.door_front_door,
    onCmd: 'open',
    offCmd: 'close',
    onStatus: 'open',
    onLabel: 'باز کردن',
    offLabel: 'بستن',
    statusLabels: {'open': 'باز', 'closed': 'بسته'},
  ),
];
