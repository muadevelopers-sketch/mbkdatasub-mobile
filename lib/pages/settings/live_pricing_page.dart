import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/data_plan_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class LivePricingPage extends StatefulWidget {
  const LivePricingPage({super.key});

  @override
  State<LivePricingPage> createState() => _LivePricingPageState();
}

class _LivePricingPageState extends State<LivePricingPage> {
  String _selectedNetwork = 'ALL';
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final plans = appState.dataPlans;
    final userRole = appState.user?.role ?? 'customer';
    final query = _searchController.text.toLowerCase().trim();

    final filtered = plans.where((p) {
      if (_selectedNetwork != 'ALL' && p.network.toUpperCase() != _selectedNetwork) {
        return false;
      }
      if (query.isNotEmpty) {
        return p.name.toLowerCase().contains(query) || p.type.toLowerCase().contains(query);
      }
      return true;
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
          'Live Telecom Pricing',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search plans by size or type...',
                    hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Network Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: ['ALL', 'MTN', 'AIRTEL', 'GLO', '9MOBILE'].map((net) {
                  final isSelected = _selectedNetwork == net;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedNetwork = net),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? theme.primary : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          net,
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
            const SizedBox(height: 14),

            // Pricing List
            Expanded(
              child: RefreshIndicator(
                color: theme.primaryAccent,
                onRefresh: () => appState.refreshDataPlans(),
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No active plans found for this filter.',
                          style: theme.bodyMedium.override(color: theme.secondaryText),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final plan = filtered[index];
                          final customerPrice = plan.userPrice;
                          final resellerPrice = plan.resellerPrice;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    plan.network,
                                    style: theme.labelSmall.override(
                                      fontWeight: FontWeight.w900,
                                      color: theme.primaryAccent,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: theme.titleSmall.override(
                                          fontWeight: FontWeight.w700,
                                          color: theme.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Type: ${plan.type} • ${plan.validity}',
                                        style: theme.bodySmall.override(
                                          fontSize: 11,
                                          color: theme.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatNaira(customerPrice),
                                      style: theme.titleMedium.override(
                                        fontWeight: FontWeight.w800,
                                        color: theme.primary,
                                      ),
                                    ),
                                    if (userRole == 'reseller') ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'Reseller: ${formatNaira(resellerPrice)}',
                                        style: theme.labelSmall.override(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: theme.success,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
