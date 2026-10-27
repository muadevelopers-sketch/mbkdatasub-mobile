class TransactionRecord {
  final String id;
  final String reference;
  final String title;
  final String serviceCode;
  final String type; // credit, debit
  final double amount;
  final String status; // success, failed, pending
  final String recipient;
  final String? tokenOrPin;
  final String description;
  final double balanceAfter;
  final DateTime date;

  TransactionRecord({
    required this.id,
    required this.reference,
    required this.title,
    required this.serviceCode,
    required this.type,
    required this.amount,
    required this.status,
    required this.recipient,
    this.tokenOrPin,
    required this.description,
    required this.balanceAfter,
    required this.date,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['date'] ?? json['createdAt'];
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionRecord(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Transaction',
      serviceCode: json['serviceCode']?.toString() ?? 'general',
      type: json['type']?.toString().toLowerCase() ?? 'debit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString().toLowerCase() ?? 'success',
      recipient: json['recipient']?.toString() ?? '',
      tokenOrPin: json['tokenOrPin']?.toString(),
      description: json['description']?.toString() ?? '',
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
    );
  }

  bool get isCredit => type == 'credit';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}
