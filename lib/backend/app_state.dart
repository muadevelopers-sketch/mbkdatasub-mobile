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

  List<DataPlanRecord> _dataPlans = [];
  List<DataPlanRecord> get dataPlans => _dataPlans;

  List<TransactionRecord> _transactions = [];
  List<TransactionRecord> get transactions => _transactions;

  List<String> _announcements = [
    'Welcome to MBKDATASUB! Enjoy instant automated bill payments & data topups.'
  ];
  List<String> get announcements => _announcements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isWalletHidden = prefs.getBool('mbk_hide_wallet') ?? false;

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
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> logout() async {
    await MbkApi.clearAuth();
    _user = null;
    _wallet = WalletRecord();
    _transactions = [];
    notifyListeners();
  }
}
