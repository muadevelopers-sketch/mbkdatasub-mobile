import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class CablePage extends StatefulWidget {
  const CablePage({super.key});

  @override
  State<CablePage> createState() => _CablePageState();
}

class _CablePageState extends State<CablePage> {
  String _selectedProvider = 'gotv';
  final _smartcardController = TextEditingController();
  String? _verifiedCustomerName;
  bool _isVerifying = false;

  final Map<String, List<Map<String, dynamic>>> _cablePackages = {
    'gotv': [
      {'name': 'GOtv Smallie', 'id': 'gotv-smallie', 'price': 1575.0},
      {'name': 'GOtv Jinja', 'id': 'gotv-jinja', 'price': 3300.0},
      {'name': 'GOtv Jolli', 'id': 'gotv-jolli', 'price': 4850.0},
      {'name': 'GOtv Max', 'id': 'gotv-max', 'price': 7200.0},
      {'name': 'GOtv Supa', 'id': 'gotv-supa', 'price': 9600.0},
      {'name': 'GOtv Supa Plus', 'id': 'gotv-supa-plus', 'price': 15700.0},
    ],
    'dstv': [
      {'name': 'DStv Padi', 'id': 'dstv-padi', 'price': 3600.0},
      {'name': 'DStv Yanga', 'id': 'dstv-yanga', 'price': 5100.0},
      {'name': 'DStv Confam', 'id': 'dstv-confam', 'price': 9300.0},
      {'name': 'DStv Compact', 'id': 'dstv-compact', 'price': 15700.0},
      {'name': 'DStv Compact Plus', 'id': 'dstv-compact-plus', 'price': 25000.0},
      {'name': 'DStv Premium', 'id': 'dstv-premium', 'price': 37000.0},
    ],
    'startimes': [
      {'name': 'Nova (Dish/Antenna)', 'id': 'startimes-nova', 'price': 1700.0},
      {'name': 'Basic (Antenna)', 'id': 'startimes-basic', 'price': 3000.0},
      {'name': 'Smart (Dish)', 'id': 'startimes-smart', 'price': 3800.0},
      {'name': 'Classic (Antenna)', 'id': 'startimes-classic', 'price': 4500.0},
      {'name': 'Super (Dish)', 'id': 'startimes-super', 'price': 7500.0},
    ],
  };

  Map<String, dynamic>? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _selectedPackage = _cablePackages[_selectedProvider]?.first;
  }

  void _verifyIUC() async {
    final smartcard = _smartcardController.text.trim();
    if (smartcard.length < 9) {
      showErrorToast(context, 'Please enter a valid 10 or 11-digit IUC/Smartcard number.');
      return;
    }

    setState(() => _isVerifying = true);
    final res = await MbkApi.verifySmartcard(provider: _selectedProvider, smartcard: smartcard);
    setState(() => _isVerifying = false);

    if (res.success && res.data != null) {
      setState(() => _verifiedCustomerName = res.data);
      showSuccessToast(context, 'Smartcard verified: ${res.data}');
    } else {
      setState(() => _verifiedCustomerName = null);
      showErrorToast(context, res.message);
    }
  }

  void _onProceed() {
    final smartcard = _smartcardController.text.trim();
    if (smartcard.isEmpty) {
      showErrorToast(context, 'Please enter your IUC / Smartcard number.');
      return;
    }

    if (_selectedPackage == null) {
      showErrorToast(context, 'Please choose a package bouquet.');
      return;
    }

    final appState = Provider.of<FFAppState>(context, listen: false);
    final price = (_selectedPackage!['price'] as num).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '${_selectedProvider.toUpperCase()} Cable TV',
        recipient: '$smartcard ${_verifiedCustomerName != null ? "($_verifiedCustomerName)" : ""}',
        serviceDescription: _selectedPackage!['name'],
        amount: price,
        onPinConfirmed: (pin) async {
          Navigator.pop(context);
          final res = await MbkApi.renewCable(
            provider: _selectedProvider,
            smartcard: smartcard,
            packageName: _selectedPackage!['name'],
            packageId: _selectedPackage!['id'],
            price: price,
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
    final packages = _cablePackages[_selectedProvider] ?? [];

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
          'Cable TV Subscription',
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
              // Provider Selector
              Text('Select Provider', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: ['gotv', 'dstv', 'startimes'].map((p) {
                  final isSelected = _selectedProvider == p;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedProvider = p;
                            _selectedPackage = _cablePackages[p]?.first;
                            _verifiedCustomerName = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEEF4FF) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? theme.primaryAccent : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            style: theme.titleSmall.override(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? theme.primaryAccent : theme.primaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Smartcard Number Card
              Text('Smartcard / IUC Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
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
                        controller: _smartcardController,
                        keyboardType: TextInputType.number,
                        style: theme.bodyLarge.override(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Enter Smartcard / IUC digits',
                          hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.tv_rounded, color: Color(0xFF0A1C6A)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton(
                        onPressed: _isVerifying ? null : _verifyIUC,
                        child: _isVerifying
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Verify', style: theme.titleSmall.override(color: theme.primaryAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Name Banner (if verified)
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
                          style: theme.titleSmall.override(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Package Bouquet Selector
              Text('Choose Bouquet / Package', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Column(
                children: packages.map((pkg) {
                  final isSelected = _selectedPackage?['id'] == pkg['id'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.primaryAccent : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedPackage = pkg),
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: isSelected ? theme.primaryAccent : const Color(0xFF94A3B8),
                      ),
                      title: Text(
                        pkg['name'],
                        style: theme.titleSmall.override(
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                      trailing: Text(
                        formatNaira(pkg['price']),
                        style: theme.titleMedium.override(
                          fontWeight: FontWeight.w800,
                          color: isSelected ? theme.primaryAccent : theme.primaryText,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

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
