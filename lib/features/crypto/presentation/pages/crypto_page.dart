import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.coincap.io/prices?assets=bitcoin'),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _jalankanIsolate() async {
    setState(() {
      _isCalculating = true;
      _statusPajak = "Menghitung... (Perhatikan layar tidak macet!)";
    });

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Koneksi Terputus!', style: TextStyle(color: Colors.red)));
          }

          String currentPrice = 'Menunggu data...';
          
          // PARSING JSON LEBIH AMAN
          if (snapshot.hasData) {
            try {
              final String dataString = snapshot.data.toString();
              final Map<String, dynamic> dataJson = jsonDecode(dataString);
              if (dataJson.containsKey('bitcoin')) {
                currentPrice = '\$ ${dataJson['bitcoin']}';
              }
            } catch (e) {
              currentPrice = 'Loading market...';
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_bitcoin, size: 100, color: Colors.orangeAccent),
                const SizedBox(height: 20),
                const Text('Harga BTC/USD Saat Ini:', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 10),
                Text(
                  currentPrice,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
                const SizedBox(height: 40),
                // PERBAIKAN: Dibungkus SizedBox agar ukurannya tidak menciut menjadi titik
                const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 3),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade400,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                  ),
                  onPressed: _isCalculating ? null : _jalankanIsolate,
                  child: const Text('Kalkulasi Pajak Kripto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Text(_statusPajak, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          );
        },
      ),
    );
  }
}