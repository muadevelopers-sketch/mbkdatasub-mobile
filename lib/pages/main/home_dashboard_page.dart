import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/app_state.dart';
import '../../components/wallet_card_widget.dart';
import '../../components/service_grid_widget.dart';
import '../../components/promo_banner_widget.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../wallet/add_money_page.dart';
import '../settings/live_pricing_page.dart';
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
    final phone = rawPhone.startsWith('0') ? '234${rawPhone.substring(1)}' : (rawPhone.isEmpty ? '2349047050681' : rawPhone);
    final url = Uri.parse('https://wa.me/$phone?text=Hello%20MBKDATASUB%20Support,%20I%20need%20assistance.');
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final user = appState.user;
    final userName = user != null ? user.fullName : 'Guest User';

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: RefreshIndicator(
        color: theme.primaryAccent,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. Top Curved Royal Navy Header
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primary, theme.primaryAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Greeting & Actions Row
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: theme.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.titleLarge.override(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Welcome to MBKDATASUB',
                                    style: theme.labelSmall.override(
                                      color: const Color(0xFFE2E8F0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // WhatsApp Support Shortcut Button
                            InkWell(
                              onTap: _openWhatsAppSupport,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Refresh Button
                            InkWell(
                              onTap: _isRefreshing ? null : _refreshData,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: _isRefreshing
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Scrolling Announcement Ticker
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign_rounded, color: Colors.amberAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  appState.announcements.first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.bodySmall.override(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating Wallet Card (Overlaps header)
                  const Positioned(
                    bottom: -50,
                    left: 20,
                    right: 20,
                    child: WalletCardWidget(),
                  ),
                ],
              ),

              const SizedBox(height: 64),

              // 2. Quick Action Bar (Add Money, Pricing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddMoneyPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A0A1C6A),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add Money',
                                style: theme.titleSmall.override(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LivePricingPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sell_outlined, color: theme.primaryAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'View Pricing',
                                style: theme.titleSmall.override(
                                  color: theme.primaryText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2b. Featured Card: "GET YOUR APP"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GetYourAppPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primary, theme.primaryAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'PREMIUM SERVICE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'NGN 250,000',
                                    style: TextStyle(
                                      color: Color(0xFF67E8F9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'GET YOUR APP & WEBSITE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Launch your own branded fintech app & website today',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_rounded, color: theme.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Dynamic Promo Carousel Banner
              const PromoBannerWidget(),

              const SizedBox(height: 24),

              // 4. Quick Services Grid
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ServiceGridWidget(),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
