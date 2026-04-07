import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';              // ✅ ADDED
import 'package:graburticket/screens/login_page.dart';
import 'HomePageScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  final List<Particle> particles = [];
  final int particleCount = 120;
  final Random rand = Random();

  @override
  void initState() {
    super.initState();

    // Logo fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Logo subtle scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _scaleController.forward();

    // Initialize swirling particles around logo
    for (int i = 0; i < particleCount; i++) {
      particles.add(
        Particle(
          angle: rand.nextDouble() * 2 * pi,
          radius: 80 + rand.nextDouble() * 50,
          speed: 0.01 + rand.nextDouble() * 0.02,
          size: 2 + rand.nextDouble() * 2,
          color: Colors.yellowAccent.withOpacity(0.8),
        ),
      );
    }

    // Animate particles
    Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        for (var p in particles) {
          p.angle += p.speed;
        }
      });
    });

    //  Decide where to go after 3 seconds
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Not logged in → go to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        // Already logged in → go to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePageScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1️⃣ Premium radial gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.0,
                colors: [
                  Colors.red.shade900.withOpacity(0.9),
                  Colors.black,
                ],
              ),
            ),
          ),

          // 2️⃣ Swirling particles around logo
          CustomPaint(
            painter: SwirlParticlePainter(particles),
          ),

          // 3️⃣ Logo with glow, fade and scale
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade700.withOpacity(0.7),
                        blurRadius: 50,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // 4️⃣ App name with glow
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Grab Ur Ticket",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(2, 2),
                    ),
                    Shadow(
                      color: Colors.orange.shade700.withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle model for swirling effect
class Particle {
  double angle;
  double radius;
  double speed;
  double size;
  Color color;

  Particle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
    required this.color,
  });
}

// CustomPainter for swirling particles
class SwirlParticlePainter extends CustomPainter {
  final List<Particle> particles;

  SwirlParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      double x = center.dx + p.radius * cos(p.angle);
      double y = center.dy + p.radius * sin(p.angle);
      paint.color = p.color;
      canvas.drawCircle(Offset(x, y), p.size, paint);

      // Optional streak / tail for sparkle
      paint.color = p.color.withOpacity(0.3);
      canvas.drawLine(
        Offset(x, y),
        Offset(x - p.size * 2, y - p.size * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
