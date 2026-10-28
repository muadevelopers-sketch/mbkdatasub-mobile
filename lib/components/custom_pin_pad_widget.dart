import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class CustomPinPadWidget extends StatefulWidget {
  const CustomPinPadWidget({
    super.key,
    required this.onPinCompleted,
    this.onBiometricAuthenticated,
    this.showBiometrics = true,
  });

  final Function(String pin) onPinCompleted;
  final VoidCallback? onBiometricAuthenticated;
  final bool showBiometrics;

  @override
  State<CustomPinPadWidget> createState() => _CustomPinPadWidgetState();
}

class _CustomPinPadWidgetState extends State<CustomPinPadWidget> {
  String _pin = '';
  final LocalAuthentication _localAuth = LocalAuthentication();

  void _onKeyPress(String val) {
    if (_pin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += val;
      });
      if (_pin.length == 4) {
        widget.onPinCompleted(_pin);
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _triggerBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) return;
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authenticate to complete transaction securely',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth && widget.onBiometricAuthenticated != null) {
        HapticFeedback.mediumImpact();
        widget.onBiometricAuthenticated!();
      }
    } catch (_) {}
  }

  Widget _buildDot(int index, FlutterFlowTheme theme, bool isDark) {
    final bool filled = index < _pin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
            : Colors.transparent,
        border: Border.all(
          color: filled
              ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          width: 1.8,
        ),
      ),
    );
  }

  Widget _buildRectKey({
    required Widget child,
    required VoidCallback onTap,
    required FlutterFlowTheme theme,
    required bool isDark,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlighted
                    ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                    : (isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0)),
                width: isHighlighted ? 1.5 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberKey(String text, FlutterFlowTheme theme, bool isDark) {
    return _buildRectKey(
      onTap: () => _onKeyPress(text),
      theme: theme,
      isDark: isDark,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: theme.primaryText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 4 PIN Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => _buildDot(i, theme, isDark)),
        ),
        const SizedBox(height: 20),

        // Keypad Grid
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              Row(
                children: [
                  _buildNumberKey('1', theme, isDark),
                  _buildNumberKey('2', theme, isDark),
                  _buildNumberKey('3', theme, isDark),
                ],
              ),
              Row(
                children: [
                  _buildNumberKey('4', theme, isDark),
                  _buildNumberKey('5', theme, isDark),
                  _buildNumberKey('6', theme, isDark),
                ],
              ),
              Row(
                children: [
                  _buildNumberKey('7', theme, isDark),
                  _buildNumberKey('8', theme, isDark),
                  _buildNumberKey('9', theme, isDark),
                ],
              ),
              Row(
                children: [
                  // Fingerprint Button (Highlighted with blue border)
                  widget.showBiometrics
                      ? _buildRectKey(
                          onTap: _triggerBiometric,
                          theme: theme,
                          isDark: isDark,
                          isHighlighted: true,
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 26,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        )
                      : const Spacer(),

                  _buildNumberKey('0', theme, isDark),

                  // Backspace Button
                  _buildRectKey(
                    onTap: _onBackspace,
                    theme: theme,
                    isDark: isDark,
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 22,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
