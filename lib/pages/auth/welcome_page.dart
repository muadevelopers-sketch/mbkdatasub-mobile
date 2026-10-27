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

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.primaryAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MBKDATASUB',
                      style: theme.labelMedium.override(
                        color: theme.primaryAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Central Logo / 3D Graphics
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A1E5BF8),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.cell_tower_rounded,
                      size: 80,
                      color: theme.primaryAccent,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Headline & Subtitle
              Text(
                'Simplify bill payments with ease!',
                style: theme.displayMedium.override(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: theme.primary,
                  lineHeight: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Purchase data, airtime, and pay utility bills — all from the comfort of your home.',
                style: theme.bodyLarge.override(
                  color: theme.secondaryText,
                  fontSize: 15,
                  lineHeight: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Feature Badges
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFeatureChip('⚡ Instant Top-up', theme),
                  _buildFeatureChip('🔒 Secure Payments', theme),
                  _buildFeatureChip('💡 Utility Bills', theme),
                ],
              ),

              const Spacer(flex: 2),

              // Continue as Guest Button
              FFButtonWidget(
                text: 'Continue as a Guest',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavShell()),
                  );
                },
                options: FFButtonOptions(
                  height: 52,
                  color: Colors.white,
                  textStyle: theme.titleMedium.override(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 14),

              // Sign In & Sign Up Row
              Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      text: 'Sign In  →',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignInPage()),
                        );
                      },
                      options: FFButtonOptions(
                        height: 52,
                        color: theme.primary,
                        textStyle: theme.titleMedium.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FFButtonWidget(
                      text: 'Sign Up +👤',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      options: FFButtonOptions(
                        height: 52,
                        color: theme.primaryAccent,
                        textStyle: theme.titleMedium.override(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.labelMedium.override(
          color: theme.primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
