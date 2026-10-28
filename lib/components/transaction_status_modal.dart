import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../pages/wallet/add_money_page.dart';

class TransactionStatusModal extends StatelessWidget {
  const TransactionStatusModal({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    this.amount,
    this.serviceTitle,
    this.recipient,
    this.reference,
    this.updatedBalance,
    this.tokenOrPin,
    this.onClose,
  });

  final bool isSuccess;
  final String title;
  final String message;
  final double? amount;
  final String? serviceTitle;
  final String? recipient;
  final String? reference;
  final double? updatedBalance;
  final String? tokenOrPin;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSuccess
                ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
                : (isDark ? const Color(0xFFDC2626) : const Color(0xFFFECACA)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSuccess
                  ? const Color(0x2610B981)
                  : const Color(0x26EF4444),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close X Button at Top Right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    if (onClose != null) onClose!();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),

            // Concentric Circle Icon
            _buildConcentricIcon(isSuccess, isDark),
            const SizedBox(height: 14),

            // Success Pill Badge (if success)
            if (isSuccess) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text(
                      'INSTANTLY DELIVERED',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Title
            Text(
              isSuccess ? 'Transaction Successful!' : title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.primaryText,
              ),
            ),

            if (amount != null && amount! > 0) ...[
              const SizedBox(height: 8),
              Text(
                formatNaira(amount!),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0284C7),
                ),
              ),
            ],

            if (serviceTitle != null && serviceTitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                serviceTitle!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101522) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  if (recipient != null && recipient!.isNotEmpty) ...[
                    _buildDetailRow('Recipient / Beneficiary:', recipient!, theme),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  ],
                  if (reference != null && reference!.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reference:',
                          style: TextStyle(fontSize: 12, color: theme.secondaryText),
                        ),
                        Row(
                          children: [
                            Text(
                              reference!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: reference!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reference copied to clipboard')),
                                );
                              },
                              child: Icon(Icons.copy_rounded, size: 14, color: theme.secondaryText),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  ],
                  if (updatedBalance != null) ...[
                    _buildDetailRow(
                      'Updated Wallet Balance:',
                      formatNaira(updatedBalance!),
                      theme,
                      isBold: true,
                    ),
                  ] else ...[
                    _buildDetailRow(
                      'Status:',
                      isSuccess ? 'Completed (Instant)' : 'Failed',
                      theme,
                    ),
                  ],
                  if (tokenOrPin != null && tokenOrPin!.isNotEmpty) ...[
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    _buildDetailRow('Token / PIN:', tokenOrPin!, theme, isBold: true),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  if (onClose != null) onClose!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSuccess ? 'Done' : 'Try Again',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            if (isSuccess) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  if (onClose != null) onClose!();
                },
                icon: const Icon(Icons.share_outlined, size: 15, color: Color(0xFF0284C7)),
                label: const Text(
                  'View Detailed Receipt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConcentricIcon(bool isSuccess, bool isDark) {
    final ring1 = isSuccess
        ? (isDark ? const Color(0xFF064E3B).withOpacity(0.4) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF7F1D1D).withOpacity(0.4) : const Color(0xFFFEF2F2));
    final ring2 = isSuccess
        ? (isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5))
        : (isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2));
    final centerColor = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: ring1,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: ring2,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: centerColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    FlutterFlowTheme theme, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.secondaryText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: theme.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}

class InsufficientBalanceDialog extends StatelessWidget {
  const InsufficientBalanceDialog({
    super.key,
    required this.requiredAmount,
    required this.currentBalance,
    required this.serviceTitle,
  });

  final double requiredAmount;
  final double currentBalance;
  final String serviceTitle;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
    final shortfall = requiredAmount - currentBalance;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26EF4444),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close X Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context, rootNavigator: true).pop(),
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

            // Concentric Red Alert Circle
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'Insufficient Balance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              'You need ${formatNaira(requiredAmount)} to complete $serviceTitle, but your current wallet balance is ${formatNaira(currentBalance)}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.secondaryText,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Breakdown Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF101522) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildRow('Required Amount:', formatNaira(requiredAmount), theme),
                  const Divider(height: 14, color: Color(0xFFE2E8F0)),
                  _buildRow('Your Balance:', formatNaira(currentBalance), theme),
                  const Divider(height: 14, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shortfall:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.error,
                        ),
                      ),
                      Text(
                        '-${formatNaira(shortfall)}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: theme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Fund Wallet Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMoneyPage()),
                  );
                },
                icon: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Fund Wallet Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Maybe Later
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: theme.secondaryText),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.primaryText,
          ),
        ),
      ],
    );
  }
}
