import 'package:flutter/material.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  void _handleChangePassword() async {
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      showErrorToast(context, 'Please complete all password fields.');
      return;
    }

    if (newPass.length < 8) {
      showErrorToast(context, 'New password must be at least 8 characters long.');
      return;
    }

    if (newPass != confirm) {
      showErrorToast(context, 'New passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await MbkApi.changePassword(
      currentPassword: current,
      newPassword: newPass,
    );
    setState(() => _isLoading = false);

    if (res.success) {
      showSuccessToast(context, 'Password changed successfully!');
      Navigator.pop(context);
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
          'Change Password',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Password', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  style: theme.bodyLarge,
                  decoration: _passwordDecoration(
                    'Enter current password',
                    _obscureCurrent,
                    () => setState(() => _obscureCurrent = !_obscureCurrent),
                    theme,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text('New Password', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  style: theme.bodyLarge,
                  decoration: _passwordDecoration(
                    'Create strong new password',
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew),
                    theme,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text('Confirm New Password', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: theme.bodyLarge,
                  decoration: _passwordDecoration(
                    'Confirm new password',
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                    theme,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FFButtonWidget(
                text: 'Update Password',
                onPressed: _isLoading ? null : _handleChangePassword,
                showLoadingIndicator: _isLoading,
                options: FFButtonOptions(
                  height: 54,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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

  InputDecoration _passwordDecoration(String hint, bool obscure, VoidCallback onToggle, FlutterFlowTheme theme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0A1C6A)),
      suffixIcon: InkWell(
        onTap: onToggle,
        child: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF94A3B8),
        ),
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
