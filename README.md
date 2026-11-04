# MBKDATASUB V2 — Native iOS & Android Mobile Application

A fintech-grade, high-performance native mobile app for **MBK DATASUB V2**, built with **React Native (0.76)** and **Expo (SDK 52)** with 120Hz smooth animations, native tactile haptic feedback, and hardware-level biometric security.

---

## 🌟 Key Highlights & Native Features

1. **Official Brand Identity**:
   - **App Icon & Splash**: Uses official MBK DATASUB 3D Orbital sphere brand identity.
   - **Hero Home Banner Carousel**: Features the official MBK DATASUB brand ambassador poster (`assets/banner.png`) alongside active promo slides with auto-scroll and 1-tap navigation.

2. **Hardware Biometric Authorization**:
   - **Apple Face ID & Touch ID** on iPhone/iPad (`NSFaceIDUsageDescription` configured).
   - **Android BiometricPrompt & Fingerprint** on Android devices.
   - 1-tap biometric login and 1-tap payment authorization via the native `BiometricPinModal` payment sheet.

3. **Swipeable 3-Card Wallet Carousel**:
   - **Total Balance Card**: Eye toggle for balance privacy, quick "Fund" shortcut.
   - **PalmPay Dedicated Account Card**: Dedicated 10-digit account number, 1-tap copy with haptic & visual feedback.
   - **Paga Dedicated Account Card**: Distinct dedicated account number, 1-tap copy, and automated credit confirmation.
   - Fixed and hardened against duplicate account numbers.

4. **Complete Native Telecom & Utilities Services**:
   - **Mobile Data Bundles**: MTN, Airtel, Glo, 9mobile (SME, Gifting, Corporate) with auto-carrier prefix detection from phone number input.
   - **Airtime VTU Recharge**: Up to 2.5% instant cashback calculation, quick chips (₦100 to ₦5,000), and 1-tap checkout.
   - **Cable TV Renewal**: DSTV, GOtv, StarTimes with live Smartcard / IUC customer name lookup.
   - **Electricity Bills & Tokens**: IKEDC, EKEDC, AEDC, IBEDC, etc. with live meter verification and instant 20-digit token generation.
   - **Airtime to Cash**: Instant rate calculator (up to 82% payout) with direct WhatsApp admin processing.
   - **Transaction Receipts**: Shareable receipt generator with WhatsApp and native share sheet integration.

---

## 🚀 How to Run the App on Physical iPhone & Android

### Option A: Instant Live Preview with Expo Go (No Mac or Android Studio needed)

1. Install **Expo Go** from the Apple App Store (iPhone) or Google Play Store (Android).
2. Open PowerShell or Terminal in this folder:
   ```powershell
   cd mobile
   npx.cmd expo start --tunnel
   ```
3. Scan the QR code shown on screen:
   - On **iPhone**: Open Camera app and tap the Expo notification.
   - On **Android**: Open Expo Go app and tap "Scan QR Code".
4. The native app will compile and launch directly on your physical smartphone with full Face ID / Fingerprint sensor access!

---

### Option B: Build Standalone Android `.apk` / `.aab`

To generate an installable Android APK:
```powershell
npm.cmd install -g eas-cli
eas login
eas build -p android --profile preview
```
This generates a direct download link for the standalone `.apk` that any user can install on their Android phone.

---

### Option C: Build Standalone iOS `.ipa` for App Store / TestFlight

```powershell
eas build -p ios --profile production
```
*(Requires an Apple Developer Account)*

---

## 📁 Project Architecture

```
mobile/
├── assets/
│   ├── icon.png               # Official 3D logo app icon
│   ├── adaptive-icon.png      # Android adaptive icon
│   ├── splash.png             # Launch splash screen
│   └── banner.png             # Official brand ambassador welcome poster
├── src/
│   ├── api/
│   │   └── client.ts          # Axios client with https://mbkdatasub.com.ng/api interceptors
│   ├── components/
│   │   ├── Header.tsx         # User greeting, avatar, Tier badge, WhatsApp triggers
│   │   ├── WalletCard.tsx     # Swipeable 3-card balance & virtual accounts carousel
│   │   ├── HomeBannerCarousel.tsx # Official poster hero banner with timer
│   │   ├── QuickActionsGrid.tsx   # 8-service quick access grid
│   │   └── BiometricPinModal.tsx  # Native Face ID / Fingerprint payment sheet
│   ├── context/
│   │   └── AuthContext.tsx    # State, wallet, biometric credentials & deduplication
│   ├── navigation/
│   │   └── AppNavigator.tsx   # RootStack & BottomTab (Home, Services, History, Profile)
│   ├── screens/
│   │   ├── auth/              # Welcome, Login, Register, PinSetup
│   │   ├── main/              # Home, Services, History, Profile
│   │   └── services/          # Data, Airtime, FundWallet, Cable, Electricity, Airtime2Cash
│   └── utils/
│       ├── biometrics.ts      # Apple Face ID / Touch ID / Android Fingerprint wrapper
│       ├── formatters.ts      # Naira currency, phone & date formatters
│       └── haptics.ts         # Taptic engine vibration feedback
├── App.tsx                    # Root application entry
├── app.json                   # Expo SDK 52 configuration, permissions & bundle ID
└── package.json
```
