import 'package:flutter/material.dart';
import 'dart:math';

class StatusDetailPage extends StatelessWidget {
  final Map<String, dynamic> status;

  const StatusDetailPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradasi latar belakang
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Efek bintang berkelap-kelip
            Positioned.fill(child: StarFieldAnimation()),

            // Konten halaman
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50), // Untuk memberi jarak dari atas

                  // Header dengan profil pengguna
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: status['profile_image_url'] != null
                            ? NetworkImage(status['profile_image_url'])
                            : null,
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status['username'] ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            status['created_at'] != null
                                ? DateTime.parse(status['created_at']).toLocal().toString()
                                : 'Unknown time',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Menampilkan gambar jika ada
                  if (status['image_url'] != null && status['image_url'].isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        status['image_url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Menampilkan konten status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status['content'] ?? 'No Content',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),

                  // Tombol like dengan animasi
                  const SizedBox(height: 20),
                  Center(
                    child: LikeButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Efek bintang berkelap-kelip
class StarFieldAnimation extends StatefulWidget {
  const StarFieldAnimation({super.key});

  @override
  _StarFieldAnimationState createState() => _StarFieldAnimationState();
}

class _StarFieldAnimationState extends State<StarFieldAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: StarPainter(_random, _controller.value),
        );
      },
    );
  }
}

class StarPainter extends CustomPainter {
  final Random random;
  final double animationValue;

  StarPainter(this.random, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 50; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      final scale = (animationValue + i * 0.02) % 1.0;
      canvas.drawCircle(Offset(dx, dy), radius * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Tombol Like dengan animasi
class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      isLiked ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Icon(
            Icons.favorite,
            color: isLiked ? Colors.redAccent : Colors.grey,
            size: 50 * (_controller.value * 0.3 + 0.7), // Animasi scale
          );
        },
      ),
    );
  }
}
