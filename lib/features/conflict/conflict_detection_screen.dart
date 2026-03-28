import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/gradient_background.dart';

class ConflictDetectionScreen extends StatefulWidget {
  const ConflictDetectionScreen({super.key});

  @override
  State<ConflictDetectionScreen> createState() => _ConflictDetectionScreenState();
}

class _ConflictDetectionScreenState extends State<ConflictDetectionScreen> with TickerProviderStateMixin {
  late AnimationController _radarCtrl;
  late AnimationController _pulseCtrl;
  ConflictResult? _result;
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runScan());
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _runScan() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final exam1 = args['exam1'] as ExamModel;
    final exam2 = args['exam2'] as ExamModel;

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final result = await context.read<ExamProvider>().checkConflict(exam1, exam2);

    if (mounted) {
      setState(() {
        _result = result;
        _scanning = false;
      });
      if (result.isConflict) {
        _pulseCtrl.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final exam1 = args['exam1'] as ExamModel;
    final exam2 = args['exam2'] as ExamModel;

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['conflict']!,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kRed),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('CONFLICT SCAN', style: orbitron(18, color: kRed)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _ExamMiniCard(exam: exam1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('VS', style: orbitron(20, color: kOrange))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(begin: 0.9, end: 1.1, duration: 800.ms),
                    ),
                    Expanded(child: _ExamMiniCard(exam: exam2)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _scanning
                    ? _buildScanning()
                    : _result!.isConflict
                        ? _buildConflictResult(context)
                        : _buildSafeResult(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _radarCtrl,
          builder: (_, __) => CustomPaint(
            painter: _ScanRadarPainter(_radarCtrl.value),
            size: const Size(200, 200),
          ),
        ),
        const SizedBox(height: 32),
        Text('AI Analyzing Date Conflicts', style: orbitron(16, color: kCyan))
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1.5.seconds, color: kCyan),
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: kCyan, strokeWidth: 2),
      ],
    );
  }

  Widget _buildSafeResult(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kGreen.withAlpha(30),
            boxShadow: [BoxShadow(color: kGreen.withAlpha(100), blurRadius: 40, spreadRadius: 10)],
          ),
          child: const Icon(Icons.check_circle, color: kGreen, size: 64),
        ).animate().scale(begin: const Offset(0, 0), duration: 700.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),
        const SizedBox(height: 32),
        Text('NO CONFLICT DETECTED', style: orbitron(24, color: kGreen)).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Text(
          'Both exams are on different dates.\nYou are verified as safe.',
          style: exo2(16, color: Colors.white60),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 450.ms),
        const SizedBox(height: 40),
        AnimatedGlowButton(
          label: 'VIEW MY EXAMS',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          gradientColors: [kGreen, kTeal],
          icon: Icons.shield,
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildConflictResult(BuildContext context) {
    final result = _result!;
    final sevColor = severityColors[result.severity] ?? kRed;
    final isSameDay = result.daysDiff == 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kRed.withAlpha(30),
              boxShadow: [BoxShadow(color: kRed.withAlpha(100), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Icon(
              isSameDay ? Icons.error_outline : Icons.warning_amber_rounded,
              color: kRed,
              size: 56,
            ),
          ).animate().shake(hz: 4, rotation: 0.05, duration: 600.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Text(
            isSameDay ? 'COINCIDENCE DETECTED' : 'DATE CLASH DETECTED',
            style: orbitron(20, color: kRed),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          GlassCard(
            borderColor: kRed.withAlpha(80),
            child: Column(
              children: [
                _ConflictRow(exam: result.exam1),
                const Divider(color: Colors.white12),
                _ConflictRow(exam: result.exam2),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Severity:', style: exo2(13, color: Colors.white54)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: sevColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sevColor),
                      ),
                      child: Text(result.severity, style: orbitron(12, color: sevColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isSameDay ? 'Both examinations fall on the same day. Official dates are restricted until 1 month prior.' : result.message,
                  style: exo2(13, color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 24),
          if (isSameDay) ...[
            AnimatedGlowButton(
              label: 'AUTO-RESOLVE: POSTPONE',
              onTap: () => Navigator.pushNamed(context, '/reschedule', arguments: {'exam': result.exam2, 'conflict': result}),
              gradientColors: [kPurple, kViolet],
              icon: Icons.auto_fix_high_outlined,
              width: double.infinity,
              height: 56,
            ).animate().fadeIn(delay: 500.ms).scale(),
            const SizedBox(height: 12),
            Text(
              'Resolution will find an alternative date at a different time or city.',
              style: exo2(11, color: Colors.white30),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            AnimatedGlowButton(
              label: 'FIND ALTERNATIVE SLOTS',
              onTap: () => Navigator.pushNamed(context, '/reschedule', arguments: {'exam': result.exam2, 'conflict': result}),
              gradientColors: [kRed, kOrange],
              icon: Icons.swap_horiz,
              width: double.infinity,
              height: 56,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            child: Text('NOTIFY ME LATER', style: exo2(14, color: Colors.white38)),
          ).animate().fadeIn(delay: 650.ms),
        ],
      ),
    );
  }
}

class _ExamMiniCard extends StatelessWidget {
  final ExamModel exam;
  const _ExamMiniCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final color = boardColors[exam.board] ?? kCyan;
    return GlassCard(
      padding: 12,
      borderColor: color.withAlpha(80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exam.board, style: orbitron(10, color: color)),
          const SizedBox(height: 4),
          Text(exam.name, style: exo2(11, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(exam.isConfidential ? 'PENDING (TBA)' : exam.displayDate, style: exo2(10, color: Colors.white54)),
        ],
      ),
    );
  }
}

class _ConflictRow extends StatelessWidget {
  final ExamModel exam;
  const _ConflictRow({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.name, style: exo2(13, color: Colors.white, weight: FontWeight.bold)),
                Text(exam.board, style: exo2(11, color: Colors.white38)),
                const SizedBox(height: 2),
                Text(
                  exam.isConfidential ? 'FETCHED: CONFIDENTIAL' : exam.displayDate,
                  style: orbitron(10, color: exam.isConfidential ? kGold : Colors.white60),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kRed.withAlpha(40),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kRed.withAlpha(120)),
            ),
            child: Text('ANALYZED', style: orbitron(9, color: kRed)),
          ),
        ],
      ),
    );
  }
}

class _ScanRadarPainter extends CustomPainter {
  final double progress;
  _ScanRadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paintCircle = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      paintCircle.color = kCyan.withAlpha(40);
      canvas.drawCircle(center, r * i / 4, paintCircle);
    }
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: pi / 2,
        colors: [kCyan.withAlpha(0), kCyan.withAlpha(150)],
        transform: GradientRotation(progress * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: r))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, sweepPaint);
  }

  @override
  bool shouldRepaint(_ScanRadarPainter old) => old.progress != progress;
}
