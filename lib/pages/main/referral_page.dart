import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../backend/app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = Provider.of<FFAppState>(context);
    final user = appState.user;
    final referralCode = user?.referralCode.isNotEmpty == true
        ? user!.referralCode
        : (user?.phone ?? 'MBKVIP');
    final inviteLink = 'https://mbkdatasub.com.ng/register?ref=$referralCode';

    void inviteFriends() {
      Share.share(
        'Join me on MBKDATASUB for the fastest, cheapest data, airtime, and utility bill payments! Use my referral code $referralCode or register directly here: $inviteLink',
        subject: 'Join MBKDATASUB Telecom',
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Refer & Earn',
          style: theme.titleLarge.override(
            fontWeight: FontWeight.w800,
            color: theme.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card 1: Bonus Earned
              _buildStatCard(
                icon: Icons.attach_money_rounded,
                iconColor: theme.success,
                iconBg: const Color(0xFFDCFCE7),
                title: 'Bonus Earned',
                value: '₦0',
                subtitle: 'Total bonus from referrals',
                theme: theme,
              ),
              const SizedBox(height: 12),

              // Card 2: Invitation Code
              _buildStatCard(
                icon: Icons.grid_view_rounded,
                iconColor: theme.primaryAccent,
                iconBg: const Color(0xFFEEF4FF),
                title: 'Your Invitation Code',
                value: referralCode,
                subtitle: 'Share this code with friends',
                theme: theme,
              ),
              const SizedBox(height: 12),

              // Card 3: Referred Users
              _buildStatCard(
                icon: Icons.people_alt_outlined,
                iconColor: const Color(0xFFEA580C),
                iconBg: const Color(0xFFFFEDD5),
                title: 'Referred Users',
                value: '0 Users',
                subtitle: 'Accepted your invitation',
                theme: theme,
              ),
              const SizedBox(height: 24),

              // Invite Friends Button
              FFButtonWidget(
                text: 'Invite Friends',
                onPressed: inviteFriends,
                iconData: Icons.share_rounded,
                options: FFButtonOptions(
                  height: 52,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 12),

              // Copy Code & Copy Link Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        showSuccessToast(context, 'Referral code copied!');
                      },
                      icon: Icon(Icons.copy_rounded, size: 16, color: theme.primaryText),
                      label: Text('Copy Code', style: theme.titleSmall.override(color: theme.primaryText)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteLink));
                        showSuccessToast(context, 'Referral link copied!');
                      },
                      icon: Icon(Icons.link_rounded, size: 18, color: theme.primaryText),
                      label: Text('Copy Link', style: theme.titleSmall.override(color: theme.primaryText)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // "How it works" Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: theme.titleMedium.override(
                        fontWeight: FontWeight.w800,
                        color: theme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      '1',
                      'Share your code',
                      'Send your referral code or download link to friends and family.',
                      theme,
                    ),
                    const SizedBox(height: 14),
                    _buildStep(
                      '2',
                      'Friends sign up',
                      'When they register on MBKDATASUB using your invitation code.',
                      theme,
                    ),
                    const SizedBox(height: 14),
                    _buildStep(
                      '3',
                      'Earn instant commissions',
                      'Every time they purchase data or pay bills, bonuses credit automatically to your wallet.',
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String subtitle,
    required FlutterFlowTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.labelSmall.override(
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.titleLarge.override(
                    fontWeight: FontWeight.w900,
                    color: theme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.bodySmall.override(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String title, String desc, FlutterFlowTheme theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.titleSmall.override(fontWeight: FontWeight.w700, color: theme.primaryText)),
              const SizedBox(height: 2),
              Text(desc, style: theme.bodySmall.override(color: theme.secondaryText, lineHeight: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
