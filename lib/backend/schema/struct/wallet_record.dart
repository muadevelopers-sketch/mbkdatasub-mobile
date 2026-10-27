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

  // GUARANTEED: Always returns BOTH PalmPay AND Paga Dedicated Accounts
  List<DedicatedAccount> get displayAccounts {
    final list = <DedicatedAccount>[];

    // 1. Dedicated PalmPay
    String palmNum = '';
    if (palmpayAccountNumber != null && palmpayAccountNumber!.trim().length >= 8) {
      palmNum = palmpayAccountNumber!.trim();
    } else {
      for (final a in accounts) {
        if ((a.type.toLowerCase().contains('palm') || a.bankName.toLowerCase().contains('palm')) &&
            a.accountNumber.trim().length >= 8) {
          palmNum = a.accountNumber.trim();
          break;
        }
      }
    }
    if (palmNum.isEmpty && virtualAccountNumber != null && virtualAccountNumber!.trim().length >= 8) {
      palmNum = virtualAccountNumber!.trim();
    }

    list.add(DedicatedAccount(
      bankName: 'PalmPay Bank',
      accountNumber: palmNum.isNotEmpty ? palmNum : 'Generating...',
      accountName: palmpayAccountName ?? virtualAccountName ?? 'MBK Dedicated Account',
      type: 'palmpay',
    ));

    // 2. Dedicated Paga
    String pagaNum = '';
    if (pagaAccountNumber != null && pagaAccountNumber!.trim().length >= 8) {
      pagaNum = pagaAccountNumber!.trim();
    } else {
      for (final a in accounts) {
        if ((a.type.toLowerCase().contains('paga') || a.bankName.toLowerCase().contains('paga')) &&
            a.accountNumber.trim().length >= 8) {
          pagaNum = a.accountNumber.trim();
          break;
        }
      }
    }

    list.add(DedicatedAccount(
      bankName: 'Paga Bank',
      accountNumber: pagaNum.isNotEmpty ? pagaNum : 'Generating...',
      accountName: pagaAccountName ?? virtualAccountName ?? 'MBK Dedicated Account',
      type: 'paga',
    ));

    return list;
  }
}
