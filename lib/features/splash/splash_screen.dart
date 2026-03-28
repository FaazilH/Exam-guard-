import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _fadeController;
  late AnimationController _taglineController;

  late Animation<double> _drawAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _taglineAnimation;

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.fastOutSlowIn,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineAnimation = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    _drawController.forward().whenComplete(() {
      _fadeController.forward().whenComplete(() {
        _taglineController.forward();
      });
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    _fadeController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF010101),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kCyan.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _drawAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SleekEPainter(progress: _drawAnimation.value),
                      size: const Size(80, 80),
                    );
                  },
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "EXAM GUARD",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 10,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: kCyan.withOpacity(0.6),
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _taglineAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "YOUR EXAM. YOUR SLOT. NO CONFLICTS.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.exo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white54,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _taglineAnimation,
                  child: Text(
                    "learning Partner",
                    style: orbitron(10, color: kGold.withAlpha(120), spacing: 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SleekEPainter extends CustomPainter {
  final double progress;
  SleekEPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kCyan
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final sharpPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final h = size.height;
    final w = size.width;
    path.moveTo(w, 0);
    path.lineTo(0, 0);
    path.lineTo(0, h);
    path.lineTo(w, h);
    path.moveTo(0, h * 0.5);
    path.lineTo(w * 0.7, h * 0.5);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    double totalLength = metrics.fold(0, (sum, m) => sum + m.length);
    double drawLength = totalLength * progress;
    final drawnPath = Path();
    for (final metric in metrics) {
      if (drawLength <= 0) break;
      final take = math.min(metric.length, drawLength);
      drawnPath.addPath(metric.extractPath(0.0, take), Offset.zero);
      drawLength -= take;
    }
    canvas.drawPath(drawnPath, paint);
    canvas.drawPath(drawnPath, sharpPaint);
  }

  @override
  bool shouldRepaint(covariant SleekEPainter old) => old.progress != progress;
}
