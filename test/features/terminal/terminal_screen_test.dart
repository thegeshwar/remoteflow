import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/terminal/terminal_screen.dart';
import 'package:remoteflow/theme/app_theme.dart';

Widget _buildApp({String sessionId = 'test-session'}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: TerminalScreen(
      sessionId: sessionId,
      sshService: null, // No active SSH — shows error state
    ),
  );
}

void main() {
  group('TerminalScreen', () {
    group('no active session', () {
      testWidgets('shows session not found message', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Session not found'), findsOneWidget);
      });

      testWidgets('shows Go Back button', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Go Back'), findsOneWidget);
      });

      testWidgets('shows error icon', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows Terminal in app bar', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Terminal'), findsOneWidget);
      });
    });

    group('theme application', () {
      test('default terminal theme name matches constant', () {
        const screen = TerminalScreen(sessionId: 'test');
        expect(screen.terminalThemeName, isNull);
      });

      test('custom theme name is stored', () {
        const screen = TerminalScreen(
          sessionId: 'test',
          terminalThemeName: 'Dracula',
        );
        expect(screen.terminalThemeName, 'Dracula');
      });
    });
  });
}
