import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/connection/connection_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';

Widget _buildApp() {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: const Scaffold(
      body: ConnectionScreen(),
    ),
  );
}

void main() {
  group('ConnectionScreen', () {
    group('empty state (no storage service)', () {
      testWidgets('shows empty state when no storage service', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('No hosts yet'), findsOneWidget);
      });

      testWidgets('shows add host CTA in empty state', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Host'), findsOneWidget);
      });

      testWidgets('shows helpful subtitle in empty state', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add your first SSH host to get started'),
            findsOneWidget);
      });

      testWidgets('shows Hosts header', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Hosts'), findsOneWidget);
      });

      testWidgets('shows add icon button with tooltip', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byTooltip('Add host'), findsOneWidget);
      });

      testWidgets('does not show search bar when empty', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(TextField), findsNothing);
      });

      testWidgets('shows empty state icon', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
      });
    });

    group('layout', () {
      testWidgets('uses Column layout', (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.pump(const Duration(milliseconds: 100));

        // The screen should render without overflow
        expect(tester.takeException(), isNull);
      });
    });
  });
}
