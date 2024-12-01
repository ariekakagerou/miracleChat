import 'package:flutter/material.dart';
import '../App/register.dart'; // Ganti dengan path ke halaman register Anda

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menunggu 3 detik sebelum pindah ke halaman register
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                RegisterPage()), // Ganti dengan halaman register Anda
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink, // Warna latar belakang
      body: Center(
        child: Image.asset('assets/logo.png'), // Menampilkan logo
      ),
    );
  }
}
