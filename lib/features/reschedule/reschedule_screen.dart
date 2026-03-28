import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/gradient_background.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _neuralCtrl;
  late Future<List<SlotSuggestion>> _suggestionsFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _neuralCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final exam = args['exam'] as ExamModel;
      final conflict = args['conflict'] as ConflictResult;
      setState(() {
        _suggestionsFuture = _api.suggestSlots(
          exam.name,
          conflict.daysDiff == 0 ? exam.rawDate : conflict.exam1.rawDate,
          exam.city,
        );
      });
    });
    _suggestionsFuture = Future.value([]);
  }

  @override
  void dispose() {
    _neuralCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final exam = args['exam'] as ExamModel;

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['reschedule']!,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kViolet),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('AI RESCHEDULING', style: orbitron(18, color: kViolet)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text('Finding best alternative dates for ', style: exo2(14, color: Colors.white60)),
                    Flexible(
                      child: Text(exam.name, style: exo2(14, color: kGold, weight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<SlotSuggestion>>(
                  future: _suggestionsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return _buildLoading();
                    if (snap.hasError || !snap.hasData || snap.data!.isEmpty) return _buildEmpty();
                    return _buildResults(context, snap.data!, exam);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _neuralCtrl,
          builder: (_, __) => CustomPaint(
            painter: _NeuralNetPainter(_neuralCtrl.value),
            size: const Size(220, 180),
          ),
        ),
        const SizedBox(height: 24),
        Text('AI Scanning Exam Slots', style: orbitron(14, color: kViolet))
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2.seconds, color: kViolet),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text('No alternative slots found', style: exo2(16, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<SlotSuggestion> suggestions, ExamModel exam) {
    final rankLabels = ['RANK 1', 'RANK 2', 'RANK 3'];
    final labels = ['BEST MATCH', 'GOOD MATCH', 'ACCEPTABLE'];
    final borderColors = [kGold, Colors.grey.shade400, const Color(0xFFCD7F32)];
    final btnColors = [
      [kGold, kOrange],
      [Colors.grey.shade400, Colors.grey.shade600],
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: suggestions.length,
      itemBuilder: (_, i) {
        if (i >= suggestions.length) return const SizedBox.shrink();
        final s = suggestions[i];
        return _SuggestionCard(
          suggestion: s,
          rank: rankLabels[i],
          label: labels[i],
          borderColor: borderColors[i],
          btnColors: btnColors[i].cast<Color>(),
          animationDelay: i * 300,
          onSelect: () => _showConfirmSheet(context, s, exam),
        );
      },
    );
  }

  void _showConfirmSheet(BuildContext context, SlotSuggestion suggestion, ExamModel exam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFF1A0A3E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm New Date', style: orbitron(18, color: kViolet)),
            const SizedBox(height: 16),
            GlassCard(
              borderColor: kViolet.withAlpha(80),
              child: Column(
                children: [
                  Text(exam.name, style: orbitron(14, color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, color: kViolet, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM yyyy').format(suggestion.date),
                        style: exo2(16, color: kGold, weight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${suggestion.shift} · ${suggestion.city}', style: exo2(13, color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedGlowButton(
              label: 'CONFIRM & UPDATE',
              onTap: () async {
                final newSlot = ExamModel(
                  id: '${exam.id}_rescheduled',
                  name: exam.name,
                  board: exam.board,
                  displayDate: DateFormat('dd MMM yyyy').format(suggestion.date),
                  rawDate: suggestion.date,
                  shift: suggestion.shift,
                  availableSlots: suggestion.availableSlots,
                  city: suggestion.city,
                  isRegistered: true,
                  regNumber: exam.regNumber,
                  isConfidential: false,
                );
                await context.read<ExamProvider>().updateExamDate(exam, newSlot);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Exam rescheduled successfully', style: exo2(14)),
                      backgroundColor: kGreen.withAlpha(220),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              gradientColors: [kViolet, kPurple],
              icon: Icons.check_circle_outline,
              width: double.infinity,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: exo2(14, color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final SlotSuggestion suggestion;
  final String rank;
  final String label;
  final Color borderColor;
  final List<Color> btnColors;
  final int animationDelay;
  final VoidCallback onSelect;

  const _SuggestionCard({
    required this.suggestion,
    required this.rank,
    required this.label,
    required this.borderColor,
    required this.btnColors,
    required this.animationDelay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 20,
      borderColor: borderColor.withAlpha(150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rank, style: orbitron(12, color: borderColor, weight: FontWeight.w900)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor.withAlpha(150)),
                ),
                child: Text(label, style: orbitron(10, color: borderColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(DateFormat('dd MMMM yyyy').format(suggestion.date), style: orbitron(20, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${suggestion.shift} · ${suggestion.city}', style: exo2(13, color: Colors.white60)),
          const SizedBox(height: 4),
          Text('${(suggestion.availableSlots / 1000).toStringAsFixed(0)}K slots available', style: exo2(13, color: Colors.white54)),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: (suggestion.confidence / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.white12,
            progressColor: borderColor,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            trailing: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text('${suggestion.confidence.toStringAsFixed(1)}%', style: exo2(12, color: borderColor)),
            ),
          ),
          const SizedBox(height: 8),
          Text(suggestion.reason, style: exo2(12, color: Colors.white54)),
          const SizedBox(height: 16),
          AnimatedGlowButton(
            label: 'SELECT THIS DATE',
            onTap: onSelect,
            gradientColors: btnColors,
            icon: Icons.check,
            width: double.infinity,
            height: 44,
            fontSize: 13,
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: animationDelay)).slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _NeuralNetPainter extends CustomPainter {
  final double progress;
  _NeuralNetPainter(this.progress);

  static const List<List<int>> layers = [[0, 1, 2], [3, 4, 5, 6], [7, 8, 9]];

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = <Offset>[];
    for (int li = 0; li < layers.length; li++) {
      final layer = layers[li];
      for (int ni = 0; ni < layer.length; ni++) {
        final x = (li + 1) / (layers.length + 1) * size.width;
        final y = (ni + 1) / (layer.length + 1) * size.height;
        nodes.add(Offset(x, y));
      }
    }
    int nodeIdx = 0;
    for (int li = 0; li < layers.length - 1; li++) {
      final layerA = layers[li];
      final layerB = layers[li + 1];
      int startA = nodeIdx;
      int startB = nodeIdx + layerA.length;
      for (int ai = 0; ai < layerA.length; ai++) {
        for (int bi = 0; bi < layerB.length; bi++) {
          final pulse = ((progress * 3 + ai * 0.2 + bi * 0.1) % 1.0);
          final edgePaint = Paint()..color = kViolet.withAlpha((pulse * 180).toInt())..strokeWidth = 1;
          canvas.drawLine(nodes[startA + ai], nodes[startB + bi], edgePaint);
        }
      }
      nodeIdx += layerA.length;
    }
    for (final node in nodes) {
      final pulse = (sin(progress * 2 * pi + nodes.indexOf(node) * 0.5) + 1) / 2;
      canvas.drawCircle(node, 5, Paint()..color = kViolet.withAlpha((80 + pulse * 175).toInt())..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    }
  }

  @override
  bool shouldRepaint(_NeuralNetPainter old) => old.progress != progress;
}
