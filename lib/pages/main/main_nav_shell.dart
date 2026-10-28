import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'home_dashboard_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../../components/service_grid_widget.dart';
import '../services/get_your_app_page.dart';
import '../settings/live_pricing_page.dart';
import '../wallet/add_money_page.dart';

class MainNavShell extends StatefulWidget {
  const MainNavShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeDashboardPage(),
    ServicesCatalogPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1F293D) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : const Color(0x0C000000),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', theme, isDark),
              _buildNavItem(1, Icons.grid_view_rounded, 'Services', theme, isDark),
              _buildNavItem(2, Icons.access_time_rounded, 'History', theme, isDark),
              _buildNavItem(3, Icons.person_outline_rounded, 'Profile', theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    FlutterFlowTheme theme,
    bool isDark,
  ) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A).withOpacity(0.7) : const Color(0xFFE0F2FE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: theme.labelSmall.override(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesCatalogPage extends StatelessWidget {
  const ServicesCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Services',
          style: theme.titleLarge.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ServiceGridWidget(),
              const SizedBox(height: 28),

              // Additional Quick Actions
              Text(
                'Financial & Development Services',
                style: theme.titleMedium.override(
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 14),

              _buildServiceRow(
                context,
                title: 'Get Your App & Website',
                subtitle: 'Launch your branded telecom VTU portal in 24 hours',
                icon: Icons.rocket_launch_rounded,
                iconColor: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GetYourAppPage())),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildServiceRow(
                context,
                title: 'Instant Automated Wallet Funding',
                subtitle: 'Dedicated PalmPay & Paga virtual accounts',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyPage())),
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildServiceRow(
                context,
                title: 'Live Catalog Pricing',
                subtitle: 'Check real-time rates for customer, reseller & API roles',
                icon: Icons.sell_outlined,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LivePricingPage())),
                theme: theme,
                isDark: isDark,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    required FlutterFlowTheme theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.titleSmall.override(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.labelSmall.override(
                      color: theme.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.secondaryText, size: 20),
          ],
        ),
      ),
    );
  }
}
