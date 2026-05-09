import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';

// 1. NAMA TUGAS LATAR BELAKANG
const String syncTask = "tugas_sinkronisasi_rutin";

// 2. PEKERJA LATAR BELAKANG (Top-Level Function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == syncTask) {
      try {
        debugPrint("Mulai mengambil data dari server secara gaib...");
        await Future.delayed(const Duration(seconds: 3)); // Simulasi download
        
        final prefs = await SharedPreferences.getInstance();
        String currentTime = DateFormat('dd MMM yyyy, HH:mm:ss').format(DateTime.now());
        await prefs.setString("last_sync_time", "Sinkronisasi diam-diam sukses pada:\n$currentTime");
        
        debugPrint("Tugas Latar Belakang Selesai!");
      } catch (e) {
        debugPrint("Tugas gagal: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Inisialisasi WorkManager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Memunculkan notifikasi debug saat task berjalan
  );

  setupLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'UTD Store',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurpleAccent,
          surface: const Color(0xFF1E1E2C),
          background: const Color(0xFF12121D),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF12121D),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}