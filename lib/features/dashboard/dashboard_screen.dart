import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/exam_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/gradient_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService().getUser();
    if (mounted) setState(() => _userName = user['name'] ?? 'Aspirant');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(userName: _userName),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
      const SizedBox.shrink(),
    ];

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['dashboard']!,
        child: tabs[_currentTab],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(180),
        border: Border(top: BorderSide(color: kCyan.withAlpha(40), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) {
          if (i == 0) {
            setState(() => _currentTab = i);
          } else if (i == 1) {
            Navigator.pushNamed(context, '/exam-selection');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/conflicts');
          } else if (i == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: kCyan,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: exo2(10, color: kCyan, weight: FontWeight.bold),
        unselectedLabelStyle: exo2(10, color: Colors.white38),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Add Exam'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_outlined), activeIcon: Icon(Icons.warning_amber), label: 'Conflicts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String userName;
  const _HomeTab({required this.userName});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.shield, color: kCyan, size: 28),
                const SizedBox(width: 8),
                Text('EXAM GUARD', style: orbitron(16, color: kCyan)),
                const Spacer(),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: Colors.white70),
                      onPressed: () => Navigator.pushNamed(context, '/conflicts'),
                    ),
                    if (provider.conflictCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(color: kRed, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${provider.conflictCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$greeting, $userName',
                style: exo2(20, color: Colors.white, weight: FontWeight.w600),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _StatCard('REGISTERED', '${provider.registeredExams.length}', Icons.list_alt, kCyan, 0)),
                const SizedBox(width: 8),
                Expanded(child: _StatCard('CONFLICTS', '${provider.conflictCount}', Icons.warning_amber, kRed, 1)),
                const SizedBox(width: 8),
                Expanded(child: _StatCard('NEXT EXAM', '${provider.daysUntilNextExam}d', Icons.access_time, kGold, 2)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('MY EXAMS', style: orbitron(14, color: Colors.white70)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/exam-selection'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kCyan.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kCyan.withAlpha(80)),
                    ),
                    child: Text('+ ADD', style: orbitron(11, color: kCyan)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: kCyan))
                : provider.registeredExams.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.registeredExams.length,
                        itemBuilder: (_, i) {
                          final exam = provider.registeredExams[i];
                          final hasConflict = provider.conflicts.any(
                            (c) => c.isConflict && !c.isResolved &&
                                (c.exam1.id == exam.id || c.exam2.id == exam.id),
                          );
                          return ExamCard(
                            exam: exam,
                            hasConflict: hasConflict,
                            animationIndex: i,
                            onTap: () => Navigator.pushNamed(context, '/exam-detail', arguments: exam),
                            onLongPress: () => _showDeleteDialog(context, provider, exam),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text('No exams added yet', style: exo2(16, color: Colors.white38)),
          const SizedBox(height: 24),
          AnimatedGlowButton(
            label: 'ADD EXAM',
            onTap: () => Navigator.pushNamed(context, '/exam-selection'),
            gradientColors: [kCyan, kPurple],
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExamProvider provider, ExamModel exam) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Exam', style: orbitron(16, color: kRed)),
        content: Text('Remove ${exam.name} from your list?', style: exo2(14, color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: exo2(14, color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              provider.removeExam(exam.id);
              Navigator.pop(context);
            },
            child: Text('REMOVE', style: exo2(14, color: kRed, weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard(this.label, this.value, this.icon, this.color, this.delay);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 12,
      borderColor: color.withAlpha(80),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: orbitron(20, color: color)),
          const SizedBox(height: 4),
          Text(label, style: exo2(10, color: Colors.white54), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay * 150 + 300)).slideY(begin: 0.3);
  }
}
