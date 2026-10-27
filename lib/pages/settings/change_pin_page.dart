import 'package:flutter/material.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../components/custom_pin_pad_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  String? _newPin;
  bool _isConfirming = false;
  bool _isLoading = false;

  void _handlePinCompleted(String pin) async {
    if (!_isConfirming) {
      setState(() {
        _newPin = pin;
        _isConfirming = true;
      });
    } else {
      if (pin != _newPin) {
        showErrorToast(context, 'New PINs do not match. Please try again.');
        setState(() {
          _newPin = null;
          _isConfirming = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      final res = await MbkApi.setTransactionPin(pin);
      setState(() => _isLoading = false);

      if (res.success) {
        showSuccessToast(context, 'Transaction PIN updated successfully!');
        Navigator.pop(context);
      } else {
        showErrorToast(context, res.message);
        setState(() {
          _newPin = null;
          _isConfirming = false;
        });
      }
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
          'Change PIN',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF4FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_clock_outlined, size: 36, color: theme.primaryAccent),
              ),
              const SizedBox(height: 20),
              Text(
                _isConfirming ? 'Confirm your new 4-digit PIN' : 'Enter your new 4-digit PIN',
                style: theme.headlineSmall.override(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This PIN will be required to confirm all future checkouts',
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(color: theme.secondaryText),
              ),
              const SizedBox(height: 36),

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
