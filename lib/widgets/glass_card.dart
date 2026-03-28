import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double borderRadius;
  final Color? borderColor;
  final double blurSigma;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = 16,
    this.borderRadius = 16,
    this.borderColor,
    this.blurSigma = 10,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor ?? Colors.white.withAlpha(13),
                Colors.white.withAlpha(5),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withAlpha(26),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (borderColor ?? kCyan).withAlpha(30),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          padding: EdgeInsets.all(padding),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
