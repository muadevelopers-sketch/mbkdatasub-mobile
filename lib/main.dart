import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'backend/app_state.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'pages/auth/welcome_page.dart';
import 'pages/main/main_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix orientation to portrait for native fintech experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final appState = FFAppState();
  await appState.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
      ],
      child: const MbkApp(),
    ),
  );
}

class MbkApp extends StatelessWidget {
  const MbkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<FFAppState>(context);
    final theme = FlutterFlowTheme.of(context);

    return MaterialApp(
      title: 'MBKDATASUB',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
      home: appState.isAuthenticated ? const MainNavShell() : const WelcomePage(),
    );
  }
}
