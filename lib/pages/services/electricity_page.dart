import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class ElectricityPage extends StatefulWidget {
  const ElectricityPage({super.key});

  @override
  State<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  String _selectedDisco = 'ikeja-electric';
  String _meterType = 'prepaid';
  final _meterController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _verifiedCustomerName;
  bool _isVerifying = false;

  final List<Map<String, String>> _discos = [
    {'name': 'ikeja-electric', 'label': 'IKEDC (Ikeja)'},
    {'name': 'eko-electric', 'label': 'EKEDC (Eko)'},
    {'name': 'abuja-electric', 'label': 'AEDC (Abuja)'},
    {'name': 'kano-electric', 'label': 'KEDCO (Kano)'},
    {'name': 'ibadan-electric', 'label': 'IBEDC (Ibadan)'},
    {'name': 'kaduna-electric', 'label': 'KAEDCO (Kaduna)'},
    {'name': 'jos-electric', 'label': 'JED (Jos)'},
    {'name': 'port-harcourt-electric', 'label': 'PHED (Port Harcourt)'},
  ];

  void _verifyMeter() async {
    final meter = _meterController.text.trim();
    if (meter.length < 8) {
      showErrorToast(context, 'Please enter a valid meter number.');
      return;
    }

    setState(() => _isVerifying = true);
    final res = await MbkApi.verifyMeter(
      disco: _selectedDisco,
      meterNumber: meter,
      meterType: _meterType,
    );
    setState(() => _isVerifying = false);

    if (res.success && res.data != null) {
      setState(() => _verifiedCustomerName = res.data);
      showSuccessToast(context, 'Meter verified: ${res.data}');
    } else {
      setState(() => _verifiedCustomerName = null);
      showErrorToast(context, res.message);
    }
  }

  void _onProceed() {
    final meter = _meterController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final phone = _phoneController.text.trim();

    if (meter.isEmpty) {
      showErrorToast(context, 'Please enter your meter number.');
      return;
    }

    if (amount < 500 || amount > 500000) {
      showErrorToast(context, 'Electricity recharge must be between ₦500 and ₦500,000.');
      return;
    }

    if (phone.length < 10) {
      showErrorToast(context, 'Please provide a valid phone number for token delivery.');
      return;
    }

    final appState = Provider.of<FFAppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '${_selectedDisco.toUpperCase()} (${_meterType.toUpperCase()})',
        recipient: '$meter ${_verifiedCustomerName != null ? "($_verifiedCustomerName)" : ""}',
        serviceDescription: 'Electricity Token (₦${amount.toStringAsFixed(0)})',
        amount: amount,
        onPinConfirmed: (pin) async {
          Navigator.pop(context);
          final res = await MbkApi.payElectricity(
            disco: _selectedDisco,
            meterNumber: meter,
            meterType: _meterType,
            amount: amount,
            phone: phone,
            pin: pin,
          );

          if (mounted) {
            await appState.refreshWallet();
            await appState.refreshTransactions();
            final token = res.data?['token']?.toString() ?? res.data?['purchased_code']?.toString();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Success!' : 'Transaction Failed',
                message: res.message,
                tokenOrPin: token,
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
          'Electricity Bill Payment',
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
              // DISCO Selector
              Text('Select Electricity DISCO', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDisco,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _discos.map((d) {
                      return DropdownMenuItem<String>(
                        value: d['name'],
                        child: Text(d['label']!, style: theme.titleSmall.override(fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() {
                        _selectedDisco = val;
                        _verifiedCustomerName = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Meter Type Tabs (Prepaid / Postpaid)
              Text('Meter Type', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: ['prepaid', 'postpaid'].map((t) {
                  final isSelected = _meterType == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => setState(() => _meterType = t),
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
                            t.toUpperCase(),
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

              // Meter Number Input + Verify Button
              Text('Meter Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _meterController,
                        keyboardType: TextInputType.number,
                        style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter 11-digit Meter Number',
                          hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.speed_rounded, color: Color(0xFF0A1C6A)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton(
                        onPressed: _isVerifying ? null : _verifyMeter,
                        child: _isVerifying
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Verify', style: theme.titleSmall.override(color: theme.primaryAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Name Banner
              if (_verifiedCustomerName != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: theme.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Customer: $_verifiedCustomerName',
                          style: theme.titleSmall.override(color: const Color(0xFF166534), fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Amount Field
              Text('Recharge Amount (₦)', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 18),

              // Recipient Phone Number
              Text('Phone Number (For Token SMS)', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
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
                    hintText: 'Enter phone number',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0A1C6A)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Proceed Button
              FFButtonWidget(
                text: 'Proceed to Payment',
                onPressed: _onProceed,
                options: FFButtonOptions(
                  height: 54,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
