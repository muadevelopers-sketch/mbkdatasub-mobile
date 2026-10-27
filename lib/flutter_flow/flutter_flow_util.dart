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
