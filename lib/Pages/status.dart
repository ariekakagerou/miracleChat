import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:miracle_chat/App/register.dart';
import 'package:miracle_chat/App/user.dart';
import 'package:miracle_chat/Pages/status_detail.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Map<String, dynamic>> statuses = [];
  List<Map<String, dynamic>> viewedUpdates = [];
  final String userId = '1'; // Ganti dengan ID pengguna yang sesuai

  @override
  void initState() {
    super.initState();
    fetchStatuses(); // Ambil daftar status saat inisialisasi
  }

  Future<void> fetchStatuses() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/statuses'));

    if (response.statusCode == 200) {
      setState(() {
        statuses = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to load statuses: ${response.statusCode}');
    }
  }

  Future<void> postTextStatus(BuildContext context) async {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buat Status Tulisan'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: "Masukkan status Anda"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String content = textController.text;
                if (content.isNotEmpty) {
                  await postTextStatusToServer(content);
                  Navigator.of(context).pop(); // Menutup dialog setelah mengirim
                }
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> postTextStatusToServer(String content) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/statuses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'content': content,
        'image_url': null,
      }),
    );

    if (response.statusCode == 201) {
      fetchStatuses(); // Memperbarui daftar status setelah berhasil
    } else {
      print('Failed to post status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Tambahkan ini untuk melihat detail kesalahan
    }
  }

  Future<void> postImageStatus(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String content = '';

        // Menampilkan dialog untuk menambahkan teks
        TextEditingController textController = TextEditingController();
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('Tambahkan Teks untuk Status'),
                    content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Image.file(imageFile), // Menampilkan gambar yang dipilih
                            TextField(
                                controller: textController,
                                decoration: InputDecoration(hintText: "Masukkan status Anda"),
                            ),
                        ],
                    ),
                    actions: [
                        TextButton(
                            onPressed: () {
                                Navigator.of(context).pop(); // Menutup dialog
                            },
                            child: Text('Batal'),
                        ),
                        TextButton(
                            onPressed: () async {
                                content = textController.text;
                                if (content.isNotEmpty) {
                                    await postImageStatusToServer(content, imageFile);
                                    Navigator.of(context).pop(); // Menutup dialog setelah mengirim
                                }
                            },
                            child: Text('Kirim'),
                        ),
                    ],
                );
            },
        );
    } else {
        print('No image selected.');
    }
  }

  Future<void> postImageStatusToServer(String content, File imageFile) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/statuses/image'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['content'] = content; // Menggunakan konten dari input pengguna
    request.fields['user_id'] = userId;

    var response = await request.send();

    if (response.statusCode == 201) {
        fetchStatuses(); // Memperbarui daftar status setelah berhasil
        setState(() {
            viewedUpdates.add({
                "image": imageFile.path,
                "name": "Status Anda",
                "time": DateTime.now().toString(),
            });
        });
    } else {
        print('Failed to post image status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idol Updates'),
        backgroundColor: Colors.pinkAccent[100],
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(phone: '', userId: '',)),
                );
              } else if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
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
      body: RefreshIndicator(
        onRefresh: fetchStatuses,
        child: Container(
          color: Colors.pink[50],
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text(
                    'My Idol Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Stack(
                        children: const [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/default_profile.png'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.favorite,
                              color: Colors.pinkAccent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      title: const Text('Status Saya'),
                      subtitle: const Text('Tap to update your idol status!'),
                      onTap: () async {
                        await postImageStatus(context); // Memanggil fungsi untuk mengupload gambar
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatusDetailPage(status: {
                              'content': 'Contoh status',
                              'created_at': DateTime.now().toIso8601String(),
                              'image_url': null,
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Latest Idol Updates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...statuses.map((status) {
                    return Card(
                      color: Colors.pink[50],
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(status["profile"] ?? 'assets/default_profile.png'),
                        ),
                        title: Text(
                          status["username"] ?? 'Unknown User',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          status["created_at"] != null
                              ? DateTime.parse(status["created_at"]).toLocal().toString()
                              : 'Unknown time',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusDetailPage(status: status),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    backgroundColor: Colors.pink[50],
                    iconColor: Colors.pinkAccent,
                    collapsedIconColor: Colors.pink,
                    title: const Text(
                      'Viewed Idol Updates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.pink,
                      ),
                    ),
                    children: viewedUpdates.map((update) {
                      return Card(
                        color: Colors.pink[50],
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(update["image"]!),
                          ),
                          title: Text(
                            update["name"]!,
                            style: TextStyle(color: Colors.pink[900]),
                          ),
                          subtitle: Text(update["time"]!),
                          onTap: () {
                            // Logika untuk membuka detail status
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientFAB(
                      icon: Icons.create,
                      onPressed: () {
                        postTextStatus(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    GradientFAB(
                      icon: Icons.photo,
                      onPressed: () {
                        postImageStatus(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Floating Action Button dengan Gradient Effect
class GradientFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const GradientFAB({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.pinkAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}