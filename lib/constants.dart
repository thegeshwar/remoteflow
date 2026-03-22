/// Application-wide constants for RemoteFlow.
class AppConstants {
  AppConstants._();

  // -- App Info --
  static const String appName = 'RemoteFlow';
  static const String appVersion = '0.1.0';

  // -- SSH Defaults --
  static const int defaultSSHPort = 22;
  static const Duration connectionTimeout = Duration(seconds: 30);

  // -- Terminal --
  static const int defaultScrollbackLines = 10000;
  static const double defaultFontSize = 14.0;

  /// Default terminal font family (matches bundled asset).
  static const String defaultTerminalFontFamily = 'JetBrainsMono';

  // -- Scroll Intent --
  /// Distance from bottom (in pixels) within which auto-scroll resumes.
  static const double scrollBottomThreshold = 50.0;

  /// Default terminal theme name.
  static const String defaultTerminalTheme = 'Default Dark';

  // -- Layout Breakpoints --
  /// Width below which compact layout (bottom nav) is used.
  static const double compactBreakpoint = 600.0;

  // -- Sessions --
  /// Maximum concurrent SSH sessions.
  static const int maxSessions = 4;

  // -- Android Build Config --
  /// Android target SDK version (Play Store requirement).
  static const int androidTargetSdk = 35;

  /// Android minimum SDK version.
  static const int androidMinSdk = 23;

  /// Android compile SDK version.
  static const int androidCompileSdk = 35;

  // -- Hive Box Names --
  static const String hostsBoxName = 'hosts';
  static const String settingsBoxName = 'settings';
  static const String sessionHistoryBoxName = 'session_history';
}
