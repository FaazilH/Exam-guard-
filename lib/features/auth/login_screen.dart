
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/exam_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    setState(() => _loading = true);
    final provider = context.read<ExamProvider>();
    if (!mounted) return;
    final name = _emailCtrl.text.split('@').first;
    await StorageService().saveUser(name.capitalize(), _emailCtrl.text);
    await provider.initialize();
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: exo2(14, color: Colors.white)),
        backgroundColor: kRed.withAlpha(220),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFF0D1B2A), Color(0xFF001133)],
        showParticles: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield, color: kCyan, size: 32),
                    const SizedBox(width: 10),
                    Text('EXAM GUARD', style: orbitron(20, color: kCyan)),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                const SizedBox(height: 48),
                // Glass card
                GlassCard(
                  padding: 28,
                  borderRadius: 24,
                  child: Column(
                    children: [
                      Text('WELCOME BACK', style: orbitron(22, color: kCyan))
                          .animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to EXAM GUARD',
                        style: exo2(14, color: Colors.white54),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 32),
                      // Email field
                      _GlassTextField(
                        controller: _emailCtrl,
                        hint: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      // Password field
                      _GlassTextField(
                        controller: _passCtrl,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: kCyan,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('FORGOT PASSWORD?',
                              style: exo2(12, color: kCyan)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Login button
                      _loading
                          ? const CircularProgressIndicator(color: kCyan)
                          : AnimatedGlowButton(
                              label: 'LOGIN',
                              onTap: _login,
                              gradientColors: [kCyan, kPurple],
                              icon: Icons.login,
                              width: double.infinity,
                            ),
                      const SizedBox(height: 20),
                      // Divider
                      Row(children: [
                        Expanded(child: Divider(color: Colors.white24)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: exo2(12, color: Colors.white38)),
                        ),
                        Expanded(child: Divider(color: Colors.white24)),
                      ]),
                      const SizedBox(height: 16),
                      // Google button
                      GestureDetector(
                        onTap: _login,
                        child: GlassCard(
                          padding: 14,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Center(
                                  child: Text('G',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Continue with Google',
                                  style: exo2(14, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have account? ", style: exo2(14, color: Colors.white54)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text('REGISTER',
                          style: exo2(14, color: kCyan, weight: FontWeight.bold)),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _selectedState;
  bool _obscure = true;
  bool _loading = false;

  final List<String> _states = const [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan',
    'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh',
    'Uttarakhand', 'West Bengal',
  ];

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields', style: exo2(14)),
          backgroundColor: kRed,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final provider = context.read<ExamProvider>();
    if (!mounted) return;
    await StorageService().saveUser(_nameCtrl.text, _emailCtrl.text);
    await provider.initialize();
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [Color(0xFF0A1628), Color(0xFF001833)],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: kCyan),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('CREATE ACCOUNT', style: orbitron(18, color: kCyan)),
                  ],
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: 28,
                  borderRadius: 24,
                  child: Column(
                    children: [
                      _GlassTextField(
                          controller: _nameCtrl, hint: 'Full Name', icon: Icons.person_outline),
                      const SizedBox(height: 16),
                      _GlassTextField(
                          controller: _emailCtrl,
                          hint: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _GlassTextField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _obscure),
                      const SizedBox(height: 16),
                      _GlassTextField(
                          controller: _confirmCtrl,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscure: _obscure),
                      const SizedBox(height: 16),
                      // State dropdown
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withAlpha(13),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1A1A2E),
                            hint: Text('Select State',
                                style: exo2(14, color: Colors.white38)),
                            style: exo2(14, color: Colors.white),
                            items: _states
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedState = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? const CircularProgressIndicator(color: kCyan)
                          : AnimatedGlowButton(
                              label: 'CREATE ACCOUNT',
                              onTap: _register,
                              gradientColors: [kGreen, kTeal],
                              icon: Icons.rocket_launch,
                              width: double.infinity,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: exo2(14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: exo2(14, color: Colors.white38),
        prefixIcon: Icon(icon, color: kCyan, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kCyan, width: 1.5),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
