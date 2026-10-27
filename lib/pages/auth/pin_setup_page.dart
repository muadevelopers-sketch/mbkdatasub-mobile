import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/custom_pin_pad_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../main/main_nav_shell.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String? _firstPin;
  bool _isConfirming = false;
  bool _isLoading = false;

  void _handlePinCompleted(String pin) async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
      });
    } else {
      if (pin != _firstPin) {
        showErrorToast(context, 'PINs do not match. Please try again.');
        setState(() {
          _firstPin = null;
          _isConfirming = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      final res = await MbkApi.setTransactionPin(pin);
      setState(() => _isLoading = false);

      if (res.success) {
        showSuccessToast(context, 'Security PIN configured successfully!');
        final appState = Provider.of<FFAppState>(context, listen: false);
        await appState.initialize();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavShell()),
          (route) => false,
        );
      } else {
        showErrorToast(context, res.message);
        setState(() {
          _firstPin = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final userName = appState.user?.fullName ?? 'User';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavShell()),
                (route) => false,
              );
            },
            child: Text(
              'Skip for now',
              style: theme.titleSmall.override(color: theme.secondaryText),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // User Avatar
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC7D2FE),
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 20),

              // Greeting & Prompt
              Text(
                'Hi, $userName',
                style: theme.headlineSmall.override(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isConfirming ? 'Confirm your 4-digit PIN' : 'Set a 4-digit PIN',
                style: theme.bodyMedium.override(
                  color: theme.secondaryText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),

              // PIN Pad
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF1E5BF8))
              else
                CustomPinPadWidget(
                  key: ValueKey(_isConfirming),
                  onPinCompleted: _handlePinCompleted,
                  showBiometrics: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
