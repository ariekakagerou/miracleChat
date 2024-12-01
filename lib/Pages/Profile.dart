import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String userId; // Menyimpan ID pengguna

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String phoneNumber = '';
  String profileImage = 'URL_FOTO'; // Ganti dengan URL foto default

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // Ambil data profil saat halaman dimuat
  }

  Future<void> fetchUserProfile() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/users/${widget.userId}')); // Ganti dengan URL API Anda

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        username = data['username']; // Ambil username dari response
        phoneNumber = data['phone_number']; // Ambil nomor telepon dari response
        profileImage = data['profile_image']; // Ambil URL gambar profil dari response
      });
    } else {
      print('Failed to load user profile: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Idol Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink[100]!,
              Colors.pink[50]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        child: Column(
          children: [
            // Avatar dengan bingkai
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.pinkAccent,
                      width: 4,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profileImage), // Menggunakan URL gambar dari API
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Nama Pengguna
            Text(
              username.isNotEmpty ? username : 'Loading...', // Menampilkan username
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 8),
            // Deskripsi
            const Text(
              'Ini bukan nama pengguna atau PIN Anda. Nama ini akan terlihat oleh kontak WhatsApp Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            // Telepon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, color: Colors.pinkAccent),
                const SizedBox(width: 8),
                Text(
                  phoneNumber.isNotEmpty ? phoneNumber : 'Loading...', // Menampilkan nomor telepon
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Tombol interaktif
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Logika untuk mengikuti idol
                  },
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  label: const Text('Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Logika untuk mengirim pesan
                  },
                  icon: const Icon(Icons.message, color: Colors.pinkAccent),
                  label: const Text(
                    'Message',
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.pinkAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}