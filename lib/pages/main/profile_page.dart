import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../backend/app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../auth/welcome_page.dart';
import '../settings/change_pin_page.dart';
import '../settings/change_password_page.dart';
import '../settings/live_pricing_page.dart';
import '../settings/support_page.dart';
import '../services/get_your_app_page.dart';
import 'main_nav_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final user = appState.user;
    final fullName = user != null ? user.fullName : 'Guest User';
    final email = user != null ? user.email : 'guest@mbkdatasub.com.ng';

    void handleLogout() async {
      await appState.logout();
      showSuccessToast(context, 'Logged out successfully.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }

    void confirmDeleteAccount() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Account', style: theme.headlineSmall.override(color: theme.error)),
          content: Text(
            'Are you sure you want to request permanent account deletion? All transaction history and wallet access will be securely terminated.',
            style: theme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: theme.titleSmall.override(color: theme.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                handleLogout();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: theme.titleLarge.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: handleLogout,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded, color: theme.error, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Top Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC7D2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF475569), size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleLarge.override(
                              fontWeight: FontWeight.w800,
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.override(color: theme.secondaryText),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tier ${user?.kycTier ?? 1} Customer',
                                  style: theme.labelSmall.override(
                                    color: theme.primaryAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, size: 14, color: theme.primaryAccent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grouped Account Settings Card
              Text(
                'Account Settings',
                style: theme.titleMedium.override(
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.rocket_launch_rounded,
                      iconColor: theme.primaryAccent,
                      iconBg: const Color(0xFFEEF2FF),
                      title: 'GET YOUR APP',
                      subtitle: 'Get your own custom VTU website + mobile app',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GetYourAppPage()),
                        );
                      },
                      theme: theme,
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildSettingsTile(
                      icon: Icons.person_add_alt_1_outlined,
                      iconColor: theme.success,
                      iconBg: const Color(0xFFDCFCE7),
                      title: 'Refer a Friend',
                      subtitle: 'Earn money when you invite friends',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavShell(initialIndex: 2)),
                        );
                      },
                      theme: theme,
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildSettingsTile(
                      icon: Icons.sell_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: const Color(0xFFFEF3C7),
                      title: 'Our Pricing',
                      subtitle: 'View live MBKDATASUB telecom pricing',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LivePricingPage()),
                        );
                      },
                      theme: theme,
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildSettingsTile(
                      icon: Icons.lock_clock_outlined,
                      iconColor: const Color(0xFF9333EA),
                      iconBg: const Color(0xFFF3E8FF),
                      title: 'Change PIN',
                      subtitle: 'Update your 4-digit transaction PIN',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePinPage()),
                        );
                      },
                      theme: theme,
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildSettingsTile(
                      icon: Icons.key_outlined,
                      iconColor: theme.primaryAccent,
                      iconBg: const Color(0xFFEEF4FF),
                      title: 'Change Password',
                      subtitle: 'Update login credentials',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                      theme: theme,
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    _buildSettingsTile(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF0D9488),
                      iconBg: const Color(0xFFCCFBF1),
                      title: 'Customer Support',
                      subtitle: 'Direct WhatsApp & Help Tickets',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SupportPage()),
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Delete Account Button (Pink pill card matching Image 9)
              InkWell(
                onTap: confirmDeleteAccount,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: theme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: theme.titleMedium.override(
                          color: theme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Version Footer
              Center(
                child: Text(
                  'MBKDATASUB v1.0.0 (Production Native Build)',
                  style: theme.labelSmall.override(color: const Color(0xFF94A3B8)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required FlutterFlowTheme theme,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.titleSmall.override(
          fontWeight: FontWeight.w700,
          color: theme.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.bodySmall.override(
          color: theme.secondaryText,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
    );
  }
}
