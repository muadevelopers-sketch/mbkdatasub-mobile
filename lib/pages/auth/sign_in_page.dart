import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/user_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'sign_up_page.dart';
import 'pin_setup_page.dart';
import 'forgot_password_page.dart';
import '../main/main_nav_shell.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _canUseBiometrics = false;
  bool _hasSavedCredentials = false;
  String _savedIdentifier = '';
  String _savedPassword = '';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  void _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      final creds = await MbkApi.getBiometricCredentials();

      if (mounted) {
        setState(() {
          _canUseBiometrics = canCheck && isSupported;
          if (creds != null) {
            _hasSavedCredentials = true;
            _savedIdentifier = creds['identifier'] ?? '';
            _savedPassword = creds['password'] ?? '';
            if (_identifierController.text.isEmpty && _savedIdentifier.isNotEmpty) {
              _identifierController.text = _savedIdentifier;
            }
          }
        });

        // If biometric is available and credentials saved, prompt right away
        if (_canUseBiometrics && _hasSavedCredentials) {
          _authenticateWithBiometrics();
        }
      }
    } catch (_) {}
  }

  void _authenticateWithBiometrics() async {
    try {
      final isIos = Platform.isIOS;
      final authenticated = await _localAuth.authenticate(
        localizedReason: isIos
            ? 'Scan your Face ID to unlock MBKDATASUB'
            : 'Scan your fingerprint to unlock MBKDATASUB',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && _savedIdentifier.isNotEmpty && _savedPassword.isNotEmpty) {
        _performLogin(_savedIdentifier, _savedPassword, isBiometric: true);
      }
    } catch (e) {
      // User cancelled or biometric failed; fall back to password entry
    }
  }

  void _handlePasswordSignIn() {
    final id = _identifierController.text.trim();
    final pass = _passwordController.text;

    if (id.isEmpty || pass.isEmpty) {
      showErrorToast(context, 'Please enter your phone/email and password.');
      return;
    }

    _performLogin(id, pass);
  }

  void _performLogin(String id, String pass, {bool isBiometric = false}) async {
    setState(() => _isLoading = true);
    final res = await MbkApi.login(identifier: id, password: pass);
    setState(() => _isLoading = false);

    if (res.success && res.data != null) {
      showSuccessToast(context, isBiometric ? 'Unlocked with Biometrics!' : 'Welcome back to MBKDATASUB!');
      final appState = Provider.of<FFAppState>(context, listen: false);
      if (res.data!['user'] != null) {
        final user = UserRecord.fromJson(res.data!['user']);
        appState.setUser(user);

        if (!user.hasTransactionPin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PinSetupPage()),
          );
          return;
        }
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavShell()),
        (route) => false,
      );
    } else {
      showErrorToast(context, res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isIos = Platform.isIOS;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Centered App Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x140A1C6A), blurRadius: 20, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),

              Text(
                'Welcome Back',
                style: theme.headlineMedium.override(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to manage your wallet and bills.',
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 28),

              // Quick Biometric Unlock Button (If Enabled)
              if (_canUseBiometrics && _hasSavedCredentials) ...[
                InkWell(
                  onTap: _authenticateWithBiometrics,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.primaryAccent.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isIos ? Icons.face_rounded : Icons.fingerprint_rounded,
                          color: theme.primaryAccent,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isIos ? 'Tap to Unlock with Face ID' : 'Tap to Unlock with Fingerprint',
                          style: TextStyle(
                            color: theme.primaryAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR PASSWORD', style: TextStyle(color: theme.secondaryText, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Phone / Email Field
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    'Phone Number or Email',
                    style: theme.labelMedium.override(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.bodyMedium.override(color: theme.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Enter phone or email',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: theme.secondaryText, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Password Field
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    'Password',
                    style: theme.labelMedium.override(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: theme.bodyMedium.override(color: theme.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.secondaryText, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.secondaryText),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: theme.bodySmall.override(
                      color: theme.primaryAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign In Button
              FFButtonWidget(
                onPressed: _isLoading ? null : _handlePasswordSignIn,
                text: _isLoading ? 'Signing In...' : 'Sign In',
                options: FFButtonOptions(
                  height: 52,
                  color: theme.primaryAccent,
                  textStyle: theme.titleSmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 24),

              // Switch to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.bodyMedium.override(color: theme.secondaryText),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: theme.bodyMedium.override(
                        color: theme.primaryAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
