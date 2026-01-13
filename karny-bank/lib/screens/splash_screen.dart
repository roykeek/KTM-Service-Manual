// lib/screens/splash_screen.dart
// App initialization and splash screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../services/database_service.dart';
import '../services/database_models.dart';
import 'dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize database
      await DatabaseService.initDatabase();

      // Create sample accounts if needed
      final accounts = await DatabaseService.getAllAccounts();
      if (accounts.isEmpty) {
        await DatabaseService.createAccount(
          name: 'Maayan',
          dateOfBirth: DateTime(2011, 8, 16),
        );

        await DatabaseService.createAccount(
          name: 'Tomer',
          dateOfBirth: DateTime(2014, 4, 28),
        );

        await DatabaseService.createAccount(
          name: 'Or',
          dateOfBirth: DateTime(2016, 1, 21),
        );
      }

      // Run automation checks
      await ref.read(automationProvider.future);

      // Delay for visual feedback
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF4DB6AC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    '🏦',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                'Karny Bank',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Teaching Kids About Money',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Named route configuration
const splashRoute = '/';
const dashboardRoute = '/dashboard';
const historyRoute = '/history';
const settingsRoute = '/settings';

Map<String, WidgetBuilder> routes(BuildContext context) {
  return {
    '/splash': (context) => const SplashScreen(),
    '/dashboard': (context) => const DashboardScreen(),
  };
}
