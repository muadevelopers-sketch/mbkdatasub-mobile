# MBKDATASUB Native Mobile Application (Android + iOS)

Production-grade Flutter native mobile application built for **MBKDATASUB** (`https://mbkdatasub.com.ng`), adhering to FlutterFlow project standards for seamless visual editing and maintenance.

---

## 1. Project Overview & Design System

- **Brand:** MBKDATASUB
- **Palette (from sample design reference):**
  - **Primary Dark (Header & Main CTAs):** `#0A1C6A` (Royal Navy)
  - **Primary Accent (Badges, Links):** `#1E5BF8` (Electric Royal Blue)
  - **Pill / Chip Surface:** `#EEF4FF` (Ice Blue Tint)
  - **Canvas Background:** `#F8FAFC`
  - **Card Surface:** `#FFFFFF` with smooth 18-24px rounded corners and ambient elevation
  - **Success / Credit:** `#22C55E`
  - **Error / Debit / Lockout:** `#EF4444`
- **Typography:** Plus Jakarta Sans (Headlines) & Inter (Body)
- **Component Patterns:**
  - Floating white balance card with eye hide/reveal toggle and 1-tap copyable dedicated accounts (PalmPay & Paga).
  - Quick action buttons (*Add Money*, *Pricing*).
  - Promo banner carousel.
  - 2×4 rounded circular quick service icon grid.
  - Bottom sheet purchase summary with embedded 4-digit PIN pad and fingerprint/Face ID.
  - Animated transaction success/failure modals with 1-tap token copy.
  - 4-tab bottom navigation (*Home*, *History*, *Referral*, *Profile*).

---

## 2. Directory Structure (FlutterFlow Compatible)

```
mobile_app/
├── assets/
│   └── images/
│       ├── logo.png               # Official MBKDATASUB planetary logo
│       └── logo.jpg
├── lib/
│   ├── flutter_flow/
│   │   ├── flutter_flow_theme.dart     # Central design tokens & colors
│   │   ├── flutter_flow_util.dart      # Money formatting, toast helpers, dates
│   │   └── flutter_flow_widgets.dart   # Standard FlutterFlow buttons & controls
│   ├── backend/
│   │   ├── api_requests/
│   │   │   └── api_calls.dart          # Full REST client for mbkdatasub.com.ng
│   │   ├── schema/
│   │   │   └── struct/
│   │   │       ├── user_record.dart
│   │   │       ├── wallet_record.dart
│   │   │       ├── data_plan_record.dart
│   │   │       ├── transaction_record.dart
│   │   │       └── service_config_record.dart
│   │   └── app_state.dart              # Global reactive state provider
│   ├── components/
│   │   ├── custom_pin_pad_widget.dart           # Custom numeric pad + biometrics
│   │   ├── purchase_summary_bottom_sheet.dart  # Modal summary with PIN verification
│   │   ├── transaction_status_modal.dart       # Animated success/failure modal
│   │   ├── wallet_card_widget.dart             # Floating wallet & account card
│   │   ├── service_grid_widget.dart            # Quick services grid
│   │   └── promo_banner_widget.dart            # Horizontal banner carousel
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── welcome_page.dart
│   │   │   ├── sign_in_page.dart
│   │   │   ├── sign_up_page.dart
│   │   │   ├── pin_setup_page.dart
│   │   │   └── forgot_password_page.dart
│   │   ├── main/
│   │   │   ├── main_nav_shell.dart
│   │   │   ├── home_dashboard_page.dart
│   │   │   ├── history_page.dart
│   │   │   ├── referral_page.dart
│   │   │   └── profile_page.dart
│   │   ├── services/
│   │   │   ├── airtime_page.dart
│   │   │   ├── data_page.dart
│   │   │   ├── cable_page.dart
│   │   │   ├── electricity_page.dart
│   │   │   ├── exam_pin_page.dart
│   │   │   ├── airtime_to_cash_page.dart
│   │   │   └── alpha_smile_page.dart
│   │   ├── wallet/
│   │   │   ├── add_money_page.dart
│   │   │   └── receipt_page.dart
│   │   └── settings/
│   │       ├── change_pin_page.dart
│   │       ├── change_password_page.dart
│   │       ├── live_pricing_page.dart
│   │       └── support_page.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 3. How to Run Locally

### Prerequisites
- Flutter SDK 3.16+ installed ([flutter.dev](https://flutter.dev))
- Android Studio / Xcode

### Commands
```bash
# 1. Navigate to the mobile app directory
cd "c:\Users\user\Desktop\MBKDATASUB V2\mobile_app"

# 2. Get dependencies
flutter pub get

# 3. Launch on connected Android / iOS device or simulator
flutter run
```

---

## 4. How to Build Production APK / AAB (Google Play) & IPA (App Store)

### Android Build
```bash
# Generate standalone installable release APK:
flutter build apk --release

# The APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk

# Generate Google Play App Bundle (AAB):
flutter build appbundle --release

# The AAB will be located at:
# build/app/outputs/bundle/release/app-release.aab
```

### iOS Build
```bash
flutter build ipa --release
```

---

## 5. Live Server Synchronization Guarantee

The app maintains **zero hardcoded pricing or service lists**. Everything is pulled dynamically from `https://mbkdatasub.com.ng/api/v1/`:
1. **Changing Data Plan Prices:** When updated in the Admin Dashboard (`/admin/plans`), the app fetches fresh prices directly before rendering the plan cards and before completing checkout.
2. **Real-Time Balance Updates:** Supported via automated pull-to-refresh and reactive state updates on every transaction.
3. **Dedicated Virtual Accounts:** PalmPay and Paga dedicated account numbers assigned by ASPFIY display automatically in the wallet card with 1-tap copy functionality.
