import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_requests/api_calls.dart';
import 'schema/struct/user_record.dart';
import 'schema/struct/wallet_record.dart';
import 'schema/struct/data_plan_record.dart';
import 'schema/struct/transaction_record.dart';

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  UserRecord? _user;
  UserRecord? get user => _user;
  bool get isAuthenticated => _user != null;

  WalletRecord _wallet = WalletRecord();
  WalletRecord get wallet => _wallet;

  bool _isWalletHidden = false;
  bool get isWalletHidden => _isWalletHidden;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<DataPlanRecord> _dataPlans = [];
  List<DataPlanRecord> get dataPlans => _dataPlans;

  List<TransactionRecord> _transactions = [];
  List<TransactionRecord> get transactions => _transactions;

  List<String> _announcements = [
    'Welcome to MBKDATASUB! Enjoy instant automated bill payments & data topups.'
  ];
  List<String> get announcements => _announcements;

  String _supportPhone = '+2349047050681';
  String get supportPhone => _supportPhone;

  String _supportWhatsapp = '2349047050681';
  String get supportWhatsapp => _supportWhatsapp;

  String _supportEmail = 'support@mbkdatasub.com.ng';
  String get supportEmail => _supportEmail;

  Map<String, dynamic> _manualBankInfo = {
    'bankName': 'OPAY',
    'accountNumber': '8131555945',
    'accountName': 'ABDUSSALAM A SIRAJO',
    'whatsappNotificationPhone': '2349047050681',
    'instructions': 'Transfer exact amount, include registered phone as reference, and submit receipt to WhatsApp for instant wallet credit.',
  };
  Map<String, dynamic> get manualBankInfo => _manualBankInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isWalletHidden = prefs.getBool('mbk_hide_wallet') ?? false;
      _isDarkMode = prefs.getBool('mbk_dark_mode') ?? false;

      // Restore cached contact details immediately
      final cachedPhone = prefs.getString('mbk_support_phone');
      if (cachedPhone != null && cachedPhone.isNotEmpty) _supportPhone = cachedPhone;
      final cachedWa = prefs.getString('mbk_support_whatsapp');
      if (cachedWa != null && cachedWa.isNotEmpty) _supportWhatsapp = cachedWa;
      final cachedEmail = prefs.getString('mbk_support_email');
      if (cachedEmail != null && cachedEmail.isNotEmpty) _supportEmail = cachedEmail;

      final token = await MbkApi.getToken();
      if (token != null && token.isNotEmpty) {
        final userRes = await MbkApi.getMe();
        if (userRes.success && userRes.data != null) {
          _user = userRes.data;
          await refreshWallet();
          await refreshTransactions();
        } else {
          // Token expired or invalid
          await MbkApi.clearAuth();
          _user = null;
        }
      }

      await loadAnnouncements();
      await refreshDataPlans();
      await refreshContactInfo();
      await refreshManualBank();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshContactInfo() async {
    try {
      final res = await MbkApi.getContactInfo();
      if (res.success && res.data != null) {
        final d = res.data!;
        if (d['supportPhone'] != null) _supportPhone = d['supportPhone'].toString();
        if (d['supportWhatsapp'] != null) _supportWhatsapp = d['supportWhatsapp'].toString();
        if (d['supportEmail'] != null) _supportEmail = d['supportEmail'].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mbk_support_phone', _supportPhone);
        await prefs.setString('mbk_support_whatsapp', _supportWhatsapp);
        await prefs.setString('mbk_support_email', _supportEmail);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshManualBank() async {
    try {
      final res = await MbkApi.getManualBank();
      if (res.success && res.data != null) {
        _manualBankInfo = res.data!;
        notifyListeners();
      }
    } catch (_) {}
  }

  void setUser(UserRecord user) {
    _user = user;
    notifyListeners();
    refreshWallet();
    refreshTransactions();
  }

  Future<void> refreshWallet() async {
    final res = await MbkApi.getWallet();
    if (res.success && res.data != null) {
      _wallet = res.data!;
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    final res = await MbkApi.getTransactions();
    if (res.success && res.data != null) {
      _transactions = res.data!;
      notifyListeners();
    }
  }

  Future<void> refreshDataPlans() async {
    final res = await MbkApi.getDataPlans();
    if (res.success && res.data != null) {
      _dataPlans = res.data!;
      notifyListeners();
    }
  }

  Future<void> loadAnnouncements() async {
    final res = await MbkApi.getAnnouncements();
    if (res.success && res.data != null && res.data!.isNotEmpty) {
      _announcements = res.data!;
      notifyListeners();
    }
  }

  void toggleWalletHidden() async {
    _isWalletHidden = !_isWalletHidden;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mbk_hide_wallet', _isWalletHidden);
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mbk_dark_mode', _isDarkMode);
  }

  Future<void> logout() async {
    await MbkApi.clearAuth();
    _user = null;
    _wallet = WalletRecord();
    _transactions = [];
    notifyListeners();
  }
}
