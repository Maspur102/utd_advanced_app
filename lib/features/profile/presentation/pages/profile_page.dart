import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Developer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.tealAccent, width: 3),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Purnama Raharja',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'NIM: 20123011',
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            // Mengganti "Kelompok" dengan identitas prodi yang lebih profesional
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurpleAccent),
              ),
              child: const Text(
                'Mahasiswa S1 Informatika',
                style: TextStyle(fontSize: 14, color: Colors.tealAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}