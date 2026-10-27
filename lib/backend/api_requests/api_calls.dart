import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../schema/struct/user_record.dart';
import '../schema/struct/wallet_record.dart';
import '../schema/struct/data_plan_record.dart';
import '../schema/struct/transaction_record.dart';
import '../schema/struct/service_config_record.dart';

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

  // Token cache
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

  static Future<void> clearAuth() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  static Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ================= 1. AUTHENTICATION =================

  static Future<ApiResult<Map<String, dynamic>>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
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
        message: 'Network error. Please check your internet connection and try again.',
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
        Uri.parse('$baseUrl/auth/login-pin'),
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
        message: body['message'] ?? 'Invalid PIN or account not found.',
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

  static Future<ApiResult<Map<String, dynamic>>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? referralCode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(null),
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'password': password,
          if (referralCode != null && referralCode.trim().isNotEmpty)
            'referralCode': referralCode.trim(),
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        final token = body['token']?.toString() ?? '';
        if (token.isNotEmpty) await setToken(token);
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
        message: 'Network connection failed during registration.',
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<UserRecord>> getMe() async {
    final token = await getToken();
    if (token == null) {
      return ApiResult(success: false, message: 'Not authenticated.', statusCode: 401);
    }
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _headers(token),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true && body['user'] != null) {
        return ApiResult(
          success: true,
          message: 'Profile fetched.',
          data: UserRecord.fromJson(body['user']),
        );
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to load profile.');
    } catch (e) {
      return ApiResult(success: false, message: 'Connection error loading user profile.');
    }
  }

  static Future<ApiResult<bool>> setTransactionPin(String pin) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/set-pin'),
        headers: _headers(token),
        body: jsonEncode({'pin': pin.trim()}),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? (res.statusCode == 200 ? 'Security PIN saved!' : 'Failed to set PIN.'),
        data: res.statusCode == 200 && body['success'] == true,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Connection error setting transaction PIN.');
    }
  }

  static Future<ApiResult<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: _headers(token),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Password update status received.',
        data: res.statusCode == 200 && body['success'] == true,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error updating password.');
    }
  }

  // ================= 2. WALLET & TRANSACTIONS =================

  static Future<ApiResult<WalletRecord>> getWallet() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: _headers(token),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['wallet'] != null) {
        return ApiResult(
          success: true,
          message: 'Wallet balance fetched.',
          data: WalletRecord.fromJson(body['wallet']),
        );
      }
      return ApiResult(success: false, message: body['message'] ?? 'Failed to load wallet.');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error connecting to wallet.');
    }
  }

  static Future<ApiResult<List<TransactionRecord>>> getTransactions() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/wallet/transactions'),
        headers: _headers(token),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['transactions'] is List) {
        final list = (body['transactions'] as List)
            .map((t) => TransactionRecord.fromJson(t))
            .toList();
        return ApiResult(success: true, message: 'Transactions loaded.', data: list);
      }
      return ApiResult(success: false, message: body['message'] ?? 'No transactions found.');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error loading transaction ledger.');
    }
  }

  // ================= 3. DYNAMIC DATA PLANS (FRESH LOOKUP) =================

  static Future<ApiResult<List<DataPlanRecord>>> getDataPlans() async {
    final token = await getToken();
    try {
      // Query plans directly from server to guarantee 100% real-time pricing
      final res = await http.get(
        Uri.parse('$baseUrl/admin/plans'),
        headers: _headers(token),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['plans'] is List) {
        final plans = (body['plans'] as List)
            .map((p) => DataPlanRecord.fromJson(p))
            .where((p) => p.isActive)
            .toList();
        return ApiResult(success: true, message: 'Plans fetched fresh from server.', data: plans);
      }
      return ApiResult(success: false, message: body['message'] ?? 'Could not fetch data plans.');
    } catch (e) {
      return ApiResult(success: false, message: 'Network error fetching data plans.');
    }
  }

  // ================= 4. SERVICE PURCHASE FLOWS =================

  static Future<ApiResult<Map<String, dynamic>>> buyAirtime({
    required String network,
    required String phone,
    required double amount,
    required String pin,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/airtime'),
        headers: _headers(token),
        body: jsonEncode({
          'network': network.toUpperCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'amount': amount,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Airtime purchase response received.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network timeout during airtime checkout.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> buyData({
    required String network,
    required String phone,
    required String planId,
    required String pin,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/data'),
        headers: _headers(token),
        body: jsonEncode({
          'network': network.toUpperCase(),
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'planId': planId,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Data subscription completed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network timeout during data bundle order.');
    }
  }

  static Future<ApiResult<String>> verifySmartcard({
    required String provider,
    required String smartcard,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/cable/verify-card'),
        headers: _headers(token),
        body: jsonEncode({
          'provider': provider.toLowerCase(),
          'smartcard': smartcard.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['customerName'] != null) {
        return ApiResult(
          success: true,
          message: 'Smartcard verified.',
          data: body['customerName']?.toString(),
        );
      }
      return ApiResult(success: false, message: body['message'] ?? 'Invalid IUC/Smartcard number.');
    } catch (e) {
      return ApiResult(success: false, message: 'Unable to verify smartcard right now.');
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
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/cable'),
        headers: _headers(token),
        body: jsonEncode({
          'provider': provider.toLowerCase(),
          'smartcard': smartcard.trim(),
          'packageName': packageName,
          'packageId': packageId,
          'price': price,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Cable renewal response.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network timeout during cable subscription.');
    }
  }

  static Future<ApiResult<String>> verifyMeter({
    required String disco,
    required String meterNumber,
    required String meterType,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/electricity/verify-meter'),
        headers: _headers(token),
        body: jsonEncode({
          'disco': disco.toLowerCase(),
          'meterNumber': meterNumber.trim(),
          'meterType': meterType.toLowerCase(),
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['customerName'] != null) {
        return ApiResult(
          success: true,
          message: 'Meter verified.',
          data: body['customerName']?.toString(),
        );
      }
      return ApiResult(success: false, message: body['message'] ?? 'Invalid meter number.');
    } catch (e) {
      return ApiResult(success: false, message: 'Unable to verify meter at this time.');
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
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/electricity'),
        headers: _headers(token),
        body: jsonEncode({
          'disco': disco.toLowerCase(),
          'meterNumber': meterNumber.trim(),
          'meterType': meterType.toLowerCase(),
          'amount': amount,
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Electricity payment processed.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error during electricity recharge.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> buyExamPin({
    required String examName,
    required int quantity,
    required String pin,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/exampin'),
        headers: _headers(token),
        body: jsonEncode({
          'examName': examName.toUpperCase(),
          'quantity': quantity,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Exam PIN generation response.',
        data: body,
        statusCode: res.statusCode,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error purchasing exam PINs.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> buyAlphaTopup({
    required String phone,
    required double amount,
    required String pin,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/alpha'),
        headers: _headers(token),
        body: jsonEncode({
          'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'amount': amount,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Alpha Topup processed.',
        data: body,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error during Alpha topup.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> buySmile({
    required String accountId,
    required String type,
    String? planName,
    required double amount,
    required String pin,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/smile'),
        headers: _headers(token),
        body: jsonEncode({
          'accountId': accountId.trim(),
          'type': type,
          'planName': planName ?? 'Data Bundle',
          'amount': amount,
          'pin': pin.trim(),
        }),
      );
      final body = jsonDecode(res.body);
      return ApiResult(
        success: res.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? 'Smile recharge processed.',
        data: body,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error during Smile transaction.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> submitAirtime2Cash({
    required String network,
    required String phone,
    required double amount,
  }) async {
    final token = await getToken();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services/airtime2cash'),
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
        message: body['message'] ?? 'Airtime2Cash request submitted for review.',
        data: body,
      );
    } catch (e) {
      return ApiResult(success: false, message: 'Network error submitting Airtime to Cash.');
    }
  }

  // ================= 5. LIVE ANNOUNCEMENTS & BRANDING =================

  static Future<List<String>> getAnnouncements() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/announcements'));
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['announcements'] is List) {
        return (body['announcements'] as List)
            .map((a) => (a['message'] ?? a['title'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return ['Welcome to MBKDATASUB! Enjoy instant automated bill payments & data topups.'];
  }

  static Future<Map<String, dynamic>> getManualBank() async {
    final token = await getToken();
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/admin/bank'),
        headers: _headers(token),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['bank'] != null) {
        return body['bank'];
      }
    } catch (_) {}
    return {
      'bankName': 'Wema Bank',
      'accountNumber': '9900000001',
      'accountName': 'MBKDATASUB VENTURES',
      'instruction': 'Transfer directly and contact WhatsApp support for instant confirmation.',
    };
  }
}
