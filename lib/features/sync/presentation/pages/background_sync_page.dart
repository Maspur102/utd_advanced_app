import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart'; 

class BackgroundSyncPage extends StatefulWidget {
  const BackgroundSyncPage({super.key});

  @override
  State<BackgroundSyncPage> createState() => _BackgroundSyncPageState();
}

class _BackgroundSyncPageState extends State<BackgroundSyncPage> {
  String _lastSyncInfo = "Belum pernah sinkronisasi";

  @override
  void initState() {
    super.initState();
    _cekWaktuSyncTerakhir();
  }

  Future<void> _cekWaktuSyncTerakhir() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSyncInfo = prefs.getString("last_sync_time") ?? "Belum pernah sinkronisasi";
    });
  }

  // POST-TEST 2: Constraint Eksplorasi (Harus di-cas)
  void _mulaiSinkronisasiRutin() {
    Workmanager().registerPeriodicTask(
      "unique_id_sync_01",
      syncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresCharging: true, // Jawaban Post-Test 2: Hanya jalan saat di-cas
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Auto-Sync Aktif! (Syarat: Harus di-cas & ada Internet)")),
    );
  }

  // POST-TEST 1: Eksperimen One-Off Task 10 Detik
  void _sinkronisasiSekaliJalan10Detik() {
    Workmanager().registerOneOffTask(
      "unique_id_sync_02",
      syncTask,
      initialDelay: const Duration(seconds: 10), // Jawaban Post-Test 1
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("One-Off Task Aktif! Silakan tutup aplikasi sekarang (Swipe up) dan tunggu 10 detik.")),
    );
  }

  void _hentikanSinkronisasi() {
    Workmanager().cancelAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua Tugas Background Dibatalkan!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Background')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sync_cloud, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 20),
              const Text("Terakhir Dikerjakan Oleh Latar Belakang:", style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(
                  _lastSyncInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(double.infinity, 50)),
                onPressed: _mulaiSinkronisasiRutin,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Mulai Auto-Sync (Periodic 15m)', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
                onPressed: _sinkronisasiSekaliJalan10Detik,
                icon: const Icon(Icons.timer, color: Colors.white),
                label: const Text('Test One-Off Task (10 Detik)', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                onPressed: _hentikanSinkronisasi,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: const Text('Matikan Semua Tugas', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 30),
              TextButton.icon(
                onPressed: _cekWaktuSyncTerakhir,
                icon: const Icon(Icons.refresh, color: Colors.tealAccent),
                label: const Text('Refresh Tampilan Data', style: TextStyle(color: Colors.tealAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}