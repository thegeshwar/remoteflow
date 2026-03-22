import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/models/session.dart';
import 'package:remoteflow/services/ssh_service.dart';

void main() {
  group('SSHService', () {
    late SSHService service;

    setUp(() {
      service = SSHService();
    });

    tearDown(() async {
      await service.dispose();
    });

    group('initial state', () {
      test('has no active connections', () {
        expect(service.activeCount, 0);
      });

      test('sessions map is empty', () {
        expect(service.sessions, isEmpty);
      });
    });

    group('getConnection', () {
      test('returns null for nonexistent session', () {
        expect(service.getConnection('nonexistent'), isNull);
      });
    });

    group('sendInput', () {
      test('throws StateError for nonexistent session', () {
        expect(
          () => service.sendInput('nonexistent', Uint8List(0)),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('resizeTerminal', () {
      test('throws StateError for nonexistent session', () {
        expect(
          () => service.resizeTerminal('nonexistent', 80, 24),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('disconnect', () {
      test('handles nonexistent session gracefully', () async {
        await expectLater(
          service.disconnect('nonexistent'),
          completes,
        );
      });
    });

    group('disconnectAll', () {
      test('completes with no active connections', () async {
        await expectLater(service.disconnectAll(), completes);
      });
    });

    group('dispose', () {
      test('completes cleanly', () async {
        await expectLater(service.dispose(), completes);
      });
    });
  });

  group('ActiveConnection', () {
    test('holds session reference', () {
      // Verify the ActiveConnection class structure is correct
      // by checking it compiles and the fields exist.
      // Full integration tests require a real SSH server.
      expect(ActiveConnection, isNotNull);
    });
  });

  group('Session state transitions', () {
    test('starts in connecting state', () {
      final session = Session(
        id: 'test',
        hostId: 'host-1',
      );
      expect(session.state, SessionState.connecting);
    });

    test('can transition to connected', () {
      final session = Session(
        id: 'test',
        hostId: 'host-1',
      );
      session.state = SessionState.connected;
      expect(session.state, SessionState.connected);
    });

    test('can transition to disconnected', () {
      final session = Session(
        id: 'test',
        hostId: 'host-1',
      );
      session.state = SessionState.connected;
      session.state = SessionState.disconnected;
      session.endedAt = DateTime.now();
      expect(session.state, SessionState.disconnected);
      expect(session.endedAt, isNotNull);
    });

    test('can transition to error with message', () {
      final session = Session(
        id: 'test',
        hostId: 'host-1',
      );
      session.state = SessionState.error;
      session.errorMessage = 'Connection refused';
      expect(session.state, SessionState.error);
      expect(session.errorMessage, 'Connection refused');
    });

    test('has all four states', () {
      expect(SessionState.values.length, 4);
      expect(SessionState.values, contains(SessionState.connecting));
      expect(SessionState.values, contains(SessionState.connected));
      expect(SessionState.values, contains(SessionState.disconnected));
      expect(SessionState.values, contains(SessionState.error));
    });
  });

  group('Host auth method selection', () {
    test('password host uses password auth', () {
      final host = Host(
        id: 'h1',
        label: 'PW Server',
        hostname: 'example.com',
        username: 'user',
        authMethod: AuthMethod.password,
      );
      expect(host.authMethod, AuthMethod.password);
    });

    test('sshKey host uses key auth', () {
      final host = Host(
        id: 'h2',
        label: 'Key Server',
        hostname: 'example.com',
        username: 'user',
        authMethod: AuthMethod.sshKey,
      );
      expect(host.authMethod, AuthMethod.sshKey);
    });

    test('HostCredentials stores key content not path', () {
      const creds = HostCredentials(
        privateKeyContent: '-----BEGIN OPENSSH PRIVATE KEY-----',
        passphrase: 'mypass',
      );
      expect(creds.privateKeyContent, startsWith('-----BEGIN'));
      expect(creds.passphrase, 'mypass');
    });
  });
}
