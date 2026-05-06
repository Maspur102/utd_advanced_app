import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:flutter/foundation.dart';

// Fungsi Isolate untuk beban kerja (NIM 11 * 10.000.000)
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
  List<FlSpot> _chartData = []; 
  int _timeCounter = 0;
  
  bool _isCalculating = false;
  String _statusPajak = "Belum dihitung";
  bool _isLoadingInitial = true; // Indikator untuk loading awal saja

  @override
  void initState() {
    super.initState();
    _fetchPrice();
    // Memperbarui harga setiap 5 detik (Polling) dari API DIA
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchPrice());
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    try {
      final response = await _dio.get(
        'https://api.diadata.org/v1/assetQuotation/Bitcoin/0x0000000000000000000000000000000000000000'
      );
      
      final double price = response.data['Price'].toDouble();

      if (mounted) {
        setState(() {
          _currentPrice = price;
          _isLoadingInitial = false; // Mematikan loading setelah data pertama masuk
          
          _timeCounter++;
          _chartData.add(FlSpot(_timeCounter.toDouble(), price));
          
          if (_chartData.length > 15) {
            _chartData.removeAt(0);
          }
        });
      }
    } catch (e) {
      debugPrint("Error API DIA: $e");
    }
  }

  Future<void> _jalankanIsolate() async {
    setState(() {
      _isCalculating = true;
      _statusPajak = "Menghitung... (Animasi tetap lancar!)";
    });
    // Logika Anti-AI sesuai NIM (110.000.000 loop)[cite: 1]
    final hasil = await compute(kalkulasiPajak, 110000000);
    setState(() {
      _isCalculating = false;
      _statusPajak = "Selesai! Hasil: $hasil";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BTC Pro Chart - DIA Data')),
      body: _isLoadingInitial 
        ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Harga Pro
                Text(
                  '\$ ${_currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
                const Text('+1.31% (Live Polling)', style: TextStyle(color: Colors.greenAccent)),
                
                const SizedBox(height: 20),
                
                // GRAFIK PROFESIONAL DENGAN GRADIENT
                Container(
                  height: 350,
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _chartData,
                          isCurved: true,
                          color: Colors.tealAccent,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          // Memberikan efek area bawah transparan seperti di foto
                          belowBarData: BarAreaData(
                            show: true, 
                            gradient: LinearGradient(
                              colors: [
                                Colors.tealAccent.withOpacity(0.3),
                                Colors.tealAccent.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                // PANEL KONTROL
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10)
                    ),
                    child: Column(
                      children: [
                        // LOGIKA PERBAIKAN LOADING: Hanya muncul saat kalkulasi Isolate berjalan
                        if (_isCalculating) 
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: CircularProgressIndicator(color: Colors.orangeAccent),
                          ),
                        
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          onPressed: _isCalculating ? null : _jalankanIsolate,
                          icon: const Icon(Icons.calculate),
                          label: const Text('Kalkulasi Pajak Kripto (Isolate)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusPajak, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 14)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }
}