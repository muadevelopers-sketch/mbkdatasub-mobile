class DedicatedAccount {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String type;

  DedicatedAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.type,
  });

  factory DedicatedAccount.fromJson(Map<String, dynamic> json) {
    return DedicatedAccount(
      bankName: json['bankName']?.toString() ?? 'PalmPay',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? 'MBK Dedicated Account',
      type: json['type']?.toString() ?? 'palmpay',
    );
  }
}

class WalletRecord {
  final double balance;
  final double totalFunded;
  final double totalSpent;
  final String? palmpayAccountNumber;
  final String? palmpayBankName;
  final String? palmpayAccountName;
  final String? pagaAccountNumber;
  final String? pagaBankName;
  final String? pagaAccountName;
  final String? virtualAccountNumber;
  final String? virtualBankName;
  final String? virtualAccountName;
  final List<DedicatedAccount> accounts;

  WalletRecord({
    this.balance = 0.0,
    this.totalFunded = 0.0,
    this.totalSpent = 0.0,
    this.palmpayAccountNumber,
    this.palmpayBankName = 'PalmPay',
    this.palmpayAccountName,
    this.pagaAccountNumber,
    this.pagaBankName = 'Paga',
    this.pagaAccountName,
    this.virtualAccountNumber,
    this.virtualBankName,
    this.virtualAccountName,
    this.accounts = const [],
  });

  factory WalletRecord.fromJson(Map<String, dynamic> json) {
    final rawAccounts = json['accounts'];
    final List<DedicatedAccount> accList = [];
    if (rawAccounts is List) {
      for (final a in rawAccounts) {
        if (a is Map<String, dynamic>) {
          accList.add(DedicatedAccount.fromJson(a));
        }
      }
    }

    final virt = json['virtualAccount'];
    return WalletRecord(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalFunded: (json['totalFunded'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      palmpayAccountNumber: json['palmpayAccountNumber']?.toString(),
      palmpayBankName: json['palmpayBankName']?.toString() ?? 'PalmPay',
      palmpayAccountName: json['palmpayAccountName']?.toString(),
      pagaAccountNumber: json['pagaAccountNumber']?.toString(),
      pagaBankName: json['pagaBankName']?.toString() ?? 'Paga',
      pagaAccountName: json['pagaAccountName']?.toString(),
      virtualAccountNumber: virt != null ? virt['accountNumber']?.toString() : json['virtualAccountNumber']?.toString(),
      virtualBankName: virt != null ? virt['bankName']?.toString() : json['virtualBankName']?.toString(),
      virtualAccountName: virt != null ? virt['accountName']?.toString() : json['virtualAccountName']?.toString(),
      accounts: accList,
    );
  }

  // Helper to retrieve display accounts with fallback
  List<DedicatedAccount> get displayAccounts {
    if (accounts.isNotEmpty) return accounts;
    final list = <DedicatedAccount>[];
    if (palmpayAccountNumber != null && palmpayAccountNumber!.length >= 8) {
      list.add(DedicatedAccount(
        bankName: palmpayBankName ?? 'PalmPay',
        accountNumber: palmpayAccountNumber!,
        accountName: palmpayAccountName ?? 'MBK Dedicated Account',
        type: 'palmpay',
      ));
    }
    if (pagaAccountNumber != null && pagaAccountNumber!.length >= 8) {
      list.add(DedicatedAccount(
        bankName: pagaBankName ?? 'Paga',
        accountNumber: pagaAccountNumber!,
        accountName: pagaAccountName ?? 'MBK Dedicated Account',
        type: 'paga',
      ));
    }
    if (list.isEmpty && virtualAccountNumber != null && virtualAccountNumber!.isNotEmpty) {
      list.add(DedicatedAccount(
        bankName: virtualBankName ?? 'PalmPay',
        accountNumber: virtualAccountNumber!,
        accountName: virtualAccountName ?? 'MBK Account',
        type: 'virtual',
      ));
    }
    return list;
  }
}
