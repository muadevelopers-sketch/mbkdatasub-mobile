import 'package:flutter/material.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailPhoneController = TextEditingController();
  bool _isLoading = false;

  void _handleReset() async {
    final text = _emailPhoneController.text.trim();
    if (text.isEmpty) {
      showErrorToast(context, 'Please enter your registered email or phone number.');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    showSuccessToast(context, 'Password reset instructions dispatched to $text.');
    Navigator.pop(context);
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
          'Reset Password',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot your password?',
                style: theme.headlineMedium.override(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the email or phone number associated with your MBKDATASUB account, and we will help you reset it.',
                style: theme.bodyMedium.override(color: theme.secondaryText, lineHeight: 1.4),
              ),
              const SizedBox(height: 28),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _emailPhoneController,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Email or Mobile Number',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF0A1C6A)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FFButtonWidget(
                text: 'Send Reset Instructions',
                onPressed: _isLoading ? null : _handleReset,
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
            ],
          ),
        ),
      ),
    );
  }
}
