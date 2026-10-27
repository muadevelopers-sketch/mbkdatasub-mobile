import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';
import '../main/main_nav_shell.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF07134B), // Deep navy matching banner
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Bleed Official Welcome Hero Banner
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_banner.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0A1C6A),
                alignment: Alignment.center,
                child: Image.asset('assets/images/logo.png', width: 140),
              ),
            ),
          ),

          // 2. High-Contrast Gradient Scrim Overlay at Bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.48,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF07134B).withOpacity(0.85),
                    const Color(0xFF07134B),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 3. Bottom Action Panel (Create Account & Sign In)
          Positioned(
            left: 24,
            right: 24,
            bottom: 34,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tagline
                Text(
                  'Fast, Reliable & Automated',
                  textAlign: TextAlign.center,
                  style: theme.labelMedium.override(
                    color: const Color(0xFF93C5FD),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your All-In-One VTU Portal',
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Button 1: Create Free Account (Primary)
                FFButtonWidget(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  text: 'Create Free Account',
                  options: FFButtonOptions(
                    height: 54,
                    color: theme.primaryAccent,
                    textStyle: theme.titleSmall.override(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 14),

                // Button 2: Sign In (Secondary Outline)
                FFButtonWidget(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    );
                  },
                  text: 'Sign In to Account',
                  options: FFButtonOptions(
                    height: 52,
                    color: Colors.white.withOpacity(0.12),
                    textStyle: theme.titleSmall.override(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.35),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Guest Mode / Explore Services
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavShell()),
                    );
                  },
                  child: Text(
                    'Explore Services as Guest →',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
