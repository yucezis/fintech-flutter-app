# ZenBudget — Mobile App

![Flutter](https://img.shields.io/badge/Flutter_3.19+-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart_3.3+-0175C2?style=flat-square&logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS_12+-000000?style=flat-square&logo=apple&logoColor=white)
![Android](https://img.shields.io/badge/Android_8.0+-3DDC84?style=flat-square&logo=android&logoColor=white)

![Riverpod](https://img.shields.io/badge/Riverpod-000000?style=flat-square&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive_DB-FFCA28?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Google Gemini](https://img.shields.io/badge/Gemini_API-8E75B2?style=flat-square&logo=google&logoColor=white)
![ML Kit](https://img.shields.io/badge/Google_ML_Kit-4285F4?style=flat-square&logo=google&logoColor=white)

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)

> Personal budget management application built with **Flutter 3.19+**, supporting both iOS and Android.

---

> 💡 **Note:** This repository contains the Flutter mobile client for **ZenBudget**. The application is powered by a robust .NET API built with Clean Architecture. If you are looking for the backend source code, please visit the [ZenBudget Backend Repository](https://github.com/yucezis/fintech-dotnet-backend).

---

## Table of Contents

- [About](#about)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [Features](#features)
- [Testing](#testing)
- [Build & Distribution](#build--distribution)

---

## About

ZenBudget is a personal finance application that helps users track their income and expenses, analyze their spending habits, and reach their savings goals.

**Supported Platforms:**
- 🍎 iOS 12+
- 🤖 Android 8.0+ (API 26+)

**Highlights:**
- OCR-powered receipt/invoice scanning via camera (Google ML Kit)
- Voice command support (Speech-to-Text)
- Biometric authentication (Face ID / Touch ID / Fingerprint)
- Interactive charts and spending analytics
- Offline support (Hive local database)
- Push notifications (FCM)
- PDF report generation and sharing
- 10 language support (TR, EN, DE, ES, FR, PT, IT, JA, KO, AR)

---

## Tech Stack

| Category | Package | Version |
|---|---|---|
| **Framework** | Flutter SDK | 3.19+ |
| **Language** | Dart | 3.3+ |
| **State Management** | Riverpod | 2.5.0 |
| **Networking** | Dio + Retrofit | 5.4.0 / 4.1.0 |
| **Local Storage** | Hive | 2.2.3 |
| **Secure Storage** | flutter_secure_storage | 9.0.0 |
| **Charts** | fl_chart | 0.66.0 |
| **OCR** | google_mlkit_text_recognition | 0.11.0 |
| **Voice Recognition** | speech_to_text | 6.6.0 |
| **Authentication** | firebase_auth | 4.16.0 |
| **Biometrics** | local_auth | 2.1.0 |
| **Notifications** | firebase_messaging | 14.7.0 |
| **Calendar** | table_calendar | 3.0.0 |
| **PDF** | pdf + printing | 3.10.0 / 5.11.0 |
| **Error Tracking** | sentry_flutter | 7.14.0 |
| **Analytics** | firebase_analytics | 10.8.0 |

---

## Getting Started

### Prerequisites

- [Flutter SDK 3.19+](https://flutter.dev/docs/get-started/install) (Stable channel)
- [Dart 3.3+](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode 15+](https://developer.apple.com/xcode/) (for iOS development — macOS only)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/zenbudget-mobile.git
cd zenbudget-mobile

# 2. Check Flutter version
flutter --version

# 3. Install dependencies
flutter pub get

# 4. Run code generation (Retrofit, JSON serialization, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 5. Add Firebase configuration files
# google-services.json       → android/app/
# GoogleService-Info.plist   → ios/Runner/

# 6. Run the app
flutter run
```

### Flutter Setup Check

```bash
flutter doctor
```

Make sure all items show ✅ before proceeding.

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/          # Constants, colors, theme
│   ├── errors/             # Error classes
│   ├── network/            # Dio client, interceptors
│   ├── router/             # GoRouter navigation
│   └── utils/              # Helper functions
├── features/
│   ├── auth/               # Authentication (login, register, biometric)
│   ├── dashboard/          # Home screen, summary cards
│   ├── transactions/       # Income/expense CRUD
│   ├── categories/         # Category management
│   ├── budgets/            # Budget plans
│   ├── reports/            # Charts, PDF reports
│   ├── ocr/                # Receipt scanning (ML Kit)
│   ├── voice/              # Voice commands
│   ├── ai_insights/        # Gemini AI recommendations
│   ├── notifications/      # FCM + local notifications
│   └── settings/           # Profile, language, theme settings
├── l10n/
│   └── *.arb               # Localization files for 10 languages
└── shared/
    ├── widgets/            # Shared widgets
    ├── models/             # Shared data models
    └── providers/          # Global Riverpod providers

assets/
├── images/
├── icons/
├── animations/             # Lottie JSON files
└── fonts/

test/
├── unit/
├── widget/
└── integration/
```

---

## Environment Variables

The project uses different configurations per environment. Create an `env.dart` file under `lib/core/constants/`:

```dart
// lib/core/constants/env.dart
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7001/api/v1',
  );

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
```

To run with environment variables:

```bash
# Development
flutter run --dart-define=API_BASE_URL=https://localhost:7001/api/v1

# Production
flutter run --dart-define=API_BASE_URL=https://api.zenbudget.app/api/v1 \
            --dart-define=SENTRY_DSN=https://your-sentry-dsn
```

**Firebase configuration:**
- `android/app/google-services.json` → Download from Firebase Console
- `ios/Runner/GoogleService-Info.plist` → Download from Firebase Console

---

## Features

### OCR Receipt Scanning
Automatically extracts the amount, date, and category from receipts and invoices by taking a photo with the camera or selecting from the gallery. Powered by Google ML Kit Text Recognition.

### Voice Commands
Processes natural language commands such as "Add a grocery expense of 150 for today" and automatically creates the transaction.

### Charts & Analytics
- Monthly income/expense comparison (line chart)
- Category-based spending breakdown (pie chart)
- Budget goal progress bars
- Calendar-view spending heatmap

### AI Insights
Personalized savings recommendations and spending anomaly detection powered by the Google Gemini API.

### Security
- Firebase Authentication (Email, Google, Apple, Phone)
- Biometric lock (Face ID / Touch ID / Fingerprint)
- Encrypted local storage (flutter_secure_storage)

---

## Testing

```bash
# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widget/

# Run integration tests (requires connected device)
flutter test integration_test/

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Testing Tools:** flutter_test · mockito · integration_test

---

## Build & Distribution

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release --dart-define=API_BASE_URL=https://api.zenbudget.app/api/v1

# AAB for Play Store
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release (requires Archive via Xcode)
flutter build ios --release
```

### Firebase App Distribution (Beta)

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "beta-testers"
```

### GitHub Actions

CI/CD pipelines are defined in `.github/workflows/`:
- `ci.yml` — Lint, test, build checks
- `deploy-android.yml` — Automated upload to Play Store
- `deploy-ios.yml` — Automated upload to TestFlight

---

## Code Generation

Run after any model changes for Retrofit clients and JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

---

## Localization

Supported languages:  TR ·  EN ·  FR ·  ES ·  AR ·  RU ·  PT ·  IT ·  DE

To add new translations:

```bash
# Edit the ARB files
lib/l10n/app_tr.arb
lib/l10n/app_en.arb
# ...

# Generate localization code
flutter gen-l10n
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

⭐ **If you like this project, don't forget to give it a star!**

---

<p align="center">
  ZenBudget Mobile — Financial peace, in your pocket 💙
</p>

