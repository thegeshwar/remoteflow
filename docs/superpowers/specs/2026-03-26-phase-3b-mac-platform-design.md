# RemoteFlow Phase 3b — Mac Platform Enablement

**Date:** 2026-03-26
**Status:** Approved
**Scope:** Platform enablement only — no new features

## Problem

RemoteFlow is a feature-complete Flutter SSH client with scroll-aware streaming that solves the terminal scroll-sticking problem on mobile. Phases 1–3a are done (22 issues, 306 tests, 0 warnings, Android store-ready). But the app can't run on iOS or macOS because no Mac was available during development.

Now we have a Mac (MacBook Air, Apple Silicon). Phase 3b gets RemoteFlow compiling and running on iOS and macOS.

## Primary Platform

**iOS is the primary target.** The scroll-sticking pain point is worst on mobile — Termius and other iOS SSH clients lock the terminal to the bottom line during rapid output, preventing the user from scrolling up to read previous content. RemoteFlow's ScrollIntentController solves this.

macOS and Windows are secondary. Android is already done.

## Constraints

- **Free Apple ID** — personal team signing for dev builds. No App Store submission yet.
- **No physical iOS devices yet** — simulator testing only for now. Provisioning and device testing come later.
- **No new features** — Phase 3b is strictly platform config, build verification, icons, and store prep.
- **Apple quality bar** — Apple is rejecting AI-generated apps. Every detail must feel hand-crafted. No default Flutter scaffolding left visible. Follow Apple HIG to the letter.
- **Existing 306 tests must keep passing** after all changes.

## Prerequisites

- Flutter SDK installed on Mac (not yet installed, Xcode 26.3 and CocoaPods 1.16.2 already present)

## What Already Exists

### iOS Directory (`ios/`)
- Runner.xcworkspace and Runner.xcodeproj (Flutter default scaffolding)
- AppDelegate.swift with Flutter engine setup
- Info.plist with basic Flutter config (orientations set, scene manifest configured)
- LaunchScreen.storyboard (default, needs real design)
- Assets.xcassets with placeholder AppIcon and LaunchImage sets
- RunnerTests with default test file

**Missing:**
- NSLocalNetworkUsageDescription in Info.plist
- ITSAppUsesNonExemptEncryption in Info.plist
- PrivacyInfo.xcprivacy privacy manifest
- Proper entitlements for network/keychain access
- Real app icon assets
- Real launch screen

### macOS Directory (`macos/`)
- Runner.xcworkspace and Runner.xcodeproj (Flutter default scaffolding)
- AppDelegate.swift and MainFlutterWindow.swift
- Info.plist with basic config
- DebugProfile.entitlements and Release.entitlements (exist but need SSH-related permissions)
- Assets.xcassets with placeholder AppIcon set
- Configs directory (AppInfo.xcconfig, Debug/Release/Warnings xcconfigs)

**Missing:**
- Network entitlements (outgoing connections for SSH)
- Keychain entitlements (for flutter_secure_storage)
- Window management configuration (min size, resize behavior)
- Real app icon assets

### Android (reference — already complete)
- targetSdk 35, minSdk 23, compileSdk 35
- INTERNET + ACCESS_NETWORK_STATE permissions
- network_security_config.xml (cleartext blocked)
- R8 + resource shrinking enabled
- ProGuard rules for Flutter, dartssh2, flutter_secure_storage
- Store-ready AAB builds

## Design Decisions

### D1: Flutter SDK Installation
Install via Homebrew (`brew install flutter`). Simpler than manual SDK management, auto-updates, already have Homebrew on the Mac.

### D2: iOS Signing Strategy
Use Xcode automatic signing with personal team (free Apple ID). This allows:
- Simulator builds (no signing needed)
- On-device builds when physical devices arrive (7-day provisioning)
- Easy upgrade path to paid developer account later

Document exactly what changes when upgrading to paid account.

### D3: iOS Deployment Target
iOS 16.0 (already specified in CLAUDE.md compliance rules). This covers:
- iPhone 8 and later
- All iPads from 2017+
- 98%+ of active iOS devices

### D4: macOS Deployment Target
macOS 13.0 (Ventura). Covers Apple Silicon Macs and recent Intel Macs. Matches Flutter 3.12+ requirements.

### D5: App Icon Design
Single 1024x1024 master icon, generate all sizes programmatically. Design requirements:
- Must not look AI-generated — hand-crafted feel
- Terminal/SSH visual metaphor without being generic
- Works at all sizes (16x16 through 1024x1024)
- Distinct silhouette for app grid recognition
- Dark background (matches app's dark-first theme)
- iOS: rounded rect mask applied by OS (design full-bleed)
- macOS: roundrect with subtle drop shadow (macOS icon conventions)
- Android: adaptive icon with foreground/background layers (already needed)

### D6: Privacy Manifest (PrivacyInfo.xcprivacy)
Required by Apple since Spring 2024. Must declare:
- **NSPrivacyAccessedAPITypes:**
  - `NSPrivacyAccessedAPICategoryUserDefaults` — reason `CA92.1` (app's own UserDefaults, used by Hive for host metadata)
  - `NSPrivacyAccessedAPICategoryFileTimestamp` — reason `C617.1` (used by path_provider)
  - `NSPrivacyAccessedAPICategoryDiskSpace` — reason `E174.1` (used by path_provider)
- **NSPrivacyCollectedDataTypes:** empty array (we collect no user data)
- **NSPrivacyTracking:** false
- **NSPrivacyTrackingDomains:** empty array

### D7: Entitlements

**iOS entitlements:**
- `com.apple.security.network.client` — outgoing network (SSH connections)

**macOS entitlements (Debug + Release):**
- `com.apple.security.app-sandbox` — required for Mac App Store
- `com.apple.security.network.client` — outgoing network (SSH connections)
- `com.apple.security.keychain-access-groups` — flutter_secure_storage
- `com.apple.security.files.user-selected.read-write` — SSH key import (future)

### D8: macOS Window Management
- Minimum window size: 480x320 (usable terminal at smallest)
- Default window size: 800x600
- Full-screen support enabled
- Title bar: integrated with toolbar (modern macOS style)
- No tab support in V1 (sessions managed in-app via dashboard)

### D9: Store Listing Prep
Prepare all assets and copy even though we can't submit yet:
- **Screenshots:** Capture from simulators (iPhone 6.7", iPhone 6.1", iPad 12.9")
- **App description:** Focus on scroll-aware streaming as the differentiator
- **Feature graphic:** For Play Store (already needed for Android)
- **Category:** Utilities > Developer Tools
- **Keywords:** SSH, terminal, remote, scroll, development

## Issue Breakdown

Work follows the existing GitHub issues with this dependency order:

### Config Track (sequential)

**#30 (F-23): Mac Environment Setup**
- Install Flutter SDK via Homebrew
- Verify `flutter doctor` passes (Xcode, CocoaPods, Android SDK)
- Configure Xcode command-line tools
- Run `flutter pub get` in project
- Run `flutter test` — all 306 tests must pass
- Run `flutter analyze` — 0 errors, 0 warnings
- Acceptance: `flutter doctor` shows no errors for iOS and macOS

**#31 (F-24): iOS Platform Config**
- Add NSLocalNetworkUsageDescription to Info.plist
- Add ITSAppUsesNonExemptEncryption (YES) to Info.plist
- Create PrivacyInfo.xcprivacy with correct declarations
- Configure entitlements for network access
- Set deployment target to iOS 16.0
- Set bundle identifier to `com.remoteflow.remoteflow`
- Configure automatic signing (personal team)
- Run `cd ios && pod install`
- Run `flutter build ios --no-codesign` — must succeed
- Run `flutter test` — all tests still pass
- Acceptance: iOS simulator build launches and shows the app

**#33 (F-26): macOS Desktop Build**
- Update entitlements (network.client, keychain, app-sandbox)
- Set deployment target to macOS 13.0
- Configure window minimum size (480x320)
- Configure default window size (800x600)
- Enable full-screen support
- Verify MainFlutterWindow.swift configuration
- Run `flutter build macos` — must succeed
- Run app on Mac, verify terminal connects via SSH
- Run `flutter test` — all tests still pass
- Acceptance: macOS app launches, terminal renders, SSH connects

**#32 (F-25): iOS/iPad Testing**
- Test on iPhone simulators (multiple sizes: SE, 15, 15 Pro Max)
- Test on iPad simulators (iPad, iPad Pro 12.9")
- Verify safe areas (notch, Dynamic Island, home indicator)
- Verify all orientations (portrait, landscape, both directions)
- Test iPad multitasking (Split View, Slide Over)
- Verify keyboard doesn't overlap terminal
- Verify scroll-aware streaming works on touch (swipe gestures)
- Test Reduce Motion behavior
- Test Dynamic Type scaling
- Run accessibility audit in Xcode
- Acceptance: No layout issues on any tested device/orientation

### Assets Track (can parallelize with config after #30)

**#34 (F-27): App Icons**
- Design 1024x1024 master icon
- Generate iOS icon set (all required sizes)
- Generate macOS icon set (16 through 1024, with 2x variants)
- Generate Android adaptive icon layers (already have basic, may need update)
- Replace all placeholder icons in Assets.xcassets
- Update LaunchScreen.storyboard (remove default, add branded launch)
- Acceptance: App shows correct icon on all platforms

**#35 (F-28): Store Listing Assets**
- Capture screenshots from iOS simulators (required device sizes)
- Capture screenshots from macOS
- Write app store description (en-US)
- Write short description / subtitle
- Prepare keywords list
- Create feature graphic (1024x500 for Play Store)
- Document export compliance answers
- Acceptance: All assets ready in `docs/store/` directory

## Testing Strategy

**TDD approach for platform config:**
- Existing 306 tests are the regression suite — must pass after every change
- `flutter analyze` must show 0 errors, 0 warnings after every change
- Each platform build is a verification gate:
  - `flutter build ios --no-codesign` (iOS)
  - `flutter build macos` (macOS)
  - `flutter build appbundle --release` (Android regression)
- iOS simulator smoke tests: launch, navigate, verify scroll behavior
- macOS app smoke tests: launch, SSH connect, verify window management

**No new unit tests needed** for platform config (it's Xcode project files and plists, not Dart code). New tests only if we touch Dart source files.

## What Changes When Upgrading to Paid Apple Developer Account

When Thegeshwar gets the $99/yr Apple Developer Program:
1. Change signing team from "Personal Team" to the developer team ID
2. Create proper App ID in Apple Developer portal
3. Create provisioning profiles for distribution
4. Enable push notifications capability (if needed later)
5. Submit to App Store Connect with prepared store listing assets
6. TestFlight beta distribution becomes available

No code changes needed — only Xcode project signing configuration.

## Out of Scope

- New features (keyboard input bar — tracked in #37)
- Visual redesign
- Ralph Loop integration UI
- Windows platform
- Linux desktop (already works but not priority)
- Paid Apple Developer account enrollment
- App Store submission
