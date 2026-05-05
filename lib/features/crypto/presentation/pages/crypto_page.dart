import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Wajib untuk fungsi compute()

// 1. FUNGSI PEKERJA GUDANG (ISOLATE) - BERADA DI LUAR CLASS
// Logika Anti-AI: Parameter iterations nantinya akan diisi 110.000.000 (NIM 11 * 10M)
int kalkulasiPajak(int iterations) {
  int result = 0;
  for (int i = 0; i < iterations; i++) {
    result += i;
  }
  return result;
}

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  late WebSocketChannel _channel;
  bool _isCalculating = false;
  String _statusPajak = "Belum dihitung";

  @override
  void initState() {
    super.initState();
    // 2. Membuka koneksi WebSocket ke CoinCap
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.coincap.io/prices?assets=bitcoin'),
    );
  }

  @override
  void dispose() {
    // 3. Menutup saluran saat keluar halaman agar memori tidak bocor
    _channel.sink.close();
    super.dispose();
  }

  // Fungsi untuk menjalankan Isolate saat tombol ditekan
  Future<void> _jalankanIsolate() async {
    setState(() {
      _isCalculating = true;
      _statusPajak = "Menghitung... (Perhatikan layar tidak macet!)";
    });

    // 4. MEMANGGIL COMPUTE
    // Melemparkan tugas ke Isolate dengan beban 110.000.000 sesuai NIM
    final hasil = await compute(kalkulasiPajak, 110000000);

    setState(() {
      _isCalculating = false;
      _statusPajak = "Selesai! Hasil Kalkulasi: $hasil";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Crypto Hub')),
      backgroundColor: Colors.blueGrey.shade900,
      // 5. STREAM BUILDER UNTUK DATA REALTIME
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Koneksi Terputus!', style: TextStyle(color: Colors.red)));
          }

          final String dataString = snapshot.data as String;
          final Map<String, dynamic> dataJson = jsonDecode(dataString);
          final String currentPrice = dataJson['bitcoin'] ?? '0.00';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_bitcoin, size: 100, color: Colors.orange),
                const SizedBox(height: 20),
                const Text('Harga BTC/USD Saat Ini:', style: TextStyle(fontSize: 18, color: Colors.white70)),
                Text(
                  '\$ $currentPrice',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
                const SizedBox(height: 40),
                // Indikator loading untuk membuktikan UI Thread (Kasir) tidak macet
                const CircularProgressIndicator(color: Colors.orange),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                  onPressed: _isCalculating ? null : _jalankanIsolate,
                  child: const Text('Kalkulasi Pajak Kripto', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 10),
                Text(_statusPajak, style: const TextStyle(color: Colors.white54)),
              ],
            ),
          );
        },
      ),
    );
  }
}