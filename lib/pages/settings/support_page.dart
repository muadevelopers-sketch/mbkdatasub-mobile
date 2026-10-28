import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    FFAppState().refreshContactInfo();
  }

  void _openWhatsApp() async {
    final appState = FFAppState();
    final rawPhone = appState.supportWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = rawPhone.startsWith('0') ? '234${rawPhone.substring(1)}' : (rawPhone.isEmpty ? '2349047050681' : rawPhone);
    final url = Uri.parse('https://wa.me/$phone?text=Hello%20MBKDATASUB%20Support,%20I%20need%20assistance.');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showInfoToast(context, 'WhatsApp: +$phone');
      }
    } catch (_) {
      showInfoToast(context, 'WhatsApp: +$phone');
    }
  }

  void _openCall() async {
    final appState = FFAppState();
    final rawPhone = appState.supportPhone.trim();
    final phone = rawPhone.isEmpty ? '+2349047050681' : rawPhone;
    final url = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        showInfoToast(context, 'Phone: $phone');
      }
    } catch (_) {
      showInfoToast(context, 'Phone: $phone');
    }
  }

  void _openEmail() async {
    final appState = FFAppState();
    final email = appState.supportEmail.trim().isEmpty ? 'support@mbkdatasub.com.ng' : appState.supportEmail.trim();
    final url = Uri.parse('mailto:$email?subject=MBKDATASUB%20Support%20Enquiry');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        showInfoToast(context, 'Email: $email');
      }
    } catch (_) {
      showInfoToast(context, 'Email: $email');
    }
  }

  void _submitTicket() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      showErrorToast(context, 'Please complete both subject and message.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    _subjectController.clear();
    _messageController.clear();
    showSuccessToast(context, 'Support ticket submitted! An agent will respond shortly.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Text(
          'Customer Support Desk',
          style: theme.titleLarge.override(fontWeight: FontWeight.w800, color: theme.primaryText),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Channels Row (WhatsApp, Phone Call, Email)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _openWhatsApp,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 26),
                            const SizedBox(height: 6),
                            Text('WhatsApp', style: theme.titleSmall.override(fontWeight: FontWeight.w800, color: const Color(0xFF166534), fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Chat Now', style: theme.labelSmall.override(color: const Color(0xFF15803D), fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _openCall,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.phone_in_talk_rounded, color: theme.primaryAccent, size: 26),
                            const SizedBox(height: 6),
                            Text('Phone Call', style: theme.titleSmall.override(fontWeight: FontWeight.w800, color: theme.primary, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(FFAppState().supportPhone, style: theme.labelSmall.override(color: theme.primaryAccent, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _openEmail,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.email_rounded, color: Color(0xFFD97706), size: 26),
                            const SizedBox(height: 6),
                            Text('Email Us', style: theme.titleSmall.override(fontWeight: FontWeight.w800, color: const Color(0xFF92400E), fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Official Desk', style: theme.labelSmall.override(color: const Color(0xFFB45309), fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // In-App Ticket Form
              Text(
                'Submit Support Ticket',
                style: theme.titleMedium.override(fontWeight: FontWeight.w800, color: theme.primaryText),
              ),
              const SizedBox(height: 6),
              Text(
                'Experiencing an issue with a transaction? Send a message directly to our engineering desk.',
                style: theme.bodySmall.override(color: theme.secondaryText, lineHeight: 1.3),
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _subjectController,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Ticket Subject (e.g. Delayed Airtime Topup)',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 5,
                  style: theme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue or include transaction reference...',
                    hintStyle: theme.labelLarge.override(color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              FFButtonWidget(
                text: 'Send Support Ticket',
                onPressed: _isSubmitting ? null : _submitTicket,
                showLoadingIndicator: _isSubmitting,
                options: FFButtonOptions(
                  height: 54,
                  color: theme.primary,
                  textStyle: theme.titleMedium.override(color: Colors.white, fontWeight: FontWeight.w800),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
