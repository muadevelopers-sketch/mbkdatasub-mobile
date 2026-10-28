import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/app_state.dart';
import '../../components/wallet_card_widget.dart';
import '../../components/service_grid_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../services/get_your_app_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    final appState = Provider.of<FFAppState>(context, listen: false);
    await Future.wait([
      appState.refreshWallet(),
      appState.refreshTransactions(),
      appState.refreshDataPlans(),
      appState.loadAnnouncements(),
    ]);
    if (mounted) {
      setState(() => _isRefreshing = false);
      showSuccessToast(context, 'Balances and catalog synchronized!');
    }
  }

  void _openWhatsAppSupport() async {
    final appState = FFAppState();
    final rawPhone = appState.supportWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = rawPhone.startsWith('0')
        ? '234${rawPhone.substring(1)}'
        : (rawPhone.isEmpty ? '2349047050681' : rawPhone);
    final url = Uri.parse(
        'https://wa.me/$phone?text=Hello%20MBKDATASUB%20Support,%20I%20need%20assistance.');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showInfoToast(context, 'WhatsApp Support: +$phone');
      }
    } catch (_) {
      showInfoToast(context, 'WhatsApp Support: +$phone');
    }
  }

  String _getUserInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'MB';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final user = appState.user;
    final userName = user != null && user.fullName.isNotEmpty ? user.fullName : 'Ummulkhulthum';
    final initials = _getUserInitials(userName);
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.primaryAccent,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Top Bar (Avatar + Greeting + Theme/WhatsApp/Notifications)
                Row(
                  children: [
                    // Avatar Circle with Initials
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0284C7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Greeting + Tier Badge + User Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Welcome back,',
                                style: theme.labelSmall.override(
                                  color: theme.secondaryText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 10,
                                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Tier 1',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleMedium.override(
                              fontWeight: FontWeight.w800,
                              color: theme.primaryText,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Actions: Dark/Light Toggle, WhatsApp, Notifications
                    Row(
                      children: [
                        // Moon / Sun Theme Mode Toggle
                        _buildHeaderIconButton(
                          onTap: () => appState.toggleDarkMode(),
                          icon: isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                          iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFF0284C7),
                          theme: theme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),

                        // WhatsApp Support
                        _buildHeaderIconButton(
                          onTap: _openWhatsAppSupport,
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: const Color(0xFF10B981),
                          theme: theme,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),

                        // Notification Bell with Badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildHeaderIconButton(
                              onTap: () {
                                showInfoToast(context, 'No new notifications at this time.');
                              },
                              icon: Icons.notifications_none_rounded,
                              iconColor: const Color(0xFF0284C7),
                              theme: theme,
                              isDark: isDark,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Active Wallet Card (Deep Indigo Gradient with Balance & Stats)
                const WalletCardWidget(),

                const SizedBox(height: 22),

                // 3. Quick Services Grid (4x2 items with Badges)
                const ServiceGridWidget(),

                const SizedBox(height: 22),

                // 4. GET APP Feature Banner (Replaces the Advert Banner below Services)
                _buildGetAppBanner(context, theme, isDark),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required FlutterFlowTheme theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildGetAppBanner(
    BuildContext context,
    FlutterFlowTheme theme,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GetYourAppPage()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF2E1065),
              Color(0xFF3B2DB8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28231E63),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 13, color: Color(0xFFFBBF24)),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM SERVICE',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'NGN 250,000',
                  style: TextStyle(
                    color: Color(0xFF67E8F9),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            const Text(
              'GET YOUR APP & WEBSITE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Text(
              'Launch your own branded fintech app & website today. Direct telecom API connections with 99.9% uptime.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Bottom Action Pill Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Bundle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white24,
                  size: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
