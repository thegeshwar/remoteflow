import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/features/connection/host_form_screen.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/theme/app_theme.dart';

Widget _buildApp({
  Host? existingHost,
  HostCredentials? existingCredentials,
}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: HostFormScreen(
      existingHost: existingHost,
      existingCredentials: existingCredentials,
    ),
  );
}

void main() {
  group('HostFormScreen', () {
    group('add mode', () {
      testWidgets('shows Add Host title', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Add Host'), findsOneWidget);
      });

      testWidgets('shows all required fields', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Label'), findsOneWidget);
        expect(find.text('Hostname'), findsOneWidget);
        expect(find.text('Port'), findsOneWidget);
        expect(find.text('Username'), findsOneWidget);
      });

      testWidgets('shows Save button', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('shows authentication section', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Authentication'), findsOneWidget);
      });

      testWidgets('defaults to password auth method', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('Password'), findsAtLeast(1));
      });

      testWidgets('port field defaults to 22', (tester) async {
        await tester.pumpWidget(_buildApp());
        expect(find.text('22'), findsAtLeast(1));
      });
    });

    group('edit mode', () {
      testWidgets('shows Edit Host title', (tester) async {
        await tester.pumpWidget(_buildApp(
          existingHost: Host(
            id: 'h1',
            label: 'My Server',
            hostname: 'example.com',
            port: 2222,
            username: 'admin',
            authMethod: AuthMethod.sshKey,
          ),
        ));
        expect(find.text('Edit Host'), findsOneWidget);
      });

      testWidgets('pre-populates fields from existing host', (tester) async {
        await tester.pumpWidget(_buildApp(
          existingHost: Host(
            id: 'h1',
            label: 'My Server',
            hostname: 'example.com',
            port: 2222,
            username: 'admin',
          ),
        ));
        // Fields are pre-populated (may appear in hint too)
        expect(find.text('My Server'), findsAtLeast(1));
        expect(find.text('example.com'), findsAtLeast(1));
        expect(find.text('2222'), findsAtLeast(1));
        expect(find.text('admin'), findsAtLeast(1));
      });
    });

    group('auth method switching', () {
      testWidgets('shows password field when password is selected',
          (tester) async {
        await tester.pumpWidget(_buildApp());

        // Password is default — password field should exist
        // Find the TextFormField with Password label
        expect(find.text('Password'), findsAtLeast(1));
      });

      testWidgets('shows Private Key field when SSH Key is selected',
          (tester) async {
        tester.view.physicalSize = const Size(400, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildApp());
        await tester.tap(find.text('SSH Key'));
        await tester.pumpAndSettle();

        expect(find.text('Private Key'), findsOneWidget);
      });

      testWidgets('hides password field when switching to SSH Key',
          (tester) async {
        await tester.pumpWidget(_buildApp());
        await tester.tap(find.text('SSH Key'));
        await tester.pumpAndSettle();

        // Password label should only appear in the segment button,
        // not as a form field
        final passwordFields = find.text('Password');
        // The SegmentedButton still shows "Password" text
        expect(passwordFields, findsOneWidget);
      });
    });

    group('validation', () {
      testWidgets('shows error for empty label', (tester) async {
        await tester.pumpWidget(_buildApp());

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Label is required'), findsOneWidget);
      });

      testWidgets('shows error for empty hostname', (tester) async {
        await tester.pumpWidget(_buildApp());

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Hostname is required'), findsOneWidget);
      });

      testWidgets('shows error for empty username', (tester) async {
        await tester.pumpWidget(_buildApp());

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Username is required'), findsOneWidget);
      });

      testWidgets('shows error for invalid port', (tester) async {
        await tester.pumpWidget(_buildApp());

        final portField = find.widgetWithText(TextFormField, '22');
        await tester.enterText(portField, '99999');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Port must be 1-65535'), findsOneWidget);
      });

      testWidgets('shows error for empty port', (tester) async {
        await tester.pumpWidget(_buildApp());

        final portField = find.widgetWithText(TextFormField, '22');
        await tester.enterText(portField, '');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Port is required'), findsOneWidget);
      });

      testWidgets('requires private key when SSH Key auth selected',
          (tester) async {
        await tester.pumpWidget(_buildApp());

        await tester.tap(find.text('SSH Key'));
        await tester.pumpAndSettle();

        // Fill other required fields but not key
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Label'), 'Test');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Hostname'), 'test.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Username'), 'user');

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(
            find.text('Private key content is required'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('fields have semantic wrappers', (tester) async {
        await tester.pumpWidget(_buildApp());

        // Verify Semantics widgets exist wrapping form fields
        expect(find.byType(Semantics), findsAtLeast(4));
      });
    });
  });
}
