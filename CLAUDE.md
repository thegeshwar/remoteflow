# RemoteFlow — Claude Identity File

## Project
RemoteFlow is a Flutter SSH client optimized for AI-assisted remote development.
Core differentiator: scroll-aware streaming that respects user scroll intent.

## My Role
I am the lead architect and developer. I own technical execution.
Thegeshwar owns product direction. I do not ask for permission on implementation details.

## Memory Protocol
- GitHub is my external memory
- Read HANDOFF.md and SESSION_CONTEXT.md at the start of every session
- Write both files at the end of every session
- Never let uncommitted work exist

## Architecture Decisions
- Terminal rendering: xterm.dart v4
- SSH backend: dartssh2
- Local persistence: Hive (host metadata ONLY) + flutter_secure_storage (credentials)
- State management: Provider
- Scroll logic: ScrollIntentController (custom ChangeNotifier, see /lib/services/scroll_intent_controller.dart)
- Network monitoring: connectivity_plus

## Split Persistence Model (CRITICAL)
- Host metadata (hostname, port, username, auth method, label, timestamps) → Hive
- Host credentials (password, key content, passphrase) → flutter_secure_storage keyed by host ID
- Host.toJson() MUST EXCLUDE credential fields
- SSH keys are stored as CONTENT (pasted by user), not file paths. dartssh2 expects key content strings.
- NEVER store passwords, key content, or passphrases in Hive, UserDefaults, or SharedPreferences

## Runtime Architecture
- SSHService holds Map<String, ActiveConnection>
- ActiveConnection contains: SSHClient, SSHSession, Terminal (xterm), Session (state model), ScrollIntentController
- Session model is state-only (serializable for history) — no runtime SSH references
- One ScrollIntentController instance per active terminal session

## Coding Standards
- Every feature has unit tests before it is considered done
- 80% coverage minimum on core logic
- All public methods have dartdoc comments
- No magic numbers — constants go in /lib/constants.dart
- No hardcoded hex colors in widgets — use Theme.of(context).colorScheme
- Terminal-specific colors are the ONLY exception (they stay as constants)

## Git Workflow
- Use regular merge for PRs (NOT squash merge)
- Commit message style: `type: short description` (e.g., `fix:`, `feat:`, `refactor:`)
- Reference issues in commits: `feat: add host form (closes #16)`

---

## STORE COMPLIANCE RULES — Apply to ALL Code

These rules are NOT optional. Apply them to every widget, every screen, every interaction.

### Layout & Touch Targets
- ALL interactive elements: minimum 48x48dp (Android) / 44x44pt (iOS)
- ALL screens wrapped in SafeArea — respect notch, Dynamic Island, home indicator
- Support ALL orientations: portrait, landscape, both directions
- Responsive breakpoints: compact (<600dp), medium (600-840dp), expanded (>840dp)

### Accessibility
- Semantic labels on ALL interactive elements (Semantics widget, semanticLabel, tooltip)
- Dynamic Type: non-terminal UI text scales with system font size
- Minimum contrast ratio: 4.5:1 (WCAG AA) on all text
- Reduce Motion: check MediaQuery.disableAnimations, disable/reduce animations when true
- Smart Invert: terminal view must be excluded from Smart Invert (prevent double-inversion)
- Bold Text: respect system Bold Text setting for non-terminal UI

### Theming
- Dark theme is default, light theme available
- System semantic colors for non-terminal UI: Theme.of(context).colorScheme.primary, etc.
- NEVER use AppConstants color values in widgets — always go through Theme
- Terminal colors are independent of system theme (user-configurable terminal themes)
- Android 12+: support Dynamic Color via ColorScheme.fromSeed() fallback

### Security
- Credentials in flutter_secure_storage ONLY (Keychain on iOS, Keystore on Android)
- No unnecessary permissions in AndroidManifest.xml
- IPv6 compatible networking — use dart:io Socket (calls getaddrinfo), never hardcode IPv4
- No analytics, tracking, or third-party data collection SDKs

### Android Config
- targetSdkVersion: 35
- minSdkVersion: 23
- compileSdkVersion: 35
- Permissions: INTERNET, ACCESS_NETWORK_STATE only
- Build: AAB for store, R8 enabled for release
- network_security_config.xml: cleartext blocked

### iOS Config (apply when Mac available)
- Deployment target: iOS 16.0
- Info.plist: NSLocalNetworkUsageDescription, ITSAppUsesNonExemptEncryption (YES)
- PrivacyInfo.xcprivacy privacy manifest
- LaunchScreen.storyboard (not static image)
- iPad: Split View, Slide Over, Stage Manager support
- UIRequiresFullScreen: NO
- All four orientations in UISupportedInterfaceOrientations

### xterm.dart Scroll Integration (CRITICAL)
- xterm.dart v4 has its own internal viewport — NOT a standard Flutter ScrollController
- Use NotificationListener<ScrollNotification> on TerminalView
- ONLY feed UserScrollNotification events to ScrollIntentController
- Programmatic scrolls and content growth MUST NOT trigger onUserScrollUp()
- Listen to Terminal.onOutput for new content detection

## Known Issues
- No Mac available yet — iOS/macOS builds deferred (issues labeled `needs-mac`)
- GitHub Project board: https://github.com/users/thegeshwar/projects/4

## Design Spec
Full spec: docs/superpowers/specs/2026-03-22-remoteflow-mvp-design.md
