import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatNaira(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: amount is int || amount % 1 == 0 ? 0 : 2,
  );
  return formatter.format(amount);
}

String formatDateTime(dynamic date) {
  if (date == null) return '';
  DateTime dt;
  if (date is DateTime) {
    dt = date;
  } else {
    dt = DateTime.tryParse(date.toString()) ?? DateTime.now();
  }
  return DateFormat('MMMM dd, yyyy hh:mm:ss a').format(dt);
}

void showSuccessToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
      backgroundColor: const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}

void showErrorToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ),
  );
}

void showInfoToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
      backgroundColor: const Color(0xFF1E5BF8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Detect Nigerian telecom network operator from phone number prefix
String? detectNetworkFromPhone(String phone) {
  String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (clean.startsWith('234') && clean.length > 3) {
    clean = '0${clean.substring(3)}';
  }
  if (clean.length < 4) return null;

  const mtnPrefixes = [
    '0803', '0806', '0703', '0706', '0813', '0816', '0810', '0814',
    '0903', '0906', '0913', '0916', '0704', '0707', '07025', '07026',
  ];

  const airtelPrefixes = [
    '0802', '0808', '0708', '0812', '0701', '0902', '0901', '0904',
    '0907', '0912', '0911',
  ];

  const gloPrefixes = [
    '0805', '0807', '0705', '0815', '0811', '0905', '0915',
  ];

  const etisalatPrefixes = [
    '0809', '0818', '0817', '0909', '0908',
  ];

  for (final p in mtnPrefixes) {
    if (clean.startsWith(p)) return 'MTN';
  }
  for (final p in airtelPrefixes) {
    if (clean.startsWith(p)) return 'AIRTEL';
  }
  for (final p in gloPrefixes) {
    if (clean.startsWith(p)) return 'GLO';
  }
  for (final p in etisalatPrefixes) {
    if (clean.startsWith(p)) return '9MOBILE';
  }
  return null;
}

