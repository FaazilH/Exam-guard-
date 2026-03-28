import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../models/exam_model.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class ConflictCheckPromptScreen extends StatefulWidget {
  const ConflictCheckPromptScreen({super.key});

  @override
  State<ConflictCheckPromptScreen> createState() => _ConflictCheckPromptScreenState();
}

class _ConflictCheckPromptScreenState extends State<ConflictCheckPromptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exam = ModalRoute.of(context)!.settings.arguments as ExamModel;

    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFF0F1A2E), Color(0xFF0A1020)],
        child: Stack(
          children: [
            // Radar background
            Center(
              child: AnimatedBuilder(
                animation: _radarCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _RadarPainter(_radarCtrl.value),
                  size: const Size(300, 300),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield, color: kCyan, size: 48)
                        .animate()
                        .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: 28,
                      borderColor: kCyan.withAlpha(80),
                      child: Column(
                        children: [
                          Text(
                            'Exam Added!',
                            style: orbitron(20, color: kGreen),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 12),
                          Text(
                            "You've added",
                            style: exo2(14, color: Colors.white54),
                          ),
                          Text(
                            exam.name,
                            style: orbitron(16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Would you like to register a second exam and check for conflicts?',
                            style: exo2(15, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          AnimatedGlowButton(
                            label: 'YES, ADD SECOND EXAM',
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/exam-selection'),
                            gradientColors: [kCyan, kPurple],
                            icon: Icons.add,
                            width: double.infinity,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/dashboard'),
                            child: Text('NO, SKIP',
                                style: exo2(14, color: Colors.white54)),
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Concentric circles
    for (int i = 1; i <= 4; i++) {
      paint.color = kCyan.withAlpha(30);
      canvas.drawCircle(center, maxR * i / 4, paint);
    }

    // Sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi / 2,
        colors: [kCyan.withAlpha(0), kCyan.withAlpha(120)],
        transform: GradientRotation(progress * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: maxR))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxR, sweepPaint);
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}
