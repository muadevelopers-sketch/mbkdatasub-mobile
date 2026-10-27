import 'dart:async';
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
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;
  bool _isVerifyingOtp = false;

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralCodeController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleInitiateSignUp() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      showErrorToast(context, 'Please fill in all required fields.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showErrorToast(context, 'Please enter a valid email address.');
      return;
    }

    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid phone number.');
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
      showErrorToast(context, 'Please accept the Terms & Conditions.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await MbkApi.requestRegistrationOtp(email: email, phone: phone);
    setState(() => _isLoading = false);

    if (res.success) {
      showSuccessToast(context, '6-digit OTP dispatched to $email');
      _startResendTimer();
      _showOtpModal(email);
    } else {
      showErrorToast(context, res.message);
    }
  }

  void _showOtpModal(String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final theme = FlutterFlowTheme.of(context);
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Verify Your Email',
                  textAlign: TextAlign.center,
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.w900,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit confirmation code to:\n$email',
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium.copyWith(
                    color: theme.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // 6-digit OTP input field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primaryAccent, width: 1.5),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: Color(0xFF0A1C6A),
                    ),
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Resend Countdown
                Center(
                  child: _resendCountdown > 0
                      ? Text(
                          'Resend code in ${_resendCountdown}s',
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        )
                      : TextButton(
                          onPressed: () async {
                            final res = await MbkApi.requestRegistrationOtp(
                              email: _emailController.text.trim(),
                              phone: _phoneController.text.trim(),
                            );
                            if (res.success) {
                              showSuccessToast(context, 'New OTP sent!');
                              _startResendTimer();
                              setModalState(() {});
                            } else {
                              showErrorToast(context, res.message);
                            }
                          },
                          child: Text(
                            'Resend Code Now',
                            style: TextStyle(
                              color: theme.primaryAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 18),

                // Verify & Complete Registration Button
                FFButtonWidget(
                  onPressed: _isVerifyingOtp
                      ? null
                      : () async {
                          final otp = _otpController.text.trim();
                          if (otp.length != 6) {
                            showErrorToast(context, 'Please enter the 6-digit OTP code.');
                            return;
                          }

                          setModalState(() => _isVerifyingOtp = true);
                          final res = await MbkApi.register(
                            fullName: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text,
                            otp: otp,
                            referralCode: _referralCodeController.text.trim().isNotEmpty
                                ? _referralCodeController.text.trim()
                                : null,
                          );
                          setModalState(() => _isVerifyingOtp = false);

                          if (res.success && res.data != null) {
                            Navigator.pop(context); // close modal
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
                        },
                  text: _isVerifyingOtp ? 'Verifying...' : 'Verify & Create Account',
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
              ],
            ),
          );
        },
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: theme.headlineMedium.override(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join MBKDATASUB for automated VTU, data & bill payments.',
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Full Name
              _buildInputLabel('Full Name', theme),
              _buildInputField(
                controller: _fullNameController,
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // Email
              _buildInputLabel('Email Address', theme),
              _buildInputField(
                controller: _emailController,
                hintText: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // Phone Number
              _buildInputLabel('Phone Number', theme),
              _buildInputField(
                controller: _phoneController,
                hintText: 'e.g. 08012345678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // Password
              _buildInputLabel('Password', theme),
              _buildInputField(
                controller: _passwordController,
                hintText: 'Create a strong password (min 8 chars)',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                theme: theme,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.secondaryText),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              _buildInputLabel('Confirm Password', theme),
              _buildInputField(
                controller: _confirmPasswordController,
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirmPassword,
                theme: theme,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: theme.secondaryText),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 16),

              // Referral Code (Optional)
              _buildInputLabel('Referral Code (Optional)', theme),
              _buildInputField(
                controller: _referralCodeController,
                hintText: 'Enter referral code if you have one',
                prefixIcon: Icons.card_giftcard_rounded,
                theme: theme,
              ),
              const SizedBox(height: 18),

              // Terms Agreement
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: theme.primaryAccent,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? true),
                  ),
                  Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: theme.bodySmall.override(color: theme.secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              FFButtonWidget(
                onPressed: _isLoading ? null : _handleInitiateSignUp,
                text: _isLoading ? 'Sending Verification Code...' : 'Send OTP & Create Account',
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
              const SizedBox(height: 20),

              // Switch to Sign In
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

  Widget _buildInputLabel(String label, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: theme.labelMedium.override(
          color: theme.primaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required FlutterFlowTheme theme,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: theme.bodyMedium.override(color: theme.primaryText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
          prefixIcon: Icon(prefixIcon, color: theme.secondaryText, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
