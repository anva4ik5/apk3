# APK3 Frontend - Flutter Premium Messenger UI

Beautiful, feature-rich Flutter UI for the APK3 premium messenger platform. Glassmorphic design with end-to-end encryption support and real-time WebSocket integration.

## Features

- **Glassmorphism UI**: Modern, premium design language
- **End-to-End Encryption**: X25519 + ChaCha20-Poly1305
- **WebSocket Real-time**: Instant message delivery
- **Premium Animations**: Smooth transitions and interactions
- **Multi-platform**: Android, iOS support
- **Dark Mode**: Full theme support

## Requirements

- Flutter 3.14+ (stable channel)
- Dart 3.2+
- Java 17 for Android builds
- Android SDK API 23+

## Quick Start

### Local Development

```bash
# Get dependencies
flutter pub get

# Run on device/emulator
flutter run --release

# Run on Android physical device
flutter run -d device_name --release
```

### Android APK Build

```bash
# Build release APK (universal)
flutter build apk --release

# Build split APKs per ABI (smaller downloads)
flutter build apk --release --split-per-abi
```

## Configuration

Configure API endpoint in `lib/core/config.dart`:

```dart
class AppConfig {
  static const String baseUrl = 'https://api.apk2.railway.app';
  static const String wsUrl = 'wss://ws.apk2.railway.app';
  // ...
}
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart              # Theme configuration
├── config.dart             # App configuration
├── core/
│   └── config.dart        # API configuration
├── models/                # Data models
├── screens/               # UI screens
│   ├── home_screen.dart
│   ├── auth/
│   ├── chats/
│   ├── channels/
│   ├── contacts/
│   └── profile/
├── services/              # Business logic
│   ├── api.dart          # REST API client
│   ├── ws.dart           # WebSocket client
│   ├── encryption_ffi.dart # E2EE via FFI to C++
│   └── settings.dart     # Local settings
└── widgets/               # Reusable UI widgets
```

## Technologies

- Flutter 3.14+ SDK
- Dart 3.2+
- WebSocket for real-time messaging
- Dart FFI for C++ encryption integration
- SharedPreferences for local storage
- Android SDK 23+

## CI/CD

GitHub Actions workflow builds and releases APKs automatically:

```bash
# Tagged releases trigger automatic APK builds
git tag v1.0.0
git push origin v1.0.0
```

Artifacts are uploaded to GitHub Releases.
