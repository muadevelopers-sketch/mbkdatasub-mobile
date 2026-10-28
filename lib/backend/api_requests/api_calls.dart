import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../schema/struct/user_record.dart';
import '../schema/struct/wallet_record.dart';
import '../schema/struct/data_plan_record.dart';
import '../schema/struct/transaction_record.dart';

class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResult({
    required this.success,
    required this.message,
    this.data,
    this.statusCode = 200,
  });
}

class MbkApi {
  static const String baseUrl = 'https://mbkdatasub.com.ng/api/v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'mbk_auth_jwt_token';
  static const String _userKey = 'mbk_user_profile_cache';
  static const String _bioIdKey = 'mbk_bio_identifier';
  static const String _bioPassKey = 'mbk_bio_password';

  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<void> setToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> saveBiometricCredentials(String identifier, String password) async {
    await _storage.write(key: _bioIdKey, value: identifier);
    await _storage.write(key: _bioPassKey, value: password);
  }

  static Future<Map<String, String>?> getBiometricCredentials() async {
    final id = await _storage.read(key: _bioIdKey);
    final pass = await _storage.read(key: _bioPassKey);
    if (id != null && pass != null && id.isNotEmpty && pass.isNotEmpty) {
      return {'identifier': id, 'password': pass};
    }
    return null;
  }

  static Future<void> clearAuth() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  static Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Strict anti-cache headers ensure all website changes reflect immediately
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final params = Map<String, String>.from(queryParams ?? {});
    params['_t'] = DateTime.now().millisecondsSinceEpoch.toString();
    return Uri.parse('$baseUrl$path').replace(queryParameters: params);
  }

  // ================= 1. AUTHENTICATION =================

  static Future<ApiResult<Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        _buildUri('/auth/login'),
        headers: _headers(null),
        body: jsonEncode({
          'identifier': identifier.trim(),
          'password': password,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final token = body['token']?.toString() ?? '';
        await setToken(token);
        await saveBiometricCredentials(identifier.trim(), password);
        return ApiResult(
          success: true,
          message: body['message'] ?? 'Login successful!',
          data: body,
          statusCode: res.statusCode,
        );
      }
      return ApiResult(
        success: false,
        message: body['message'] ?? 'Authentication failed.',
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error. Please check your internet connection.',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> requestRegistrationOtp({
    required String email,
    required String phone,
  }) async {
    try {
      final res = await http.post(
        _buildUri('/auth/request-otp'),
        headers: _headers(null),
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        }),
      );

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Verification code sent to your email.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Failed to request OTP. Please verify your connection.',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String otp,
    String? referralCode,
  }) async {
    try {
      final res = await http.post(
        _buildUri('/auth/register'),
        headers: _headers(null),
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'password': password,
          'otp': otp.trim(),
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referralCode': referralCode.trim(),
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        final token = body['token']?.toString() ?? '';
        if (token.isNotEmpty) await setToken(token);
        await saveBiometricCredentials(email.trim().toLowerCase(), password);
        return ApiResult(
          success: true,
          message: body['message'] ?? 'Registration successful!',
          data: body,
          statusCode: res.statusCode,
        );
      }
      return ApiResult(
        success: false,
        message: body['message'] ?? 'Registration failed.',
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error. Please try again.',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> loginWithPin({
    required String identifier,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        _buildUri('/auth/login-pin'),
        headers: _headers(null),
        body: jsonEncode({
          'identifier': identifier.trim(),
          'pin': pin.trim(),
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final token = body['token']?.toString() ?? '';
        await setToken(token);
        return ApiResult(
          success: true,
          message: body['message'] ?? 'PIN authentication successful!',
          data: body,
          statusCode: res.statusCode,
        );
      }
      return ApiResult(
        success: false,
        message: body['message'] ?? 'Invalid PIN.',
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(
        success: false,
        message: 'Network error.',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<bool>> setTransactionPin(String pin) async {
    try {
      final token = await getToken();
      final res = await http.post(
        _buildUri('/auth/set-pin'),
        headers: _headers(token),
        body: jsonEncode({'pin': pin.trim()}),
      );

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Transaction PIN updated.',
        data: res.statusCode == 200,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  static Future<ApiResult<bool>> changePassword({
    String? oldPassword,
    String? currentPassword,
    required String newPassword,
  }) async {
    final effectiveOld = (currentPassword ?? oldPassword ?? '').trim();
    try {
      final token = await getToken();
      final res = await http.post(
        _buildUri('/auth/change-password'),
        headers: _headers(token),
        body: jsonEncode({
          'oldPassword': effectiveOld,
          'currentPassword': effectiveOld,
          'newPassword': newPassword,
        }),
      );

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Password updated.',
        data: res.statusCode == 200,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  // ================= 2. USER PROFILE & WALLET =================

  static Future<ApiResult<UserRecord>> getMe() async {
    try {
      final token = await getToken();
      if (token == null) return ApiResult(success: false, message: 'Unauthenticated', statusCode: 401);

      final res = await http.get(_buildUri('/auth/me'), headers: _headers(token));
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        return ApiResult(
          success: true,
          message: 'Profile retrieved',
          data: UserRecord.fromJson(body['data'] ?? body['user']),
          statusCode: res.statusCode,
        );
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to get profile', statusCode: res.statusCode);
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  static Future<ApiResult<UserRecord>> fetchProfile() => getMe();

  static Future<ApiResult<WalletRecord>> getWallet() async {
    try {
      final token = await getToken();
      if (token == null) return ApiResult(success: false, message: 'Unauthenticated', statusCode: 401);

      final res = await http.get(_buildUri('/wallet'), headers: _headers(token));
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final rawWallet = body['data'] ?? body['wallet'];
        if (rawWallet != null && rawWallet is Map<String, dynamic>) {
          return ApiResult(
            success: true,
            message: 'Wallet retrieved',
            data: WalletRecord.fromJson(rawWallet),
            statusCode: res.statusCode,
          );
        }
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to get wallet', statusCode: res.statusCode);
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  static Future<ApiResult<WalletRecord>> fetchWallet() => getWallet();

  static Future<ApiResult<Map<String, dynamic>>> getManualBank() async {
    try {
      final token = await getToken();
      var res = await http.get(_buildUri('/wallet/manual-bank'), headers: _headers(token));
      if (res.statusCode != 200) {
        res = await http.get(_buildUri('/admin/bank'), headers: _headers(token));
      }
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final bData = body['data'] ?? body['bank'];
        if (bData != null && bData is Map<String, dynamic>) {
          return ApiResult(success: true, message: 'Bank info loaded', data: bData);
        }
      }
      return ApiResult(
        success: true,
        message: 'Default bank',
        data: {
          'bankName': 'Moniepoint Microfinance Bank',
          'accountNumber': '8123456789',
          'accountName': 'MBK TELECOMS LTD (OFFICIAL)',
          'whatsappNotificationPhone': '08123456789',
          'instructions': 'Transfer exact amount, include registered phone as reference, and submit receipt to WhatsApp for instant 3-minute wallet credit.',
        },
      );
    } catch (_) {
      return ApiResult(
        success: true,
        message: 'Offline bank fallback',
        data: {
          'bankName': 'Moniepoint Microfinance Bank',
          'accountNumber': '8123456789',
          'accountName': 'MBK TELECOMS LTD (OFFICIAL)',
          'whatsappNotificationPhone': '08123456789',
          'instructions': 'Transfer exact amount, include registered phone as reference, and submit receipt to WhatsApp for instant 3-minute wallet credit.',
        },
      );
    }
  }

  // ================= 3. SERVICES: AIRTIME & DATA =================

  static Future<ApiResult<List<DataPlanRecord>>> getDataPlans({String? network}) async {
    try {
      final token = await getToken();
      final q = network != null ? {'network': network.toUpperCase()} : null;
      var res = await http.get(_buildUri('/services/data/plans', q), headers: _headers(token));
      if (res.statusCode != 200) {
        res = await http.get(_buildUri('/admin/plans', q), headers: _headers(token));
      }

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final List list = (body['data'] ?? body['plans']) ?? [];
        final plans = list.map((p) => DataPlanRecord.fromJson(p)).toList();
        return ApiResult(success: true, message: 'Plans loaded', data: plans, statusCode: res.statusCode);
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to load plans', statusCode: res.statusCode);
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  static Future<ApiResult<List<DataPlanRecord>>> fetchDataPlans({String? network}) => getDataPlans(network: network);

  static Future<ApiResult<Map<String, dynamic>>> buyAirtime({
    required String network,
    required double amount,
    required String phone,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'network': network.toUpperCase(),
        'amount': amount,
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/airtime/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/airtime'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Airtime purchase processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Transaction request timed out or connection error. Please retry.', statusCode: 0);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> purchaseAirtime({
    required String network,
    required double amount,
    required String phone,
    required String pin,
  }) => buyAirtime(network: network, amount: amount, phone: phone, pin: pin);

  static Future<ApiResult<Map<String, dynamic>>> buyData({
    required String network,
    required String planId,
    required String phone,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'network': network.toUpperCase(),
        'planId': planId,
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/data/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/data'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Data bundle processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Transaction request timed out or connection error. Please retry.', statusCode: 0);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> purchaseData({
    required String network,
    required String planId,
    required String phone,
    required String pin,
  }) => buyData(network: network, planId: planId, phone: phone, pin: pin);

  // ================= 4. CABLE TV =================

  static Future<ApiResult<String>> verifySmartcard({
    required String provider,
    required String smartcard,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'provider': provider.toLowerCase(),
        'smartcard': smartcard.trim(),
        'smartcardNumber': smartcard.trim(),
      });

      var res = await http.post(
        _buildUri('/services/cable/validate'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/cable/verify-card'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 12));
      }

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final name = body['data']?['customerName']?.toString() ??
            body['customerName']?.toString() ??
            body['name']?.toString() ??
            'VERIFIED CUSTOMER';
        return ApiResult(success: true, message: 'Verified', data: name);
      }
      return ApiResult(success: false, message: body['message'] ?? 'Smartcard not found');
    } catch (e) {
      return ApiResult(success: false, message: 'Verification timed out or connection error.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> renewCable({
    required String provider,
    required String smartcard,
    required String packageName,
    required String packageId,
    required double price,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'provider': provider.toLowerCase(),
        'packageId': packageId,
        'packageName': packageName,
        'smartcard': smartcard.trim(),
        'smartcardNumber': smartcard.trim(),
        'price': price,
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/cable/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/cable'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Cable TV renewal processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Renewal timed out or connection error.', statusCode: 0);
    }
  }

  // ================= 5. ELECTRICITY =================

  static Future<ApiResult<String>> verifyMeter({
    required String disco,
    required String meterNumber,
    required String meterType,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'disco': disco.toLowerCase(),
        'meterNumber': meterNumber.trim(),
        'meter': meterNumber.trim(),
        'meterType': meterType.toLowerCase(),
      });

      var res = await http.post(
        _buildUri('/services/electricity/validate'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/electricity/verify-meter'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 12));
      }

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final name = body['data']?['customerName']?.toString() ??
            body['customerName']?.toString() ??
            body['name']?.toString() ??
            'VERIFIED CUSTOMER';
        return ApiResult(success: true, message: 'Verified', data: name);
      }
      return ApiResult(success: false, message: body['message'] ?? 'Meter verification failed');
    } catch (e) {
      return ApiResult(success: false, message: 'Verification timed out or connection error.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> payElectricity({
    required String disco,
    required String meterNumber,
    required String meterType,
    required double amount,
    required String phone,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'disco': disco.toLowerCase(),
        'meterNumber': meterNumber.trim(),
        'meter': meterNumber.trim(),
        'meterType': meterType.toLowerCase(),
        'amount': amount,
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/electricity/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/electricity'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Electricity token generated.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Payment timed out or connection error.', statusCode: 0);
    }
  }

  // ================= 6. EXAM PINS =================

  static Future<ApiResult<Map<String, dynamic>>> buyExamPin({
    required String examName,
    required int quantity,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'examName': examName.toUpperCase(),
        'examType': examName.toUpperCase(),
        'quantity': quantity,
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/exam/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/exampin'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Exam PIN purchase processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Request timed out or network error. Please retry.', statusCode: 0);
    }
  }

  // ================= 7. GLO ALPHA & SMILE 4G =================

  static Future<ApiResult<Map<String, dynamic>>> buyAlphaTopup({
    required String phone,
    required double amount,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        'amount': amount,
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/alpha/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/alpha'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Glo Alpha Topup processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Request timed out or network error. Please retry.', statusCode: 0);
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> buySmile({
    required String accountId,
    required String type,
    required double amount,
    required String pin,
  }) async {
    try {
      final token = await getToken();
      final payload = jsonEncode({
        'accountId': accountId.trim(),
        'type': type,
        'amount': amount,
        'pin': pin.trim(),
      });

      var res = await http.post(
        _buildUri('/services/smile/purchase'),
        headers: _headers(token),
        body: payload,
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 404) {
        res = await http.post(
          _buildUri('/services/smile'),
          headers: _headers(token),
          body: payload,
        ).timeout(const Duration(seconds: 15));
      }

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Smile 4G topup processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Request timed out or network error. Please retry.', statusCode: 0);
    }
  }

  // ================= 8. AIRTIME TO CASH =================

  static Future<ApiResult<Map<String, dynamic>>> submitAirtime2Cash({
    required String network,
    required String phone,
    required double amount,
  }) async {
    try {
      final token = await getToken();
      final res = await http.post(
        _buildUri('/services/airtime2cash/submit'),
        headers: _headers(token),
        body: jsonEncode({
          'network': network.toUpperCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'amount': amount,
        }),
      );

      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'A2C request logged.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  // ================= 9. TRANSACTIONS & ANNOUNCEMENTS =================

  static Future<ApiResult<List<TransactionRecord>>> getTransactions() async {
    try {
      final token = await getToken();
      final res = await http.get(_buildUri('/wallet/transactions'), headers: _headers(token));

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final List list = (body['data'] ?? body['transactions']) ?? [];
        final txs = list.map((t) => TransactionRecord.fromJson(t)).toList();
        return ApiResult(success: true, message: 'Transactions loaded', data: txs, statusCode: res.statusCode);
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to load ledger', statusCode: res.statusCode);
    } catch (e) {
      return ApiResult(success: false, message: 'Network error.', statusCode: 0);
    }
  }

  static Future<ApiResult<List<TransactionRecord>>> fetchTransactions() => getTransactions();

  static Future<ApiResult<List<String>>> getAnnouncements() async {
    try {
      final res = await http.get(_buildUri('/admin/announcements'), headers: _headers(null));
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final text = body['data']?['announcementText']?.toString() ?? '⚡ Welcome to MBKDATASUB - Instant Automated Topups!';
        return ApiResult(success: true, message: 'Loaded', data: [text]);
      }
      return ApiResult(success: true, message: 'Default', data: ['⚡ Welcome to MBKDATASUB - Fast & Automated Services.']);
    } catch (_) {
      return ApiResult(success: true, message: 'Offline', data: ['⚡ Welcome to MBKDATASUB - Fast & Automated Services.']);
    }
  }
}
