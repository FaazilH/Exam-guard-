import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBgDark = Color(0xFF0A0A0F);
const Color kCyan = Color(0xFF00F5FF);
const Color kPurple = Color(0xFF6C3AFF);
const Color kGold = Color(0xFFFFD700);
const Color kGreen = Color(0xFF00FF88);
const Color kRed = Color(0xFFFF3333);
const Color kOrange = Color(0xFFFF6B35);
const Color kTeal = Color(0xFF00C9A7);
const Color kNavy = Color(0xFF0D1B2A);
const Color kViolet = Color(0xFF9B5DE5);

final Map<String, List<Color>> screenGradients = {
  'splash': [const Color(0xFF0A0A0F), const Color(0xFF001F3F)],
  'onboard': [const Color(0xFF0D0221), const Color(0xFF1A0A3E)],
  'auth': [const Color(0xFF0D1B2A), const Color(0xFF001133)],
  'dashboard': [const Color(0xFF0F0F23), const Color(0xFF1A1A3E)],
  'exam': [const Color(0xFF003B46), const Color(0xFF001820)],
  'conflict': [const Color(0xFF1A0505), const Color(0xFF0A0000)],
  'reschedule': [const Color(0xFF120820), const Color(0xFF0A0515)],
  'profile': [const Color(0xFF1C1C1C), const Color(0xFF0A0A0A)],
  'conflicts_list': [const Color(0xFF1A1A2E), const Color(0xFF0F0F1E)],
};

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBgDark,
      colorScheme: const ColorScheme.dark(
        primary: kCyan,
        secondary: kPurple,
        surface: Color(0xFF1A1A2E),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(color: kCyan, fontSize: 36, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.exo2(color: Colors.white, fontSize: 16),
        bodyMedium: GoogleFonts.exo2(color: Colors.white70, fontSize: 14),
        bodySmall: GoogleFonts.exo2(color: Colors.white54, fontSize: 12),
        labelLarge: GoogleFonts.exo2(color: kCyan, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(color: kCyan, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: kCyan),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: kCyan,
        unselectedItemColor: Colors.white38,
      ),
    );
  }
}

TextStyle orbitron(double size, {Color color = Colors.white, FontWeight weight = FontWeight.bold, double spacing = 0}) {
  return GoogleFonts.orbitron(fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing);
}

TextStyle exo2(double size, {Color color = Colors.white70, FontWeight weight = FontWeight.normal, double spacing = 0}) {
  return GoogleFonts.exo2(fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing);
}
