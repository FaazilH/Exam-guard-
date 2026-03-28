import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/gradient_background.dart';

class ExamDetailScreen extends StatefulWidget {
  const ExamDetailScreen({super.key});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  ExamModel? _fetchedSlot;
  bool _isFetching = false;
  final _regNumCtrl = TextEditingController();
  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _regNumCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchFromPortal(String examId) async {
    if (_regNumCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your Registration Number')),
      );
      return;
    }

    setState(() => _isFetching = true);
    final res = await context.read<ExamProvider>().fetchAndRegister(
          _regNumCtrl.text,
          examId,
        );
    setState(() => _isFetching = false);

    if (res['success'] == true) {
      setState(() {
        _fetchedSlot = ExamModel.fromJson(res);
      });
      
      final bool hasConflict = res['has_conflict'] ?? false;
      final bool isCritical = res['critical_conflict'] ?? false;

      if (!hasConflict) {
        _confettiCtrl.play();
        _showSuccessSheet(context, _fetchedSlot!, false);
      } else {
        _showSuccessSheet(context, _fetchedSlot!, true, isCritical: isCritical);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Fetch failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = ModalRoute.of(context)!.settings.arguments as ExamModel;
    final boardColor = boardColors[exam.board] ?? kCyan;

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['exam']!,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: kCyan),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(exam.name,
                              style: orbitron(16, color: Colors.white),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header card
                          GlassCard(
                            borderColor: boardColor.withAlpha(80),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: boardColor.withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: boardColor.withAlpha(120)),
                                  ),
                                  child: Text(exam.board,
                                      style: orbitron(12, color: boardColor)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(exam.name,
                                      style: exo2(15, color: Colors.white, weight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 40),
                          
                          // Portal Integration Section
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.account_balance_outlined, color: boardColor, size: 48),
                                const SizedBox(height: 16),
                                Text('PORTAL INTEGRATION', style: orbitron(14, color: Colors.white70)),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your registration ID to fetch official dates from the ${exam.board} portal.',
                                  style: exo2(13, color: Colors.white38),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          
                          const SizedBox(height: 32),
                          
                          TextField(
                            controller: _regNumCtrl,
                            style: orbitron(16, color: kCyan, weight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'e.g. REG101 or TN999',
                              hintStyle: orbitron(14, color: Colors.white10),
                              filled: true,
                              fillColor: Colors.white.withAlpha(5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: boardColor.withAlpha(40)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: boardColor.withAlpha(40)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: boardColor, width: 2),
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms).scale(),
                          
                          const SizedBox(height: 32),
                          
                          _isFetching 
                            ? const Center(child: CircularProgressIndicator(color: kCyan))
                            : AnimatedGlowButton(
                                label: 'FETCH FROM PORTAL',
                                onTap: () => _fetchFromPortal(exam.id),
                                gradientColors: [boardColor, boardColor.withAlpha(150)],
                                icon: Icons.cloud_download_outlined,
                                width: double.infinity,
                                height: 60,
                              ),
                          
                          const SizedBox(height: 40),
                          
                          // Note for User
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kGold.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kGold.withAlpha(40)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: kGold, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Exams are only added to Guard after successful portal verification.',
                                    style: exo2(12, color: kGold.withAlpha(200)),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiCtrl,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 40,
                colors: [kCyan, kPurple, kGold, kGreen],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSheet(BuildContext context, ExamModel slot, bool hasConflict, {bool isCritical = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasConflict)
              Icon(isCritical ? Icons.report_problem : Icons.warning_amber_rounded,
                      color: isCritical ? kRed : kOrange, size: 72)
                  .animate()
                  .shake(duration: 800.ms)
            else
              Icon(Icons.check_circle, color: kGreen, size: 72)
                  .animate()
                  .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              hasConflict 
                ? (isCritical ? 'CRITICAL CLASH DETECTED!' : 'CONFLICT DETECTED!') 
                : 'Registration Verified! 🎉',
              style: orbitron(20, color: hasConflict ? (isCritical ? kRed : kOrange) : kGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(slot.name, style: exo2(16, color: Colors.white, weight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '${DateFormat('dd MMM yyyy').format(slot.date)} | ${slot.shift}',
                style: orbitron(12, color: kCyan),
              ),
            ),
            const SizedBox(height: 16),
            if (hasConflict)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isCritical ? kRed : kOrange).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (isCritical ? kRed : kOrange).withAlpha(60)),
                ),
                child: Text(
                  isCritical 
                    ? 'DANGER: This exam falls exactly on the same day as another registration! Immediate action required.'
                    : 'WARNING: This exam is very close to another registration. Proceed with caution.',
                  style: exo2(13, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            AnimatedGlowButton(
              label: hasConflict ? 'RESOLVE CONFLICT NOW' : 'SCAN ALL CONFLICTS',
              onTap: () {
                Navigator.pop(context);
                final provider = context.read<ExamProvider>();
                if (provider.registeredExams.length >= 2) {
                  final exams = provider.registeredExams;
                  Navigator.pushNamed(
                    context,
                    '/conflict-detection',
                    arguments: {
                      'exam1': exams[exams.length - 1],
                      'exam2': exams[exams.length - 2],
                    },
                  );
                } else {
                  Navigator.pushNamed(context, '/conflict-prompt', arguments: slot);
                }
              },
              gradientColors: hasConflict ? [kRed, kOrange] : [kCyan, kPurple],
              icon: Icons.radar,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: Text('DISMISS', style: exo2(14, color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
