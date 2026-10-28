import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/app_state.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../pages/wallet/add_money_page.dart';
import 'custom_pin_pad_widget.dart';

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

  void _handlePin(String pin) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await widget.onPinConfirmed(pin);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
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
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // Drag handle
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Icon(Icons.phone_android_rounded, color: theme.primary, size: 26),
              const SizedBox(width: 10),
              Text(
                'Purchase Summary',
                style: theme.headlineSmall.override(
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildRow('Network / Provider', widget.provider, theme),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildRow('Recipient', widget.recipient, theme),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                _buildRow('Package / Service', widget.serviceDescription, theme),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount', style: theme.titleMedium.override(color: theme.secondaryText)),
                    Text(
                      formatNaira(widget.amount),
                      style: theme.headlineSmall.override(
                        color: theme.primaryAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Wallet Balance', style: theme.bodyMedium.override(color: theme.secondaryText)),
                    Text(
                      formatNaira(walletBalance),
                      style: theme.titleSmall.override(
                        color: isInsufficient ? const Color(0xFFDC2626) : theme.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isInsufficient) ...[
            // Insufficient Balance Warning Card
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Insufficient Balance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Your balance is ${formatNaira(walletBalance)}. You need ${formatNaira(widget.amount - walletBalance)} more to complete this order.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB91C1C),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            FFButtonWidget(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMoneyPage()),
                );
              },
              text: 'Fund Wallet to Proceed',
              iconData: Icons.account_balance_wallet_rounded,
              options: FFButtonOptions(
                width: double.infinity,
                height: 52,
                color: theme.primary,
                textStyle: theme.titleSmall.override(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            // Instructions
            Text(
              'Enter your 4-digit PIN to confirm transaction',
              style: theme.labelMedium.override(color: theme.secondaryText),
            ),
            const SizedBox(height: 18),

            // PIN Pad or Loader
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: theme.primaryAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Processing payment securely...',
                      style: theme.titleSmall.override(color: theme.primaryText),
                    ),
                  ],
                ),
              )
            else
              CustomPinPadWidget(
                onPinCompleted: _handlePin,
                onBiometricAuthenticated: () => _handlePin(''),
              ),
          ],
        ],
      ),
    ));
  }

  Widget _buildRow(String label, String value, FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.bodyMedium.override(color: theme.secondaryText)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.titleSmall.override(
              fontWeight: FontWeight.w700,
              color: theme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
