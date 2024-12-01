import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'message.dart';
import 'contact.dart';
import 'profile.dart';
import '../App/register.dart';
// ignore: duplicate_import
import 'message.dart'; // Pastikan untuk mengimpor file yang berisi MessagePage


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> chats = [
    {
      'name': 'Marsha',
      'last_message': 'Hii, gimana kabar kalian? semoga sehat terus!',
      'id': '1',
      'profile_image': 'assets/marsha_profile.png',
    },
    {
      'name': 'Gita',
      'last_message': 'Selamat pagi!',
      'id': '2',
      'profile_image': 'assets/gita_profile.png',
    },
    {
      'name': 'Flora',
      'last_message': 'Apa rencanamu hari ini?',
      'id': '3',
      'profile_image': 'assets/flora_profile.png',
    },
    {
      'name': 'Adel',
      'last_message': 'Kita bisa bertemu!',
      'id': '4',
      'profile_image': 'assets/adel_profile.png',
    },
    {
      'name': 'Oniel',
      'last_message': 'Sudah makan?',
      'id': '5',
      'profile_image': 'assets/oniel_profile.png',
    },
    {
      'name': 'Zee',
      'last_message': 'Ayo kita olahraga!',
      'id': '6',
      'profile_image': 'assets/zee_profile.png',
    },
    {
      'name': 'Freya',
      'last_message': 'Kamu sudah tidur?',
      'id': '7',
      'profile_image': 'assets/freya_profile.png',
    },
  ]; // Data statis untuk chat
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchChats(); // Ambil daftar chat saat inisialisasi
  }

  Future<void> fetchChats() async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/api/chats')); // Ganti dengan URL API Anda

    if (response.statusCode == 200) {
      setState(() {
        chats = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      // Tangani kesalahan
      print('Failed to load chats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Miracle Chat',
            style: TextStyle(fontFamily: 'Lobster', color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage(userId: '',)), // Ganti dengan halaman profile Anda
                );
              } else if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()), // Ganti dengan halaman register Anda
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Log Out'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Colors.pinkAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari chat...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.pink[50],
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: chats.map((chat) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(chat['profile_image']),
                        ),
                        title: Text(
                          chat['name'] ?? 'Nama tidak tersedia',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          chat['last_message'] ?? 'Belum ada pesan',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagePage(
                                name: chat['name'] ?? 'Nama tidak tersedia',
                                profileImage: chat['profile_image'], chatId: '', senderId: '', receiverId: '',
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 18,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactPage(),
                  ),
                );
              },
              backgroundColor: Colors.pinkAccent,
              child: Icon(Icons.person_add_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
