import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasConflict;
  final int animationIndex;

  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
    this.onLongPress,
    this.hasConflict = false,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final boardColor = boardColors[exam.board] ?? kCyan;
    final statusColor = hasConflict ? kRed : kGreen;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              boardColor.withAlpha(40),
              Colors.black.withAlpha(120),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: boardColor.withAlpha(80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: boardColor.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Board badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: boardColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: boardColor.withAlpha(120)),
                ),
                child: Center(
                  child: Text(
                    exam.board.substring(0, exam.board.length > 3 ? 3 : exam.board.length),
                    style: orbitron(10, color: boardColor, weight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Exam info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: orbitron(13, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(exam.date)} · ${exam.shift}',
                      style: exo2(12, color: Colors.white60),
                    ),
                    Text(
                      '📍 ${exam.city}',
                      style: exo2(12, color: Colors.white.withAlpha(127)),
                    ),
                  ],
                ),
              ),
              // Status badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withAlpha(120)),
                    ),
                    child: Text(
                      hasConflict ? '⚠ CLASH' : '✓ CLEAR',
                      style: orbitron(9, color: statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animationIndex * 100))
        .slideX(begin: 0.3, duration: 400.ms, curve: Curves.easeOut);
  }
}
