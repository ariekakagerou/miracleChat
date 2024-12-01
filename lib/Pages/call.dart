import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:miracle_chat/App/register.dart';
import 'package:miracle_chat/App/user.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  List<Map<String, dynamic>> calls = [];
  bool isCalling = false;

  @override
  void initState() {
    super.initState();
    fetchCalls(); // Ambil daftar panggilan saat inisialisasi
  }

  Future<void> fetchCalls() async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/calls')); // Ganti dengan URL API Anda

    if (response.statusCode == 200) {
      setState(() {
        // Decode JSON dan periksa struktur data
        final List<dynamic> jsonData = json.decode(response.body);
        calls = jsonData.map((call) {
          return {
            "username": call["caller_name"] ?? "Unknown", // Ganti dengan field yang benar
            "call_type": call["call_type"],
            "call_time": call["call_time"],
            "photo": call["photo"] ?? 'assets/images/default.jpg', // Ganti dengan field yang benar
          };
        }).toList();
      });
    } else {
      print('Failed to load calls: ${response.statusCode}');
    }
  }

  Future<void> logCall(String callerId, String callType) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/calls'), // Ganti dengan URL API Anda
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': callerId,
        'call_type': callType,
        'call_time': DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()), // Format waktu
      }),
    );

    if (response.statusCode == 201) {
      fetchCalls(); // Memperbarui daftar panggilan setelah berhasil
    } else {
      print('Failed to log call: ${response.statusCode}');
    }
  }

  void startCallingEffect() {
    setState(() {
      isCalling = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isCalling = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedCalls = {
      "Hari Ini": [],
      "Minggu Lalu": [],
      "Bulan Lalu": [],
    };

    for (var call in calls) {
      DateTime callTime = DateTime.parse(call["call_time"]);
      if (callTime.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
        groupedCalls["Hari Ini"]!.add(call);
      } else if (callTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        groupedCalls["Minggu Lalu"]!.add(call);
      } else if (callTime.isAfter(DateTime.now().subtract(const Duration(days: 30)))) {
        groupedCalls["Bulan Lalu"]!.add(call);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idol Calls', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                String userId = 'some_user_id'; // Ganti dengan ID pengguna yang sesuai
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: userId, phone: 'some_phone_number'), // Mengirimkan userId dan nomor telepon ke ProfilePage
                  ),
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
                colors: [
                  Colors.pink[100]!,
                  Colors.pink[50]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Sapaan dari Idola: "Hai, senang bisa terhubung dengan kamu!"',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.pinkAccent),
                  ),
                ),
                ...groupedCalls.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                      ...entry.value.map((call) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(call["photo"] ?? 'assets/images/default.jpg'),
                              radius: 28,
                            ),
                            title: Text(
                              call["username"].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.pink[900],
                              ),
                            ),
                            subtitle: Text(
                              call["call_type"],
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Icon(
                              call["call_type"] == "Favorit" ? Icons.star : Icons.phone,
                              color: call["call_type"] == "Favorit" ? Colors.yellow : Colors.green,
                            ),
                            onTap: () {
                              startCallingEffect();
                              logCall(call["username"].toString(), call["call_type"]);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
          if (isCalling)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pinkAccent.withOpacity(0.2),
                ),
                width: 150,
                height: 150,
                child: const Icon(
                  Icons.star,
                  size: 70,
                  color: Colors.pink,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startCallingEffect();
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.phone, color: Colors.white),
      ),
    );
  }
}