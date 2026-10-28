import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../pages/services/airtime_page.dart';
import '../pages/services/data_page.dart';
import '../pages/services/cable_page.dart';
import '../pages/services/electricity_page.dart';
import '../pages/services/exam_pin_page.dart';
import '../pages/services/airtime_to_cash_page.dart';
import '../pages/services/alpha_smile_page.dart';
import '../pages/services/get_your_app_page.dart';

class ServiceItem {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final Widget targetPage;

  ServiceItem({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.targetPage,
  });
}

class ServiceGridWidget extends StatelessWidget {
  const ServiceGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final List<ServiceItem> services = [
      ServiceItem(
        title: 'Airtime',
        icon: Icons.phone_in_talk_rounded,
        bgColor: const Color(0xFFFFE4E6),
        iconColor: const Color(0xFFE11D48),
        targetPage: const AirtimePage(),
      ),
      ServiceItem(
        title: 'Data',
        icon: Icons.wifi_tethering_rounded,
        bgColor: const Color(0xFFFCE7F3),
        iconColor: const Color(0xFFDB2777),
        targetPage: const DataPage(),
      ),
      ServiceItem(
        title: 'Cable',
        icon: Icons.tv_rounded,
        bgColor: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF9333EA),
        targetPage: const CablePage(),
      ),
      ServiceItem(
        title: 'Smile',
        icon: Icons.sentiment_satisfied_alt_rounded,
        bgColor: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF7C3AED),
        targetPage: const AlphaSmilePage(initialTab: 1),
      ),
      ServiceItem(
        title: 'Electric',
        icon: Icons.lightbulb_outline_rounded,
        bgColor: const Color(0xFFDBEAFE),
        iconColor: const Color(0xFF2563EB),
        targetPage: const ElectricityPage(),
      ),
      ServiceItem(
        title: 'Exam PINs',
        icon: Icons.school_outlined,
        bgColor: const Color(0xFFCFFAFE),
        iconColor: const Color(0xFF0891B2),
        targetPage: const ExamPinPage(),
      ),
      ServiceItem(
        title: 'A2Cash',
        icon: Icons.currency_exchange_rounded,
        bgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        targetPage: const AirtimeToCashPage(),
      ),
      ServiceItem(
        title: 'Alpha',
        icon: Icons.headset_mic_outlined,
        bgColor: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
        targetPage: const AlphaSmilePage(initialTab: 0),
      ),
      ServiceItem(
        title: 'Get App',
        icon: Icons.rocket_launch_rounded,
        bgColor: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
        targetPage: const GetYourAppPage(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Services',
              style: theme.headlineSmall.override(
                fontWeight: FontWeight.w800,
                color: theme.primaryText,
              ),
            ),
            Text(
              'See More',
              style: theme.titleSmall.override(
                fontWeight: FontWeight.w700,
                color: theme.primaryAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 18,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = services[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item.targetPage),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
