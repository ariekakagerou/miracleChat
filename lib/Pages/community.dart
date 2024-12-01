import 'package:flutter/material.dart';
import 'package:miracle_chat/App/register.dart';
import 'package:miracle_chat/App/user.dart';

class CommunityPage extends StatelessWidget {
  final List<Map<String, dynamic>> communityPosts = [
    {
      "title": "Forum Diskusi",
      "description": "Diskusikan topik menarik di sini.",
      "icon": Icons.chat_bubble_outline,
    },
    {
      "title": "Berita dan Pembaruan",
      "description": "Dapatkan berita terbaru.",
      "icon": Icons.new_releases,
    },
    {
      "title": "Event dan Kegiatan",
      "description": "Ikuti event dan kegiatan kami.",
      "icon": Icons.event,
    },
    {
      "title": "Sistem Poin dan Reward",
      "description": "Pelajari tentang sistem poin.",
      "icon": Icons.stars,
    },
    {
      "title": "Sesi Live Chat dan Q&A",
      "description": "Bergabunglah dalam sesi live chat.",
      "icon": Icons.live_tv,
    },
  ];

  CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idol Community'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(phone: '', userId: '',)), // Ganti dengan halaman profile Anda
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink[200]!,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: communityPosts.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
              curve: Curves.easeOut,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  // Animasi getar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Membuka ${communityPosts[index]["title"]}"),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.pink[50],
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      communityPosts[index]["icon"] as IconData,
                      color: Colors.pinkAccent,
                      size: 30,
                    ),
                    title: Text(
                      communityPosts[index]["title"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.pink[900],
                      ),
                    ),
                    subtitle: Text(
                      communityPosts[index]["description"]!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.pink[300],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: ShinyButton(
        onPressed: () {
          // Logika untuk membuat postingan komunitas baru
        },
      ),
    );
  }
}

// Widget khusus untuk efek kilauan pada FAB
class ShinyButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ShinyButton({required this.onPressed, super.key});

  @override
  _ShinyButtonState createState() => _ShinyButtonState();
}

class _ShinyButtonState extends State<ShinyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: Colors.pinkAccent,
          child: Icon(
            Icons.add,
            color: Colors.white.withOpacity(0.8 + 0.2 * _animation.value),
          ),
        );
      },
    );
  }
}
