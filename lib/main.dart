import 'package:flutter/material.dart';
import 'App/register.dart'; // Pastikan untuk mengimpor file register.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miracle Chat', // Mengubah nama aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterPage(), // Mengarahkan ke halaman RegisterPage
    );
  }
}
