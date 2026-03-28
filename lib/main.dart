import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/exam_provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart' show LoginScreen, RegisterScreen;
import 'features/dashboard/dashboard_screen.dart';
import 'features/exam/exam_selection_screen.dart';
import 'features/exam/exam_detail_screen.dart';
import 'features/exam/conflict_check_prompt_screen.dart';
import 'features/conflict/conflict_detection_screen.dart';
import 'features/reschedule/reschedule_screen.dart';
import 'features/conflicts/conflicts_list_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExamGuardApp());
}

class ExamGuardApp extends StatelessWidget {
  const ExamGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExamProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'EXAM GUARD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: '/splash',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _route(const SplashScreen(), settings);
      case '/onboarding':
        return _route(const OnboardingScreen(), settings);
      case '/login':
        return _route(const LoginScreen(), settings);
      case '/register':
        return _route(const RegisterScreen(), settings);
      case '/dashboard':
        return _route(const DashboardScreen(), settings);
      case '/exam-selection':
        return _route(const ExamSelectionScreen(), settings);
      case '/exam-detail':
        return _route(const ExamDetailScreen(), settings);
      case '/conflict-prompt':
        return _route(const ConflictCheckPromptScreen(), settings);
      case '/conflict-detection':
        return _route(const ConflictDetectionScreen(), settings);
      case '/reschedule':
        return _route(const RescheduleScreen(), settings);
      case '/conflicts':
        return _route(const ConflictsListScreen(), settings);
      case '/profile':
        return _route(const ProfileScreen(), settings);
      default:
        return _route(const SplashScreen(), settings);
    }
  }

  PageRouteBuilder<dynamic> _route(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
