import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../backend/app_state.dart';
import '../backend/schema/struct/wallet_record.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import 'provider_logo_widget.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final wallet = appState.wallet;
    final isHidden = appState.isWalletHidden;
    final accounts = wallet.displayAccounts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
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
                        fontSize: 24,
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
                          '₦0.00',
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

              // Right Section: Dedicated PalmPay & Paga Accounts (Stacked)
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: accounts.map((acc) => _buildAccountPill(acc, context, theme)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPill(DedicatedAccount acc, BuildContext context, FlutterFlowTheme theme) {
    final isGenerating = acc.accountNumber == 'Generating...';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: acc.type == 'palmpay' ? const Color(0xFFE0E7FF) : const Color(0xFFFFEDD5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProviderLogoWidget(
            providerName: acc.type,
            size: 20,
            borderRadius: 6,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                acc.bankName,
                style: theme.labelSmall.override(
                  fontSize: 10,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                acc.accountNumber,
                style: theme.titleSmall.override(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isGenerating ? theme.secondaryText : theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          if (!isGenerating)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: acc.accountNumber));
                showSuccessToast(context, '${acc.bankName} copied!');
              },
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: theme.primaryAccent,
              ),
            ),
        ],
      ),
    );
  }
}
