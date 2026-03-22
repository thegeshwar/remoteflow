import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/services/local_storage_service.dart';

/// Fake implementation of [FlutterSecureStorage] for testing.
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_store);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store.containsKey(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late LocalStorageService service;
  late FakeSecureStorage fakeSecureStorage;
  late Box<String> testBox;

  setUp(() async {
    Hive.init('/tmp/hive_test_${DateTime.now().millisecondsSinceEpoch}');
    testBox = await Hive.openBox<String>(
        '${AppConstants.hostsBoxName}_${DateTime.now().millisecondsSinceEpoch}');
    fakeSecureStorage = FakeSecureStorage();
    service = LocalStorageService(secureStorage: fakeSecureStorage);
    service.initializeWithBox(testBox);
  });

  tearDown(() async {
    if (testBox.isOpen) {
      await testBox.clear();
      await testBox.close();
    }
  });

  Host createTestHost({String id = 'host-1', String label = 'Test Server'}) {
    return Host(
      id: id,
      label: label,
      hostname: '192.168.1.1',
      port: 22,
      username: 'ubuntu',
      authMethod: AuthMethod.password,
      createdAt: DateTime(2026, 3, 22),
    );
  }

  group('LocalStorageService', () {
    group('saveHost', () {
      test('saves host metadata to Hive', () async {
        final host = createTestHost();
        await service.saveHost(host);

        final stored = testBox.get('host-1');
        expect(stored, isNotNull);
        final json = jsonDecode(stored!) as Map<String, dynamic>;
        expect(json['hostname'], '192.168.1.1');
        expect(json['label'], 'Test Server');
      });

      test('saves credentials to secure storage', () async {
        final host = createTestHost();
        const creds = HostCredentials(password: 'secret123');
        await service.saveHost(host, credentials: creds);

        final stored =
            await fakeSecureStorage.read(key: 'host_creds_host-1_password');
        expect(stored, 'secret123');
      });

      test('does not save empty credentials', () async {
        final host = createTestHost();
        const creds = HostCredentials();
        await service.saveHost(host, credentials: creds);

        final allKeys = (await fakeSecureStorage.readAll()).keys;
        expect(allKeys.where((k) => k.contains('host-1')), isEmpty);
      });

      test('host metadata in Hive never contains credentials', () async {
        final host = createTestHost();
        const creds = HostCredentials(
          password: 'supersecret',
          privateKeyContent: '-----BEGIN RSA KEY-----',
          passphrase: 'keypassphrase',
        );
        await service.saveHost(host, credentials: creds);

        final stored = testBox.get('host-1')!;
        final json = jsonDecode(stored) as Map<String, dynamic>;
        expect(json.containsKey('password'), isFalse);
        expect(json.containsKey('privateKeyContent'), isFalse);
        expect(json.containsKey('passphrase'), isFalse);
        expect(stored, isNot(contains('supersecret')));
        expect(stored, isNot(contains('-----BEGIN RSA KEY-----')));
        expect(stored, isNot(contains('keypassphrase')));
      });

      test('updates existing host', () async {
        final host = createTestHost();
        await service.saveHost(host);

        host.label = 'Updated Server';
        await service.saveHost(host);

        final restored = await service.getHost('host-1');
        expect(restored!.label, 'Updated Server');
      });
    });

    group('getAllHosts', () {
      test('returns empty list when no hosts', () async {
        final hosts = await service.getAllHosts();
        expect(hosts, isEmpty);
      });

      test('returns all saved hosts', () async {
        await service.saveHost(createTestHost(id: 'h1', label: 'Server 1'));
        await service.saveHost(createTestHost(id: 'h2', label: 'Server 2'));

        final hosts = await service.getAllHosts();
        expect(hosts.length, 2);
        final labels = hosts.map((h) => h.label).toSet();
        expect(labels, containsAll(['Server 1', 'Server 2']));
      });

      test('does not include credential data', () async {
        await service.saveHost(
          createTestHost(),
          credentials: const HostCredentials(password: 'secret'),
        );

        final hosts = await service.getAllHosts();
        final json = hosts.first.toJson();
        expect(json.containsKey('password'), isFalse);
      });
    });

    group('getHost', () {
      test('returns host when found', () async {
        await service.saveHost(createTestHost());
        final host = await service.getHost('host-1');
        expect(host, isNotNull);
        expect(host!.hostname, '192.168.1.1');
      });

      test('returns null when not found', () async {
        final host = await service.getHost('nonexistent');
        expect(host, isNull);
      });
    });

    group('getCredentials', () {
      test('returns credentials when stored', () async {
        await service.saveHost(
          createTestHost(),
          credentials: const HostCredentials(
            password: 'mypassword',
            privateKeyContent: '-----BEGIN RSA-----',
            passphrase: 'keypass',
          ),
        );

        final creds = await service.getCredentials('host-1');
        expect(creds.password, 'mypassword');
        expect(creds.privateKeyContent, '-----BEGIN RSA-----');
        expect(creds.passphrase, 'keypass');
      });

      test('returns empty credentials when none stored', () async {
        final creds = await service.getCredentials('nonexistent');
        expect(creds.isEmpty, isTrue);
      });

      test('returns partial credentials', () async {
        await service.saveHost(
          createTestHost(),
          credentials: const HostCredentials(password: 'onlypw'),
        );

        final creds = await service.getCredentials('host-1');
        expect(creds.password, 'onlypw');
        expect(creds.privateKeyContent, isNull);
        expect(creds.passphrase, isNull);
      });
    });

    group('deleteHost', () {
      test('removes host from Hive', () async {
        await service.saveHost(createTestHost());
        await service.deleteHost('host-1');

        final host = await service.getHost('host-1');
        expect(host, isNull);
      });

      test('removes credentials from secure storage', () async {
        await service.saveHost(
          createTestHost(),
          credentials: const HostCredentials(password: 'secret'),
        );
        await service.deleteHost('host-1');

        final creds = await service.getCredentials('host-1');
        expect(creds.isEmpty, isTrue);
      });

      test('deleting nonexistent host does not throw', () async {
        await expectLater(
          service.deleteHost('nonexistent'),
          completes,
        );
      });
    });

    group('isInitialized', () {
      test('returns true after initialization', () {
        expect(service.isInitialized, isTrue);
      });

      test('returns false after dispose', () async {
        await service.dispose();
        expect(service.isInitialized, isFalse);
      });
    });

    group('dispose', () {
      test('closes Hive box', () async {
        await service.dispose();
        expect(testBox.isOpen, isFalse);
      });
    });
  });
}
