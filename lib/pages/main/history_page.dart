import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/app_state.dart';
import '../../backend/schema/struct/transaction_record.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../wallet/receipt_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  int _activeTab = 0; // 0 = General, 1 = Funding, 2 = Failed

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final query = _searchController.text.toLowerCase().trim();

    final allTx = appState.transactions;
    final filtered = allTx.where((t) {
      if (_activeTab == 1 && !t.isCredit) return false;
      if (_activeTab == 2 && !t.isFailed) return false;
      if (query.isNotEmpty) {
        final matchTitle = t.title.toLowerCase().contains(query);
        final matchRef = t.reference.toLowerCase().contains(query);
        final matchRec = t.recipient.toLowerCase().contains(query);
        return matchTitle || matchRef || matchRec;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          // Top Curved Royal Navy Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.primaryAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Text(
                  'Transaction History',
                  style: theme.headlineSmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),

                // Sub-tabs Pill (General / Funding / Failed)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'General', theme),
                      _buildTabItem(1, 'Funding', theme),
                      _buildTabItem(2, 'Failed', theme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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
                  hintText: 'Search history by title, recipient, or ref...',
                  hintStyle: theme.labelMedium.override(color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Transaction List or Empty State
          Expanded(
            child: RefreshIndicator(
              color: theme.primaryAccent,
              onRefresh: () => appState.refreshTransactions(),
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 64, color: const Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: theme.titleMedium.override(
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your completed bills & purchases will appear here.',
                            style: theme.bodySmall.override(color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
                        return _buildTxCard(tx, theme, context);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, FlutterFlowTheme theme) {
    final bool isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: theme.labelMedium.override(
              color: isSelected ? theme.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTxCard(TransactionRecord tx, FlutterFlowTheme theme, BuildContext context) {
    final isSuccess = tx.isSuccess;
    final isCredit = tx.isCredit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReceiptPage(transaction: tx)),
          );
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSuccess
                ? (isCredit ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF))
                : const Color(0xFFFEE2E2),
          ),
          child: Icon(
            isSuccess
                ? (isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded)
                : Icons.close_rounded,
            size: 22,
            color: isSuccess
                ? (isCredit ? theme.success : theme.primaryAccent)
                : theme.error,
          ),
        ),
        title: Text(
          tx.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.titleSmall.override(
            fontWeight: FontWeight.w700,
            color: theme.primaryText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            formatDateTime(tx.date),
            style: theme.bodySmall.override(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${formatNaira(tx.amount)}',
                  style: theme.titleSmall.override(
                    fontWeight: FontWeight.w800,
                    color: isCredit ? theme.success : theme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isSuccess ? 'Success' : 'Failed',
                    style: theme.labelSmall.override(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSuccess ? theme.success : theme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
