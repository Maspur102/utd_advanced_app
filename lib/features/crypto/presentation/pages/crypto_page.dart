import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart'; // Package grafik
import 'package:flutter/foundation.dart';

// Fungsi Isolate untuk kalkulasi pajak (Tetap ada untuk syarat UTS)
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
  final Dio _dio = Dio();
  Timer? _timer;
  double _currentPrice = 0.0;
  List<FlSpot> _chartData = []; // Data untuk grafik
  int _timeCounter = 0;
  
  bool _isCalculating = false;
  String _statusPajak = "Belut dihitung";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
    // 1. POLLING: Panggil API DIA setiap 5 detik agar "Live"
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchPrice());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Berhenti memanggil API saat keluar halaman
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    try {
      // 2. MEMANGGIL API DIA DATA
      final response = await _dio.get(
        'https://api.diadata.org/v1/assetQuotation/Bitcoin/0x0000000000000000000000000000000000000000'
      );
      
      final double price = response.data['Price'].toDouble();

      setState(() {
        _currentPrice = price;
        _isLoading = false;
        
        // 3. UPDATE DATA GRAFIK
        _timeCounter++;
        _chartData.add(FlSpot(_timeCounter.toDouble(), price));
        
        // Batasi hanya menampilkan 10 titik terakhir agar grafik tidak sesak
        if (_chartData.length > 10) {
          _chartData.removeAt(0);
        }
      });
    } catch (e) {
      debugPrint("Gagal ambil data DIA: $e");
    }
  }

  Future<void> _jalankanIsolate() async {
    setState(() {
      _isCalculating = true;
      _statusPajak = "Menghitung... (Layar Tetap Lancar)";
    });
    // Logika Anti-AI: NIM 11 * 10M
    final hasil = await compute(kalkulasiPajak, 110000000);
    setState(() {
      _isCalculating = false;
      _statusPajak = "Selesai! Hasil: $hasil";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DIA Real-time Bitcoin')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.currency_bitcoin, size: 60, color: Colors.orangeAccent),
                const SizedBox(height: 10),
                const Text('Harga BTC (DIA Data)', style: TextStyle(color: Colors.white70)),
                Text(
                  '\$ ${_currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
                
                // 4. WIDGET GRAFIK
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(20),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData,
                          isCurved: true,
                          color: Colors.tealAccent,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true, 
                            color: Colors.tealAccent.withOpacity(0.1)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.orangeAccent),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade400,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50)
                          ),
                          onPressed: _isCalculating ? null : _jalankanIsolate,
                          child: const Text('Kalkulasi Pajak (Isolate)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(_statusPajak, style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }
}