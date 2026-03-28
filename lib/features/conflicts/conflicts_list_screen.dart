import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class ConflictsListScreen extends StatefulWidget {
  const ConflictsListScreen({super.key});

  @override
  State<ConflictsListScreen> createState() => _ConflictsListScreenState();
}

class _ConflictsListScreenState extends State<ConflictsListScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final allConflicts = provider.conflicts;

    final filtered = _filter == 'ALL'
        ? allConflicts
        : _filter == 'RESOLVED'
            ? allConflicts.where((c) => c.isResolved).toList()
            : allConflicts.where((c) => !c.isResolved && c.isConflict).toList();

    // Severity counts for pie chart
    final Map<String, int> sevCounts = {
      'CRITICAL': 0, 'HIGH': 0, 'MEDIUM': 0, 'LOW': 0
    };
    for (final c in allConflicts.where((c) => c.isConflict)) {
      if (sevCounts.containsKey(c.severity)) {
        sevCounts[c.severity] = sevCounts[c.severity]! + 1;
      }
    }

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['conflicts_list']!,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kCyan),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('CONFLICT HISTORY', style: orbitron(18, color: kCyan)),
                  ],
                ),
              ),
              // Filter chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['ALL', 'PENDING', 'RESOLVED'].map((f) {
                    final isActive = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? kCyan.withAlpha(200) : Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isActive ? kCyan : Colors.white24),
                        ),
                        child: Text(
                          f,
                          style: exo2(12,
                              color: isActive ? Colors.black : Colors.white70,
                              weight: isActive ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              // List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length +
                            (sevCounts.values.any((v) => v > 0) ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == filtered.length) {
                            return _buildPieChart(sevCounts);
                          }
                          return _ConflictHistoryCard(
                            conflict: filtered[i],
                            animIndex: i,
                            onResolve: () {
                              provider.resolveConflict(filtered[i]);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, color: kGreen, size: 80)
              .animate()
              .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('No conflicts detected yet.',
              style: orbitron(16, color: Colors.white60)),
          const SizedBox(height: 8),
          Text("You're safe! 🛡",
              style: exo2(14, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> counts) {
    final sections = counts.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              title: '${e.key}\n${e.value}',
              color: severityColors[e.key] ?? kCyan,
              radius: 60,
              titleStyle: exo2(9, color: Colors.white, weight: FontWeight.bold),
            ))
        .toList();

    if (sections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Column(
          children: [
            Text('CONFLICT SEVERITY BREAKDOWN',
                style: orbitron(12, color: Colors.white70)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(PieChartData(sections: sections)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictHistoryCard extends StatelessWidget {
  final ConflictResult conflict;
  final int animIndex;
  final VoidCallback onResolve;

  const _ConflictHistoryCard({
    required this.conflict,
    required this.animIndex,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final sevColor = severityColors[conflict.severity] ?? kRed;
    final isResolved = conflict.isResolved;

    return GlassCard(
      padding: 16,
      borderColor: isResolved ? kGreen.withAlpha(60) : sevColor.withAlpha(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conflict.exam1.name,
                        style: exo2(13, color: Colors.white, weight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      DateFormat('dd MMM yyyy').format(conflict.exam1.date),
                      style: exo2(11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.compare_arrows, color: Colors.white38, size: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(conflict.exam2.name,
                        style: exo2(13, color: Colors.white, weight: FontWeight.bold),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      DateFormat('dd MMM yyyy').format(conflict.exam2.date),
                      style: exo2(11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sevColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sevColor.withAlpha(150)),
                ),
                child: Text(conflict.severity, style: orbitron(10, color: sevColor)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isResolved ? kGreen.withAlpha(40) : kRed.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: isResolved ? kGreen.withAlpha(120) : kRed.withAlpha(80)),
                ),
                child: Text(
                  isResolved ? 'RESOLVED ✓' : 'PENDING ⚠',
                  style: orbitron(9, color: isResolved ? kGreen : kRed),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM').format(conflict.detectedAt),
                style: exo2(11, color: Colors.white38),
              ),
              if (!isResolved) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onResolve,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kGreen.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: kGreen.withAlpha(80)),
                    ),
                    child: Text('RESOLVE', style: orbitron(9, color: kGreen)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animIndex * 100))
        .slideY(begin: 0.2, duration: 400.ms);
  }
}
