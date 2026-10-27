import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../backend/schema/struct/transaction_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key, required this.transaction});
  final TransactionRecord transaction;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSuccess = transaction.isSuccess;

    void shareReceipt() {
      final text = '''
==============================
MBKDATASUB TRANSACTION RECEIPT
==============================
Status: ${transaction.status.toUpperCase()}
Reference: ${transaction.reference}
Service: ${transaction.title}
Amount: ${formatNaira(transaction.amount)}
Recipient: ${transaction.recipient}
Date: ${formatDateTime(transaction.date)}
${transaction.tokenOrPin != null ? "Token/PIN: ${transaction.tokenOrPin}\n" : ""}
Balance After: ${formatNaira(transaction.balanceAfter)}
==============================
Thank you for using MBKDATASUB!
Website: https://mbkdatasub.com.ng
''';
      Share.share(text, subject: 'MBKDATASUB Payment Receipt - ${transaction.reference}');
    }

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
          'Transaction Receipt',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: shareReceipt,
            icon: Icon(Icons.share_outlined, color: theme.primaryAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    // Status Badge Icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isSuccess ? theme.success : theme.error,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isSuccess ? 'Transaction Successful' : 'Transaction Failed',
                      style: theme.headlineSmall.override(
                        fontWeight: FontWeight.w800,
                        color: isSuccess ? const Color(0xFF166534) : theme.error,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNaira(transaction.amount),
                      style: theme.displayMedium.override(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 16),

                    // Details Rows
                    _buildRow('Transaction Reference', transaction.reference, theme, canCopy: true, context: context),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildRow('Service Title', transaction.title, theme),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildRow('Recipient', transaction.recipient, theme),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildRow('Date & Time', formatDateTime(transaction.date), theme),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _buildRow('Balance After', formatNaira(transaction.balanceAfter), theme),

                    if (transaction.tokenOrPin != null && transaction.tokenOrPin!.isNotEmpty) ...[
                      const Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _buildRow('Token / PIN', transaction.tokenOrPin!, theme, canCopy: true, context: context),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Share Receipt Button
              FFButtonWidget(
                text: 'Share Payment Receipt',
                onPressed: shareReceipt,
                iconData: Icons.share_rounded,
                options: FFButtonOptions(
                  height: 52,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, FlutterFlowTheme theme, {bool canCopy = false, BuildContext? context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.bodyMedium.override(color: theme.secondaryText)),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              if (canCopy && context != null) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    showSuccessToast(context, '$label copied!');
                  },
                  child: Icon(Icons.copy_rounded, size: 16, color: theme.primaryAccent),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
