import 'package:flutter/material.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class PromoBannerWidget extends StatelessWidget {
  const PromoBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final List<Map<String, String>> banners = [
      {
        'title': 'Earn Commissions Every Day!',
        'subtitle': 'Invite friends to MBKDATASUB and earn instant bonuses on every recharge.',
        'badge': 'REFERRAL PROGRAM',
        'color1': '0xFF0A1C6A',
        'color2': '0xFF1E5BF8',
      },
      {
        'title': 'Instant Cable & Electricity Recharges',
        'subtitle': 'Enjoy zero-delay token generation directly on your phone.',
        'badge': '24/7 AUTOMATED',
        'color1': '0xFF1E1B4B',
        'color2': '0xFF4338CA',
      },
    ];

    return SizedBox(
      height: 140,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final b = banners[index];
          final c1 = Color(int.parse(b['color1']!));
          final c2 = Color(int.parse(b['color2']!));

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c1, c2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F1E5BF8),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          b['badge']!,
                          style: theme.labelSmall.override(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleMedium.override(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b['subtitle']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 11,
                          lineHeight: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.amberAccent,
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
