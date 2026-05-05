import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key});

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  // JEMBATAN KOMUNIKASI KE KOTLIN
  static const platform = MethodChannel('utd.ac.id/native_jembatan');
  
  String _batteryLevel = 'Baterai belum dicek.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Sisa Baterai Anda: $result %';
    } on PlatformException catch (e) {
      batteryLevel = "Gagal membaca baterai: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _showNativeToast() async {
    try {
      // LOGIKA ANTI-AI: Mengirim Nama dan NIM ke Native Toast
      await platform.invokeMethod('showToast', {
        "pesan": "Purnama Raharja - 20123011"
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal Toast: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrasi Native Android')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.android, size: 80, color: Colors.greenAccent),
                const SizedBox(height: 20),
                Text(
                  _batteryLevel, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _getBatteryLevel,
                    icon: const Icon(Icons.battery_charging_full),
                    label: const Text('Cek Baterai (Via Kotlin)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showNativeToast,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Munculkan Native Toast'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade400,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}