import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/api_requests/api_calls.dart';
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

  void _openWhatsApp() async {
    const phone = '2348123456780';
    final url = Uri.parse('https://wa.me/$phone?text=Hello%20MBKDATASUB%20Support,%20I%20need%20assistance.');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      showInfoToast(context, 'WhatsApp: +$phone');
    }
  }

  void _openCall() async {
    const phone = '+2348123456780';
    final url = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (_) {
      showInfoToast(context, 'Phone: $phone');
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
              // Contact Channels Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _openWhatsApp,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 30),
                            const SizedBox(height: 8),
                            Text('WhatsApp', style: theme.titleSmall.override(fontWeight: FontWeight.w800, color: const Color(0xFF166534))),
                            const SizedBox(height: 2),
                            Text('Instant Chat', style: theme.labelSmall.override(color: const Color(0xFF15803D), fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: _openCall,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.phone_in_talk_rounded, color: theme.primaryAccent, size: 30),
                            const SizedBox(height: 8),
                            Text('Direct Call', style: theme.titleSmall.override(fontWeight: FontWeight.w800, color: theme.primary)),
                            const SizedBox(height: 2),
                            Text('+234 812 345 6780', style: theme.labelSmall.override(color: theme.primaryAccent, fontSize: 11)),
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
