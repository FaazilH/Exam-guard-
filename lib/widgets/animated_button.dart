import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class AnimatedGlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final List<Color> gradientColors;
  final IconData? icon;
  final double? width;
  final double height;
  final double fontSize;

  const AnimatedGlowButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradientColors = const [kCyan, kPurple],
    this.icon,
    this.width,
    this.height = 52,
    this.fontSize = 16,
  });

  @override
  State<AnimatedGlowButton> createState() => _AnimatedGlowButtonState();
}

class _AnimatedGlowButtonState extends State<AnimatedGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.gradientColors.first;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (context, _) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment(-1 + _shimmerCtrl.value * 2, 0),
                  end: Alignment(1 + _shimmerCtrl.value * 2, 0),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: first.withAlpha(100),
                    blurRadius: 16,
                    spreadRadius: _pressed ? 1 : 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: orbitron(widget.fontSize, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: Colors.white24);
  }
}
