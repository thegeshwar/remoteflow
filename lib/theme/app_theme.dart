import 'package:flutter/material.dart';

/// Provides dark and light [ThemeData] for RemoteFlow.
///
/// Widgets must use `Theme.of(context).colorScheme` for all colors —
/// never hardcoded hex values.
class AppTheme {
  AppTheme._();

  /// The font family used throughout the app.
  static const String fontFamily = 'JetBrainsMono';

  /// Minimum touch target size (Material 48dp, iOS 44pt — use 48).
  static const double minTouchTarget = 48.0;

  /// Creates the dark [ThemeData] (default).
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF89B4FA),
      onPrimary: Color(0xFF1E1E2E),
      secondary: Color(0xFFA6E3A1),
      onSecondary: Color(0xFF1E1E2E),
      tertiary: Color(0xFFFAB387),
      onTertiary: Color(0xFF1E1E2E),
      error: Color(0xFFF38BA8),
      onError: Color(0xFF1E1E2E),
      surface: Color(0xFF1E1E2E),
      onSurface: Color(0xFFCDD6F4),
      surfaceContainerHighest: Color(0xFF313244),
      onSurfaceVariant: Color(0xFFBAC2DE),
      outline: Color(0xFF585B70),
      outlineVariant: Color(0xFF45475A),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  /// Creates the light [ThemeData].
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF1E66F5),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF40A02B),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFE640B),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD20F39),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFEFF1F5),
      onSurface: Color(0xFF4C4F69),
      surfaceContainerHighest: Color(0xFFDCE0E8),
      onSurfaceVariant: Color(0xFF5C5F77),
      outline: Color(0xFF8C8FA1),
      outlineVariant: Color(0xFFBCC0CC),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  /// Creates a [ThemeData] from a seed color using Material You dynamic color.
  ///
  /// Used as fallback for Android 12+ dynamic color support.
  static ThemeData fromSeed(Color seedColor, {required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return _buildTheme(colorScheme, brightness);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 8,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
