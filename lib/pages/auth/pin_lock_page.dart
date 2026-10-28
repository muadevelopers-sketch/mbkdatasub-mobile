import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/custom_pin_pad_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../main/main_nav_shell.dart';
import 'sign_in_page.dart';

class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String _errorMessage = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) return;
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Unlock MBKDATASUB securely',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth && mounted) {
        final appState = Provider.of<FFAppState>(context, listen: false);
        appState.unlockApp();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Biometric authentication cancelled. Enter your 4-digit PIN below.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Biometric failed or cancelled. Enter your 4-digit PIN below.';
        });
      }
    }
  }

  void _onPinEntered(String pin) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    final res = await MbkApi.verifyTransactionPin(pin);
    if (mounted) {
      setState(() => _isVerifying = false);
      if (res.success) {
        final appState = Provider.of<FFAppState>(context, listen: false);
        await appState.saveTransactionPin(pin);
        appState.unlockApp();
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN. Please try again.';
        });
      }
    }
  }

  void _onLogout() async {
    final appState = Provider.of<FFAppState>(context, listen: false);
    await appState.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
    final appState = Provider.of<FFAppState>(context);
    final userName = appState.user?.fullName ?? 'User';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Top Padlock Icon in Light Blue Circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 34,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'MBKDATASUB Locked',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Welcome back, $userName',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // Error / Biometric status message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // Tap to Retry Biometric Button
              InkWell(
                onTap: _tryBiometric,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to Retry Biometric / Fingerprint',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // PIN Keypad with 4 Dots
              if (_isVerifying)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                )
              else
                CustomPinPadWidget(
                  showBiometrics: true,
                  onPinCompleted: _onPinEntered,
                  onBiometricAuthenticated: _tryBiometric,
                ),

              const Spacer(),

              // Logout / Switch Account Link
              TextButton.icon(
                onPressed: _onLogout,
                icon: Icon(Icons.logout_rounded, size: 16, color: theme.secondaryText),
                label: Text(
                  'Log Out / Switch Account',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
