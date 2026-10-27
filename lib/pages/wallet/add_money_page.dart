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
        _manualBank = bank;
        _isLoadingBank = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final wallet = appState.wallet;

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
          'Fund Wallet',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: theme.primaryAccent, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transfer directly to either of your permanent dedicated accounts below. Your wallet balance credits automatically in seconds.',
                        style: theme.bodySmall.override(color: theme.primary, lineHeight: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Automated Virtual Accounts', style: theme.titleMedium.override(fontWeight: FontWeight.w800, color: theme.primaryText)),
              const SizedBox(height: 12),

              // Dedicated Automated Bank Accounts
              if (wallet.displayAccounts.isNotEmpty)
                ...wallet.displayAccounts.map((acc) => _buildDedicatedCard(acc, theme, context))
              else
                _buildPlaceholderCard('PalmPay Bank', wallet.virtualAccountNumber ?? 'Generating dedicated account...', theme, context),

              const SizedBox(height: 24),

              // Manual Bank Transfer Option
              Text('Manual Bank Deposit (Zero Fee)', style: theme.titleMedium.override(fontWeight: FontWeight.w800, color: theme.primaryText)),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _isLoadingBank
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _manualBank?['bankName'] ?? 'Wema Bank',
                                style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('MANUAL', style: theme.labelSmall.override(color: theme.success, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Account Number', style: theme.labelSmall.override(color: theme.secondaryText)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _manualBank?['accountNumber'] ?? '9900000001',
                                    style: theme.headlineSmall.override(
                                      fontWeight: FontWeight.w900,
                                      color: theme.primaryAccent,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _manualBank?['accountNumber'] ?? '9900000001'));
                                  showSuccessToast(context, 'Bank account number copied!');
                                },
                                icon: Icon(Icons.copy_rounded, color: theme.primaryAccent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Account Name: ${_manualBank?['accountName'] ?? "MBKDATASUB VENTURES"}',
                            style: theme.bodySmall.override(fontWeight: FontWeight.w600, color: theme.secondaryText),
                          ),
                          const Divider(height: 24, color: Color(0xFFF1F5F9)),
                          Text(
                            _manualBank?['instruction'] ?? 'Transfer directly and contact WhatsApp support with your payment receipt for instant confirmation.',
                            style: theme.bodySmall.override(color: const Color(0xFF64748B), lineHeight: 1.3),
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

  Widget _buildDedicatedCard(DedicatedAccount acc, FlutterFlowTheme theme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                acc.bankName,
                style: theme.titleLarge.override(
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AUTOMATED',
                  style: theme.labelSmall.override(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Number', style: theme.labelSmall.override(color: theme.secondaryText)),
                  const SizedBox(height: 2),
                  Text(
                    acc.accountNumber,
                    style: theme.displaySmall.override(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: acc.accountNumber));
                  showSuccessToast(context, '${acc.bankName} account number copied!');
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Copy',
                        style: theme.labelMedium.override(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Account Name: ${acc.accountName}',
            style: theme.bodySmall.override(
              fontWeight: FontWeight.w600,
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(String bank, String number, FlutterFlowTheme theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bank, style: theme.titleLarge.override(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(number, style: theme.titleMedium.override(fontWeight: FontWeight.w700, color: theme.primaryAccent)),
        ],
      ),
    );
  }
}
