import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../pages/services/airtime_page.dart';
import '../pages/services/data_page.dart';
import '../pages/services/cable_page.dart';
import '../pages/services/electricity_page.dart';
import '../pages/services/exam_pin_page.dart';
import '../pages/services/airtime_to_cash_page.dart';
import '../pages/services/alpha_smile_page.dart';
import '../pages/wallet/add_money_page.dart';

class ServiceItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color lightBg;
  final Color darkBg;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeBgLight;
  final Color? badgeBgDark;
  final Widget targetPage;

  ServiceItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.lightBg,
    required this.darkBg,
    this.badge,
    this.badgeColor,
    this.badgeBgLight,
    this.badgeBgDark,
    required this.targetPage,
  });
}

class ServiceGridWidget extends StatelessWidget {
  const ServiceGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;

    final List<ServiceItem> services = [
      ServiceItem(
        title: 'Buy Data',
        icon: Icons.wifi_rounded,
        iconColor: const Color(0xFF2563EB),
        lightBg: const Color(0xFFEFF6FF),
        darkBg: const Color(0xFF1E293B),
        badge: 'FAST',
        badgeColor: const Color(0xFF1D4ED8),
        badgeBgLight: const Color(0xFFDBEAFE),
        badgeBgDark: const Color(0xFF1E3A8A),
        targetPage: const DataPage(),
      ),
      ServiceItem(
        title: 'Buy Airtime',
        icon: Icons.phone_android_rounded,
        iconColor: const Color(0xFFEA580C),
        lightBg: const Color(0xFFFFF7ED),
        darkBg: const Color(0xFF2D201A),
        badge: 'CASHBACK',
        badgeColor: const Color(0xFFC2410C),
        badgeBgLight: const Color(0xFFFFEDD5),
        badgeBgDark: const Color(0xFF7C2D12),
        targetPage: const AirtimePage(),
      ),
      ServiceItem(
        title: 'Fund Wallet',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF7C3AED),
        lightBg: const Color(0xFFF5F3FF),
        darkBg: const Color(0xFF241C35),
        badge: 'INSTANT',
        badgeColor: const Color(0xFF6D28D9),
        badgeBgLight: const Color(0xFFEDE9FE),
        badgeBgDark: const Color(0xFF581C87),
        targetPage: const AddMoneyPage(),
      ),
      ServiceItem(
        title: 'Airtime2Cash',
        icon: Icons.swap_horiz_rounded,
        iconColor: const Color(0xFF16A34A),
        lightBg: const Color(0xFFF0FDF4),
        darkBg: const Color(0xFF172D1E),
        badge: '82%',
        badgeColor: const Color(0xFF15803D),
        badgeBgLight: const Color(0xFFDCFCE7),
        badgeBgDark: const Color(0xFF14532D),
        targetPage: const AirtimeToCashPage(),
      ),
      ServiceItem(
        title: 'Cable TV',
        icon: Icons.tv_rounded,
        iconColor: const Color(0xFF0284C7),
        lightBg: const Color(0xFFF0F9FF),
        darkBg: const Color(0xFF132738),
        targetPage: const CablePage(),
      ),
      ServiceItem(
        title: 'Electricity',
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFD97706),
        lightBg: const Color(0xFFFFFBEB),
        darkBg: const Color(0xFF2E2413),
        targetPage: const ElectricityPage(),
      ),
      ServiceItem(
        title: 'Exam PINs',
        icon: Icons.school_rounded,
        iconColor: const Color(0xFF9333EA),
        lightBg: const Color(0xFFFAF5FF),
        darkBg: const Color(0xFF2A1938),
        badge: 'WAEC',
        badgeColor: const Color(0xFF7E22CE),
        badgeBgLight: const Color(0xFFF3E8FF),
        badgeBgDark: const Color(0xFF581C87),
        targetPage: const ExamPinPage(),
      ),
      ServiceItem(
        title: 'Smile 4G',
        icon: Icons.sensors_rounded,
        iconColor: const Color(0xFFE11D48),
        lightBg: const Color(0xFFFFF1F2),
        darkBg: const Color(0xFF33161D),
        targetPage: const AlphaSmilePage(initialTab: 1),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Quick Services',
              style: theme.titleLarge.override(
                fontWeight: FontWeight.w800,
                color: theme.primaryText,
                fontSize: 17,
              ),
            ),
            Text(
              'Instant automated delivery',
              style: theme.labelSmall.override(
                color: theme.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 4x2 Grid of Services
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            final item = services[index];
            return _buildServiceCard(context, item, theme, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ServiceItem item,
    FlutterFlowTheme theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.targetPage),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: isDark
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Badge at Top Right (if exists)
            if (item.badge != null)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isDark ? item.badgeBgDark : item.badgeBgLight,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.badge!,
                    style: TextStyle(
                      color: isDark ? Colors.white : item.badgeColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

            // Center Content: Icon + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? item.darkBg : item.lightBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.labelSmall.override(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
