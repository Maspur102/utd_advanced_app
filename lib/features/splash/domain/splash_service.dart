class SplashService {
  Future<void> processDelay() async {
    // Proses penundaan waktu eksekusi: 1 detik
    await Future.delayed(const Duration(seconds: 1));
  }
}