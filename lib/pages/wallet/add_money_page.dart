import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/wallet_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  Map<String, dynamic>? _manualBank;
  bool _isLoadingBank = false;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadManualBank();
  }

  void _loadManualBank() async {
    setState(() => _isLoadingBank = true);
    final bank = await MbkApi.getManualBank();
    if (mounted) {
      setState(() {
        _manualBank = bank.data ?? FFAppState().manualBankInfo;
        _isLoadingBank = false;
      });
    }
  }

  void _assignDedicatedAccount() async {
    setState(() => _isAssigning = true);
    final appState = Provider.of<FFAppState>(context, listen: false);
    await appState.refreshWallet();
    if (mounted) {
      setState(() => _isAssigning = false);
      showSuccessToast(context, 'Dedicated virtual accounts synchronized!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
    final appState = Provider.of<FFAppState>(context);
    final wallet = appState.wallet;
    final user = appState.user;
    final userName = user != null && user.fullName.isNotEmpty ? user.fullName : 'UMMULKHAIRI IDRIS';

    // Extract PalmPay and Paga accounts
    DedicatedAccount? palmpayAcc;
    DedicatedAccount? pagaAcc;

    for (final acc in wallet.displayAccounts) {
      final name = acc.bankName.toLowerCase();
      if (name.contains('palm') && palmpayAcc == null) {
        palmpayAcc = acc;
      } else if (name.contains('paga') && pagaAcc == null) {
        pagaAcc = acc;
      }
    }

    // Fallbacks from wallet fields
    final palmpayNumber = palmpayAcc?.accountNumber ?? wallet.palmpayAccountNumber ?? '';
    final palmpayName = palmpayAcc?.accountName ?? wallet.palmpayAccountName ?? 'MBK-$userName';

    final pagaNumber = pagaAcc?.accountNumber ?? wallet.pagaAccountNumber ?? (wallet.displayAccounts.isNotEmpty ? wallet.displayAccounts.first.accountNumber : '2535129544');
    final pagaName = pagaAcc?.accountName ?? wallet.pagaAccountName ?? 'MBK-$userName';

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
                color: theme.secondaryBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: theme.primaryText,
              ),
            ),
          ),
        ),
        title: Text(
          'Fund Wallet',
          style: theme.titleMedium.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Current Available Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Available Balance',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNaira(wallet.balance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text(
                            'Instant Automated Credit • 0% Charges',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Section Header: Your Dedicated Virtual Accounts + Assign Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Dedicated Virtual Accounts',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: theme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Transfer funds from any bank app, USSD, OPay or Kuda directly to either account below. Your wallet will be credited automatically.',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.secondaryText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _isAssigning ? null : _assignDedicatedAccount,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 13,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAssigning ? 'Syncing...' : 'Assign',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 3. PalmPay Virtual Bank Card
              _buildAccountCard(
                context: context,
                badgeTitle: 'PALMPAY VIRTUAL BANK',
                badgeBg: isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE),
                badgeColor: const Color(0xFF0284C7),
                accountNumber: palmpayNumber,
                beneficiaryName: palmpayName,
                copyPillBg: const Color(0xFFE0F2FE),
                copyPillColor: const Color(0xFF0284C7),
                isAssigned: palmpayNumber.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(palmpayNumber),
                onAssignTap: _assignDedicatedAccount,
                theme: theme,
                isDark: isDark,
              ),

              const SizedBox(height: 14),

              // 4. Paga Virtual Bank Card
              _buildAccountCard(
                context: context,
                badgeTitle: 'PAGA VIRTUAL BANK',
                badgeBg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                badgeColor: const Color(0xFFD97706),
                accountNumber: pagaNumber,
                beneficiaryName: pagaName,
                copyPillBg: const Color(0xFFFEF3C7),
                copyPillColor: const Color(0xFFD97706),
                isAssigned: pagaNumber.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(pagaNumber),
                onAssignTap: _assignDedicatedAccount,
                theme: theme,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // 5. How to Fund Your Wallet Guide Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Fund Your Wallet:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildGuideStep(
                      stepNumber: '1',
                      text: 'Copy either the PalmPay or Paga account number above.',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildGuideStep(
                      stepNumber: '2',
                      text: 'Open your mobile banking app or dial your bank USSD code.',
                      theme: theme,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    _buildGuideStep(
                      stepNumber: '3',
                      text: 'Transfer the desired amount. Your MBK DATASUB balance updates in seconds.',
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required BuildContext context,
    required String badgeTitle,
    required Color badgeBg,
    required Color badgeColor,
    required String accountNumber,
    required String beneficiaryName,
    required Color copyPillBg,
    required Color copyPillColor,
    required bool isAssigned,
    required VoidCallback onAssignTap,
    required FlutterFlowTheme theme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Bank Pill Left, AUTOMATED Pill Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeTitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: badgeColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text(
                      'AUTOMATED',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Middle Row: Account Number OR Tap to Assign link
          if (isAssigned) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  accountNumber,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: theme.primaryText,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: accountNumber));
                    showSuccessToast(context, 'Account number copied: $accountNumber');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : copyPillBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: copyPillColor),
                        const SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: copyPillColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: onAssignTap,
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text(
                    'Tap to Assign Account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0284C7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Beneficiary Name
          Text(
            'Beneficiary: $beneficiaryName',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep({
    required String stepNumber,
    required String text,
    required FlutterFlowTheme theme,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0284C7),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              color: theme.secondaryText,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
