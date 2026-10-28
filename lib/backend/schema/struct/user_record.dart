class UserRecord {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  String get phoneNumber => phone;
  final String role;
  final int kycTier;
  final String referralCode;
  final bool hasTransactionPin;
  final String status;

  UserRecord({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.kycTier = 1,
    this.referralCode = '',
    this.hasTransactionPin = false,
    this.status = 'active',
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      kycTier: (json['kycTier'] as num?)?.toInt() ?? 1,
      referralCode: json['referralCode']?.toString() ?? '',
      hasTransactionPin: json['hasTransactionPin'] == true,
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'kycTier': kycTier,
        'referralCode': referralCode,
        'hasTransactionPin': hasTransactionPin,
        'status': status,
      };
}
