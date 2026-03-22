# RemoteFlow MVP Design Spec

**Date**: 2026-03-22
**Author**: Claude (architect) + Thegeshwar (product owner)
**Status**: Final (post-review)

---

## 1. Product Overview

RemoteFlow is a cross-platform SSH client built in Flutter, optimized for AI-assisted remote development workflows. The core differentiator is scroll-aware streaming: when the user scrolls up during live output, the viewport locks in place; when they scroll back to the bottom, auto-scroll resumes.

### Target Platforms (MVP)
- **Android** — primary build and test platform (free, no Mac needed)
- **Linux desktop** — secondary build and test platform (free, builds on VPS)
- **iOS** — code written and compliant, compilation deferred until Mac available
- **macOS** — deferred until Mac available
- **Windows** — deferred (low priority)

### Cost Constraints
- $0 development and testing budget
- No Apple Developer Program ($99) — use free Apple ID signing (7-day certs) when Mac available
- No Google Play Console ($25) until ready to publish
- No paid analytics, crash reporting, or third-party services

---

## 2. Core Features

### 2.1 SSH Connection Management
- Save/edit/delete host configurations (hostname, port, username, auth method)
- Authentication: password, SSH key, SSH key with passphrase
- **Split persistence**: host metadata (hostname, port, username, auth method) in Hive; secrets (password, key content, passphrase) in flutter_secure_storage keyed by host ID. Host model's `toJson` excludes credential fields.
- **SSH key import**: users paste key content directly into the app (not file path). dartssh2 expects key content as string. File picker is post-MVP.
- Host list with search when >10 hosts
- Connection status indicators

### 2.2 Terminal Rendering
- xterm.dart terminal widget with ANSI color support
- Terminal resize propagated to remote PTY
- Bundled monospace font (JetBrains Mono)
- Terminal theme independent of system theme (configurable: Dracula, Solarized, Monokai, etc.)
- 10,000-line scrollback buffer

### 2.3 Scroll-Aware Streaming (Core Differentiator)
- ScrollIntentController state machine (already implemented and tested)
- Integrated into terminal view: suppresses auto-scroll when user scrolls up
- "New output below" badge when auto-scroll is paused
- Resumes auto-scroll when viewport reaches bottom (50px threshold)
- No flickering or jank during state transitions

### 2.4 Session Dashboard
- Grid of up to 4 session cards showing live terminal preview
- Tap a card → full-screen terminal
- Back → returns to dashboard
- No notifications while in full-screen — check dashboard to see other sessions
- Live-updating card previews showing recent terminal output

### 2.5 Multi-Session Management
- Up to 4 simultaneous SSH sessions (UX constraint: dashboard grid is 2x2, more would make cards too small to read live output)
- Create/destroy sessions from dashboard
- Session state tracking (connecting, connected, disconnected, error)

### 2.6 Keyboard & Input
- Full keyboard input forwarding to SSH channel
- Special keys: Ctrl+C/D/Z, arrow keys, function keys, tab
- Copy: text selection via click-drag, Ctrl+Shift+C
- Paste: Ctrl+Shift+V, multi-line paste with line ending conversion

### 2.7 Settings
- Terminal font size (configurable)
- Terminal theme selection
- Biometric lock toggle for stored credentials
- App theme (dark default, light available)

---

## 3. Technical Architecture

### 3.1 Tech Stack
| Component | Technology |
|---|---|
| Framework | Flutter (cross-platform) |
| Terminal rendering | xterm.dart |
| SSH protocol | dartssh2 |
| Local persistence | Hive (hosts metadata) + flutter_secure_storage (credentials) |
| State management | Provider |
| Scroll logic | ScrollIntentController (custom ChangeNotifier) |

### 3.2 Project Structure
```
remoteflow/
├── lib/
│   ├── constants.dart              # All app constants, no magic numbers
│   ├── main.dart                   # App entry point
│   ├── theme/
│   │   ├── app_theme.dart          # Dark + light themes with semantic tokens
│   │   └── terminal_themes.dart    # Terminal-specific color schemes
│   ├── models/
│   │   ├── host.dart               # Host configuration model
│   │   └── session.dart            # Session state model
│   ├── services/
│   │   ├── ssh_service.dart        # SSH connection management
│   │   ├── scroll_intent_controller.dart  # Core scroll logic
│   │   └── local_storage_service.dart     # Hive + secure storage
│   ├── features/
│   │   ├── connection/
│   │   │   ├── connection_screen.dart     # Host list
│   │   │   └── host_form_screen.dart      # Add/edit host
│   │   ├── terminal/
│   │   │   ├── terminal_screen.dart       # Full-screen terminal
│   │   │   └── terminal_card.dart         # Dashboard preview card
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart      # 4-card session grid
│   │   ├── settings/
│   │   │   └── settings_screen.dart       # App settings
│   │   └── input/
│   │       └── input_handler.dart         # Keyboard/input translation
│   └── widgets/
│       ├── adaptive_shell.dart            # Bottom nav / nav rail
│       ├── terminal_view.dart             # xterm wrapper with scroll logic
│       ├── connection_manager.dart        # Host list widget
│       └── new_output_badge.dart          # "↓ New output below" indicator
├── test/
│   ├── services/
│   │   ├── scroll_intent_controller_test.dart  # ✅ Done
│   │   ├── ssh_service_test.dart
│   │   └── local_storage_service_test.dart
│   ├── models/
│   │   └── host_test.dart
│   ├── features/
│   │   ├── dashboard_screen_test.dart
│   │   └── connection_screen_test.dart
│   └── widgets/
│       └── terminal_view_test.dart
├── PROMPT.md           # Ralph Loop prompt
├── CLAUDE.md           # Identity + compliance rules
├── HANDOFF.md          # Session handoff
└── SESSION_CONTEXT.md  # Progress tracking
```

### 3.3 State Management Architecture
```
Provider
├── SSHService (singleton)
│   └── manages Map<String, ActiveConnection>
│       ActiveConnection holds: SSHClient, SSHSession, Terminal (xterm), Session (state model)
│       Session model is state-only (no runtime references, serializable for history)
│       SSHService owns the lifecycle of SSH clients and xterm Terminal instances
├── LocalStorageService (singleton)
│   └── manages Hive boxes (host metadata) + flutter_secure_storage (credentials)
│       Host.toJson() excludes password/key/passphrase fields
│       Secrets stored separately keyed by host ID
├── ScrollIntentController (per-session)
│   └── one instance per active terminal
└── ThemeProvider
    └── manages app theme + terminal theme
```

---

## 4. App Store & Play Store Compliance

### 4.1 Rules Applied to ALL Code (Not a Separate Phase)

Every UI widget Ralph builds must comply with these from the start:

**Layout & Touch Targets:**
- iOS: 44x44pt minimum touch targets
- Android: 48x48dp minimum touch targets
- Safe area compliance on all screens (notch, Dynamic Island, home indicator)
- Support all orientations (portrait, landscape, both)

**Accessibility:**
- Semantic labels on all interactive elements (VoiceOver + TalkBack)
- Dynamic Type support for non-terminal UI
- Minimum contrast ratio 4.5:1 (WCAG AA)
- Reduce Motion support (disable animations when system setting enabled)
- Smart Invert exclusion on terminal view (prevent double-inversion)
- Bold Text setting respected for non-terminal UI

**Theming:**
- Dark mode default, light mode available
- System semantic colors for non-terminal UI (never hardcoded hex in widgets)
- Terminal colors independent of system theme
- Android 12+ Dynamic Color support (Material You)

**Security:**
- Credentials in flutter_secure_storage (Keychain/Keystore), NEVER plain Hive or UserDefaults
- No unnecessary permissions
- IPv6 compatible networking (no hardcoded IPv4)

### 4.2 Android-Specific Config
- `targetSdkVersion`: 35 (Android 15)
- `minSdkVersion`: 23 (Android 6.0)
- `compileSdkVersion`: 35
- Permissions: `INTERNET`, `ACCESS_NETWORK_STATE` only
- Build output: AAB (not APK) for store submission
- 64-bit libraries (arm64-v8a, x86_64) — Flutter default
- R8/ProGuard enabled for release
- `network_security_config.xml` — cleartext traffic blocked
- Data safety: credentials stored locally, not shared, no analytics SDKs

### 4.3 iOS-Specific Config (Deferred Until Mac Available)
- Deployment target: iOS 16.0
- Info.plist keys: `NSLocalNetworkUsageDescription`, `ITSAppUsesNonExemptEncryption`
- `PrivacyInfo.xcprivacy` privacy manifest
- `LaunchScreen.storyboard` (not static image)
- iPad multitasking: Split View, Slide Over, Stage Manager
- Entitlements: `com.apple.security.network.client`
- App icon: 1024x1024, no transparency, no rounded corners
- Export compliance: declare SSH encryption usage, mass-market exemption
- Edge deferral for home indicator during terminal sessions

### 4.4 Store Listing Requirements
- Privacy policy URL (static HTML page)
- App icon: 1024x1024 (Apple) + 512x512 (Google)
- Feature graphic: 1024x500 (Google)
- Screenshots: 6-8 per device class (phone, tablet)
- Content rating: PEGI 3 / Everyone (no violence, no UGC, no ads)
- Description: "professional remote server management tool" framing, no "hack"/"exploit" terms
- Demo/review mode: local echo terminal for reviewers without SSH servers

---

## 5. Issue Breakdown

### Phase 1 — Foundation

| Issue | Title | Labels | Depends On |
|---|---|---|---|
| F-01 | Android build config: targetSdk 35, minSdk 23, permissions, network security config, R8 | `phase-1` | None |
| F-02 | Bundle JetBrains Mono font, define theme system (dark+light) using ThemeData/ColorScheme. Widgets use Theme.of(context).colorScheme — never AppConstants colors directly. Replace hardcoded hex in constants.dart with proper theme setup. Terminal-specific colors remain as constants (excluded from semantic theming). | `phase-1` | None |
| F-03 | Host model: Hive for metadata (toJson excludes secrets), flutter_secure_storage for credentials keyed by host ID | `phase-1` | F-01 |
| F-04 | LocalStorageService: CRUD hosts with split persistence (Hive metadata + secure storage credentials) | `phase-1` | F-03 |
| F-05 | SSHService: connect/disconnect with dartssh2, password + key content + key+passphrase auth, IPv6. SSHService holds ActiveConnection map (SSHClient + SSHSession + Terminal refs). Key import = paste content, not file path. | `phase-1` | F-03 |

### Phase 2 — Core UI & Terminal

| Issue | Title | Labels | Depends On |
|---|---|---|---|
| F-07 | Adaptive navigation shell: bottom nav (compact), nav rail (medium/expanded), safe areas, all orientations | `phase-2` | F-02 |
| F-08 | Connection list screen: host list, search, touch targets, semantic labels, Dynamic Type | `phase-2` | F-04, F-07 |
| F-09 | Add/edit host form: auth method picker, validation, modal sheet presentation | `phase-2` | F-04, F-07 |
| F-10 | Terminal screen: xterm.dart integration, ANSI colors, PTY resize, terminal theme, scrollback buffer | `phase-2` | F-05, F-07 |
| F-11 | Scroll-aware streaming: wire ScrollIntentController into terminal view, widget-level integration tests, "new output below" badge. CRITICAL: only feed USER-initiated scroll events into the controller (check `notification is UserScrollNotification`). Programmatic scrolls and content growth must NOT trigger state changes. xterm.dart v4 uses its own internal viewport — listen to Terminal.onOutput and TerminalView scroll notifications, not a standard ScrollController. | `phase-2` | F-10 |
| F-12 | Keyboard input forwarding: special keys, arrow keys, tab, Ctrl combos | `phase-2` | F-10 |
| F-13 | Copy-paste: text selection, clipboard, Ctrl+Shift+C/V, multi-line paste | `phase-2` | F-10 |
| F-14 | Session dashboard: 4-card grid, live terminal previews, tap to full-screen, back to dashboard | `phase-2` | F-10, F-11 |

### Phase 3a — Polish (No Mac Needed)

| Issue | Title | Labels | Depends On |
|---|---|---|---|
| F-15 | Multi-session management: create/destroy sessions, max 4 active, state tracking | `phase-3a` | F-14 |
| F-16 | Responsive layouts: compact/medium/expanded breakpoints, layout switching | `phase-3a` | F-07 |
| F-17 | Accessibility pass: VoiceOver labels, TalkBack labels, Reduce Motion, Bold Text, contrast audit | `phase-3a` | F-08, F-10, F-14 |
| F-18 | Network resilience: graceful disconnect on background, reconnect (add retry state/attempt tracking to Session model), connection error states, network monitor via connectivity_plus | `phase-3a` | F-05, F-10 |
| F-19 | Settings screen: terminal font size, terminal theme picker, biometric lock toggle, app theme toggle | `phase-3a` | F-02, F-04 |
| F-20 | Privacy policy: static HTML page, hosted URL, linked in-app | `phase-3a` | None |
| F-21 | Demo/review mode: local echo terminal for store reviewers | `phase-3a` | F-10 |
| F-22 | Build validation: AAB output, 64-bit libs, analyze clean, no unnecessary permissions, release config | `phase-3a` | F-01 |

### Phase 3b — Mac-Dependent (Labeled `needs-mac`)

| Issue | Title | Labels | Depends On |
|---|---|---|---|
| F-23 | Mac environment setup: Xcode, Flutter, CocoaPods, free Apple ID signing, iOS simulator verification | `phase-3b`, `needs-mac` | None |
| F-24 | iOS platform config: Info.plist keys, PrivacyInfo.xcprivacy, LaunchScreen.storyboard, entitlements | `phase-3b`, `needs-mac` | F-23 |
| F-25 | iOS/iPad testing: safe areas all devices, iPad multitasking, all orientations, IPv6 NAT64 test | `phase-3b`, `needs-mac` | F-24 |
| F-26 | macOS desktop build: verify compilation, window management, menu bar | `phase-3b`, `needs-mac` | F-23 |
| F-27 | App icons: 1024x1024 (Apple) + 512x512 (Google), feature graphic, launch screen theming | `phase-3b`, `needs-mac` | F-23 |
| F-28 | Store listing assets: 6-8 screenshots per device class, descriptions, export compliance declaration | `phase-3b`, `needs-mac` | F-25 |

---

## 6. Ralph Loop Prompt Design

### Structure
The prompt (`PROMPT.md`) has 4 sections:

1. **Identity & Context** — what RemoteFlow is, read CLAUDE.md
2. **Iteration Protocol** — check GitHub → pick next issue → build → test → commit → close → loop
3. **Compliance Rules** — always-active constraints applied to every line of code
4. **Quality Gates** — must pass before closing any issue
5. **Completion** — when all non-`needs-mac` issues are closed, output `<promise>MVP COMPLETE</promise>`

### Issue Selection Algorithm
Each iteration:
1. `gh issue list --repo thegeshwar/remoteflow --state open --json number,title,labels,body`
2. Filter out issues labeled `needs-mac`
3. Sort by phase priority: `phase-1` > `phase-2` > `phase-3a`
4. For each issue, check if dependencies (listed in issue body as "Depends on: F-XX, F-YY") are all closed
5. Pick the first issue whose dependencies are satisfied
6. If no issue is ready (all blocked), output error and stop

### Quality Gates (Per Issue)
Before closing any issue:
- `flutter test` — all tests pass
- `flutter analyze` — zero errors
- New public APIs have dartdoc comments
- No magic numbers (constants in constants.dart)
- Commit message: `type: description (closes #N)`
- Issue moved to Done on Kanban board

---

## 7. User Workflow

1. All setup done in current session (issues, labels, PROMPT.md, CLAUDE.md update)
2. Open new Claude Code session: `cd /home/ubuntu/remoteflow`
3. Run: `/ralph-loop "$(cat PROMPT.md)" --completion-promise "MVP COMPLETE" --max-iterations 50`
4. Monitor: Kanban board, terminal output, `git log`
5. Ralph completes → working Android + Linux MVP
6. Later with Mac: run same command → picks up `needs-mac` issues

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Ralph gets stuck on a complex issue | Max iterations + clear acceptance criteria in each issue. User can `/cancel-ralph`, fix manually, restart |
| dartssh2 or xterm.dart API issues | These are mature packages. Skeleton code already validates imports. Issues have fallback notes. |
| Flutter test environment on VPS (headless) | `flutter test` works headless. Widget tests use `TestWidgetsFlutterBinding`. No integration test issues. |
| Issue dependency deadlock | Linear dependency chain verified — no circular deps in the breakdown |
| Prompt too long for context | PROMPT.md stays concise (~800 words). Detailed compliance rules live in CLAUDE.md which Claude Code loads automatically. |
