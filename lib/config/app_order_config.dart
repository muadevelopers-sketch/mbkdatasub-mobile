/**
 * Global Configuration for "GET YOUR APP" Feature
 * Centralized constants - no scattered hardcoded values
 */
class AppOrderConfig {
  // Pricing Constants
  static const int appPrice = 250000;
  static const String priceDisplay = 'NGN 250,000';
  static const String pricePlain = 'NGN250000';
  static const String packageDescription = 'Covers both custom website and mobile app';
  static const String packageType = 'app';

  // Step 2 Payment Details
  static const String accountNumber = '8131555945';
  static const String bank = 'OPAY';
  static const String accountName = 'ABDUSSALAM A SIRAJO';
  static const String amountToPay = 'NGN250000';

  // Contact & WhatsApp
  static const String whatsappNumber = '2349047050681';
  static const String whatsappBaseUrl = 'https://wa.me/2349047050681';

  // Validation Limits
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'pdf'];

  // API Endpoints
  static const String ordersEndpoint = 'https://mbkdatasub.com.ng/api/orders';
  static const String fallbackOrdersEndpoint = 'https://mbkdatasub.com.ng/api/v1/orders';

  // Success Message
  static const String successMessage = "Thank you! We'll confirm your payment and contact you shortly.";
}
