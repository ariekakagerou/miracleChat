import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_contact.dart'; // Import halaman untuk menambah kontak
import 'message.dart'; // Import halaman pesan

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> filteredContacts = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchContacts(); // Ambil daftar kontak saat inisialisasi
    searchController.addListener(_filterContacts);
  }

  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/contacts?phone=user_phone_number'));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedContacts = List<Map<String, dynamic>>.from(json.decode(response.body));
        
        if (fetchedContacts.isEmpty) {
          setState(() {
            contacts = []; // Set kontak menjadi kosong
            filteredContacts = []; // Set filteredContacts menjadi kosong
          });
        } else {
          setState(() {
            contacts = fetchedContacts;
            filteredContacts = contacts; // Awalnya, tampilkan semua kontak
          });
        }
        print('Contacts fetched: $contacts'); // Log data kontak
      } else {
        print('Failed to load contacts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  void _filterContacts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) {
        return contact["username"].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void updateContacts() {
    fetchContacts(); // Memanggil fungsi untuk mengambil kontak terbaru
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari idola...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Pilih Idola'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredContacts = contacts;
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.pink[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: const Icon(Icons.person_add, color: Colors.white),
              ),
              title: const Text('Tambah Idol Baru'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddContactPage(onContactAdded: updateContacts), // Pass callback
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Idol Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...filteredContacts.map((contact) {
              print('Profile URL: ${contact['profile']}'); // Log URL gambar
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (contact['profile'] != null && contact['profile'].isNotEmpty)
                      ? NetworkImage(contact['profile'])
                      : const AssetImage('assets/images/default_profile.png'), // Gambar default
                  backgroundColor: Colors.pink[300],
                ),
                title: Text(
                  contact['username']?.isNotEmpty == true 
                      ? contact['username'] 
                      : 'Nama tidak tersedia', // Menampilkan username dengan nilai default
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                subtitle: Text(contact['no_telepon'] ?? 'Nomor tidak tersedia'), // Menampilkan nomor telepon
                onTap: () {
                  // Navigasi ke halaman pesan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagePage(
                        name: contact['username'] ?? 'Nama tidak tersedia',
                        profileImage: contact['profile'] ?? 'assets/images/default_profile.png',
                        chatId: 'id',
                        senderId: 'sender_id',
                        receiverId: contact['user_id'] ?? 'default_receiver_id',
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}