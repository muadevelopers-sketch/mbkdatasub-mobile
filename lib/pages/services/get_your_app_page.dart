import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../backend/api_requests/api_calls.dart';
import '../../backend/app_state.dart';
import '../../config/app_order_config.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class GetYourAppPage extends StatefulWidget {
  const GetYourAppPage({super.key});

  @override
  State<GetYourAppPage> createState() => _GetYourAppPageState();
}

class _GetYourAppPageState extends State<GetYourAppPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 = Info, 1 = Payment, 2 = Receipt, 3 = Success

  // Controllers for Step 1
  final _fullNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _appNameController = TextEditingController();

  // Form errors
  String? _fullNameError;
  String? _whatsappError;
  String? _emailError;
  String? _appNameError;

  // Step 2 state
  bool _copiedAccount = false;

  // Step 3 state
  File? _receiptFile;
  String? _receiptFileName;
  int? _receiptFileSize;
  bool _isPdf = false;
  String? _receiptFileError;

  // Submission state
  bool _isSubmitting = false;
  String? _submitError;
  String? _uploadedReceiptUrl;
  String? _createdOrderId;

  @override
  void initState() {
    super.initState();
    // Pre-fill user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<FFAppState>(context, listen: false);
      final user = appState.user;
      if (user != null) {
        if (_fullNameController.text.isEmpty && user.fullName.isNotEmpty) {
          _fullNameController.text = user.fullName;
        }
        if (_whatsappController.text.isEmpty && user.phone.isNotEmpty) {
          _whatsappController.text = user.phone;
        }
        if (_emailController.text.isEmpty && user.email.isNotEmpty) {
          _emailController.text = user.email;
        }
        _validateStep1(silent: true);
        setState(() {});
      }
    });

    _fullNameController.addListener(() => _validateStep1(silent: true));
    _whatsappController.addListener(() => _validateStep1(silent: true));
    _emailController.addListener(() => _validateStep1(silent: true));
    _appNameController.addListener(() => _validateStep1(silent: true));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _appNameController.dispose();
    super.dispose();
  }

  // Step 1 Validation
  bool _validateStep1({bool silent = false}) {
    final name = _fullNameController.text.trim();
    final whatsapp = _whatsappController.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final email = _emailController.text.trim();
    final appName = _appNameController.text.trim();

    String? nameErr;
    String? phoneErr;
    String? emailErr;
    String? appErr;

    if (name.isEmpty) {
      nameErr = 'Full Name is required.';
    } else if (name.length < 3) {
      nameErr = 'Full Name must be at least 3 characters.';
    }

    final phoneRegex = RegExp(r'^(?:\+?234|0)[789][01]\d{8}$');
    final generalPhoneRegex = RegExp(r'^(?:\+?234|0)\d{10}$');
    if (whatsapp.isEmpty) {
      phoneErr = 'WhatsApp number is required.';
    } else if (!phoneRegex.hasMatch(whatsapp) && !generalPhoneRegex.hasMatch(whatsapp)) {
      phoneErr = 'Enter a valid number (e.g. 08012345678 or +2348012345678).';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (email.isEmpty) {
      emailErr = 'Email Address is required.';
    } else if (!emailRegex.hasMatch(email)) {
      emailErr = 'Please enter a valid email address.';
    }

    if (appName.isEmpty) {
      appErr = 'App Name is required.';
    } else if (appName.length < 2) {
      appErr = 'App Name must be at least 2 characters.';
    }

    if (!silent) {
      setState(() {
        _fullNameError = nameErr;
        _whatsappError = phoneErr;
        _emailError = emailErr;
        _appNameError = appErr;
      });
    }

    return nameErr == null && phoneErr == null && emailErr == null && appErr == null;
  }

  void _goToStep(int stepIndex) {
    setState(() => _currentStep = stepIndex);
    _pageController.animateToPage(
      stepIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  // Copy Account Number
  void _copyAccountNumber() {
    Clipboard.setData(const ClipboardData(text: AppOrderConfig.accountNumber));
    setState(() => _copiedAccount = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Account number copied to clipboard!'),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copiedAccount = false);
    });
  }

  // Pick Receipt File
  Future<void> _pickReceiptFile() async {
    setState(() => _receiptFileError = null);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppOrderConfig.allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final size = await file.length();

        // Check size limit (5MB)
        if (size > AppOrderConfig.maxFileSizeBytes) {
          setState(() {
            _receiptFileError = 'File exceeds 5MB limit. Please choose a smaller file.';
          });
          return;
        }

        // Check extension
        final ext = platformFile.extension?.toLowerCase() ?? '';
        if (!AppOrderConfig.allowedExtensions.contains(ext)) {
          setState(() {
            _receiptFileError = 'Unsupported format. Allowed: JPG, PNG, WEBP, or PDF.';
          });
          return;
        }

        setState(() {
          _receiptFile = file;
          _receiptFileName = platformFile.name;
          _receiptFileSize = size;
          _isPdf = ext == 'pdf';
        });
      }
    } catch (e) {
      setState(() {
        _receiptFileError = 'Failed to select file. Please try again.';
      });
    }
  }

  // Send Order Details & Upload Receipt
  Future<void> _submitOrder() async {
    if (_receiptFile == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final token = await MbkApi.getToken();
      final uri = Uri.parse(AppOrderConfig.ordersEndpoint);

      var request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['fullName'] = _fullNameController.text.trim();
      request.fields['whatsapp'] = _whatsappController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['projectName'] = _appNameController.text.trim();
      request.fields['appName'] = _appNameController.text.trim();
      request.fields['name'] = _appNameController.text.trim();
      request.fields['packageType'] = AppOrderConfig.packageType;

      // Attach file
      final multipartFile = await http.MultipartFile.fromPath(
        'receipt',
        _receiptFile!.path,
        filename: _receiptFileName ?? 'receipt.jpg',
      );
      request.files.add(multipartFile);

      // Send request with timeout
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final responseBody = await streamedResponse.stream.bytesToString();

      Map<String, dynamic> responseData = {};
      try {
        responseData = json.decode(responseBody);
      } catch (_) {
        throw Exception('Server returned an unexpected response. Please try again.');
      }

      if (streamedResponse.statusCode != 200 || responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to submit order.');
      }

      final receiptUrl = responseData['receiptUrl'] ??
          responseData['data']?['receiptUrl'] ??
          'https://mbkdatasub.com.ng/uploads/order-receipt.jpg';
      final orderId = responseData['orderId'] ?? responseData['data']?['orderId'] ?? 'ORD-PENDING';

      setState(() {
        _uploadedReceiptUrl = receiptUrl;
        _createdOrderId = orderId;
      });

      // Prepare WhatsApp Message
      final message = 'NEW ORDER - GET YOUR APP\n'
          'Full Name: ${_fullNameController.text.trim()}\n'
          'WhatsApp Number: ${_whatsappController.text.trim()}\n'
          'Email: ${_emailController.text.trim()}\n'
          'App Name: ${_appNameController.text.trim()}\n'
          'Amount Paid: ${AppOrderConfig.pricePlain}\n'
          'Payment Receipt: $receiptUrl';

      final waUri = Uri.parse(
          'https://wa.me/${AppOrderConfig.whatsappNumber}?text=${Uri.encodeComponent(message)}');

      // Launch WhatsApp in external app
      try {
        if (await canLaunchUrl(waUri)) {
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        // Continue to success screen even if WhatsApp fails to open directly
      }

      // Navigate to Success screen
      _goToStep(3);
    } catch (e) {
      setState(() {
        _submitError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Share Receipt Document via SharePlus
  Future<void> _shareReceiptDocument() async {
    if (_receiptFile == null) return;
    try {
      final xFile = XFile(_receiptFile!.path, name: _receiptFileName);
      await Share.shareXFiles(
        [xFile],
        text: 'MBKDATASUB Payment Receipt - ${_appNameController.text.trim()}',
      );
    } catch (_) {
      showErrorToast(context, 'Could not launch file share.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0 && _currentStep < 3) {
              _goToStep(_currentStep - 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'GET YOUR APP',
          style: theme.titleMedium.override(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator Header (Only shown during steps 0, 1, 2)
            if (_currentStep < 3) _buildStepIndicator(theme),

            // Main Steps PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Controlled via buttons
                children: [
                  _buildStep1Form(theme),
                  _buildStep2Payment(theme),
                  _buildStep3Receipt(theme),
                  _buildStep4Success(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step Indicator Widget
  Widget _buildStepIndicator(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: theme.alternate, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(theme, 0, 'Details', Icons.edit_note_rounded),
          _buildStepLine(theme, 0),
          _buildStepItem(theme, 1, 'Payment', Icons.account_balance_wallet_rounded),
          _buildStepLine(theme, 1),
          _buildStepItem(theme, 2, 'Receipt', Icons.receipt_long_rounded),
        ],
      ),
    );
  }

  Widget _buildStepItem(FlutterFlowTheme theme, int index, String label, IconData icon) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? theme.success
                : isActive
                    ? theme.primary
                    : const Color(0xFFF1F5F9),
            border: Border.all(
              color: isActive ? theme.primaryAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : theme.secondaryText,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.labelSmall.override(
            color: isActive ? theme.primaryText : theme.secondaryText,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(FlutterFlowTheme theme, int afterIndex) {
    final isDone = _currentStep > afterIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isDone ? theme.success : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ================= STEP 1: INFORMATION FORM =================
  Widget _buildStep1Form(FlutterFlowTheme theme) {
    final isValid = _validateStep1(silent: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Badge Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.primaryAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryAccent.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEBSITE + MOBILE APP PACKAGE',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Launch Your Own VTU Business',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This complete package covers both your custom website and Android app.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Rounded Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080A1C6A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                _buildFieldLabel('Full Name', true, theme),
                _buildTextField(
                  controller: _fullNameController,
                  hint: 'e.g. Ibrahim Mohammed',
                  icon: Icons.person_outline_rounded,
                  theme: theme,
                  error: _fullNameError,
                ),
                const SizedBox(height: 16),

                // WhatsApp Number
                _buildFieldLabel('WhatsApp Number', true, theme),
                _buildTextField(
                  controller: _whatsappController,
                  hint: 'e.g. 08012345678 or +2348012345678',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  theme: theme,
                  error: _whatsappError,
                ),
                const SizedBox(height: 16),

                // Email Address
                _buildFieldLabel('Email Address', true, theme),
                _buildTextField(
                  controller: _emailController,
                  hint: 'e.g. ibrahim@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  theme: theme,
                  error: _emailError,
                ),
                const SizedBox(height: 16),

                // App Name
                _buildFieldLabel('App Name', true, theme),
                _buildTextField(
                  controller: _appNameController,
                  hint: 'e.g. SmartData Hub',
                  icon: Icons.apps_rounded,
                  theme: theme,
                  error: _appNameError,
                ),
                const SizedBox(height: 16),

                // Price Read-Only Field
                _buildFieldLabel('Package Price', false, theme),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: theme.secondaryText, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppOrderConfig.priceDisplay,
                                style: theme.titleMedium.override(
                                  color: theme.primaryText,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                '(this package covers both website and app)',
                                style: theme.labelSmall.override(
                                  color: theme.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'FIXED',
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PAY NOW Button (Disabled until valid)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isValid
                  ? () {
                      if (_validateStep1()) {
                        _goToStep(1);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: isValid ? 4 : 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PAY NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= STEP 2: PAYMENT DETAILS CARD =================
  Widget _buildStep2Payment(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'STEP 2 OF 3: BANK TRANSFER',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make Bank Transfer',
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transfer exact amount to the official company account below',
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stylish Financial Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryDark, theme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryDark.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFF34D399), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'OFFICIAL PAYMENT ACCOUNT',
                          style: theme.labelSmall.override(
                            color: const Color(0xFF34D399),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppOrderConfig.bank,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Account Number
                Text(
                  'ACCOUNT NUMBER',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppOrderConfig.accountNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    InkWell(
                      onTap: _copyAccountNumber,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _copiedAccount
                              ? const Color(0xFF22C55E)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _copiedAccount ? Icons.check_rounded : Icons.copy_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _copiedAccount ? 'Copied!' : 'Copy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(color: Colors.white24, height: 28),

                // Account Name & Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT NAME',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppOrderConfig.accountName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AMOUNT TO PAY',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppOrderConfig.amountToPay,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Instructions card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transfer exactly ${AppOrderConfig.priceDisplay} to the OPAY account above using your banking app or USSD. Once sent, click "I HAVE PAID" below to upload your payment receipt.',
                    style: theme.bodySmall.override(
                      color: theme.secondaryText,
                      lineHeight: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Action Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _goToStep(0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _goToStep(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'I HAVE PAID',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= STEP 3: RECEIPT UPLOAD =================
  Widget _buildStep3Receipt(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'STEP 3 OF 3: PROOF OF PAYMENT',
                    style: TextStyle(
                      color: theme.primaryAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload Payment Receipt',
                  style: theme.headlineSmall.override(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload screenshot or PDF receipt from your bank transfer',
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Pick File Drop Zone
          InkWell(
            onTap: _isSubmitting ? null : _pickReceiptFile,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _receiptFile != null
                      ? const Color(0xFF22C55E)
                      : _receiptFileError != null
                          ? theme.error
                          : const Color(0xFFCBD5E1),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080A1C6A),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _receiptFile != null
                  ? Column(
                      children: [
                        // Preview
                        if (_isPdf)
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.picture_as_pdf_rounded,
                                color: Color(0xFFEF4444), size: 36),
                          )
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _receiptFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _receiptFileName ?? 'Payment Receipt',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleSmall.override(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${((_receiptFileSize ?? 0) / 1024 / 1024).toFixed(2)} MB • Tap to replace file',
                          style: theme.bodySmall.override(color: theme.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Receipt selected successfully',
                              style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(Icons.cloud_upload_outlined,
                              color: theme.primaryAccent, size: 30),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Tap to choose receipt',
                          style: theme.titleSmall.override(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accepts JPG, PNG, WEBP, or PDF up to 5MB',
                          style: theme.bodySmall.override(
                            color: theme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // File error banner
          if (_receiptFileError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: theme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _receiptFileError!,
                      style: TextStyle(color: theme.error, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Submit error banner with Retry
          if (_submitError != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: theme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Failed',
                        style: TextStyle(color: theme.error, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _submitError!,
                    style: TextStyle(color: theme.error, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                      label: const Text('Retry Upload',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Action Buttons: "Show the button SEND YOUR DETAILS only after a receipt is selected"
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : () => _goToStep(1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              if (_receiptFile != null)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'SENDING DETAILS...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SEND YOUR DETAILS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================= STEP 4: SUCCESS SCREEN =================
  Widget _buildStep4Success(FlutterFlowTheme theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Success animated badge
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 50),
          ),
          const SizedBox(height: 20),

          Text(
            'Order Submitted!',
            style: theme.headlineSmall.override(
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppOrderConfig.successMessage,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
              lineHeight: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // Order summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Order Reference', _createdOrderId ?? 'ORD-APP-CONFIRMED', theme, isMono: true),
                const Divider(height: 20),
                _buildSummaryRow('App Name', _appNameController.text.trim(), theme),
                const Divider(height: 20),
                _buildSummaryRow('Client Name', _fullNameController.text.trim(), theme),
                const Divider(height: 20),
                _buildSummaryRow('Amount Paid', AppOrderConfig.pricePlain, theme, highlight: true),
                const Divider(height: 20),
                _buildSummaryRow('Status', 'Pending Confirmation', theme, isWarning: true),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Open WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final message = 'NEW ORDER - GET YOUR APP\n'
                    'Full Name: ${_fullNameController.text.trim()}\n'
                    'WhatsApp Number: ${_whatsappController.text.trim()}\n'
                    'Email: ${_emailController.text.trim()}\n'
                    'App Name: ${_appNameController.text.trim()}\n'
                    'Amount Paid: ${AppOrderConfig.pricePlain}\n'
                    'Payment Receipt: ${_uploadedReceiptUrl ?? ''}';
                final waUri = Uri.parse(
                    'https://wa.me/${AppOrderConfig.whatsappNumber}?text=${Uri.encodeComponent(message)}');
                if (await canLaunchUrl(waUri)) {
                  await launchUrl(waUri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Open WhatsApp Message',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Share receipt document via share_plus
          if (_receiptFile != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _shareReceiptDocument,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: theme.primaryAccent),
                ),
                icon: Icon(Icons.share_rounded, color: theme.primaryAccent, size: 18),
                label: Text(
                  'Share Receipt Document',
                  style: TextStyle(
                    color: theme.primaryAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Return Home
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Done & Return to Dashboard',
              style: TextStyle(
                color: theme.secondaryText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, FlutterFlowTheme theme,
      {bool highlight = false, bool isWarning = false, bool isMono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.labelSmall.override(color: theme.secondaryText)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF16A34A)
                  : isWarning
                      ? const Color(0xFFF59E0B)
                      : theme.primaryText,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, bool isRequired, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: label,
          style: theme.labelMedium.override(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FlutterFlowTheme theme,
    TextInputType keyboardType = TextInputType.text,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null ? theme.error : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.bodyMedium.override(
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.bodyMedium.override(
                color: theme.secondaryText.withOpacity(0.6),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: theme.secondaryText, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error,
              style: TextStyle(color: theme.error, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

extension DoubleFormat on double {
  String toFixed(int fractionDigits) => toStringAsFixed(fractionDigits);
}
