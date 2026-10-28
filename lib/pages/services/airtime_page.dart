import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({super.key});

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _AirtimePageState extends State<AirtimePage> {
  String _selectedNetwork = 'MTN';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController(text: '100');
  final List<double> _quickAmounts = [50, 100, 200, 500, 1000, 2000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<FFAppState>(context, listen: false).refreshWallet();
      }
    });
  }

  final List<Map<String, dynamic>> _networks = [
    {
      'id': 'MTN',
      'label': 'MTN',
      'color': const Color(0xFFFBBF24),
      'selectedBg': const Color(0xFFFEF3C7),
      'darkSelectedBg': const Color(0xFF451A03),
    },
    {
      'id': 'AIRTEL',
      'label': 'Airtel',
      'color': const Color(0xFFEF4444),
      'selectedBg': const Color(0xFFFEE2E2),
      'darkSelectedBg': const Color(0xFF450A0A),
    },
    {
      'id': 'GLO',
      'label': 'Glo',
      'color': const Color(0xFF10B981),
      'selectedBg': const Color(0xFFDCFCE7),
      'darkSelectedBg': const Color(0xFF064E3B),
    },
    {
      'id': '9MOBILE',
      'label': '9mobile',
      'color': const Color(0xFF059669),
      'selectedBg': const Color(0xFFD1FAE5),
      'darkSelectedBg': const Color(0xFF064E3B),
    },
  ];

  void _pastePhoneNumber() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      final clean = data.text!.replaceAll(RegExp(r'[^0-9]'), '');
      setState(() {
        _phoneController.text = clean;
      });
    }
  }

  void _useMyPhone() {
    final appState = Provider.of<FFAppState>(context, listen: false);
    final myPhone = appState.user?.phone ?? '';
    if (myPhone.isNotEmpty) {
      setState(() {
        _phoneController.text = myPhone;
      });
    } else {
      showInfoToast(context, 'No registered phone number found on profile.');
    }
  }

  void _onBuyPressed() {
    final phone = _phoneController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid recipient phone number.');
      return;
    }

    if (amount < 50 || amount > 50000) {
      showErrorToast(context, 'Airtime amount must be between ₦50 and ₦50,000.');
      return;
    }

    final appState = Provider.of<FFAppState>(context, listen: false);
    final isReseller = appState.user?.role == 'reseller';
    final discountRate = isReseller ? 0.03 : 0.02;
    final toPay = amount - (amount * discountRate);
    final walletBal = appState.wallet.balance;

    if (walletBal < toPay) {
      showDialog(
        context: context,
        builder: (_) => InsufficientBalanceDialog(
          requiredAmount: toPay,
          currentBalance: walletBal,
          serviceTitle: '$_selectedNetwork Airtime VTU (₦${amount.toStringAsFixed(0)})',
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '$_selectedNetwork AIRTIME VTU',
        recipient: phone,
        serviceDescription: '₦${amount.toStringAsFixed(0)} (Pay ${formatNaira(toPay)})',
        amount: toPay,
        onPinConfirmed: (pin) async {
          final res = await MbkApi.buyAirtime(
            network: _selectedNetwork,
            phone: phone,
            amount: amount,
            pin: pin,
          );

          if (mounted) {
            Navigator.pop(context); // Close summary sheet
            await appState.refreshWallet();
            await appState.refreshTransactions();

            showDialog(
              context: context,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Transaction Successful!' : 'Transaction Failed',
                message: res.message,
                amount: amount,
                serviceTitle: '$_selectedNetwork Airtime VTU',
                recipient: '$phone ($_selectedNetwork)',
                reference: res.data?['reference']?.toString() ??
                    'AIR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                updatedBalance: appState.wallet.balance,
                onClose: () {
                  if (res.success) {
                    Navigator.pop(context);
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
    final appState = Provider.of<FFAppState>(context);
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final isReseller = appState.user?.role == 'reseller';
    final discountRate = isReseller ? 0.03 : 0.02;
    final toPay = amount > 0 ? (amount - (amount * discountRate)) : 0.0;

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
        title: Column(
          children: [
            Text(
              'Airtime VTU Recharge',
              style: theme.titleMedium.override(
                fontWeight: FontWeight.w800,
                color: theme.primaryText,
                fontSize: 16,
              ),
            ),
            Text(
              'Instant Automated 24/7 Dispatch',
              style: theme.labelSmall.override(
                color: theme.secondaryText,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Balance:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.secondaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatNaira(appState.wallet.balance),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              await appState.refreshWallet();
                              if (context.mounted) {
                                showSuccessToast(context, 'Wallet updated');
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFBAE6FD),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Refresh',
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
                    ),

                    const SizedBox(height: 18),

                    // 1. SELECT NETWORK
                    Text(
                      '1. SELECT NETWORK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: _networks.map((net) {
                        final isSel = _selectedNetwork == net['id'];
                        final color = net['color'] as Color;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedNetwork = net['id'];
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 72,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? (isDark ? net['darkSelectedBg'] : net['selectedBg'])
                                      : theme.secondaryBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSel
                                        ? color
                                        : (isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0)),
                                    width: isSel ? 1.8 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: isSel
                                          ? const Icon(Icons.check, size: 9, color: Colors.black)
                                          : null,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      net['label'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isSel ? theme.primaryText : theme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 2. RECIPIENT PHONE NUMBER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2. RECIPIENT PHONE NUMBER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: theme.secondaryText,
                          ),
                        ),
                        InkWell(
                          onTap: _useMyPhone,
                          child: const Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                              SizedBox(width: 3),
                              Text(
                                'Use My Phone',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone_android_rounded, size: 20, color: theme.secondaryText),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryText,
                              ),
                              decoration: InputDecoration(
                                hintText: '09023456780',
                                hintStyle: TextStyle(
                                  color: theme.secondaryText.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _pastePhoneNumber,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.content_paste_rounded, size: 13, color: Color(0xFF0284C7)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Paste',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. ENTER AMOUNT
                    Text(
                      '3. RECHARGE AMOUNT (₦50 - ₦50,000)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '₦',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.primaryText,
                              ),
                              decoration: InputDecoration(
                                hintText: '100',
                                hintStyle: TextStyle(
                                  color: theme.secondaryText.withOpacity(0.6),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(discountRate * 100).toStringAsFixed(1)}% OFF',
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Amounts
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((q) {
                        final isSel = _amountController.text == q.toStringAsFixed(0);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _amountController.text = q.toStringAsFixed(0);
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF0284C7)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₦${q.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : theme.primaryText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL TO PAY',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: theme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatNaira(toPay),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _onBuyPressed,
                          icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                          label: Text(
                            amount > 0
                                ? 'Pay ${formatNaira(toPay)} with 1-Tap Biometric'
                                : 'Enter Amount',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
