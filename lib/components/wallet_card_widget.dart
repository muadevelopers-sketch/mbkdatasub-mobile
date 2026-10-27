import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../backend/app_state.dart';
import '../backend/schema/struct/wallet_record.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final wallet = appState.wallet;
    final isHidden = appState.isWalletHidden;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section: Balance & Bonus
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Wallet Balance',
                          style: theme.labelMedium.override(
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => appState.toggleWalletHidden(),
                          child: Icon(
                            isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isHidden ? '••••••••' : formatNaira(wallet.balance),
                      style: theme.displaySmall.override(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Bonus ',
                          style: theme.labelSmall.override(
                            color: theme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₦0',
                          style: theme.labelSmall.override(
                            color: theme.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Section: Dedicated Automated Accounts
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (wallet.displayAccounts.isNotEmpty)
                      ...wallet.displayAccounts.take(2).map((acc) => _buildAccountPill(acc, context, theme))
                    else
                      _buildPlaceholderPill('PalmPay Bank', wallet.virtualAccountNumber ?? 'Generating...', context, theme),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPill(DedicatedAccount acc, BuildContext context, FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                acc.bankName,
                style: theme.labelSmall.override(
                  fontSize: 10,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                acc.accountNumber,
                style: theme.titleSmall.override(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: acc.accountNumber));
              showSuccessToast(context, '${acc.bankName} account copied!');
            },
            child: Icon(
              Icons.copy_rounded,
              size: 16,
              color: theme.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPill(String bank, String number, BuildContext context, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(bank, style: theme.labelSmall.override(fontSize: 10, color: theme.secondaryText)),
              Text(number, style: theme.titleSmall.override(fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: number));
              showSuccessToast(context, 'Account copied!');
            },
            child: Icon(Icons.copy_rounded, size: 16, color: theme.primaryAccent),
          ),
        ],
      ),
    );
  }
}
