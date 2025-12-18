import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'services/storage_service.dart';
import 'configs/network_config.dart';
import 'core/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/notes_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/notes/notes_list_screen.dart';
import 'screens/recording/recording_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/statistics/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage services
  await StorageService.init();

  // Initialize network configuration
  NetworkConfig.dio; // This initializes the Dio instance

  // Initialize service locator
  await ServiceLocator.init();

  runApp(const TalkNotesApp());
}

class TalkNotesApp extends StatelessWidget {
  const TalkNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<RecordingProvider>(
          create: (_) => getIt<RecordingProvider>(),
        ),
        ChangeNotifierProvider<NotesProvider>(
          create: (_) => getIt<NotesProvider>(),
        ),
        // Add more providers here as needed
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/notes': (context) => const NotesListScreen(),
          '/recording': (context) => const RecordingScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/search': (context) => const SearchScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpScreen(),
          '/statistics': (context) => const StatisticsScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.slowAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNext();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    final isLoggedIn = await StorageService.isLoggedIn();

    // Force mark onboarding as completed for testing
    await StorageService.setOnboardingCompleted(true);
    final isOnboardingCompleted = StorageService.isOnboardingCompleted();

    debugPrint(
      '🚦 Navigation Logic: isLoggedIn=$isLoggedIn, isOnboardingCompleted=$isOnboardingCompleted',
    );

    if (!mounted) return;

    if (isLoggedIn) {
      // User is logged in - go directly to home screen
      debugPrint('🏠 Navigating to HomeScreen (user is logged in)');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      // User not logged in - go to login screen (skip onboarding for now)
      debugPrint('� Navigating to LoginScreen (user not logged in)');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.mic,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // App Name
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // App Description
                      const Text(
                        AppConstants.appDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Loading Indicator
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
