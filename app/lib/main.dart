import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'mqtt/mqtt_service.dart';
import 'screens/home_screen.dart';
import 'voice/voice_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the native splash (dark screen + white S) on screen while we start.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final mqtt = MqttService(VoiceService());
  await mqtt.loadSettings();

  runApp(
    ChangeNotifierProvider.value(
      value: mqtt,
      child: const SmartHomeApp(),
    ),
  );

  mqtt.connect(); // not awaited: the UI shows the connection state

  // Show the splash for a moment, then reveal the app.
  await Future.delayed(const Duration(milliseconds: 1400));
  FlutterNativeSplash.remove();
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}
