import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../widgets/animated_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<_OnboardSlide> _slides = const [
    _OnboardSlide(
      title: 'Register Multiple Exams',
      subtitle: 'Add all your govt exams in one place — UPSC, SSC, RRB, IBPS, TNPSC, SBI',
      icon: Icons.calendar_month,
      colors: [Color(0xFF0D0221), Color(0xFF2A1060)],
      accentColor: Color(0xFF6C3AFF),
    ),
    _OnboardSlide(
      title: 'AI Detects Conflicts',
      subtitle: 'Our ML model scans for date clashes instantly and alerts you in real time',
      icon: Icons.psychology,
      colors: [Color(0xFF003B46), Color(0xFF007A6E)],
      accentColor: Color(0xFF00C9A7),
    ),
    _OnboardSlide(
      title: 'Smart Rescheduling',
      subtitle: 'Get AI-ranked alternative slots instantly — never miss an exam again',
      icon: Icons.auto_fix_high,
      colors: [Color(0xFF1A0A00), Color(0xFF4A2000)],
      accentColor: Color(0xFFFF6B35),
    ),
  ];

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index], index);
            },
          ),
          // Skip button
          Positioned(
            top: 48,
            right: 20,
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text('SKIP', style: exo2(14, color: Colors.white54)),
            ),
          ),
          // Dots + button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(_OnboardSlide slide, int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.colors,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slide.accentColor.withAlpha(30),
                  border: Border.all(color: slide.accentColor.withAlpha(100), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: slide.accentColor.withAlpha(80),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(slide.icon, size: 64, color: slide.accentColor),
              )
                  .animate(target: isActive ? 1 : 0)
                  .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 48),
              // Title
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: orbitron(28, color: Colors.white),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: exo2(16, color: Colors.white60),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? kCyan : Colors.white30,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Button
          AnimatedGlowButton(
            label: _currentPage == _slides.length - 1 ? 'GET STARTED' : 'NEXT',
            onTap: _next,
            gradientColors: _currentPage == _slides.length - 1
                ? [kGreen, kTeal]
                : [kCyan, kPurple],
            icon: _currentPage == _slides.length - 1
                ? Icons.rocket_launch
                : Icons.arrow_forward,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Color accentColor;

  const _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.accentColor,
  });
}
