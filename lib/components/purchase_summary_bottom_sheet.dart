import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../backend/app_state.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'custom_pin_pad_widget.dart';
import 'transaction_status_modal.dart';

class PurchaseSummaryBottomSheet extends StatefulWidget {
  const PurchaseSummaryBottomSheet({
    super.key,
    required this.provider,
    required this.recipient,
    required this.serviceDescription,
    required this.amount,
    required this.onPinConfirmed,
  });

  final String provider;
  final String recipient;
  final String serviceDescription;
  final double amount;
  final Future<void> Function(String pin) onPinConfirmed;

  @override
  State<PurchaseSummaryBottomSheet> createState() => _PurchaseSummaryBottomSheetState();
}

class _PurchaseSummaryBottomSheetState extends State<PurchaseSummaryBottomSheet> {
  bool _isProcessing = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> _handleBiometric() async {
    if (_isProcessing) return;
    try {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) {
        if (mounted) {
          showErrorToast(context, 'Biometrics not supported on this device. Please enter your 4-digit PIN.');
        }
        return;
      }
      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Authorize payment of ${formatNaira(widget.amount)} for ${widget.provider}',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuth && mounted) {
        final appState = Provider.of<FFAppState>(context, listen: false);
        final savedPin = await appState.getSavedTransactionPin();
        _handlePin(savedPin ?? '');
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(context, 'Biometric verification failed. Please enter your 4-digit PIN.');
      }
    }
  }

  void _handlePin(String pin) async {
    if (_isProcessing) return;
    if (pin.isNotEmpty && pin.length < 4) {
      showErrorToast(context, 'Please enter your complete 4-digit security PIN.');
      return;
    }
    setState(() => _isProcessing = true);
    try {
      if (pin.isNotEmpty) {
        final appState = Provider.of<FFAppState>(context, listen: false);
        await appState.saveTransactionPin(pin);
      }
      await widget.onPinConfirmed(pin);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
    final appState = Provider.of<FFAppState>(context);
    final walletBalance = appState.wallet.balance;
    final isInsufficient = walletBalance < widget.amount;

    return PopScope(
      canPop: !_isProcessing,
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Shield Icon + "Authorize Payment" + Close 'X'
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Authorize Payment',
                    style: theme.titleMedium.override(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryText,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 16, color: theme.secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Summary Card (White / Dark with border)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF101522) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.provider.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.recipient,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.serviceDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatNaira(widget.amount),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (isInsufficient) ...[
                // If insufficient balance, show prompt to open Insufficient Dialog
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => InsufficientBalanceDialog(
                          requiredAmount: widget.amount,
                          currentBalance: walletBalance,
                          serviceTitle: widget.provider,
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.white),
                    label: const Text(
                      'Check Insufficient Balance',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ] else ...[
                // Biometric 1-Tap Button
                InkWell(
                  onTap: _handleBiometric,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          size: 22,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '1-Tap Authorize with Biometric / Fingerprint',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Or Enter 4-Digit Security PIN',
                  style: theme.labelSmall.override(
                    color: theme.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                if (_isProcessing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Authorizing transaction securely...',
                          style: theme.titleSmall.override(
                            color: theme.primaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  CustomPinPadWidget(
                    showBiometrics: true,
                    onBiometricAuthenticated: _handleBiometric,
                    onPinCompleted: _handlePin,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
