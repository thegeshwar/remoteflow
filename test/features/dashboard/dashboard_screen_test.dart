import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/dashboard/dashboard_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';

Widget _buildApp() {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: const Scaffold(
      body: DashboardScreen(),
    ),
  );
}

void main() {
  group('DashboardScreen', () {
    group('empty state', () {
      testWidgets('shows no active sessions message', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('No active sessions'), findsOneWidget);
      });

      testWidgets('shows connect CTA text', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Connect to a host to start a session'),
            findsOneWidget);
      });

      testWidgets('shows terminal icon', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.byIcon(Icons.terminal_outlined), findsOneWidget);
      });
    });
  });
}
