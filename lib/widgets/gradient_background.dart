import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Widget child;
  final bool showParticles;

  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
    this.showParticles = false,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: widget.colors,
            ),
          ),
        ),
        // Animated particle overlay
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_ctrl.value, widget.colors),
              size: Size.infinite,
            ),
          ),
        // Content
        widget.child,
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  static final List<_Particle> _particles = [];

  _ParticlePainter(this.progress, this.colors) {
    if (_particles.isEmpty) {
      final rng = Random(42);
      for (int i = 0; i < 50; i++) {
        _particles.add(_Particle(
          x: rng.nextDouble(),
          y: rng.nextDouble(),
          radius: rng.nextDouble() * 2 + 0.5,
          speed: rng.nextDouble() * 0.002 + 0.0005,
          opacity: rng.nextDouble() * 0.5 + 0.1,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = colors.isNotEmpty ? colors.first : kCyan;
    for (final p in _particles) {
      final dy = (p.y + progress * p.speed * 100) % 1.0;
      final paint = Paint()
        ..color = baseColor.withAlpha((p.opacity * 255).toInt())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(p.x * size.width, dy * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, y, radius, speed, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}
