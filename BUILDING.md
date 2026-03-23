# Building RemoteFlow

## Prerequisites
- Flutter SDK (3.12+)
- Android SDK (API 35) for Android builds
- Xcode 15+ for iOS/macOS builds (Mac required)

## Development

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Static analysis
flutter analyze

# Run on connected device
flutter run
```

## Android Release Build

```bash
# Build release AAB (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Build release APK (for side-loading)
flutter build apk --release --split-per-abi
```

### Verify AAB
- Contains arm64-v8a and x86_64 native libraries
- Size should be under 50MB
- R8 minification and resource shrinking enabled

### Android Requirements
- `targetSdkVersion`: 35
- `minSdkVersion`: 23
- `compileSdkVersion`: 35
- Permissions: INTERNET, ACCESS_NETWORK_STATE only
- Network security config blocks cleartext traffic
- ProGuard/R8 enabled for release

## iOS Build (requires Mac)

```bash
flutter build ios --release
```

See issues #30-#35 for iOS/macOS configuration.

## Store Review

### Demo Mode
The app includes a Demo Mode for store reviewers who don't have SSH servers.
Access via the "Demo" option on the connection screen.

### Test Credentials
For real testing, reviewers can use any SSH server. Demo mode is recommended.
