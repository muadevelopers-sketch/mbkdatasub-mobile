import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/user_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'sign_in_page.dart';
import 'pin_setup_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;

  void _handleSignUp() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;
    final ref = _referralCodeController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      showErrorToast(context, 'Please fill in all required fields.');
      return;
    }

    if (pass.length < 8) {
      showErrorToast(context, 'Password must be at least 8 characters long.');
      return;
    }

    if (pass != confirmPass) {
      showErrorToast(context, 'Passwords do not match. Please verify.');
      return;
    }

    if (!_agreedToTerms) {
      showErrorToast(context, 'Please agree to the Terms & Conditions.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await MbkApi.register(
      fullName: name,
      email: email,
      phone: phone,
      password: pass,
      referralCode: ref.isNotEmpty ? ref : null,
    );
    setState(() => _isLoading = false);

    if (res.success && res.data != null) {
      showSuccessToast(context, 'Account created successfully!');
      final appState = Provider.of<FFAppState>(context, listen: false);
      if (res.data!['user'] != null) {
        final user = UserRecord.fromJson(res.data!['user']);
        appState.setUser(user);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PinSetupPage()),
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
        title: Text(
          'Create Account',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join MBKDATASUB Today',
                style: theme.headlineMedium.override(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create your account to get started',
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 24),

              // Full Name
              _buildInputContainer(
                child: TextField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  style: theme.bodyLarge,
                  decoration: _inputDecoration('Full Name', Icons.person_outline_rounded, theme),
                ),
              ),
              const SizedBox(height: 14),

              // Email Address
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.bodyLarge,
                  decoration: _inputDecoration('Email Address', Icons.mail_outline_rounded, theme),
                ),
              ),
              const SizedBox(height: 14),

              // Mobile Number
              _buildInputContainer(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: theme.bodyLarge,
                  decoration: _inputDecoration('Mobile Number', Icons.phone_android_rounded, theme),
                ),
              ),
              const SizedBox(height: 14),

              // Password
              _buildInputContainer(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Create strong password',
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

              // Confirm Password
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0A1C6A)),
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      child: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Agent / Referral Code (Optional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputContainer(
                    child: TextField(
                      controller: _referralCodeController,
                      style: theme.bodyLarge,
                      decoration: _inputDecoration('Agent / Referral Code', Icons.group_add_outlined, theme),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Optional',
                      style: theme.labelSmall.override(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Terms & Conditions Checkbox
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: theme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.bodySmall.override(fontSize: 12, lineHeight: 1.4),
                          children: [
                            const TextSpan(text: 'By proceeding forward you consent to agree to our '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: theme.bodySmall.override(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: theme.bodySmall.override(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Create Account Button
              FFButtonWidget(
                text: 'Create Account',
                onPressed: _isLoading ? null : _handleSignUp,
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
              const SizedBox(height: 24),

              // Footer: Already have an account? Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.bodyMedium.override(color: theme.secondaryText),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: theme.titleSmall.override(
                        color: theme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, FlutterFlowTheme theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF0A1C6A)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
