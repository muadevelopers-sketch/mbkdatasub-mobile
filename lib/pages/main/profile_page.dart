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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = theme.isDark;
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
          backgroundColor: theme.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Account', style: theme.headlineSmall.override(color: theme.error)),
          content: Text(
            'Are you sure you want to request permanent account deletion? All transaction history and wallet access will be securely terminated.',
            style: TextStyle(color: theme.primaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
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
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
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
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : const Color(0x0A000000),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
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
                              fontSize: 16,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined, size: 12, color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  'Tier ${user?.kycTier ?? 1} Verified',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262E3D) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    // Dark Mode Switch
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Dark Mode Theme',
                        style: theme.titleSmall.override(
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText,
                        ),
                      ),
                      subtitle: Text(
                        isDark ? 'OLED Dark Navy Active' : 'Light Clean Mode Active',
                        style: theme.bodySmall.override(
                          color: theme.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeColor: const Color(0xFF38BDF8),
                        onChanged: (_) => appState.toggleDarkMode(),
                      ),
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9)),

                    _buildSettingsTile(
                      icon: Icons.rocket_launch_rounded,
                      iconColor: const Color(0xFF4F46E5),
                      iconBg: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                      title: 'GET YOUR APP',
                      subtitle: 'Get your custom branded VTU website & mobile app',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GetYourAppPage()),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9)),

                    _buildSettingsTile(
                      icon: Icons.sell_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                      title: 'Our Pricing',
                      subtitle: 'View live MBKDATASUB telecom pricing',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LivePricingPage()),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9)),

                    _buildSettingsTile(
                      icon: Icons.lock_clock_outlined,
                      iconColor: const Color(0xFF9333EA),
                      iconBg: isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF),
                      title: 'Change PIN',
                      subtitle: 'Update your 4-digit transaction PIN',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePinPage()),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9)),

                    _buildSettingsTile(
                      icon: Icons.key_outlined,
                      iconColor: const Color(0xFF0284C7),
                      iconBg: isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE),
                      title: 'Change Password',
                      subtitle: 'Update login credentials',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? const Color(0xFF262E3D) : const Color(0xFFF1F5F9)),

                    _buildSettingsTile(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF0D9488),
                      iconBg: isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1),
                      title: 'Customer Support',
                      subtitle: 'Direct WhatsApp & Help Center',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SupportPage()),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Delete Account Button
              InkWell(
                onTap: confirmDeleteAccount,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, color: theme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Account',
                        style: TextStyle(
                          color: theme.error,
                          fontSize: 14,
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
                  'MBKDATASUB v2.0.0 (Automated Build)',
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
    required bool isDark,
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
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      ),
    );
  }
}
