import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../flutter_flow/flutter_flow_util.dart';

class TransactionStatusModal extends StatelessWidget {
  const TransactionStatusModal({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    this.tokenOrPin,
    this.onClose,
  });

  final bool isSuccess;
  final String title;
  final String message;
  final String? tokenOrPin;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
          const SizedBox(height: 28),

          // Circle Icon
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              border: Border.all(
                color: isSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                width: 3,
              ),
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.close_rounded,
              size: 52,
              color: isSuccess ? theme.success : theme.error,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: theme.displaySmall.override(
              fontWeight: FontWeight.w800,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                color: theme.secondaryText,
                fontSize: 14,
                lineHeight: 1.5,
              ),
            ),
          ),

          // Token / PIN Display Box (if generated)
          if (tokenOrPin != null && tokenOrPin!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                children: [
                  Text(
                    'TOKEN / PIN(S)',
                    style: theme.labelSmall.override(
                      fontWeight: FontWeight.w700,
                      color: theme.secondaryText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    tokenOrPin!,
                    textAlign: TextAlign.center,
                    style: theme.titleLarge.override(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: tokenOrPin!));
                      showSuccessToast(context, 'Token copied to clipboard!');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 16, color: theme.primaryAccent),
                        const SizedBox(width: 6),
                        Text(
                          'Copy Token',
                          style: theme.titleSmall.override(color: theme.primaryAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Action Button
          FFButtonWidget(
            text: 'Got it',
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose!();
            },
            options: FFButtonOptions(
              color: isSuccess ? theme.success : theme.primary,
              textStyle: theme.titleMedium.override(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              borderRadius: BorderRadius.circular(16),
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}
