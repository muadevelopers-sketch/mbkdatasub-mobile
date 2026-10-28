import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/data_plan_record.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../components/provider_logo_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  String _selectedNetwork = 'MTN';
  String _selectedType = 'ALL';
  final _phoneController = TextEditingController();
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    _fetchPlansIfNeeded();
  }

  void _fetchPlansIfNeeded() async {
    final appState = Provider.of<FFAppState>(context, listen: false);
    if (appState.dataPlans.isEmpty) {
      setState(() => _isLoadingPlans = true);
      await appState.refreshDataPlans();
      if (mounted) setState(() => _isLoadingPlans = false);
    }
  }

  final List<Map<String, String>> _networks = [
    {'name': 'MTN', 'label': 'MTN'},
    {'name': 'AIRTEL', 'label': 'Airtel'},
    {'name': 'GLO', 'label': 'Glo'},
    {'name': '9MOBILE', 'label': '9mobile'},
  ];

  void _onPlanSelected(DataPlanRecord plan) {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid recipient phone number first.');
      return;
    }

    final appState = Provider.of<FFAppState>(context, listen: false);
    final role = appState.user?.role ?? 'customer';
    final price = plan.priceForRole(role);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '${plan.network} Data Bundle',
        recipient: phone,
        serviceDescription: '${plan.name} (${plan.validity})',
        amount: price,
        onPinConfirmed: (pin) async {
          Navigator.pop(context);
          final res = await MbkApi.buyData(
            network: plan.network,
            phone: phone,
            planId: plan.planId,
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
    final appState = Provider.of<FFAppState>(context);
    final userRole = appState.user?.role ?? 'customer';

    // Filter plans for the chosen network
    final networkPlans = appState.dataPlans
        .where((p) => p.network.toUpperCase() == _selectedNetwork.toUpperCase())
        .toList();

    // Collect available types for this network
    final types = <String>{'ALL'};
    for (final p in networkPlans) {
      types.add(p.type.toUpperCase());
    }

    // Filter by type
    final displayedPlans = networkPlans.where((p) {
      if (_selectedType == 'ALL') return true;
      return p.type.toUpperCase() == _selectedType.toUpperCase();
    }).toList();

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
          'Buy Data',
          style: theme.titleLarge.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoadingPlans
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            onPressed: () async {
              setState(() => _isLoadingPlans = true);
              await Provider.of<FFAppState>(context, listen: false).refreshDataPlans();
              if (mounted) {
                setState(() => _isLoadingPlans = false);
                showSuccessToast(context, 'Data plans refreshed from server!');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Provider.of<FFAppState>(context, listen: false).refreshDataPlans(),
          color: theme.primaryAccent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Network Selector Row (Matching Image 6)
              Text('Network', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _networks.map((net) {
                  final isSelected = _selectedNetwork == net['name'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedNetwork = net['name']!;
                        _selectedType = 'ALL';
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 76,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEEF4FF) : Colors.white,
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
              const SizedBox(height: 16),

              // 2. Phone Number Input with Trailing Bookmark Icon (Matching Image 6)
              Text('Phone Number', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                          hintText: 'Enter recipient number',
                          hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF0A1C6A)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Use My Number Button
                  InkWell(
                    onTap: () {
                      final myPhone = appState.user?.phone ?? '';
                      if (myPhone.isNotEmpty) {
                        _phoneController.text = myPhone;
                        showSuccessToast(context, 'Number filled!');
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.bookmark_add_outlined, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Data Type Horizontal Scrolling Chips (Matching Image 6)
              Text('Data Type', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: types.map((type) {
                    final isSelected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedType = type),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? theme.primary : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            type == 'ALL' ? 'ALL PLANS' : '$_selectedNetwork $type',
                            style: theme.labelSmall.override(
                              color: isSelected ? Colors.white : theme.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Choose a Plan (2-Column Grid matching Image 6)
              Text('Choose a Plan', style: theme.labelMedium.override(color: theme.secondaryText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              displayedPlans.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'No plans active for this selection.',
                          style: theme.bodyMedium.override(color: theme.secondaryText),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedPlans.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                      ),
                      itemBuilder: (context, index) {
                        final plan = displayedPlans[index];
                        final price = plan.priceForRole(userRole);

                        return InkWell(
                          onTap: () => _onPlanSelected(plan),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 3)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  plan.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.titleSmall.override(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: theme.primaryText,
                                    lineHeight: 1.25,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        formatNaira(price),
                                        style: theme.labelSmall.override(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      plan.validity,
                                      style: theme.bodySmall.override(
                                        fontSize: 11,
                                        color: theme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
