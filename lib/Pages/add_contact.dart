import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddContactPage extends StatelessWidget {
  final Function onContactAdded; // Callback untuk memperbarui kontak
  final TextEditingController phoneController = TextEditingController();

  AddContactPage({super.key, required this.onContactAdded}); // Tambahkan parameter ini

  Future<void> addContact(BuildContext context) async {
    final String noTelepon = phoneController.text.trim();

    if (noTelepon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon harus diisi!')),
      );
      return;
    }

    // Validasi format nomor telepon (harus diawali dengan + dan diikuti oleh 10-15 digit)
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(noTelepon)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak valid!')),
      );
      return;
    }

    // Memeriksa apakah nomor telepon sudah terdaftar di tabel pengguna
    try {
      final userCheckResponse = await http.post(
        Uri.parse('http://localhost:3000/api/check-phone'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'no_telepon': noTelepon,
        }),
      );

      if (userCheckResponse.statusCode == 200) {
        final userCheckData = jsonDecode(userCheckResponse.body);
        print('Data pengguna: $userCheckData');

        if (!userCheckData['exists']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nomor telepon tidak terdaftar di pengguna!')),
          );
          return;
        }

        // Ambil id_user dari data pengguna
        final int? idUser = userCheckData['userId'];
        print('ID Pengguna: $idUser');

        // Tambahkan validasi untuk idUser
        if (idUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ID pengguna tidak ditemukan!')),
          );
          return;
        }

        // Menambahkan kontak baru
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/contacts'), // Endpoint untuk menambahkan kontak
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'id_user': idUser,
            'id_contact': noTelepon, // Pastikan ini sesuai dengan struktur tabel
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kontak berhasil ditambahkan!')),
          );
          onContactAdded(); // Panggil callback untuk memperbarui kontak
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan kontak: ${response.body}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memeriksa nomor telepon pengguna')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Idol Baru',
          style: TextStyle(fontFamily: 'Pacifico', fontSize: 22),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.pink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Tambahkan Idola Favoritmu!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => addContact(context),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Simpan Idol',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}