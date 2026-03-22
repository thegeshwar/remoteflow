import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('dark', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.dark();
      });

      test('has dark brightness', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('uses JetBrainsMono font family', () {
        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AppTheme.fontFamily,
        );
      });

      test('has valid color scheme', () {
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.surface, isNotNull);
        expect(theme.colorScheme.error, isNotNull);
      });

      test('scaffold uses surface color', () {
        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
      });

      test('app bar has zero elevation', () {
        expect(theme.appBarTheme.elevation, 0);
      });
    });

    group('light', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('has light brightness', () {
        expect(theme.brightness, Brightness.light);
      });

      test('uses Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('uses JetBrainsMono font family', () {
        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AppTheme.fontFamily,
        );
      });

      test('has valid color scheme', () {
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.surface, isNotNull);
        expect(theme.colorScheme.error, isNotNull);
      });
    });

    group('fromSeed', () {
      test('creates dark theme from seed', () {
        final theme = AppTheme.fromSeed(
          Colors.blue,
          brightness: Brightness.dark,
        );
        expect(theme.brightness, Brightness.dark);
        expect(theme.useMaterial3, isTrue);
      });

      test('creates light theme from seed', () {
        final theme = AppTheme.fromSeed(
          Colors.blue,
          brightness: Brightness.light,
        );
        expect(theme.brightness, Brightness.light);
      });
    });

    group('touch targets', () {
      test('minimum touch target is 48dp', () {
        expect(AppTheme.minTouchTarget, 48.0);
      });

      test('elevated buttons meet minimum touch target', () {
        final theme = AppTheme.dark();
        final buttonStyle = theme.elevatedButtonTheme.style!;
        final minSize = buttonStyle.minimumSize!.resolve({});
        expect(minSize!.width, greaterThanOrEqualTo(AppTheme.minTouchTarget));
        expect(minSize.height, greaterThanOrEqualTo(AppTheme.minTouchTarget));
      });

      test('icon buttons meet minimum touch target', () {
        final theme = AppTheme.dark();
        final buttonStyle = theme.iconButtonTheme.style!;
        final minSize = buttonStyle.minimumSize!.resolve({});
        expect(minSize!.width, greaterThanOrEqualTo(AppTheme.minTouchTarget));
        expect(minSize.height, greaterThanOrEqualTo(AppTheme.minTouchTarget));
      });
    });
  });
}
