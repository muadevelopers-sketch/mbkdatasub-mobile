class DataPlanRecord {
  final String id;
  final String planId;
  final String name;
  final String network; // MTN, GLO, AIRTEL, 9MOBILE
  final String type; // SME, GIFTING, CORPORATE GIFTING, CG PROMO, COUPON
  final double userPrice;
  final double resellerPrice;
  final String validity;
  final bool isActive;

  DataPlanRecord({
    required this.id,
    required this.planId,
    required this.name,
    required this.network,
    required this.type,
    required this.userPrice,
    required this.resellerPrice,
    this.validity = '30 Days',
    this.isActive = true,
  });

  factory DataPlanRecord.fromJson(Map<String, dynamic> json) {
    // Automatically use server-provided validity or infer from plan name (e.g. "1GB (30 days)")
    String inferredValidity = (json['validity']?.toString() ?? '').trim();
    final nameLower = (json['name']?.toString() ?? '').toLowerCase();
    if (inferredValidity.isEmpty) {
      if (nameLower.contains('1 day') || nameLower.contains('24 hrs') || nameLower.contains('24hr') || nameLower.contains('daily')) {
        inferredValidity = '1 Day';
      } else if (nameLower.contains('2 days') || nameLower.contains('2 day') || nameLower.contains('48 hrs')) {
        inferredValidity = '2 Days';
      } else if (nameLower.contains('3 days') || nameLower.contains('3 day')) {
        inferredValidity = '3 Days';
      } else if (nameLower.contains('7 days') || nameLower.contains('weekly') || nameLower.contains('1 week')) {
        inferredValidity = '7 Days';
      } else if (nameLower.contains('14 days') || nameLower.contains('2 weeks')) {
        inferredValidity = '14 Days';
      } else if (nameLower.contains('60 days')) {
        inferredValidity = '60 Days';
      } else if (nameLower.contains('90 days') || nameLower.contains('quarterly')) {
        inferredValidity = '90 Days';
      } else if (nameLower.contains('365 days') || nameLower.contains('yearly') || nameLower.contains('annual')) {
        inferredValidity = '365 Days';
      } else {
        inferredValidity = '30 Days';
      }
    }

    return DataPlanRecord(
      id: json['id']?.toString() ?? '',
      planId: json['planId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Data Plan',
      network: json['network']?.toString().toUpperCase() ?? 'MTN',
      type: json['type']?.toString().toUpperCase() ?? 'SME',
      userPrice: (json['userPrice'] as num?)?.toDouble() ?? 0.0,
      resellerPrice: (json['resellerPrice'] as num?)?.toDouble() ?? 0.0,
      validity: inferredValidity,
      isActive: json['isActive'] == 1 || json['isActive'] == true,
    );
  }

  double priceForRole(String role) {
    if (role == 'reseller' || role == 'agent') {
      return resellerPrice;
    }
    return userPrice;
  }
}
