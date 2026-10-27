import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class AirtimeToCashPage extends StatefulWidget {
  const AirtimeToCashPage({super.key});

  @override
  State<AirtimeToCashPage> createState() => _AirtimeToCashPageState();
}

class _AirtimeToCashPageState extends State<AirtimeToCashPage> {
  String _selectedNetwork = 'MTN';
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  final Map<String, double> _rates = {
    'MTN': 0.82,
    'AIRTEL': 0.80,
    'GLO': 0.75,
    '9MOBILE': 0.70,
  };

  void _handleSubmit() async {
    final phone = _phoneController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid sender phone number.');
      return;
    }

    if (amount < 1000) {
      showErrorToast(context, 'Minimum conversion amount is ₦1,000.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await MbkApi.submitAirtime2Cash(
      network: _selectedNetwork,
      phone: phone,
      amount: amount,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      final appState = Provider.of<FFAppState>(context, listen: false);
      await appState.refreshTransactions();
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => TransactionStatusModal(
          isSuccess: res.success,
          title: res.success ? 'Request Submitted!' : 'Submission Failed',
          message: res.message,
          onClose: () {
            if (res.success) Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final currentRate = _rates[_selectedNetwork] ?? 0.80;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final payout = amount * currentRate;

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
          'Airtime to Cash (A2C)',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                    Icon(Icons.info_outline_rounded, color: theme.primaryAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Convert your excess airtime into real wallet cash. Funds credit instantly once transfer is verified.',
                        style: theme.bodySmall.override(color: theme.primary, lineHeight: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Network Selector
              Text('Select Network', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: _rates.keys.map((net) {
                  final isSelected = _selectedNetwork == net;
                  final ratePercent = ((_rates[net] ?? 0.8) * 100).toInt();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedNetwork = net),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEEF4FF) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? theme.primaryAccent : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                net,
                                style: theme.titleSmall.override(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? theme.primaryAccent : theme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$ratePercent%',
                                style: theme.labelSmall.override(
                                  fontSize: 10,
                                  color: theme.success,
                                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 18),

              // Sender Phone
              Text('Transferring Phone Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Enter SIM phone number transferring airtime',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0A1C6A)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Airtime Amount
              Text('Airtime Amount (₦)', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: theme.bodyLarge.override(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'Minimum ₦1,000',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.currency_exchange_rounded, color: Color(0xFF0A1C6A)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payout Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Conversion Rate', style: theme.bodyMedium.override(color: theme.secondaryText)),
                        Text('${(currentRate * 100).toInt()}%', style: theme.titleMedium.override(fontWeight: FontWeight.w800, color: theme.success)),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cash Credited to Wallet', style: theme.bodyMedium.override(fontWeight: FontWeight.w600)),
                        Text(
                          formatNaira(payout),
                          style: theme.headlineSmall.override(
                            color: theme.primaryAccent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              FFButtonWidget(
                text: 'Submit Conversion Request',
                onPressed: _isLoading ? null : _handleSubmit,
                showLoadingIndicator: _isLoading,
                options: FFButtonOptions(
                  height: 54,
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
}
