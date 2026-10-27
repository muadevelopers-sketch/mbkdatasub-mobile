import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../components/provider_logo_widget.dart';
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
  final _amountController = TextEditingController();
  final List<double> _quickAmounts = [50, 100, 200, 400, 500, 1000];

  final List<Map<String, String>> _networks = [
    {'name': 'MTN', 'label': 'MTN', 'color': '0xFFFBBF24'},
    {'name': 'AIRTEL', 'label': 'Airtel', 'color': '0xFFEF4444'},
    {'name': 'GLO', 'label': 'Glo', 'color': '0xFF22C55E'},
    {'name': '9MOBILE', 'label': '9mobile', 'color': '0xFF16A34A'},
  ];

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

    // Discount preview (2.5% for customer, 3% for reseller)
    final appState = Provider.of<FFAppState>(context, listen: false);
    final isReseller = appState.user?.role == 'reseller';
    final discountRate = isReseller ? 0.03 : 0.025;
    final toPay = amount - (amount * discountRate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '$_selectedNetwork Airtime',
        recipient: phone,
        serviceDescription: '₦${amount.toStringAsFixed(0)} (Pay ₦${toPay.toStringAsFixed(2)})',
        amount: toPay,
        onPinConfirmed: (pin) async {
          Navigator.pop(context); // close summary sheet
          final res = await MbkApi.buyAirtime(
            network: _selectedNetwork,
            phone: phone,
            amount: amount,
            pin: pin,
          );

          if (mounted) {
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
          'Buy Airtime',
          style: theme.titleLarge.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Select Network
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Network', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _networks.map((net) {
                        final isSelected = _selectedNetwork == net['name'];
                        return InkWell(
                          onTap: () => setState(() => _selectedNetwork = net['name']!),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 76,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEEF4FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? theme.primaryAccent : const Color(0xFFE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ProviderLogoWidget(
                                  providerName: net['name']!,
                                  size: 38,
                                  borderRadius: 10,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  net['label']!,
                                  textAlign: TextAlign.center,
                                  style: theme.labelSmall.override(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: isSelected ? theme.primaryAccent : theme.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 2: Phone Number Input
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Phone Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                        InkWell(
                          onTap: () {
                            // Quick populate with user's own phone
                            final myPhone = Provider.of<FFAppState>(context, listen: false).user?.phone ?? '';
                            if (myPhone.isNotEmpty) {
                              _phoneController.text = myPhone;
                              showSuccessToast(context, 'Filled with your account phone');
                            }
                          },
                          child: Text(
                            '+ Use My Number',
                            style: theme.titleSmall.override(
                              fontSize: 12,
                              color: theme.primaryAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter phone number (e.g. 08123456789)',
                          hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0A1C6A)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card 3: Quick Select Pills
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Select', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _quickAmounts.map((amt) {
                        final isSelected = _amountController.text == amt.toStringAsFixed(0);
                        return InkWell(
                          onTap: () => setState(() => _amountController.text = amt.toStringAsFixed(0)),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 96) / 3,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEEF4FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? theme.primaryAccent : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              formatNaira(amt),
                              style: theme.titleSmall.override(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? theme.primaryAccent : theme.primaryText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bottom Input & Buy Button Row (Matching Image 5)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: theme.titleLarge.override(fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          hintText: 'Enter amount',
                          hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                          prefixText: '₦ ',
                          prefixStyle: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _onBuyPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Buy',
                        style: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
