import 'package:flutter/material.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import 'home_dashboard_page.dart';
import 'history_page.dart';
import 'referral_page.dart';
import 'profile_page.dart';

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
    HistoryPage(),
    ReferralPage(),
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

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', theme),
              _buildNavItem(1, Icons.history_rounded, 'History', theme),
              _buildNavItem(2, Icons.group_outlined, 'Referral', theme),
              _buildNavItem(3, Icons.person_outline_rounded, 'Profile', theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, FlutterFlowTheme theme) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? theme.primaryAccent : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.labelSmall.override(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.primary : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
