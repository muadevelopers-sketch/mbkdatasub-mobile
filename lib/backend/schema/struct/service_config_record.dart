class ServiceConfigRecord {
  final String serviceCode;
  final String serviceName;
  final String category;
  final bool isActive;
  final double discountRate;

  ServiceConfigRecord({
    required this.serviceCode,
    required this.serviceName,
    required this.category,
    required this.isActive,
    this.discountRate = 0.0,
  });

  factory ServiceConfigRecord.fromJson(Map<String, dynamic> json) {
    return ServiceConfigRecord(
      serviceCode: json['serviceCode']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      category: json['category']?.toString() ?? 'telecom',
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      discountRate: (json['discountRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
