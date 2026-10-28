import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int _selectedBankIndex = 0;

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

  List<Map<String, String>> _getBankOptions() {
    final list = <Map<String, String>>[];
    final data = _manualBank ?? FFAppState().manualBankInfo;

    final pBank = data['bankName']?.toString() ?? 'OPAY';
    final pAcc = data['accountNumber']?.toString() ?? '8131555945';
    final pName = data['accountName']?.toString() ?? 'ABDUSSALAM A SIRAJO';
    list.add({'bank': pBank, 'account': pAcc, 'name': pName});

    final palmAcc = data['palmpayAccount']?.toString();
    final palmName = data['palmpayName']?.toString() ?? pName;
    if (palmAcc != null && palmAcc.isNotEmpty && palmAcc != pAcc) {
      list.add({'bank': 'PalmPay', 'account': palmAcc, 'name': palmName});
    }

    final monieAcc = data['moniepointAccount']?.toString();
    final monieName = data['moniepointName']?.toString() ?? pName;
    if (monieAcc != null && monieAcc.isNotEmpty && monieAcc != pAcc && monieAcc != palmAcc) {
      list.add({'bank': 'Moniepoint MFB', 'account': monieAcc, 'name': monieName});
    }

    final wemaAcc = data['wemaAccount']?.toString();
    final wemaName = data['wemaName']?.toString() ?? pName;
    if (wemaAcc != null && wemaAcc.isNotEmpty && wemaAcc != pAcc && wemaAcc != monieAcc && wemaAcc != palmAcc) {
      list.add({'bank': 'Wema Bank', 'account': wemaAcc, 'name': wemaName});
    }

    return list;
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
                    : Builder(
                        builder: (context) {
                          final bankOptions = _getBankOptions();
                          final currentBank = bankOptions.isNotEmpty && _selectedBankIndex < bankOptions.length
                              ? bankOptions[_selectedBankIndex]
                              : (bankOptions.isNotEmpty
                                  ? bankOptions.first
                                  : {'bank': 'OPAY', 'account': '8131555945', 'name': 'ABDUSSALAM A SIRAJO'});

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (bankOptions.length > 1) ...[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(bankOptions.length, (idx) {
                                      final isSel = idx == _selectedBankIndex;
                                      final opt = bankOptions[idx];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                                        child: ChoiceChip(
                                          label: Text(opt['bank'] ?? 'Bank'),
                                          selected: isSel,
                                          onSelected: (val) {
                                            if (val) setState(() => _selectedBankIndex = idx);
                                          },
                                          selectedColor: const Color(0xFFDCFCE7),
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          labelStyle: TextStyle(
                                            color: isSel ? const Color(0xFF166534) : const Color(0xFF475569),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currentBank['bank'] ?? 'OPAY',
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
                                        currentBank['account'] ?? '8131555945',
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
                                      Clipboard.setData(ClipboardData(text: currentBank['account'] ?? '8131555945'));
                                      showSuccessToast(context, 'Bank account number copied!');
                                    },
                                    icon: Icon(Icons.copy_rounded, color: theme.primaryAccent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Account Name: ${currentBank['name'] ?? "ABDUSSALAM A SIRAJO"}',
                                style: theme.bodySmall.override(fontWeight: FontWeight.w600, color: theme.secondaryText),
                              ),
                              const Divider(height: 24, color: Color(0xFFF1F5F9)),
                              Text(
                                _manualBank?['instructions'] ?? _manualBank?['instruction'] ?? 'Transfer exact amount, include registered phone as reference, and submit receipt to WhatsApp for instant wallet credit.',
                                style: theme.bodySmall.override(color: const Color(0xFF64748B), lineHeight: 1.35),
                              ),
                              if ((_manualBank?['whatsappNotificationPhone'] ?? FFAppState().supportWhatsapp).toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: () async {
                                    final raw = (_manualBank?['whatsappNotificationPhone'] ?? FFAppState().supportWhatsapp).toString().replaceAll(RegExp(r'[^0-9]'), '');
                                    final intlPhone = raw.startsWith('0') ? '234${raw.substring(1)}' : (raw.isEmpty ? '2349047050681' : raw);
                                    final url = Uri.parse('https://wa.me/$intlPhone?text=Hello%20MBKDATASUB,%20I%20have%20transferred%20funds%20to%20your%20manual%20bank%20account%20(${currentBank['bank']}%20${currentBank['account']}).%20Here%20is%20my%20receipt.');
                                    try {
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        showInfoToast(context, 'WhatsApp: $intlPhone');
                                      }
                                    } catch (_) {
                                      showInfoToast(context, 'WhatsApp: $intlPhone');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Submit Receipt on WhatsApp',
                                          style: theme.labelMedium.override(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
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
    final isGenerating = acc.accountNumber == 'Generating...';
    final isMaintenance = acc.accountNumber.toLowerCase().contains('maintenance') || acc.accountNumber.toLowerCase().contains('unavailable');
    final isActionable = !isGenerating && !isMaintenance && acc.accountNumber.trim().length >= 8 && RegExp(r'^[0-9]+$').hasMatch(acc.accountNumber.trim());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: acc.type == 'palmpay' ? const Color(0xFFE0E7FF) : const Color(0xFFFFEDD5),
        ),
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
                  color: isActionable ? const Color(0xFFEEF4FF) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isActionable ? 'AUTOMATED' : (isMaintenance ? 'MAINTENANCE' : 'SYNCING'),
                  style: theme.labelSmall.override(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isActionable ? theme.primaryAccent : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Number', style: theme.labelSmall.override(color: theme.secondaryText)),
                    const SizedBox(height: 2),
                    Text(
                      acc.accountNumber,
                      style: theme.displaySmall.override(
                        fontSize: isActionable ? 22 : 13,
                        fontWeight: FontWeight.w900,
                        color: isActionable ? theme.primary : (isMaintenance ? const Color(0xFFB45309) : theme.secondaryText),
                        letterSpacing: isActionable ? 1.5 : 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActionable)
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
