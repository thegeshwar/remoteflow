import 'package:flutter/material.dart';

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
  static const String defaultFontFamily = 'monospace';

  // -- Scroll Intent --
  /// Distance from bottom (in pixels) within which auto-scroll resumes.
  static const double scrollBottomThreshold = 50.0;

  // -- Theme Colors --
  static const Color primaryColor = Color(0xFF1E1E2E);
  static const Color surfaceColor = Color(0xFF181825);
  static const Color accentColor = Color(0xFF89B4FA);
  static const Color terminalBackground = Color(0xFF11111B);
  static const Color terminalForeground = Color(0xFFCDD6F4);
  static const Color errorColor = Color(0xFFF38BA8);
  static const Color successColor = Color(0xFFA6E3A1);
  static const Color warningColor = Color(0xFFFAB387);

  // -- Hive Box Names --
  static const String hostsBoxName = 'hosts';
  static const String settingsBoxName = 'settings';
  static const String sessionHistoryBoxName = 'session_history';
}
