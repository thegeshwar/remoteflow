import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:remoteflow/constants.dart';
import 'package:remoteflow/models/host.dart';

/// Manages local persistence with split storage:
/// - Hive for host metadata (non-sensitive)
/// - flutter_secure_storage for credentials (passwords, keys, passphrases)
///
/// Credentials are NEVER stored in Hive.
class LocalStorageService {
  /// Creates a [LocalStorageService].
  ///
  /// Pass custom [secureStorage] for testing.
  LocalStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  Box<String>? _hostsBox;

  /// Prefix for secure storage keys to namespace host credentials.
  static const String _credentialKeyPrefix = 'host_creds_';

  /// Whether the service has been initialized.
  bool get isInitialized => _hostsBox != null && _hostsBox!.isOpen;

  /// Initializes Hive and opens required boxes.
  Future<void> initialize() async {
    await Hive.initFlutter();
    _hostsBox = await Hive.openBox<String>(AppConstants.hostsBoxName);
  }

  /// Initializes with a pre-opened box (for testing).
  void initializeWithBox(Box<String> box) {
    _hostsBox = box;
  }

  Box<String> get _hosts {
    if (_hostsBox == null || !_hostsBox!.isOpen) {
      throw StateError(
          'LocalStorageService not initialized. Call initialize() first.');
    }
    return _hostsBox!;
  }

  /// Saves a [host] and its [credentials] with split persistence.
  ///
  /// Host metadata goes to Hive; credentials go to flutter_secure_storage.
  Future<void> saveHost(Host host, {HostCredentials? credentials}) async {
    final jsonString = jsonEncode(host.toJson());
    await _hosts.put(host.id, jsonString);

    if (credentials != null && credentials.isNotEmpty) {
      await _saveCredentials(host.id, credentials);
    }
  }

  /// Returns all saved host configurations (metadata only, no credentials).
  Future<List<Host>> getAllHosts() async {
    final hosts = <Host>[];
    for (final key in _hosts.keys) {
      final jsonString = _hosts.get(key as String);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        hosts.add(Host.fromJson(json));
      }
    }
    return hosts;
  }

  /// Returns the host with the given [id], or null if not found.
  Future<Host?> getHost(String id) async {
    final jsonString = _hosts.get(id);
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return Host.fromJson(json);
  }

  /// Retrieves credentials for a host from secure storage.
  Future<HostCredentials> getCredentials(String hostId) async {
    final password = await _secureStorage.read(
      key: '$_credentialKeyPrefix${hostId}_password',
    );
    final privateKeyContent = await _secureStorage.read(
      key: '$_credentialKeyPrefix${hostId}_privateKeyContent',
    );
    final passphrase = await _secureStorage.read(
      key: '$_credentialKeyPrefix${hostId}_passphrase',
    );
    return HostCredentials(
      password: password,
      privateKeyContent: privateKeyContent,
      passphrase: passphrase,
    );
  }

  /// Deletes the host with the given [id] from both Hive and secure storage.
  Future<void> deleteHost(String id) async {
    await _hosts.delete(id);
    await _deleteCredentials(id);
  }

  /// Closes all Hive boxes and releases resources.
  Future<void> dispose() async {
    await _hostsBox?.close();
    _hostsBox = null;
  }

  /// Saves credentials to secure storage, keyed by host ID.
  Future<void> _saveCredentials(
      String hostId, HostCredentials credentials) async {
    final map = credentials.toSecureMap();
    for (final entry in map.entries) {
      await _secureStorage.write(
        key: '$_credentialKeyPrefix${hostId}_${entry.key}',
        value: entry.value,
      );
    }
  }

  /// Deletes all credentials for a host from secure storage.
  Future<void> _deleteCredentials(String hostId) async {
    for (final field in ['password', 'privateKeyContent', 'passphrase']) {
      await _secureStorage.delete(
        key: '$_credentialKeyPrefix${hostId}_$field',
      );
    }
  }
}
