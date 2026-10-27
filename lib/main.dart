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
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);

    return MaterialApp(
      title: 'MBKDATASUB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: theme.primary,
        scaffoldBackgroundColor: theme.primaryBackground,
        colorScheme: ColorScheme.light(
          primary: theme.primary,
          secondary: theme.primaryAccent,
          surface: theme.secondaryBackground,
          error: theme.error,
        ),
      ),
      home: appState.isAuthenticated ? const MainNavShell() : const WelcomePage(),
    );
  }
}
