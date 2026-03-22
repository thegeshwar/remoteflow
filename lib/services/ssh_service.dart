import 'dart:async';
import 'dart:typed_data';

import 'package:remoteflow/models/host.dart';
import 'package:remoteflow/models/session.dart';

/// Manages SSH connections using dartssh2.
///
/// Handles establishing connections, managing sessions,
/// sending input, and receiving output from remote servers.
class SSHService {
  /// Active sessions indexed by session ID.
  final Map<String, Session> _sessions = {};

  /// Returns all active sessions.
  Map<String, Session> get sessions => Map.unmodifiable(_sessions);

  /// Establishes an SSH connection to the given [host].
  ///
  /// Returns a [Session] representing the new connection.
  /// Throws if connection fails.
  Future<Session> connect(Host host) async {
    // TODO: Implement with dartssh2
    throw UnimplementedError('SSH connection not yet implemented');
  }

  /// Disconnects the session with the given [sessionId].
  Future<void> disconnect(String sessionId) async {
    // TODO: Implement
    throw UnimplementedError('SSH disconnect not yet implemented');
  }

  /// Sends [data] to the remote shell for the given [sessionId].
  void sendInput(String sessionId, Uint8List data) {
    // TODO: Implement
    throw UnimplementedError('SSH input not yet implemented');
  }

  /// Returns a stream of output data from the remote shell.
  Stream<Uint8List> getOutputStream(String sessionId) {
    // TODO: Implement
    throw UnimplementedError('SSH output stream not yet implemented');
  }

  /// Notifies the remote server of a terminal resize.
  void resizeTerminal(String sessionId, int width, int height) {
    // TODO: Implement
    throw UnimplementedError('SSH resize not yet implemented');
  }

  /// Disconnects all active sessions.
  Future<void> disconnectAll() async {
    for (final sessionId in _sessions.keys.toList()) {
      await disconnect(sessionId);
    }
  }

  /// Disposes of all resources.
  void dispose() {
    disconnectAll();
  }
}
