import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/exam_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService().getUser();
    if (mounted) {
      setState(() {
        _name = user['name'] ?? 'Aspirant';
        _email = user['email'] ?? 'exam@guard.in';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamProvider>();
    final initials = _name.isNotEmpty
        ? _name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'EG';

    return Scaffold(
      body: GradientBackground(
        colors: screenGradients['profile']!,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kGold),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('PROFILE', style: orbitron(18, color: kGold)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kGold, kOrange]),
                    boxShadow: [
                      BoxShadow(color: kGold.withAlpha(80), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: Text(initials, style: orbitron(26, color: Colors.black, weight: FontWeight.bold)),
                  ),
                ).animate().scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(_name, style: orbitron(22, color: Colors.white)).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 4),
                Text(_email, style: exo2(14, color: Colors.white54)).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _MiniStatCard(label: 'Exams\nGuarded', value: '${provider.registeredExams.length}', color: kCyan, delay: 0)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStatCard(label: 'Conflicts\nCaught', value: '${provider.conflicts.where((c) => c.isConflict).length}', color: kRed, delay: 100)),
                    const SizedBox(width: 10),
                    Expanded(child: _MiniStatCard(label: 'Exams\nCleared', value: '${provider.clearedCount}', color: kGreen, delay: 200)),
                  ],
                ),
                const SizedBox(height: 24),
                if (provider.registeredBoards.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('MY EXAM BOARDS', style: orbitron(12, color: Colors.white60)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.registeredBoards.map((board) {
                      final color = boardColors[board] ?? kCyan;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color.withAlpha(120)),
                        ),
                        child: Text(board, style: exo2(12, color: color, weight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('SETTINGS', style: orbitron(12, color: Colors.white60)),
                ),
                const SizedBox(height: 10),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  trailing: Switch(
                    value: _notificationsOn,
                    onChanged: (v) => setState(() => _notificationsOn = v),
                    activeColor: kCyan,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  trailing: Switch(value: true, onChanged: (_) {}, activeColor: kCyan),
                ),
                _SettingsTile(
                  icon: Icons.file_download_outlined,
                  label: 'Export Schedule',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Feature coming soon', style: exo2(14)),
                        backgroundColor: kTeal.withAlpha(220),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.logout,
                  label: 'Logout',
                  labelColor: kRed,
                  onTap: () async {
                    await StorageService().clearAll();
                    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                const SizedBox(height: 32),
                Text('EXAM GUARD v1.0 | INVICTUS 1 | HAT-059', style: exo2(11, color: Colors.white24), textAlign: TextAlign.center),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _MiniStatCard({required this.label, required this.value, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: 14,
      borderColor: color.withAlpha(80),
      child: Column(
        children: [
          Text(value, style: orbitron(24, color: color)),
          const SizedBox(height: 6),
          Text(label, style: exo2(10, color: Colors.white54), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay + 400)).slideY(begin: 0.3);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.label, this.labelColor, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          padding: 16,
          child: Row(
            children: [
              Icon(icon, color: labelColor ?? kCyan, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: exo2(15, color: labelColor ?? Colors.white, weight: FontWeight.w500))),
              trailing ?? Icon(Icons.chevron_right, color: labelColor ?? Colors.white38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
