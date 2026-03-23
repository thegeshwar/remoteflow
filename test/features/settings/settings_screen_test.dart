import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/settings/settings_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';

Widget _buildApp() {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: const Scaffold(body: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('shows Settings header', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows Terminal section', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Terminal'), findsOneWidget);
    });

    testWidgets('shows Font Size control', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Font Size'), findsOneWidget);
    });

    testWidgets('shows Terminal Theme picker', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Terminal Theme'), findsOneWidget);
    });

    testWidgets('shows Appearance section', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('shows App Theme control', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('App Theme'), findsOneWidget);
    });

    testWidgets('shows Security section', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Security'), findsOneWidget);
    });

    testWidgets('shows Biometric Lock toggle', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Biometric Lock'), findsOneWidget);
    });

    testWidgets('shows About section', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('shows Version', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.text('Version'), findsOneWidget);
    });

    testWidgets('shows Privacy Policy link', (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildApp());
      await tester.scrollUntilVisible(find.text('Privacy Policy'), 100);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('has font size slider', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
