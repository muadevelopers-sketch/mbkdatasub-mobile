import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';

class ExamPinPage extends StatefulWidget {
  const ExamPinPage({super.key});

  @override
  State<ExamPinPage> createState() => _ExamPinPageState();
}

class _ExamPinPageState extends State<ExamPinPage> {
  String _selectedExam = 'WAEC';
  int _quantity = 1;

  final Map<String, double> _examPrices = {
    'WAEC': 5400.0,
    'NECO': 2400.0,
    'NABTEB': 1200.0,
    'JAMB': 6500.0,
  };

  void _onProceed() {
    final unitPrice = _examPrices[_selectedExam] ?? 5400.0;
    final total = unitPrice * _quantity;
    final appState = Provider.of<FFAppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '$_selectedExam Result Checker PIN',
        recipient: '$_quantity Quantity PIN(s)',
        serviceDescription: '$_quantity x $_selectedExam (₦${unitPrice.toStringAsFixed(0)} each)',
        amount: total,
        onPinConfirmed: (pin) async {
          Navigator.pop(context);
          final res = await MbkApi.buyExamPin(
            examName: _selectedExam,
            quantity: _quantity,
            pin: pin,
          );

          if (mounted) {
            await appState.refreshWallet();
            await appState.refreshTransactions();

            String? tokenSummary;
            if (res.data?['pins'] is List) {
              final list = res.data!['pins'] as List;
              tokenSummary = list.map((p) => '${p['serial']}: ${p['pin']}').join('\n');
            }

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Success!' : 'Transaction Failed',
                message: res.message,
                tokenOrPin: tokenSummary,
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
    final unitPrice = _examPrices[_selectedExam] ?? 5400.0;
    final total = unitPrice * _quantity;

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
          'Exam Result PINs',
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
              // Examination Board Selector
              Text('Select Examination Board', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: _examPrices.keys.map((exam) {
                  final isSelected = _selectedExam == exam;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedExam = exam),
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
                            exam,
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
              const SizedBox(height: 20),

              // Pricing Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price Per PIN', style: theme.bodyMedium.override(color: theme.secondaryText)),
                        Text(formatNaira(unitPrice), style: theme.titleLarge.override(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 28, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Quantity', style: theme.bodyMedium.override(color: theme.secondaryText)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              icon: const Icon(Icons.remove_circle_outline_rounded),
                              color: theme.primary,
                            ),
                            Text('$_quantity', style: theme.titleLarge.override(fontWeight: FontWeight.w800)),
                            IconButton(
                              onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                              icon: const Icon(Icons.add_circle_outline_rounded),
                              color: theme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 28, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: theme.titleMedium.override(fontWeight: FontWeight.w700)),
                        Text(
                          formatNaira(total),
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
              const SizedBox(height: 32),

              FFButtonWidget(
                text: 'Generate Exam PIN(s)',
                onPressed: _onProceed,
                options: FFButtonOptions(
                  height: 54,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
