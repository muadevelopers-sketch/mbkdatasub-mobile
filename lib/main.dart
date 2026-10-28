import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'backend/app_state.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'pages/auth/welcome_page.dart';
import 'pages/auth/pin_lock_page.dart';
import 'pages/main/main_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix orientation to portrait for native fintech experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system navigation and status bar style (Dark theme native bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B0F17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final appState = FFAppState();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MbkApp(),
    ),
  );
}

class MbkApp extends StatefulWidget {
  const MbkApp({super.key});

  @override
  State<MbkApp> createState() => _MbkAppState();
}

class _MbkAppState extends State<MbkApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appState = Provider.of<FFAppState>(context, listen: false);
    if (!appState.isAuthenticated) return;

    // Requirement 2: App locks immediately whenever the user leaves the app (minimize, switch apps, screen lock)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      appState.lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<FFAppState>(context);
    final isDark = appState.isDarkMode;

    Widget homePage;
    if (!appState.isInitialized) {
      homePage = const AppSplashBannerScreen();
    } else if (!appState.isAuthenticated) {
      homePage = const WelcomePage();
    } else if (appState.isAppLocked) {
      // Require Biometric or PIN authentication upon returning or starting
      homePage = const PinLockPage();
    } else {
      homePage = const MainNavShell();
    }

    return MaterialApp(
      title: 'MBKDATASUB',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0A1C6A),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0A1C6A),
          secondary: Color(0xFF1E5BF8),
          surface: Colors.white,
          error: Color(0xFFEF4444),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0B0F17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF161B26),
          error: Color(0xFFF87171),
        ),
      ),
      home: homePage,
    );
  }
}

// Requirement 1: Instant App Banner Splash Screen (Eliminating plain white screen)
class AppSplashBannerScreen extends StatefulWidget {
  const AppSplashBannerScreen({super.key});

  @override
  State<AppSplashBannerScreen> createState() => _AppSplashBannerScreenState();
}

class _AppSplashBannerScreenState extends State<AppSplashBannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );

    _startApp();
  }

  void _startApp() async {
    final appState = Provider.of<FFAppState>(context, listen: false);
    await appState.initialize();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dark OLED ambient glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF0B0F17),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                // App Banner with smooth pulse
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withOpacity(0.2),
                          blurRadius: 36,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/welcome_banner.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'MBKDATASUB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Instant Telecom & Digital Services',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 3),
                // Custom branded progress indicator
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                    backgroundColor: Colors.white.withOpacity(0.08),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Starting secure session...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
