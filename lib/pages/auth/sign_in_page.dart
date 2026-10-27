import 'package:flutter/material.dart';
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
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleSignIn() async {
    final id = _identifierController.text.trim();
    final pass = _passwordController.text;

    if (id.isEmpty || pass.isEmpty) {
      showErrorToast(context, 'Please enter your phone/email and password.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await MbkApi.login(identifier: id, password: pass);
    setState(() => _isLoading = false);

    if (res.success && res.data != null) {
      showSuccessToast(context, 'Welcome back to MBKDATASUB!');
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
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E5BF8),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.bolt_rounded,
                    size: 40,
                    color: theme.primaryAccent,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Phone / Email Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Mobile Number or Email',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0A1C6A)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0A1C6A)),
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: theme.titleSmall.override(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Sign In Button
              FFButtonWidget(
                text: 'Sign In',
                onPressed: _isLoading ? null : _handleSignIn,
                showLoadingIndicator: _isLoading,
                options: FFButtonOptions(
                  height: 54,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 28),

              // Footer: Create Account
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
                      'Create Account',
                      style: theme.titleSmall.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
