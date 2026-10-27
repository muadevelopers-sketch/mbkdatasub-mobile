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
    // Automatically infer validity from plan name if not provided (e.g. "1GB (30 days)")
    String inferredValidity = json['validity']?.toString() ?? '';
    final nameLower = (json['name']?.toString() ?? '').toLowerCase();
    if (inferredValidity.isEmpty) {
      if (nameLower.contains('1 day') || nameLower.contains('24 hrs') || nameLower.contains('daily')) {
        inferredValidity = '1 Day';
      } else if (nameLower.contains('2 days')) {
        inferredValidity = '2 Days';
      } else if (nameLower.contains('7 days') || nameLower.contains('weekly')) {
        inferredValidity = '7 Days';
      } else if (nameLower.contains('14 days')) {
        inferredValidity = '14 Days';
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
