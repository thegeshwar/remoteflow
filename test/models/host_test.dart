import 'package:flutter_test/flutter_test.dart';
import 'package:remoteflow/models/host.dart';

void main() {
  group('Host', () {
    late Host host;
    late DateTime fixedTime;

    setUp(() {
      fixedTime = DateTime(2026, 3, 22, 12, 0, 0);
      host = Host(
        id: 'test-host-1',
        label: 'My Server',
        hostname: '192.168.1.100',
        port: 22,
        username: 'ubuntu',
        authMethod: AuthMethod.password,
        createdAt: fixedTime,
      );
    });

    group('toJson', () {
      test('serializes all metadata fields', () {
        final json = host.toJson();
        expect(json['id'], 'test-host-1');
        expect(json['label'], 'My Server');
        expect(json['hostname'], '192.168.1.100');
        expect(json['port'], 22);
        expect(json['username'], 'ubuntu');
        expect(json['authMethod'], 'password');
        expect(json['createdAt'], fixedTime.toIso8601String());
      });

      test('excludes password field', () {
        final json = host.toJson();
        expect(json.containsKey('password'), isFalse);
      });

      test('excludes privateKeyContent field', () {
        final json = host.toJson();
        expect(json.containsKey('privateKeyContent'), isFalse);
      });

      test('excludes privateKeyPath field', () {
        final json = host.toJson();
        expect(json.containsKey('privateKeyPath'), isFalse);
      });

      test('excludes passphrase field', () {
        final json = host.toJson();
        expect(json.containsKey('passphrase'), isFalse);
      });

      test('serializes lastConnectedAt when present', () {
        final connectedTime = DateTime(2026, 3, 22, 14, 0, 0);
        host.lastConnectedAt = connectedTime;
        final json = host.toJson();
        expect(json['lastConnectedAt'], connectedTime.toIso8601String());
      });

      test('serializes lastConnectedAt as null when absent', () {
        final json = host.toJson();
        expect(json['lastConnectedAt'], isNull);
      });

      test('serializes sshKey auth method', () {
        final keyHost = Host(
          id: 'key-host',
          label: 'Key Server',
          hostname: 'example.com',
          username: 'admin',
          authMethod: AuthMethod.sshKey,
          createdAt: fixedTime,
        );
        final json = keyHost.toJson();
        expect(json['authMethod'], 'sshKey');
      });
    });

    group('fromJson', () {
      test('deserializes all metadata fields', () {
        final json = host.toJson();
        final restored = Host.fromJson(json);
        expect(restored.id, host.id);
        expect(restored.label, host.label);
        expect(restored.hostname, host.hostname);
        expect(restored.port, host.port);
        expect(restored.username, host.username);
        expect(restored.authMethod, host.authMethod);
        expect(restored.createdAt, host.createdAt);
      });

      test('round-trips correctly', () {
        final json = host.toJson();
        final restored = Host.fromJson(json);
        final json2 = restored.toJson();
        expect(json2, equals(json));
      });

      test('defaults port to 22 when missing', () {
        final json = host.toJson();
        json.remove('port');
        final restored = Host.fromJson(json);
        expect(restored.port, 22);
      });

      test('defaults authMethod to password when missing', () {
        final json = host.toJson();
        json['authMethod'] = 'unknownMethod';
        final restored = Host.fromJson(json);
        expect(restored.authMethod, AuthMethod.password);
      });

      test('handles null lastConnectedAt', () {
        final json = host.toJson();
        final restored = Host.fromJson(json);
        expect(restored.lastConnectedAt, isNull);
      });

      test('parses lastConnectedAt when present', () {
        final connectedTime = DateTime(2026, 3, 22, 14, 0, 0);
        host.lastConnectedAt = connectedTime;
        final json = host.toJson();
        final restored = Host.fromJson(json);
        expect(restored.lastConnectedAt, connectedTime);
      });
    });

    group('copyWith', () {
      test('copies with new label', () {
        final copy = host.copyWith(label: 'New Label');
        expect(copy.label, 'New Label');
        expect(copy.id, host.id);
        expect(copy.hostname, host.hostname);
      });

      test('preserves all fields when no arguments', () {
        final copy = host.copyWith();
        expect(copy.id, host.id);
        expect(copy.label, host.label);
        expect(copy.hostname, host.hostname);
        expect(copy.port, host.port);
        expect(copy.username, host.username);
        expect(copy.authMethod, host.authMethod);
        expect(copy.createdAt, host.createdAt);
      });

      test('preserves id (immutable)', () {
        final copy = host.copyWith(label: 'Changed');
        expect(copy.id, host.id);
      });
    });

    group('defaults', () {
      test('port defaults to 22', () {
        final h = Host(
          id: 'x',
          label: 'x',
          hostname: 'x',
          username: 'x',
        );
        expect(h.port, 22);
      });

      test('authMethod defaults to password', () {
        final h = Host(
          id: 'x',
          label: 'x',
          hostname: 'x',
          username: 'x',
        );
        expect(h.authMethod, AuthMethod.password);
      });

      test('createdAt defaults to now when not provided', () {
        final before = DateTime.now();
        final h = Host(
          id: 'x',
          label: 'x',
          hostname: 'x',
          username: 'x',
        );
        final after = DateTime.now();
        expect(h.createdAt.isAfter(before) || h.createdAt == before, isTrue);
        expect(h.createdAt.isBefore(after) || h.createdAt == after, isTrue);
      });
    });
  });

  group('HostCredentials', () {
    test('isEmpty when all fields are null', () {
      const creds = HostCredentials();
      expect(creds.isEmpty, isTrue);
      expect(creds.isNotEmpty, isFalse);
    });

    test('isNotEmpty with password', () {
      const creds = HostCredentials(password: 'secret');
      expect(creds.isNotEmpty, isTrue);
      expect(creds.isEmpty, isFalse);
    });

    test('isNotEmpty with privateKeyContent', () {
      const creds = HostCredentials(privateKeyContent: '-----BEGIN RSA-----');
      expect(creds.isNotEmpty, isTrue);
    });

    test('isNotEmpty with passphrase', () {
      const creds = HostCredentials(passphrase: 'mypass');
      expect(creds.isNotEmpty, isTrue);
    });

    group('toSecureMap', () {
      test('includes only non-null fields', () {
        const creds = HostCredentials(password: 'secret');
        final map = creds.toSecureMap();
        expect(map, {'password': 'secret'});
        expect(map.containsKey('privateKeyContent'), isFalse);
        expect(map.containsKey('passphrase'), isFalse);
      });

      test('includes all fields when present', () {
        const creds = HostCredentials(
          password: 'pw',
          privateKeyContent: 'key',
          passphrase: 'pp',
        );
        final map = creds.toSecureMap();
        expect(map['password'], 'pw');
        expect(map['privateKeyContent'], 'key');
        expect(map['passphrase'], 'pp');
      });

      test('returns empty map when no credentials', () {
        const creds = HostCredentials();
        expect(creds.toSecureMap(), isEmpty);
      });
    });

    group('fromSecureMap', () {
      test('deserializes all fields', () {
        final creds = HostCredentials.fromSecureMap({
          'password': 'pw',
          'privateKeyContent': 'key',
          'passphrase': 'pp',
        });
        expect(creds.password, 'pw');
        expect(creds.privateKeyContent, 'key');
        expect(creds.passphrase, 'pp');
      });

      test('handles null values in map', () {
        final creds = HostCredentials.fromSecureMap({
          'password': null,
          'privateKeyContent': null,
          'passphrase': null,
        });
        expect(creds.isEmpty, isTrue);
      });

      test('handles empty map', () {
        final creds = HostCredentials.fromSecureMap({});
        expect(creds.isEmpty, isTrue);
      });

      test('round-trips through toSecureMap', () {
        const original = HostCredentials(
          password: 'secret',
          privateKeyContent: '-----BEGIN RSA-----',
          passphrase: 'passphrase123',
        );
        final map = original.toSecureMap();
        final restored = HostCredentials.fromSecureMap(map);
        expect(restored.password, original.password);
        expect(restored.privateKeyContent, original.privateKeyContent);
        expect(restored.passphrase, original.passphrase);
      });
    });

    group('copyWith', () {
      test('copies with new password', () {
        const creds = HostCredentials(password: 'old');
        final copy = creds.copyWith(password: 'new');
        expect(copy.password, 'new');
      });

      test('preserves fields not specified', () {
        const creds = HostCredentials(
          password: 'pw',
          privateKeyContent: 'key',
          passphrase: 'pp',
        );
        final copy = creds.copyWith(password: 'newpw');
        expect(copy.password, 'newpw');
        expect(copy.privateKeyContent, 'key');
        expect(copy.passphrase, 'pp');
      });
    });
  });

  group('AuthMethod', () {
    test('has password value', () {
      expect(AuthMethod.password.name, 'password');
    });

    test('has sshKey value', () {
      expect(AuthMethod.sshKey.name, 'sshKey');
    });

    test('has exactly 2 values', () {
      expect(AuthMethod.values.length, 2);
    });
  });
}
