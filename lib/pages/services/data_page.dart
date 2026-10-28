import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/data_plan_record.dart';
import '../../components/purchase_summary_bottom_sheet.dart';
import '../../components/transaction_status_modal.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  String _selectedNetwork = 'MTN';
  String _selectedCategory = 'ALL';
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  DataPlanRecord? _selectedPlan;
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
    final myPhone = appState.user?.phoneNumber ?? '';
    if (myPhone.isNotEmpty) {
      setState(() {
        _phoneController.text = myPhone;
      });
    } else {
      showInfoToast(context, 'No registered phone number found on profile.');
    }
  }

  void _onProceedToPay() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      showErrorToast(context, 'Please enter a valid recipient phone number first.');
      return;
    }

    if (_selectedPlan == null) {
      showErrorToast(context, 'Please choose a data bundle to continue.');
      return;
    }

    final plan = _selectedPlan!;
    final appState = Provider.of<FFAppState>(context, listen: false);
    final role = appState.user?.role ?? 'customer';
    final price = plan.priceForRole(role);
    final walletBal = appState.wallet.balance;

    if (walletBal < price) {
      showDialog(
        context: context,
        builder: (_) => InsufficientBalanceDialog(
          requiredAmount: price,
          currentBalance: walletBal,
          serviceTitle: '${plan.network} ${plan.name}',
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseSummaryBottomSheet(
        provider: '${plan.network} DATA TOPUP',
        recipient: phone,
        serviceDescription: '${plan.name} (${plan.validity})',
        amount: price,
        onPinConfirmed: (pin) async {
          final res = await MbkApi.buyData(
            network: plan.network,
            phone: phone,
            planId: plan.planId,
            pin: pin,
          );

          if (mounted) {
            Navigator.pop(context); // Close bottom sheet
            await appState.refreshWallet();
            await appState.refreshTransactions();

            showDialog(
              context: context,
              builder: (_) => TransactionStatusModal(
                isSuccess: res.success,
                title: res.success ? 'Transaction Successful!' : 'Transaction Failed',
                message: res.message,
                amount: price,
                serviceTitle: '${plan.network} Data Topup',
                recipient: '$phone (${plan.network})',
                reference: res.data?['reference']?.toString() ?? 'DAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                updatedBalance: appState.wallet.balance,
                onClose: () {
                  if (res.success) {
                    setState(() {
                      _selectedPlan = null;
                    });
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
    final userRole = appState.user?.role ?? 'customer';

    // Filter plans for chosen network
    final networkPlans = appState.dataPlans
        .where((p) => p.network.toUpperCase() == _selectedNetwork.toUpperCase())
        .toList();

    // Category pills
    final categories = ['ALL', 'SME', 'CORPORATE', 'GIFTING'];

    // Filter plans by category and search
    final query = _searchController.text.trim().toLowerCase();
    final displayedPlans = networkPlans.where((p) {
      final matchesCategory = _selectedCategory == 'ALL' ||
          p.type.toUpperCase() == _selectedCategory.toUpperCase();
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.type.toLowerCase().contains(query) ||
          p.validity.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    final selectedPrice = _selectedPlan != null ? _selectedPlan!.priceForRole(userRole) : 0.0;

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
              'Buy Mobile Data',
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
                    // Top Available Balance Card
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
                                'Available Balance',
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
                              await appState.refreshDataPlans();
                              if (context.mounted) {
                                showSuccessToast(context, 'Wallet & plans updated');
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

                    // 1. SELECT MOBILE OPERATOR
                    Text(
                      '1. SELECT MOBILE OPERATOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4 Network Cards
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
                                  _selectedPlan = null;
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
                                    Row(
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
                                      ],
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

                    // Phone Input Field with Paste Pill
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

                    // 3. CHOOSE BUNDLE
                    Text(
                      '3. CHOOSE BUNDLE (${displayedPlans.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search Plan Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 18, color: theme.secondaryText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.primaryText,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search plan (e.g. 1GB, 2GB, SME, CG)...',
                                hintStyle: TextStyle(
                                  color: theme.secondaryText.withOpacity(0.6),
                                  fontSize: 12.5,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Filter Pills: ALL, SME, CORPORATE, GIFTING
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSel = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? const Color(0xFF0284C7)
                                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                    color: isSel ? Colors.white : theme.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // List of Plans
                    if (_isLoadingPlans)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                        ),
                      )
                    else if (displayedPlans.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(30),
                        alignment: Alignment.center,
                        child: Text(
                          'No bundles available for the selected filter.',
                          style: TextStyle(color: theme.secondaryText, fontSize: 13),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedPlans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final plan = displayedPlans[index];
                          final isSel = _selectedPlan?.planId == plan.planId;
                          final price = plan.priceForRole(userRole);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPlan = plan;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: theme.secondaryBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel
                                      ? const Color(0xFF0284C7)
                                      : (isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0)),
                                  width: isSel ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            plan.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: theme.primaryText,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0F2FE),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              plan.type.toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF0369A1),
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${plan.validity} • Automated Fast Topup',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formatNaira(price),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isSel ? const Color(0xFF0284C7) : theme.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar: Total to debit + Pay button
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
                          'TOTAL TO DEBIT',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: theme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatNaira(selectedPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _selectedPlan != null ? const Color(0xFF0284C7) : theme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _onProceedToPay,
                          icon: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
                          label: Text(
                            _selectedPlan != null
                                ? 'Authorize Topup'
                                : 'Select Bundle',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPlan != null
                                ? const Color(0xFF0284C7)
                                : const Color(0xFF93C5FD),
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
