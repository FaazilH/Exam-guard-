import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';

import '../../providers/exam_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class ExamSelectionScreen extends StatefulWidget {
  const ExamSelectionScreen({super.key});

  @override
  State<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends State<ExamSelectionScreen> {
  String _query = '';
  String _selectedBoard = 'ALL';
  String? _expandedBoard;

  final List<String> _boards = ['ALL', ...examBoards];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().loadAllExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();

    // PRE-FILTERED LIST to avoid O(N^2)
    final filteredExams = provider.allExams.where((e) {
      final matchesBoard = _selectedBoard == 'ALL' || e.board == _selectedBoard;
      final matchesQuery = e.name.toLowerCase().contains(_query.toLowerCase());
      return matchesBoard && matchesQuery;
    }).toList();

    // Grouping logic O(N)
    final Map<String, List<String>> byBoard = {};
    for (final e in filteredExams) {
      byBoard.putIfAbsent(e.board, () => []);
      if (!byBoard[e.board]!.contains(e.name)) {
        byBoard[e.board]!.add(e.name);
      }
    }
    
    // Sort names within boards
    for (final board in byBoard.keys) {
      byBoard[board]!.sort();
    }

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['exam']!,
        child: SafeArea(
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
                    Text('SELECT EXAM', style: orbitron(18, color: kCyan)),
                  ],
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: exo2(14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search exams...',
                    hintStyle: exo2(14, color: Colors.white38),
                    prefixIcon: Icon(Icons.search, color: kCyan),
                    filled: true,
                    fillColor: Colors.white.withAlpha(13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: kCyan.withAlpha(80)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: kCyan, width: 1.5),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 12),
              // Board filter chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _boards.length,
                  itemBuilder: (_, i) {
                    final board = _boards[i];
                    final isActive = _selectedBoard == board;
                    final color = boardColors[board] ?? kCyan;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedBoard = board),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? color.withAlpha(200) : Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isActive ? color : Colors.white24),
                          boxShadow: isActive
                              ? [BoxShadow(color: color.withAlpha(80), blurRadius: 8)]
                              : [],
                        ),
                        child: Text(
                          board,
                          style: exo2(12,
                              color: isActive ? Colors.black : Colors.white70,
                              weight: isActive ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Exam list by board
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: kCyan))
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: byBoard.entries.map((entry) {
                          final board = entry.key;
                          final exams = entry.value;
                          final boardColor = boardColors[board] ?? kCyan;
                          final isExpanded = _expandedBoard == board;

                          return Column(
                            children: [
                              // Board header
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _expandedBoard = isExpanded ? null : board),
                                child: GlassCard(
                                  padding: 16,
                                  borderColor: boardColor.withAlpha(80),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: boardColor.withAlpha(40),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            board,
                                            style: orbitron(10, color: boardColor),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(board,
                                                style: orbitron(14, color: boardColor)),
                                            Text('${exams.length} exams',
                                                style: exo2(12, color: Colors.white54)),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: boardColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded exam list
                              if (isExpanded)
                                ...exams.asMap().entries.map((e) {
                                  final idx = e.key;
                                  final examName = e.value;
                                  final slots = provider.getSlotsForExam(examName);

                                  return GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/exam-detail',
                                      arguments: slots.first,
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(16, 4, 0, 4),
                                      child: GlassCard(
                                        padding: 14,
                                        borderColor: boardColor.withAlpha(40),
                                        child: Row(
                                          children: [
                                            Icon(Icons.chevron_right, color: boardColor, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(examName,
                                                  style: exo2(14, color: Colors.white)),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: boardColor.withAlpha(30),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text('${slots.length} slots',
                                                  style: exo2(11, color: boardColor)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: Duration(milliseconds: idx * 60))
                                      .slideX(begin: 0.2);
                                }),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
