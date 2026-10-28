import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../components/provider_logo_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class AlphaSmilePage extends StatefulWidget {
  const AlphaSmilePage({super.key, this.initialTab = 0});
  final int initialTab; // 0 = Alpha Topup, 1 = Smile 4G LTE

  @override
  State<AlphaSmilePage> createState() => _AlphaSmilePageState();
}

class _AlphaSmilePageState extends State<AlphaSmilePage> {
  late int _activeTab;
  final _alphaPhoneController = TextEditingController();
  final _alphaAmountController = TextEditingController();

  final _smileAccountController = TextEditingController();
  final _smileAmountController = TextEditingController();
  String _smileType = 'data';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  void _onAlphaBuy() {
    final phone = _alphaPhoneController.text.trim();
    final amount = double.tryParse(_alphaAmountController.text) ?? 0.0;

    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid Glo phone number.');
      return;
    }
    if (amount < 100) {
      showErrorToast(context, 'Minimum Alpha topup is ₦100.');
      return;
    }

    // 3.5% wholesale discount
    final toPay = amount - (amount * 0.035);
    final appState = Provider.of<FFAppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: 'Glo Alpha Wholesale Topup',
        recipient: phone,
        serviceDescription: '₦${amount.toStringAsFixed(0)} (3.5% wholesale discount)',
        amount: toPay,
        onPinConfirmed: (pin) async {
          final res = await MbkApi.buyAlphaTopup(
            phone: phone,
            amount: amount,
            pin: pin,
          );

          if (mounted) {
            Navigator.pop(context); // Close summary sheet after processing completes
            await appState.refreshWallet();
            await appState.refreshTransactions();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Success!' : 'Transaction Failed',
                message: res.message,
                onClose: () {
                  if (res.success) Navigator.pop(context);
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _onSmileBuy() {
    final account = _smileAccountController.text.trim();
    final amount = double.tryParse(_smileAmountController.text) ?? 0.0;

    if (account.length < 8) {
      showErrorToast(context, 'Please enter a valid Smile Account ID or Phone.');
      return;
    }
    if (amount < 500) {
      showErrorToast(context, 'Minimum Smile recharge is ₦500.');
      return;
    }

    final appState = Provider.of<FFAppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: 'Smile 4G LTE (${_smileType.toUpperCase()})',
        recipient: account,
        serviceDescription: 'Smile ${_smileType.toUpperCase()} Recharge',
        amount: amount,
        onPinConfirmed: (pin) async {
          final res = await MbkApi.buySmile(
            accountId: account,
            type: _smileType,
            amount: amount,
            pin: pin,
          );

          if (mounted) {
            Navigator.pop(context); // Close summary sheet after processing completes
            await appState.refreshWallet();
            await appState.refreshTransactions();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Success!' : 'Transaction Failed',
                message: res.message,
                onClose: () {
                  if (res.success) Navigator.pop(context);
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
          _activeTab == 0 ? 'Glo Alpha Wholesale' : 'Smile 4G LTE Recharge',
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
              // Segmented Tab Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? theme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Glo Alpha Topup',
                            style: theme.labelMedium.override(
                              color: _activeTab == 0 ? Colors.white : theme.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTab = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? theme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Smile 4G LTE',
                            style: theme.labelMedium.override(
                              color: _activeTab == 1 ? Colors.white : theme.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_activeTab == 0) ...[
                // Glo Alpha Topup Form
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.discount_rounded, color: theme.success, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Enjoy 3.5% wholesale discount on all Glo Alpha airtime purchases.',
                          style: theme.bodySmall.override(color: const Color(0xFF166534), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text('Glo Phone Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _alphaPhoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) {
                      final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                      if (clean.length == 11 || (clean.startsWith('234') && clean.length == 13)) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter Glo phone number',
                      hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ProviderLogoWidget(providerName: 'GLO', size: 26, borderRadius: 6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text('Topup Amount (₦)', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _alphaAmountController,
                    keyboardType: TextInputType.number,
                    style: theme.bodyLarge.override(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Minimum ₦100',
                      hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF0A1C6A)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FFButtonWidget(
                  text: 'Proceed to Purchase',
                  onPressed: _onAlphaBuy,
                  options: FFButtonOptions(
                    height: 54,
                    color: theme.primary,
                    textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ] else ...[
                // Smile 4G LTE Form
                Text('Smile Account ID / Phone', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _smileAccountController,
                    keyboardType: TextInputType.number,
                    style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Enter Smile Account number',
                      hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ProviderLogoWidget(providerName: 'SMILE', size: 26, borderRadius: 6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                Text('Recharge Type', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: ['data', 'voice'].map((st) {
                    final isSelected = _smileType == st;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () => setState(() => _smileType = st),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? theme.primary : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? theme.primary : const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              'Smile ${st.toUpperCase()}',
                              style: theme.labelMedium.override(
                                color: isSelected ? Colors.white : theme.primaryText,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                Text('Amount (₦)', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _smileAmountController,
                    keyboardType: TextInputType.number,
                    style: theme.bodyLarge.override(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Minimum ₦500',
                      hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.attach_money_rounded, color: Color(0xFF0A1C6A)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                FFButtonWidget(
                  text: 'Recharge Smile Account',
                  onPressed: _onSmileBuy,
                  options: FFButtonOptions(
                    height: 54,
                    color: theme.primary,
                    textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
