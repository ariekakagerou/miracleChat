import 'package:flutter/material.dart';

class MessagePage extends StatelessWidget {
  final String name;
  final String profileImage;
  final String lastMessage;

  const MessagePage({
    super.key,
    required this.name,
    required this.profileImage,
    required this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Contoh data pesan
    final List<Map<String, String>> messages = [
      {'sender': 'Marsha', 'message': 'Hii, gimana kabar kalian? semoga sehat terus!'},
      {'sender': 'Gita', 'message': 'Selamat pagi!'},
      {'sender': 'Flora', 'message': 'Apa rencanamu hari ini?'},
      {'sender': 'Adel', 'message': 'Kita bisa bertemu!'},
      {'sender': 'Oniel', 'message': 'Sudah makan?'},
      {'sender': 'Zee', 'message': 'Ayo kita olahraga!'},
      {'sender': 'Freya', 'message': 'Kamu sudah tidur?'},
      
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + 1, // Tambahkan 1 untuk lastMessage
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildMessageBubble(lastMessage, name); // Tampilkan lastMessage
                }
                return ListTile(
                  title: Text(messages[index - 1]['message'] ?? ''),
                  subtitle: Text(messages[index - 1]['sender'] ?? ''),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.pink[50],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, String sender) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.pink[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.0),
          Text(message),
        ],
      ),
    );
  }
}
