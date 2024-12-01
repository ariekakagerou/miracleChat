import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagePage extends StatefulWidget {
  final String name;
  final String profileImage;
  final String chatId;
  final String senderId;
  final String receiverId;

  const MessagePage({
    super.key, 
    required this.name, 
    required this.profileImage, 
    required this.chatId,
    required this.senderId,
    required this.receiverId,
  });

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:3000/ws'), // Ganti dengan URL WebSocket Anda
    );

    // Mendengarkan pesan yang diterima
    _channel.stream.listen((message) {
      setState(() {
        _messages.add(jsonDecode(message));
      });
    });

    _fetchMessages(); // Ambil pesan saat halaman dimuat
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/messages'), // Endpoint untuk mengambil semua pesan
      );

      if (response.statusCode == 200) {
        final List<dynamic> messages = jsonDecode(response.body);
        setState(() {
          _messages = messages.map((msg) => msg as Map<String, dynamic>).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil pesan: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan jaringan: $e')),
      );
    }
  }

  Future<bool> _checkUserExists(String userId) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID pengguna tidak boleh kosong')),
      );
      return false;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/users/$userId'));
      return response.statusCode == 200;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan jaringan saat memeriksa ID pengguna: $e')),
      );
      return false;
    }
  }

  Future<void> _sendMessage() async {
    String message = _controller.text.trim(); // Menghapus spasi di awal dan akhir
    if (message.isNotEmpty) {
      print('Sender ID: ${widget.senderId}, Receiver ID: ${widget.receiverId}');
      
      bool senderExists = await _checkUserExists(widget.senderId);
      bool receiverExists = await _checkUserExists(widget.receiverId);

      if (senderExists && receiverExists) {
        try {
          final response = await http.post(
            Uri.parse('http://localhost:3000/api/messages'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'sender_id': widget.senderId,
              'receiver_id': widget.receiverId,
              'content': message,
              'is_read': 0,
            }),
          );

          if (response.statusCode == 201) {
            // Kirim pesan melalui WebSocket
            _channel.sink.add(jsonEncode({
              'sender_id': widget.senderId,
              'receiver_id': widget.receiverId,
              'content': message,
              'is_read': 0,
              'timestamp': DateTime.now().toIso8601String(), // Tambahkan timestamp
            }));
            _controller.clear();

            setState(() {
              _messages.add({
                'sender_id': widget.senderId,
                'receiver_id': widget.receiverId,
                'content': message,
                'is_read': 0,
                'timestamp': DateTime.now().toIso8601String(), // Tambahkan timestamp
              });
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal mengirim pesan: ${response.body}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kesalahan jaringan: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengirim atau penerima tidak valid')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesan tidak boleh kosong')),
      );
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _sendMedia(pickedFile);
    }
  }

  Future<void> _sendMedia(XFile file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/messages'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['sender_id'] = widget.senderId;
    request.fields['receiver_id'] = widget.receiverId;
    request.fields['content'] = 'Image sent';

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image sent successfully');
        _fetchMessages();
      } else {
        print('Failed to send image: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan jaringan saat mengirim gambar: $e');
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat melakukan panggilan telepon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.profileImage),
            ),
            SizedBox(width: 10),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.phone),
            onPressed: () => _makePhoneCall('08123456789'),
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () {
              // Logika untuk video
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Logika untuk pengaturan
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['sender_id'] == widget.senderId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: message['sender_id'] == widget.senderId
                          ? Colors.pink[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'],
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['timestamp'] != null
                              ? DateTime.parse(message['timestamp']).toLocal().toString() // Format waktu
                              : '',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['is_read'] == 1 ? '✓✓' : '✓',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions, color: Colors.pink),
                  onPressed: () {
                    // Logika untuk menampilkan emoji
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image, color: Colors.pink),
                  onPressed: _pickMedia,
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.pink),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}