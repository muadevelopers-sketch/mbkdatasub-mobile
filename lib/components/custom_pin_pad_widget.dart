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

  Widget _buildDot(int index, FlutterFlowTheme theme) {
    final bool filled = index < _pin.length;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? theme.primaryAccent : const Color(0xFFE2E8F0),
        border: Border.all(
          color: filled ? theme.primaryAccent : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildKey(String text, FlutterFlowTheme theme) {
    return InkWell(
      onTap: () => _onKeyPress(text),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Text(
          text,
          style: theme.displaySmall.override(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 4 PIN Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => _buildDot(i, theme)),
        ),
        const SizedBox(height: 24),

        // Keypad Grid
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('1', theme),
                  _buildKey('2', theme),
                  _buildKey('3', theme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('4', theme),
                  _buildKey('5', theme),
                  _buildKey('6', theme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildKey('7', theme),
                  _buildKey('8', theme),
                  _buildKey('9', theme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Biometric or info button
                  widget.showBiometrics
                      ? InkWell(
                          onTap: _triggerBiometric,
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.fingerprint_rounded,
                              size: 32,
                              color: theme.primaryAccent,
                            ),
                          ),
                        )
                      : const SizedBox(width: 68, height: 68),
                  _buildKey('0', theme),
                  // Backspace button
                  InkWell(
                    onTap: _onBackspace,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 26,
                        color: theme.error,
                      ),
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
